import asyncio
from openai import AsyncOpenAI
from erc.pipeline import ErcPipeline
from erc.types import Erc
import json
import logging

from erc.utils import get_base_erc_name
from llm.utils import trim_json_markers
from log import get_private_file_logger

logger = logging.getLogger(__name__)
llm_logger = get_private_file_logger("llm.log")


async def empty():
    return None

class GenSym(ErcPipeline):
    def name(self) -> str:
        return "sym"

    def __init__(self, openai: AsyncOpenAI) -> None:
        super().__init__()
        self._openai = openai
        self._sym_json_schema = {
    "throw": json.loads(open("docs/sym_input/throw_verify.json").read()),
    "emit": json.loads(open("docs/sym_input/emit_verify.json").read()),
    "return": json.loads(open("docs/sym_input/return_verify.json").read()),
    "assign": json.loads(open("docs/sym_input/state_assign_verify.json").read()),
    "call": json.loads(open("docs/sym_input/call_verify.json").read()),
    "order": json.loads(open("docs/sym_input/order_verify.json").read()),
}
        self._emit_global = json.loads(open("docs/sym_input/emit_verify_global.json").read())
        self._assign_global = json.loads(open("docs/sym_input/state_assign_verify_global.json").read())
        self._anchor_list = {
            "ERC20": open("docs/sym_input/ERC20_anchors.txt").read(),
            "ERC721": open("docs/sym_input/ERC721_anchors.txt").read(),
            "ERC1155": open("docs/sym_input/ERC1155_anchors.txt").read(),
            #"IERC3525": open("docs/sym_input/ERC3525_anchors.txt").read()
        }

    
    async def run(self, ei: Erc) -> Erc:
        # For each rule, generate config for sym engine
        coroutines = []
        for rule in ei["rules"]:
            rtype = rule["type"]
            if rtype not in self._sym_json_schema:
                # logger.debug(f"no json schema for {rtype}")
                coroutines.append(empty())
                continue
            if "sym" in rule:
                # logger.debug(f"sym for {rule['rule']} already exists")
                coroutines.append(empty())
                continue
            if rtype == "emit" and rule["interface"].startswith("event "):
                verify_json_schema = self._emit_global
            elif rtype == "assign" and rule["interface"].startswith("event"):
                verify_json_schema = self._assign_global
            else:
                verify_json_schema = self._sym_json_schema[rtype]
            erc_name = get_base_erc_name(ei["name"])
            anchor_list = f"Possible anchor functions for StateVarSelector:\n{self._anchor_list[erc_name]}\n  ONLY use them with StateVarSelector. DO NOT use anchor functions with FnCallRetSelector(which mainly for receiver function)." if erc_name in self._anchor_list else ""
            rule_str = rule["rule"]
            args_str = ""
            if "if" in rule and rule["if"] is not None:
                if_str = rule["if"]
                args = rule.get("args", None)
                args_rules = json.dumps(rule.get("args", []), indent=4) if args is not None else None
                rule_str += f" if {if_str}"
                args_str = f"Arg rules: {args_rules}" if args_rules else "Arg rules: None"
            prompt = f"""For '{rule['interface']}'
rule: {rule_str}
{args_str}
By using the following json schema of the configuration for the rule verification:
{json.dumps(verify_json_schema, indent=4)}
{anchor_list}
Generate the verify json for the rule.{"" if args_str else "Do not generate arg verifiers if there is no arg rule."}
"""
            
            llm_logger.info(f"ID=0 Label=ext_sym\nPrompt=\n{prompt}")
            coroutine = self._openai.chat.completions.create(
                messages=[
                    {
                        "content": prompt,
                        "role": "user",
                    }
                ],
                model="gpt-5",
                reasoning_effort="high",
                #response_format={"type": "json_object" }
            )
            coroutines.append(coroutine)
            
        results = await asyncio.gather(*coroutines)
        
        for (res, rule) in zip(results, ei["rules"]):
            if "sym_debug" in rule:
                llm_logger.info(f"ID=0 Label=ext_sym\nReplies=\n0:\n{rule["sym_debug"]}")
            if res is None:
                continue
            res_text = res.choices[0].message.content

            try:
                rule["sym"] = json.loads(trim_json_markers(res_text))
                if rule["type"] == "assign" and rule["interface"].startswith("event"):
                    rule["sym"]["event"] = rule["interface"].split(" ")[1].split("(")[0]
            except Exception as e:
                rule["sym"] = None
               
            rule["sym_debug"] = res_text
            logger.debug(f"sym for {rule['rule']} is {rule['sym']}")
            

        return ei

