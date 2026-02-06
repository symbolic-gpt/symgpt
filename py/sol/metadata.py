
from dataclasses import dataclass
from typing import Dict, List
from slither.core.declarations import Contract

from audit.utils import find_all_callees, get_functions_to_check, is_function_overrided_by_state_variable, slithir_funcs_to_text
from sol.utils import get_public_state_var_sigs


@dataclass
class ContractMetadata:
    events: List
    func2str: Dict
    func2attrs: Dict
    ercs: List[str]
    name: str
    state_var_sigs: List[str]

def get_contract_metadata(c: Contract, ercs:List[str], clines: List[str], selected_fns: List[str] = None, no_func_slice = False) -> ContractMetadata:
    cmeta = ContractMetadata(
            events=[],
            func2str={},
            func2attrs={},
            ercs=ercs,
            name=c.name,
            state_var_sigs = get_public_state_var_sigs(c)
        )
    funcs = get_functions_to_check(c)

    sliced_fn = set()
    # slice each function
    for f in funcs:
        if selected_fns is not None:
            if f.full_name not in selected_fns:
                continue
        if is_function_overrided_by_state_variable(f):
            # since function is overrided by a state variable
            # and there is no way to get Solidity version of the generated function
            # simply give up
            continue
        
        if not no_func_slice:
            to_explore = set()
            to_explore.add(f)
            explored = find_all_callees(to_explore)
            text = slithir_funcs_to_text(explored, clines, True, False, True, True)
        

        if f.full_name in sliced_fn:
            if f.contract_declarer == f.contract:
                # should override
                pass
            else:
                
                continue
        if not no_func_slice:
            cmeta.func2str[f.signature_str] = text
        cmeta.func2attrs[f.signature_str] = {
            "is_view": f.view,
            "is_pure": f.pure,
        }
        sliced_fn.add(f.full_name)

    state_var_sigs = get_public_state_var_sigs(c)
    cmeta.state_var_sigs = list(state_var_sigs)
    events = []
    for e in c.events:
        events.append(
            {
                "name": e.name,
                "params": [
                    {"type": str(p.type), "indexed": p.indexed} for p in e.elems
                ],
            }
        )

    cmeta.events.extend(events)
    return cmeta