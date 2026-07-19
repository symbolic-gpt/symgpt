from erc.types import Erc
import re

def iterate_rules(ei: Erc, includes_interfaces=False):
    if includes_interfaces:
        for fn in ei['functions']:
            yield (fn, "interface", f"{fn['def']}", None)
        for evt in ei["events"]:
            yield (evt, "interface", f"{evt['def']}", None)
    
    for fn in ei['functions']:
        rule_set = fn.get("extracted", {})
        throw_rules = rule_set.get("throw", [])
        if throw_rules is None:
            throw_rules = []
        assign_rules = rule_set.get("assign", [])
        if assign_rules is None:
            assign_rules = []
        
        arg_assign_rules = rule_set.get("arg_assign", [])
        if arg_assign_rules is None:
            arg_assign_rules = []
        return_rules = rule_set.get("return", [])
        if return_rules is None:
            return_rules = []
        call_rules = rule_set.get("call", [])
        if call_rules is None:
            call_rules = []
        emit_rules = rule_set.get("emit", [])
        if emit_rules is None:
            emit_rules = []
            
        semantic_return = rule_set.get("semantic_return", {})
        
        if semantic_return:
            yield (fn, "semantic_return", f"{semantic_return}", None)

        for rule in throw_rules:
            _not = "" if rule['throw'] else "not"
            yield (fn, "throw", f"{_not} throw if {rule['if']}", None)
        
        for rule in assign_rules:
            yield (fn, "assign", f"{rule}", None)
        
        for rule in return_rules:
            ifcond = "if "+rule.get("if", "") if rule.get("if", "") else ""
            yield (fn, "return", f"return {rule['ret_value']} {ifcond}", None)
        
        for rule in emit_rules:
            yield (fn, "emit", f"emit '{rule['emit']}' if {rule['if']}", None)
        for rule in call_rules:
            yield (fn, "call", f"call {rule['call']} if {rule['if']}", None)

    for evt in ei["events"]:
        rule_set = evt.get("extracted", {})
        emit_rules = rule_set.get("emit", [])
        if emit_rules is None:
            emit_rules = []

        for cond in emit_rules:
            
            yield (evt, "emit", f"emit '{evt['format']['name']}'", cond)
            
        assign_rules = rule_set.get("assign", [])
        if assign_rules is None:
            assign_rules = []
        for rule in assign_rules:
            yield (evt, "assign", f"{rule}", None)

        

def get_base_erc_name(full_name: str) -> str:
    match = re.match(r'(ERC\d+)', full_name)
    if match:
        return match.group(1)
    else:
        return full_name
