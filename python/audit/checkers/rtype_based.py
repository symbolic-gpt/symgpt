from . import LLMErcChecker
from llm.utils import trim_json_markers
from sol.ast import get_sol_ast
from sol.simil import zss_distance
from abc import ABC, abstractmethod
import json
from typing import Any, Callable, Dict, Tuple

from audit.context import init_sol_audit_context
from erc.types import ErcRule
from llm.adapters import LLMAdapter
import logging


logger = logging.getLogger(__name__)

class RuleTypeBasedLLMErcChecker(LLMErcChecker):
    def get_prompt(self, rule: ErcRule, code: str) -> str:
        
        if rule["type"] == "throw":
            example = self._get_random_oneshot_example_from_files(rule)
            
            a1 = get_sol_ast(example)
            a2 = get_sol_ast(code)
            dist = zss_distance(a1, a2)
            logger.debug(f"similarity: {dist}")
#             example_str = f"""Example:\"\"\"
# {example}
# \"\"\"""" if example else ""
            example_str = ""

            prompt = f"""
Rule:
The function '{rule['interface']}' and the related parts should {rule['rule']}

Instruction:
Think step by step and return a JSON object with key 'throw' (boolean) indicating whether the given code will throw as required or not"

{example_str}
Code:\"\"\"
{code}
\"\"\"
            """
            return prompt
        else:
            # FIXME: copy existing template to here
            raise NotImplementedError()
    
    def check(self, rule: ErcRule, code: str) -> Tuple[bool, str]:
        audit_msg = self.get_prompt(rule, code)
        res = self._llm.ask([{"content": audit_msg, "role":"user"}], temperature=0, n=1)[0]
        res = json.loads(trim_json_markers(res))
        return self.is_passed(rule, res), res
            

    def is_passed(self, rule: ErcRule, result: Dict) -> bool:
        if rule["type"] == "throw":
            return result["throw"] == (not rule['rule'].startswith('not'))
        else:
            # FIXME: copy existing template to here
            raise NotImplementedError()