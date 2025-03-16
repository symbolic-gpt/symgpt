from abc import ABC, abstractmethod
import json
from typing import Any, Callable, Dict, Tuple

from audit.context import init_sol_audit_context
from erc.types import ErcRule
from llm.adapters import LLMAdapter
import logging


from sol.super_slice import super_slice
from sol.utils import get_function_signature, parse_function_signature
logger = logging.getLogger(__name__)

class ErcChecker(ABC):
    
    @abstractmethod
    def check(self, rule: ErcRule, code:str) -> Tuple[bool, Any]:
        raise NotImplementedError()
    

class LLMErcChecker(ErcChecker):
    def __init__(self, llm:LLMAdapter) -> None:
        """Audit erc rule against code by using LLM

        Args:
            llm (_type_): llm adapter
            prompt_fn (Callable[[str, str], str]):  rule, code => prompt
            prompt_fn (Callable[[str, str], bool]): rule, response => pass or not
        """
        self._llm = llm
    
    def check(self, rule: ErcRule, code:str) -> Tuple[bool, str]:
        audit_msg = self.get_prompt(rule, code)
        res = self._llm.ask([{"content": audit_msg, "role":"user"}], temperature=0, n=1)[0]
        return self.is_passed(rule, res), res
    
    def _get_random_oneshot_example_from_files(self, rule: ErcRule):
        erc_file = "local/10k/BABYAPE-0xc03735F8.sol"
        fi = parse_function_signature(rule['interface'])
        sig = get_function_signature(fi['name'], [ft['type'] for ft in fi['arg_types']], fi.get('return_type',{}).get('type', None))
        ctx = init_sol_audit_context(erc_file, ".cache")
        for contract in ctx.metadata.contracts:
            if sig not in contract.func2str:
                continue
            func_text = contract.func2str[sig]
            if func_text:
                if "related_vars" in rule:
                    after_text = super_slice(func_text, contract.name, fi['name'],
                                    target_fn_param_idx_list=rule["related_vars"]["parameters"],
                                    target_keyword_list=rule["related_vars"]["variables"],
                                    keep_throws=True)
                    return after_text
        return None


class MockLLMErcChecker(LLMErcChecker):
    def __init__(self) -> None:
        super().__init__(None)
    

    def check(self, rule: ErcRule, code: str) -> Tuple[bool, str]:
        return None, None