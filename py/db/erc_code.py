

from typing import Dict

from audit.process import get_the_function
from erc.find import  get_erc
from erc.types import Erc
from sol.utils import compile, get_function_signature, parse_function_signature
from audit.utils import get_functions_to_check, shrink_file, slice as solslice

import logging

logger = logging.getLogger(__name__)

def init_erc_code_database(erc_ct:Dict, existing: Dict=None) -> Dict:
    ercs = ["20"]
    erc_code_db = {} if existing is None else existing
    for erc in ercs:
        erc_info = get_erc(erc)
        items = erc_ct[erc]
        for item in items:
            file = item['file']
            contract_name = item['contract']
            partial = get_erc_code(file, contract_name, erc_info)
            for erc_rule_id, code in partial.items():
                if erc_rule_id not in erc_code_db:
                    erc_code_db[erc_rule_id] = []
                erc_code_db[erc_rule_id].append(code)
    return erc_code_db
            
def get_erc_code(file:str, contract_name:str, erc:Erc) -> Dict:
    partial = {}
    with open(file, 'r') as f:
        filelines = f.read().splitlines(True)
    try:
        _, cu = compile(file)
    except Exception as ex:
        logger.error(f"{file}: {ex}")
    
    rules = erc['rules']
    
    for id, rule in enumerate(rules):
        if rule['type'] == "emit" and rule['interface'].startswith("event"):
            continue
        fi = parse_function_signature(rule['interface'])
        rule_fn = get_the_function(cu, contract_name, fi)
        if rule_fn is None:
            logger.error(f"failed to audit rule {rule} since cannot find matched function")
            continue
        related_vars = rule.get('related_vars', {})
        if related_vars is None:
            related_vars = {}
        good_exp_lines = solslice(rule_fn, related_vars.get('parameters'), "msg.sender" in related_vars.get('variables', []), actions=[rule['type']], reverse=False)
        result = shrink_file(filelines, good_exp_lines)
        partial[f"{erc['name']}:{id}"] = result
        
    return partial