from typing import Dict, List, Optional, TypedDict

from sol.types import SolidityFunctionFormat, SolidityEventFormat


class ErcRuleSet(TypedDict):
    throw: List
    # return:
    assign: List
    call: List

class ErcFunction(TypedDict):
    # def: str
    raw_rules: str
    format: SolidityFunctionFormat
    

class ErcEvent(TypedDict):
    # def: str
    raw_rules: str
    format: SolidityEventFormat

class ErcRule(TypedDict):
    rule: str
    type: str
    interface: str
    related_vars: Dict
    
    # Only available for auditing response
    violated: bool
    
class Erc(TypedDict):
    name: str
    functions: List[ErcFunction]
    events: List[ErcEvent]
    rules: List[Dict]
    
