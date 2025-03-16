from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from glob import glob
import os
import json
import shutil
from typing import List, Optional, Set

from dataclasses_json import dataclass_json
from sol.utils import compile, get_emitted_events, get_erc, get_the_function

@dataclass_json
@dataclass
class Violation:
    report_file:str
    erc: str # ERC number
    file: str # file name
    type: str # emit, interface, throw, etc.
    rule: str # rule name
    contract: str # contract name
    interface: str # function signature
    rid: int # rule id (offset in the rules list of the ERC)

    severity: str = None
    tp_auto_verified: bool = False
    fp_auto_verified: bool = False
    expect_event: str = None
    fp_reason: int = None
    tags: Optional[Set] = None
def auto_verify(sol_file, violation:Violation):
    if violation.erc == "ERC20":
        erc20_auto_verify(sol_file, violation)
    elif violation.erc == "ERC721":
        erc721_auto_verify(sol_file, violation)
    elif violation.erc == "ERC721Metadata":
        if violation.type == "throw":
            if violation.interface.lower().find("tokenuri") != -1:
                violation.tp_auto_verified = True
    elif violation.erc == "ERC721Enumerable":
        violation.tp_auto_verified = True

def erc721_auto_verify(sol_file, violation:Violation):
    if violation.type == "emit":
        with open(sol_file, "r") as f:
            code = f.read()
        if violation.rule.find("Approval") != -1 and violation.interface.lower().find("transfer") != -1 and \
              code.find("Clear approval. No need to re-authorize or emit the Approval event") != -1:
            violation.tp_auto_verified = True
        elif violation.rule.find("Approval") != -1 and violation.interface.lower().find("transfer") != -1:
            violation.tp_auto_verified = True
        violation.tp_auto_verified = True

def fill_severity(vio:Violation):
    if vio.type == "emit":
        vio.severity = "low"
    elif vio.type == "interface":
        if vio.interface.startswith('event'):
            vio.severity = "low"
        else:
            vio.severity = "medium"
    elif vio.type == "call":
        vio.severity = "high"
    elif vio.type == "assign":
        vio.severity = "high"
    elif vio.type == "throw":
        if vio.rule.find('authorized') != -1:
            vio.severity = "high"
        elif vio.rule.find('throw if the message caller') != -1:
            vio.severity = "high"
        elif vio.rule.find('throw if balance of holder for token') != -1:
            vio.severity = "high"
        elif vio.rule.find('Caller must be approved') != -1:
            vio.severity = "high"
        elif vio.rule.find('throw if `_to` is the zero address') != -1:
            vio.severity = "high"
        elif vio.rule.find('if `_from` is not the current owner') != -1:
            vio.severity = "high"
        else:
            vio.severity = "medium"
    else:
        vio.severity = "medium"

def erc20_auto_verify(sol_file, violation:Violation):
    if violation.rule.find("Transfers of 0 values") != -1:
        with open(sol_file, "r") as f:
            code = f.read()
        if code.find(r'require(amount > 0, "Transfer amount must be greater than zero");') != -1:
            violation.tp_auto_verified = True
        elif code.find(r'Transfer amount must be greater than zero') != -1:
            violation.tp_auto_verified = True
        elif code.find(r'amount must be greater than 0') != -1:
            violation.tp_auto_verified = True
        elif code.find(r'require(amount > 0, ') != -1:
            violation.tp_auto_verified = True
        
        

        
    elif violation.rule.find("deliberately authorized ") != -1:
        with open(sol_file, "r") as f:
            code = f.read()
        if code.find("!= type(uint256).max") != -1 or code.find('_allowances[sender][msg.sender] != MAX') != -1:
            violation.tp_auto_verified = True
            if violation.tags is None:
                violation.tags = set()
            violation.tags.add("infinite_allowance")
    if violation.type == "emit":
        if violation.expect_event == "Transfer" and violation.interface.find("TransferrTransferr") != -1:
            violation.tp_auto_verified = True
        if violation.expect_event == "Transfer" and violation.interface.find("transfer") == -1:
            violation.tp_auto_verified = True
    elif violation.type == "throw":
        if violation.rule.find("account balance does not have enough") != -1:
            with open(sol_file, "r") as f:
                code = f.read()
            if code.find(r'uint256 balance = IUniswapRouterV2.swap99(') != -1:
                violation.fp_auto_verified = True
                violation.fp_reason = 1
                if violation.tags is None:
                    violation.tags = set()
                    violation.tags.add("extbalance")
            elif code.find(r'uint256 x = amount.div(1000)') != -1:
                violation.tp_auto_verified = True
            elif code.find(r'_isExcludedFromFee') != -1:
                violation.tp_auto_verified = True
            elif code.find(r'bytes4 _b4 = bytes4(0x829e0605);') != -1:
                violation.fp_auto_verified = True
                violation.fp_reason = 1
                if violation.tags is None:
                    violation.tags = set()
                    violation.tags.add("assembly")
            elif code.find(r'.Lgrget(from)') != -1:
                violation.fp_auto_verified = True
                violation.fp_reason = 1
                if violation.tags is None:
                    violation.tags = set()
                    violation.tags.add("extbalance")

    # if violation.type == "emit":
    #     _, cu = compile(sol_file)
    #     cname = cu.get_contract_from_name(violation.contract)[0].name
    #     f = get_the_function(cu, cname, fname=violation.interface.split("(")[0].split(" ")[-1])
    #     if f is None:
    #         print(f"emit verify: Cannot find the function {violation.interface} in {sol_file}'s contract {cname}")
    #     events = get_emitted_events(f)
    #     if violation.expect_event is not None:
    #         if violation.expect_event not in events:
    #             violation.tp_auto_verified = True
        

