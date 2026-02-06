import logging
from typing import Dict, List
import os
from audit.context import init_sol_audit_context
from sol.utils import get_the_function 
from slither.core.declarations import Contract, FunctionContract, SolidityFunction
import json

def fast_process_sol(sol_file:str, 
                      out_dir:str, 
                      cname2ercs:Dict = None, 
                      ercs:List[str] = None, 
                      only_rules_at:Dict[str, List[int]] = None,
                      logger: logging.Logger = None):
    if logger is None:  
        logger = logging.getLogger(__name__)    
    try:
        print(sol_file)
        # Compile it into get slithir
        cu, ctx = init_sol_audit_context(sol_file, cname2ercs=cname2ercs)
        logger.debug(f"{sol_file}: found {len(ctx.metadata.contracts)} final contracts")

        for contract_meta in ctx.metadata.contracts:
            if "20" in contract_meta.ercs:
                
                at_least_one = False
                trf_res = fast_check_erc20_transfer_from(cu, contract_meta.name)
                at_least_one |= trf_res
                result = {
                    "trf_res": trf_res
                }
                if at_least_one:
                    dst = os.path.join(out_dir, os.path.basename(sol_file).split(".")[0] + contract_meta.name + ".json")
                    with open(dst, "w") as f:
                        json.dump(result, f, indent=4)
    except Exception as e:
        logger.error(f"Error: {e}")
        raise e


def fast_check_erc20_transfer_from(cu, contract_name) -> bool:
    fn = get_the_function(cu, contract_name, fname="transferFrom", fnumofargs=3)
    if fn is None:
        return False
    
    if not isinstance(fn, FunctionContract):
        return False
    
    wsv_names = [sv.name for sv in fn.all_state_variables_read()]
    at_least_one = False
    for name in wsv_names:
        if name.find("allow") != -1:
            at_least_one = True
            break

    return not at_least_one