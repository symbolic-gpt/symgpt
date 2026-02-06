import logging
import os
from typing import Dict, List, Optional

from audit.context import (ContractMetadata, init_sol_audit_context)
from audit.report import AuditReport, ErcViolation
from audit.utils import get_functions_to_check
from erc.find import get_erc_suit
from slither.core.slither_core import SlitherCompilationUnit
from erc.types import Erc
from sol.sym import (ErcVerifier, FnNotFound, StateVarAnchorFnNotFound,
                     deserialize_verify)
from sol.utils import (get_emitted_events, get_event_interface, get_function_signature,
                       parse_function_signature)
import json

erc_mapping = {
    '721a': '721'
}

def process_sol(sol_file:str, 
                out_dir:str, 
                cname2ercs:Dict = None, 
                ercs:List[str] = None, 
                only_rules_at:Dict[str, List[int]] = None,
                no_cache:bool = False,
                logger: Optional[logging.Logger] = None,
                solc_lock = None,
                filter_erc:List[str] = None,
                filter_rule:List[str] = None,
                filter_rtype:List[str] = None,
                constraintsllmaudit:bool = False,
                erc_spec: str = None
                ):
    if logger is None:
        logger = logging.getLogger(__name__)
    
    try:
        # Compile it into get slithir
        cu, ctx = init_sol_audit_context(sol_file, cname2ercs=cname2ercs, no_func_slice=True, solc_lock = solc_lock)
        # logger.debug(f"{sol_file}: found {len(ctx.metadata.contracts)} final contracts")
        filename = os.path.basename(sol_file).split(".")[0]
        out = os.path.join(out_dir, f"{filename}.json")
        if os.path.exists(out) and not no_cache:
            # logger.info(f"Skipping {sol_file}, already processed.")
            return
        # Report for the whole file
        # file can include multiple contracts 
        # each contract can have multiple ercs to be audited
        sol_report = AuditReport(sol_file, {})

        erc_spec_override = {}
        if erc_spec is not None:
            parts = erc_spec.split(";")
            for part in parts:
                erc_name, erc_path = part.split(":")
                with open(erc_path, "r") as f:
                    erc_spec_data = json.load(f)
                    erc_spec_override[erc_name] = erc_spec_data
            

        # check each contract that we found
        for contract in ctx.metadata.contracts:
            # collect all ercs for this contract
            all_ercs = set(contract.ercs)
            ercs_to_audit = []
            erc_suite_str = None

            # add ercs from cli args if any
            if cname2ercs is not None and contract.name in cname2ercs:
                for erc in cname2ercs[contract.name]:
                    all_ercs.add(erc) 
            if ercs is not None:
                for erc in ercs:
                    all_ercs.add(erc)

            # logger.info(f"auditing file='{sol_file}' contract='{contract.name}' for ercs={all_ercs}")
                
            # audit contract against every erc we can found/want
            for erc_suite_str in all_ercs:
                if erc_suite_str in erc_mapping:
                    erc_suite_str = erc_mapping[erc_suite_str]
                if erc_suite_str in erc_spec_override:
                    ercs_to_audit.append(erc_spec_override[erc_suite_str])
                else:
                    suite = get_erc_suit(erc_suite_str)
                    if suite is None:
                        # # logger.debug(f"failed to find erc suite for '{erc_suite_str}'")
                        continue
                    ercs_to_audit.append(suite.main_erc)
                    if suite.optional_ercs is not None:
                        ercs_to_audit.extend(suite.optional_ercs)
            
            if filter_erc:
                # logger.info(f"filtering ercs with filter_erc={filter_erc}")
                ercs_to_audit = [erc for erc in ercs_to_audit if any(f in erc['name'] for f in filter_erc)]
                
            for idx, erc in enumerate(ercs_to_audit):

                try:
                    only_rules = None
                    if only_rules_at is not None and erc['name'] in only_rules_at:
                        only_rules = only_rules_at[erc["name"]]


                    violations = audit_with_erc(
                        sol_file,
                            cu, 
                            contract, 
                            erc["name"],
                            erc, 
                            filter_rtype,
                            filter_rule,
                            idx != 0,
                            only_rules,
                            logger,
                            constraintsllmaudit
                            
                    )

                    sol_report.add_violations(contract.name, violations)
                except Exception:
                    # # logger.error(f"failed to handle '{sol_file}' with ERC='{erc['name']}'", exc_info=True)
                    # # logger.info("skip to next ERC")
                    pass

        with open(out, "w") as f:
            f.write(AuditReport.to_json(sol_report, indent=4))
        print(f"[+] {out}")

    except Exception:
        # # logger.error(f"failed to handle '{sol_file}': {ex}")
        # traceback.print_exc() 
        pass


