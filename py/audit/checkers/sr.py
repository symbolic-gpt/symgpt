import json
import logging
from typing import Dict, Tuple

from audit.checkers import LLMErcChecker
from erc.types import ErcRule
from llm.utils import trim_json_markers
logger = logging.getLogger(__name__)

class SRLLMErcChecker(LLMErcChecker):
    
    def check(self, rule: ErcRule, code: str, label=None) -> Tuple[bool, str]:
        """Check the given code compliant with rule

        Args:
            rule (ErcRule): ERC Rule
            code (str): Code in string
            label (str, optional): Log label used in llm adapter. Defaults to None.

        Returns:
            Tuple[bool, str]: compliant and debug information.
        """

        # if compound rule, handle compound rule 
        if "if" in rule and rule['if']:
            cp_check = self.get_compound_check_prompt(rule['if'], code)
            res = self._llm.ask([{"content": cp_check, "role":"user"}], temperature=0, n=1)[0]
            try:
                res_json = json.loads(trim_json_markers(res))
            except Exception as ex:
                logger.error(ex)
                return None, None
            
            if res_json['exist']: 
                followup = self.get_follow_up_prompt(rule['rule'])
                res = self._llm.ask([
                    {"content": cp_check, "role":"user"}, 
                    {"content": res, "role":"assistant"},
                    {"content": followup, "role":"user"}
                ], temperature=0, n=1)[0]
                res_json = json.loads(trim_json_markers(res))
                return self.is_passed(rule, res_json), res
            else:
                return True, cp_check
            

        audit_msg = self.get_prompt(rule, code)
        res = self._llm.ask([{"content": audit_msg, "role":"user"}], temperature=0, n=1)[0]
        try:
            res_json = json.loads(trim_json_markers(res))
            return self.is_passed(rule, res_json), res
        except Exception as ex:
            logger.error(ex)
            return None, None
        
    def get_prompt(self, rule: ErcRule, code: str) -> str:
        return f"""
{rule['sr']}
Return a JSON object with keys 'compliant' (boolean) indicating whether the given code follows the given rule, and 'reason' (string) providing an explanation if it does not."
Code:\"\"\"
{code}
\"\"\"
The code has been sliced and only rule related logic are kept. So do not report compliance issue regarding to other rules/solidity syntax.
"""  

    def get_compound_check_prompt(self, cond:str, code:str) -> str:
        return f"""
Return a JSON object with keys 'exist' (boolean) indicating whether the given code contains "{cond}".
Code:\"\"\"
{code}
\"\"\""""
    
    def get_follow_up_prompt(self, expect_action:str) -> str:
        return f"""
Return a JSON object with keys 'compliant' (boolean), True if code {expect_action}, False otherwise, and 'reason' (string) providing an explanation if it does not."
"""  

    def is_passed(self, rule: ErcRule, result: Dict) -> bool:
        return result["compliant"]