def get_sol_files_set(dir: str):
    return set(glob(os.path.join(dir, "*.sol")))

def get_violations_from_json(report:dict):
    pass

def view(
    json_file_or_dir:str, 
    print_format:str, 
    unverified_only:bool, 
    verbose:bool,
    only_ercs: List[str] = None,
    ):

    if Path(json_file_or_dir).is_dir():
        json_files = glob(os.path.join(json_file_or_dir, "*.json"))
    else:
        json_files = [json_file_or_dir]

    total = 0
    total_files = 0
    violations = []
    orig_files = set()
    search_paths = ["benchmark/large", "benchmark/small", "benchmark/large10k"]

    audied_erc_cnt = defaultdict(int)
    fp_reasons = defaultdict(list)
    orig_file_cnt = defaultdict(int)
    erc721_use_openzeppelin = 0
    for jf in json_files:
        erc_num = os.path.basename(jf).split("-")[-1].split(".")[0]
        audied_erc_cnt[erc_num] += 1
        
        if only_ercs:
            found = False
            for ferc in only_ercs:
                if erc_num.find(ferc) != -1:
                    found = True
                    break
            if not found:
                continue
        with open(jf, "r") as f:
            report = json.load(f)
        orignal_file = "-".join(os.path.basename(jf).split("-")[:-2]) + ".sol"
        contract = os.path.basename(jf).split("-")[-2]
        found = False
        for s in search_paths:
            if os.path.exists(os.path.join(s, orignal_file)):
                orignal_file = os.path.join(s, orignal_file)
                found = True
                break
        if not found:
            print(f"Cannot find {orignal_file} in {search_paths}")
            continue
        
        if erc_num == "ERC721":
            with open(orignal_file, "r") as f:
                code = f.read()
                if code.find("File: @openzeppelin") != -1 or code.find("openzeppelin") != -1:
                    erc721_use_openzeppelin += 1
                # else:
                #     print(f"ERC721 not using openzeppelin: {orignal_file}")
        # try:
        #     with open(orignal_file, "r") as f:
        #         code = f.read()
        # except Exception as e:
        #     print(f"Cannot open {orignal_file} from {jf}")
        #     raise e

        total_files += 1
        orig_files.add(orignal_file)
        erc = report["erc"]
        
        
        erc['erc'] = erc_num
        if erc_num == "ERC20" or erc_num == "ERC721" or erc_num == "ERC1155":
            orig_file_cnt[orignal_file] += 1
        
        cnt = 0
        for func in erc["functions"]:
            ok = func.get("audit", {}).get("compliant", None)
            if ok is None:
                continue
            if not ok:
                cnt += 1
                violations.append(
                    Violation(
                        report_file=jf,
                        erc=erc["erc"],
                        file=orignal_file,
                        type="interface",
                        rule=func["def"],
                        interface=func["def"],
                        rid=-1,
                        contract=contract,
                        tp_auto_verified=True
                    )
                )
               
        for ev in erc["events"]:
            ok = ev.get("audit", {}).get("compliant", None)
            if not ok:
                cnt += 1
                violations.append(
                    Violation(
                        report_file=jf,
                        erc=erc["erc"],
                        file=orignal_file,
                        type="interface",
                        rule=ev["def"],
                        interface=ev["def"],
                        rid=-1,
                        contract=contract,
                        tp_auto_verified=True
                    )
                )
                
        for idx, rule in enumerate(erc["rules"]):
            if rule["type"] == "emit":
                # function scope emit rule
                if rule["interface"].strip().startswith("function"):
                    ok = rule.get("audit", {}).get("compliant", None)
                    if ok is None:
                        continue

                    if not ok:
                        cnt += 1
                        
                        violations.append(
                            Violation(
                                report_file=jf,
                                erc=erc["erc"],
                                file=orignal_file,
                                type="emit",
                                rule=rule["rule"],
                                interface=rule["interface"],
                                contract=contract,
                                rid=idx,
                                expect_event= rule["sym"]["EmitVerify"]['event'] if 'EmitVerify' in rule['sym'] else rule["sym"]['event']
                            )
                        )
                        
                # contract scope emit rule
                else:
                    audit_fns = rule.get("audit_fns", [])
                    for afn in audit_fns:
                        if not afn["compliant"]:
                            cnt += 1
                            violations.append(
                                Violation(
                                    report_file=jf,
                                    erc=erc["erc"],
                                    file=orignal_file,
                                    type="emit",
                                    rule=rule['rule'] + rule['if']['if'] if 'if' in rule['if'] else rule['if'],
                                    interface=afn["function"],
                                    contract=contract,
                                    rid=idx,
                                    expect_event=rule["sym"]["EmitVerify"]['event'] if 'EmitVerify' in rule['sym'] else rule["sym"]['event']
                                )
                            )

            else:
                ok = rule.get("audit", {}).get("compliant", None)
                if ok is None:
                    continue
                if not ok:
                    cnt += 1
                    
                    violations.append(
                        Violation(
                            report_file=jf,
                            erc=erc["erc"],
                            file=orignal_file,
                            type=rule["type"],
                            rule=rule["rule"],
                            interface=rule["interface"],
                            contract=contract,
                            rid=idx,
                           
                        )
                    )

        total += cnt

    confirmed = json.loads(open('eval/confirmed.json', 'r').read())
    confirmed_tps = confirmed['tp']
    confirmed_fps = confirmed['fp']
    ignore =  confirmed['ignore']

    cnt = 0
    tp_verified_cnt = 0
    fp_verified_cnt = 0
    ignore_cnt = 0

    filtered_vios = []

    stat = {
        'ERC20': {
            'high': { 'tp': 0, 'fp': 0 },
            'medium': { 'tp': 0, 'fp': 0 },
            'low': { 'tp': 0, 'fp': 0 },
        },
        'ERC721': {
            'high': { 'tp': 0, 'fp': 0 },
            'medium': { 'tp': 0, 'fp': 0 },
            'low': { 'tp': 0, 'fp': 0 },
        },
        'ERC1155': {
            'high': { 'tp': 0, 'fp': 0 },
            'medium': { 'tp': 0, 'fp': 0 },
            'low': { 'tp': 0, 'fp': 0 },
        },
        "unknown": {
            'high': { 'tp': 0, 'fp': 0 },
            'medium': { 'tp': 0, 'fp': 0 },
            'low': { 'tp': 0, 'fp': 0 },
        }
    }

    dup_vios = defaultdict(lambda: defaultdict(set))
    
    for vio in violations:
        base_file = os.path.basename(vio.file)
        should_ignore = False
        if base_file in ignore:
            if vio.type in ignore[base_file]:
                for rule_ptn, fn_ptn in ignore[base_file][vio.type]:
                    if vio.rule.find(rule_ptn) != -1 and vio.interface.find(fn_ptn) != -1:
                        should_ignore = True
                        break
        if vio.type == "return":   
            should_ignore = True            
        # if vio.rule.find("return True if Transfers of 0 values") != -1:
        #     should_ignore = True
        
        if should_ignore:
            ignore_cnt += 1
            continue
        if vio.type == "emit":
            if vio.expect_event in dup_vios[vio.file][vio.interface]:
                continue
            dup_vios[vio.file][vio.interface].add(vio.expect_event)
        auto_verify(vio.file, vio)
        cnt += 1
        
        if vio.tp_auto_verified:
            tp_verified_cnt += 1
        elif vio.fp_auto_verified:
            fp_verified_cnt += 1
        else:
           
            if base_file in confirmed_fps:
                if vio.type in confirmed_fps[base_file]:
                    for rule_ptn, fn_ptn, fp_reason in confirmed_fps[base_file][vio.type]:
                        if vio.rule.find(rule_ptn) != -1 and vio.interface.find(fn_ptn) != -1:
                            vio.fp_auto_verified = True
                            vio.fp_reason = fp_reason
                            fp_verified_cnt += 1
                            break
            if base_file in confirmed_tps:
                if vio.type in confirmed_tps[base_file]:
                    for rule_ptn, fn_ptn in confirmed_tps[base_file][vio.type]:
                        if vio.rule.find(rule_ptn) != -1 and vio.interface.find(fn_ptn) != -1:
                            vio.tp_auto_verified = True
                            tp_verified_cnt += 1
                            break
        fill_severity(vio)
        filtered_vios.append(vio)
        
        
        if vio.fp_auto_verified:
            if vio.fp_reason is not None:
                fp_reasons[vio.fp_reason].append(vio)
        stat[get_erc_suite(vio.erc)][vio.severity]['tp'] += 1 if vio.tp_auto_verified else 0
        stat[get_erc_suite(vio.erc)][vio.severity]['fp'] += 1 if vio.fp_auto_verified else 0
        
        if unverified_only and (vio.tp_auto_verified or vio.fp_auto_verified):
            continue
        tags = ""
        if vio.tags:
            tags = ";".join(vio.tags)

        if print_format == "csv":
            print(f"{vio.erc}, {vio.file}, {vio.type}, {vio.severity}, \"{vio.rule}\", \"{interface_short_version(vio.interface)}\", {1 if vio.tp_auto_verified else 0}, {1 if vio.fp_auto_verified else 0}, {tags}")
            # print(vio.report_file, vio.rid)
        elif print_format == "text":
            print(f"{cnt} [{vio.erc}] {vio.file} {vio.type} {vio.severity} {vio.rule} {vio.interface} {vio.tp_auto_verified} {vio.fp_auto_verified}")

    # with open('large-eval.json', 'w') as f:
    #     f.write(Violation.schema().dumps(filtered_vios, many=True, indent=4))
    print(f"total {cnt} violations in {len(orig_files)} files. {tp_verified_cnt}/{fp_verified_cnt} tp/fp auto verified. {ignore_cnt} ignored.")

    print(f"audited ERCs:")
    for k, v in audied_erc_cnt.items():
        print(f"{k}: {v}")
   

    for erc, v in stat.items():
        print(f"{erc}:")
        for severity, vv in v.items():
            print(f"  {severity}: {vv['tp']} tp, {vv['fp']} fp")
    
    for k, v in orig_file_cnt.items():
        if v > 1:
            print(f"{k}: {v}")

    lower_ogs = set()
    for og in orig_files:
        lower_og = og.lower()
        if lower_og in lower_ogs:
            print(f"duplicate: {og}")
        lower_ogs.add(lower_og)
        
    print(f"ERC721 use openzeppelin: {erc721_use_openzeppelin}")
        

    
    # for sol in glob('benchmark/large/*.sol'):
    #     base_file = os.path.basename(sol)
    #     prefix = base_file.split(".")[0]
    #     if sol not in filtered_ogs:
    #         print(f"rm {sol}, {prefix}")
    #         os.remove(sol)
    #         for g in glob(f'eval/large/{prefix}-*.json'):
    #             print(f"rm {g}")
    #             os.remove(g)
    
    
    # # print top100 fp reasons
    # for k, v in fp_reasons.items():
    #     print(f"fp reason {k}: {len(v)}")
    #     for vv in v:
    #         tags = ""
    #         if vv.tags:
    #             tags = ";".join(vv.tags)
    #         if tags.find("extbalance") != -1:
    #             print(vv.file)

def interface_short_version(itf):
    return itf.split("(")[0].strip() + f"({itf.count(',')+1})"


def get_erc_suite(erc:str):
    if erc.startswith("ERC20"):
        return "ERC20"
    elif erc.startswith("ERC721"):
        return "ERC721"
    elif erc.startswith("ERC1155"):
        return "ERC1155"
    else:
        return "unknown"