def get_audit_report_filename(file, contract, erc:str) -> str:
    return f"{file}-{contract.name}-{erc}.json"
    

class ERCNotFound(Exception):
    def __init__(self, erc:str) -> None:
        super().__init__()
        self.erc = erc

class ContractNotFound(Exception):
    def __init__(self, contract:str) -> None:
        super().__init__()
        self.contract = contract

def audit_with_erc(
    sol_file:str,
    cu:SlitherCompilationUnit, 
    contract:ContractMetadata, 
    erc_suite:str,
    erc: Erc,
    filter_rtype:List[str] = None,
    filter_rule:List[str] = None,
    optional = False,
    only_rules_at: Optional[List[int]] = None, 
    logger: Optional[logging.Logger] = None,
    constraintsllmaudit:bool = False) -> List[ErcViolation]:
    if logger is None:
        logger = logging.getLogger(__name__)
    
    ei = erc
    cucontract = cu.get_contract_from_name(contract.name)[0]
    if cucontract is None:
        raise ContractNotFound(contract.name)
    if optional:
        cucontract = cu.get_contract_from_name(contract.name)[0]
        if not any([ic.name.find(ei['name']) != -1 for ic in cucontract.inheritance]):
            # logger.debug(f"skip auditing contract={contract.name} erc={ei['name']} since it is optional and not found in the contract")
            return []

    # logger.debug(f"auditing contract={contract.name} erc={ei['name']}")
    if only_rules_at is not None:
        # logger.debug(f"only_rules={only_rules_at}")
        pass
    
    violations = []
    if not filter_rtype or (filter_rtype and "interface" in filter_rtype):
        # checking function interface rules
        for idx, rule in enumerate(ei["functions"]):
            func = rule['format']
            ret_type = func.get('return_type', None)
            vio = ErcViolation(
                erc=erc_suite,
                type="interface",
                rule=rule['def'],
                contract=cucontract.name,
                interface=erc['name'],
                fn_interface=None,
                rid=idx,
                severity="medium",
                tags=set()
            )
            # checking contract has the function or not
            candidate_fns = [f for f in cucontract.functions if f.name == func['name']]
            if not candidate_fns:
                # check whether function is field getter situation
                ret_type = ret_type.get('type', None) if ret_type else None
                arg_type_strs = []
                for argt in func['arg_types']:
                    arg_type_strs.append(argt['type'])
                target_fn_sig = get_function_signature(func['name'], arg_type_strs, ret_type)
                
                in_sv = target_fn_sig in contract.state_var_sigs
                # logger.info(f"check if {target_fn_sig} is in {contract.state_var_sigs}: {in_sv}")
                if not in_sv:
                    vio.tags.add("no_function")
                    violations.append(vio)
                    continue
            else:
                correct_param_fn = None

                # checking function parameters
                for f in candidate_fns:
                    if len(f.parameters) != len(func['arg_types']):
                        continue
                    skip = False
                    for idx, at in enumerate(f.parameters):
                        if str(at.type) != func['arg_types'][idx]["type"]:
                            skip = True
                            break
                    if skip:
                        continue
                    correct_param_fn = f
                if correct_param_fn is None:
                    vio.tags.add("incorrect_param")
                    violations.append(vio)
                    continue

                # checking return type
                if ret_type is not None:
                    if correct_param_fn.return_type is None or len(correct_param_fn.return_type) != 1:
                        vio.tags.add("incorrect_return")
                        violations.append(vio)
                        continue
                    if str(correct_param_fn.return_type[0]) != ret_type["type"]:
                        vio.tags.add("incorrect_return")
                        violations.append(vio)
                        continue
                


        # checking event interface rules
        contract_events = [get_event_interface(e['name'], e['params']) for e in contract.events]
        for idx, rule in enumerate(ei['events']):
            vio = ErcViolation(
                erc=erc_suite,
                type="interface",
                rule=rule['def'],
                contract=cucontract.name,
                interface=erc['name'],
                fn_interface=None,
                rid=idx,
                severity="low",
                tags={"event"}
            )
            ev = rule['format']
            esig = get_event_interface(ev['name'], ev['arg_types'])
            compliant = esig in contract_events
            if not compliant:
                violations.append(vio)

    # checking function scope related rules
    for idx, rule in enumerate(ei['rules']):
        if rule["type"] == "return":
            continue
        if only_rules_at is not None:
            if idx not in only_rules_at:
                continue

        if filter_rtype and rule['type'] not in filter_rtype:
            continue

        if filter_rule:
            for filter_r in filter_rule:
                if rule['rule'].find(filter_r) == -1:
                    continue
                
            
        if "audit" in rule and rule['audit']['compliant'] is not None:
            continue
        
        if "sym" not in rule:
            # # logger.debug(f"[sym] skip rule='{rule['rule']}' since no sym configured")
            continue
        
        rule_sym = get_correct_sym(rule['sym'])
        ## logger.info(f"[sym][interface={rule['interface']}] checking rule='{rule['rule']}' sym='{rule_sym}'")
        try:
            verify = deserialize_verify(rule_sym)
        except Exception:
            # # logger.error(f"[sym] failed to deserialize sym='{rule_sym}': {ex}")
            # rule["audit"] = {"compliant": True, "error": str(ex)}
            continue
        if "interface" in rule and rule['interface'] != None and rule['interface'].strip().startswith('function'):
            fi = parse_function_signature(rule['interface'])
            verifier = ErcVerifier(cu=cu, logger=logger, contract_path=sol_file, llm=constraintsllmaudit)
            try:
                compliant = verifier.run(
                    contract.name, fi['name'], len(fi['arg_types']),
                    verify
                )
                # rule["audit"] = {"compliant": compliant}
                if not compliant:
                    violations.append(
                        ErcViolation(
                            erc=erc_suite,
                            type=rule["type"],
                            rule=rule['rule'],
                            contract=cucontract.name,
                            interface=erc['name'],
                            fn_interface=rule['interface'],
                            rid=idx,
                            severity="-",
                            tags={"function"}
                        )
                    )
            except FnNotFound:
                # rule["audit"] = {"compliant": False}
                # # logger.error(f"[sym] skip rule='{rule['rule']}' for function='{rule['interface']}' since function not found: {ex}")
                pass
            except Exception:
                # rule["audit"] = {"compliant": True, "error": str(ex)}
                # # logger.exception(f"[sym] failed to verify rule='{rule['rule']}' for function='{rule['interface']}': {ex}")
                pass
        else:
            # checking the compound rule (emit rule)
            c = cu.get_contract_from_name(contract.name)[0]
            public_fns = get_functions_to_check(c)
            # ignore those pure/view functions. Since event emission only happened on state variable is changed
            fns = [f for f in public_fns if f.all_state_variables_written() and not f.view and not f.pure]
            
            if rule['interface'].startswith('event') and rule['type'] == "assign":
                if verify.event is not None:
                    fns = [f for f in fns if verify.event not in get_emitted_events(f)]

            rule['audit_fns'] = []
            
            for f in fns:
                verifier = ErcVerifier(cu=cu, logger=logger, contract_path=sol_file, llm=constraintsllmaudit)
                try:
                    compliant = verifier.run(
                        contract.name, None, None,
                        vop=verify, fn=f
                    )
                    # rule["audit_fns"].append({
                    #     "function": f.signature_str,
                    #     "compliant": compliant,
                    # })
                    if not compliant:
                        violations.append(ErcViolation(
                            erc=erc_suite,
                            type=rule["type"],
                            rule=rule['rule'],
                            contract=cucontract.name,
                            interface=erc['name'],
                            fn_interface=f.signature_str,
                            rid=idx,
                            severity="-",
                            tags={"function"}
                        ))

                except FnNotFound:
                    pass
                    # # logger.error(f"[sym] skip function='{f.signature_str}' for rule='{rule['rule']}' since function not found: {ex}")
                except StateVarAnchorFnNotFound:
                    # # logger.error(f"[sym] skip function='{f.signature_str}' for rule='{rule['rule']}' since anchor function not found: {ex}")
                    pass
                except Exception:
                    # # logger.error(f"[sym] failed to verify rule='{rule['rule']}' for function='{f.signature_str}': {ex}")
                    pass
    
    return violations


def get_correct_sym(sym:Dict) -> Dict:
    if 'type' in sym:
        return sym
    
    return sym[list(sym.keys())[0]]

