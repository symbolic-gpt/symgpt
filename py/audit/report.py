
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Set
from dataclasses_json import dataclass_json, config


@dataclass_json
@dataclass
class ErcViolation:
    erc: str # ERC number
    type: str # emit, interface, throw, etc.
    rule: str # rule name
    contract: str # contract name
    # contract interface
    interface: str = field(metadata=config(exclude=lambda _v: True))
    fn_interface: str # function interface
    rid: int # rule id (offset in the rules list of the ERC)

    severity: str | None = field(default=None, metadata=config(exclude=lambda _v: True))
    tags: Optional[Set[str]] = None


@dataclass_json
@dataclass
class AuditReport:
    sol_file: str
    
    # contract name -> violations
    contract: Dict[str,  List[ErcViolation]]
    
    

    def add_violations(self, contract: str, violations: List[ErcViolation]):
        if contract not in self.contract:
            self.contract[contract] = []
        self.contract[contract].extend(violations)

    