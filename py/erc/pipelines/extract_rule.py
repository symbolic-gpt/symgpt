import asyncio
import json
import logging
import os
import re
from typing import Callable, List, Tuple
from openai import AsyncOpenAI

from erc.pipeline import ErcPipeline
from erc.types import Erc
from erc.utils import iterate_rules
from llm.utils import trim_json_markers
from log import get_private_file_logger

logger = logging.getLogger(__name__)
llm_logger = get_private_file_logger("llm.log")


def get_check_rules_prompt(interface:str, rules:str):
    return f"""Throw rules requires when to throw usually have the linguistic patterns:\"\"\"
<subject> MUST throw if <condition>
MUST check <object> <condition>
<condition> MUST treated as
<subject> checks [condition]
Caller must be approved to <action>
[necessity] revert [condition]
Caller <necessity> be the <target>
\"\"\"
Other patterns serve similar purposes also count.

Rules:\"\"\"
{rules}
\"\"\"
List the conditions that need to be thrown or checked in the given rules for function "{interface}" in a JSON array with the following format:

<if>: <string, condition to throw or check>
throw: <boolean, whether it need to throw or should not be thrown>

If no such rule, simply left empty.
"""

def get_semantic_return_rule_prompt(interface:str, rules:str):        
    if interface.find("returns") == -1:
        return None
    return f"""Rules:\"\"\"
{rules}
\"\"\"
Given the rules for function "{interface}", return semantic meaning of the return value in plain text.
"""

def get_return_rule_prompt(interface:str, rules:str):
    if interface.find("returns") == -1 or interface.find("returns (uint256") != -1 or interface.find("returns (address") != -1:
        return None
    return f"""Rules indicates the what specific return value should be return under certain conditions usually have the linguistic patterns:\"\"\"
<action> MUST be treated as normal // infers when the action happens, the return value can be true
\"\"\"

Description for "{interface}":\"\"\"
{rules}
\"\"\"

List such rules in the JSON array with the following format:
[
    {{
        "ret_value": boolean or string depends on the return type in the interface
        "if": <optional, string>
    }}
]
If no such rule, simply return empty array.
Ignore conditions that can cause the function to throw.
"""

def get_emit_rule_in_func_prompt(interface:str, rules:str):
    if interface.find("view") != -1 or interface.find("pure") != -1:
        return None
    return f"""The rules related to event emission usually have the following linguistic patterns:\"\"\"
[necessity] fire <event> [condition]
[necessity] trigger <event> [condition]
<event> emits [condition]
\"\"\"

Given the rules:\"\"\"
{rules}
\"\"\" for the function "{interface}"

list all the conditions that this function need to trigger the event in the JSON array with the following format:
[
    {{
        "emit": [array of event names(usually one, but can be multiple)],
        "if": <string, condition to trigger event(s)>
    }}
]
""" 


def get_state_assign_rule_prompt(interface:str, rules:str):
    if interface.find("view") != -1 or interface.find("pure") != -1:
        return None
    return f"""\"State-Assign\" rules require how to update a state variable usually have the linguistic patterns:
\"\"\"
<subject> is reset/set to <object>"
<subject> overwrites <object>
\"\"\"
Ignore the rule when subject is the parameter of the function/event.

Description for "{interface}":\"\"\"
{rules}
\"\"\"
List \"State-Assign\" rules explicitly mentioned in the given description in JSON array with the following format:
[<string, requirements for how to update or pass a variable>, ...]

If no such rule, simply left empty.
"""


def get_call_rule_prompt(interface:str, rules:str):
    if interface.find("view") != -1 or interface.find("pure") != -1:
        return None
    return f"""\"Call\" rules indicating requirements for calling a hook function have a pattern like “<subject> calls <function>”.

The linguistic patterns in the description for the argument rule in a hook function are:\"\"\"
<subject> MUST be sent unaltered in call to the <a hook function's argument>
\"\"\"

Description for {interface}:\"\"\"
{rules}
\"\"\"

List the conditions mentioned in the given description that need to call a hook function in the JSON array with the following format:
[
    {{
        "call": <hook function name>
        "if": <condition to call>,
        "arg_rules": [
            // This is OPTIONAL, only list argument rules if the description explicitly mentions them.
            // If no such rule, leave it empty.
            {{
                "arg": <integer, hook call argument index>,
                "rule": <string, rule for the argument>
            }}
        ],
    }}
]

If no such rule, leave it empty.

"""

def get_emit_rule_prompt(einterface:str, rules:str):
    return f"""\"Emit\"rules related to event emission usually have the following linguistic patterns:\"\"\"
[necessity] fire <event> [condition]
[necessity] trigger <event> [condition]
<event> emits [condition]
\"\"\"

The following linguistic patterns are for arguments in the emitted event:\"\"\"
The argument <subject> MUST be <object>
[condition] <subject> argument MUST be set to <object>
\"\"\"

Description for "{einterface}":\"\"\"
{rules}
\"\"\" 
List all the conditions that need to trigger the event and argument rules(if any) in the JSON array with the following format:
[{{
    "if": <string, condition to trigger event.>
    "arg_rules": [
        // This is OPTIONAL, only list argument rules if the given description explicitly mentions them with the linguistic patterns.
        {{
            "arg": <integer, event argument index>,
            "rule": <string, rule for the argument>
        }}
    ],
    alternative_events: [Optional, array of alternative events that can be emitted]
}}]
Do not confuse with the argument requirements.
"""

def get_order_rule_prompt(interface:str, rules:str):
    if interface.find("view") != -1 or interface.find("pure") != -1:
        return None
    return f"""\"Order\" rules require some specific actions(event emit, state variable written) happens in order, usually have the linguistic patterns:\"\"\"   
<subject> MUST follow the ordering of <function parameter>
\"\"\"

Description for "{interface}":\"\"\"
{rules}
\"\"\" 
List the conditions that need to be in order in the given description for function "{interface}" in a JSON array with the following format:
[
    {{
        "subject": <string>,
        "order_by": <string, usually an parameter whose type is array>,
    }}
]
"""


async def empty():
    return None

async def parse_evt_rules(openai:AsyncOpenAI, erc_obj, promptfns):
    events = erc_obj["events"]
    
    for evt in events:
        prompts = [
            promptfn(evt['def'], evt['raw_rules']) if name not in evt.get('extracted', {}) else None
            for name, promptfn in promptfns
        ]
        for name, promptfn in promptfns:
            llm_logger.info(f"ID=0 Label=ext_evt_{name}\nPrompt=\n{promptfn(evt['def'], evt['raw_rules'])}")
        coroutines = [
            openai.chat.completions.create(
                messages=[
                    {
                        "content":prompt,
                        "role":"user"
                    }
                ],
                reasoning_effort="high",
                model="gpt-5"
            ) if prompt else empty()
            for prompt in prompts
        ]

        results = await asyncio.gather(*coroutines)
            
            
        for (res, (name, _)) in zip(results, promptfns):
            if "extracted" not in evt:
                evt["extracted"] = {}
            
            
            if res is None:
                if name in evt["extract_debug"]:
                    llm_logger.info(f"ID=0 Label=ext_evt_{name}\nReplies=\n0:\n{evt['extract_debug'][name]}")
                if name not in evt["extracted"]:
                    evt["extracted"][name] = None
                continue
            try:
                evt["extracted"][name] = json.loads(trim_json_markers(res.choices[0].message.content))
            except Exception as ex:
                print(ex)
            if "extract_debug" not in evt or isinstance(evt['extract_debug'], str):
                evt['extract_debug'] = {}
            evt["extract_debug"][name] = res.choices[0].message.content

async def parse_fn_rules(openai:AsyncOpenAI, erc_obj:Erc, promptfns):
    logger.debug(f"Extracting function rules for {erc_obj['name']}")
    functions = erc_obj["functions"]
    
    # check overload function, we should put the overloaded functions description together
    merged_raw = {}
    for fn in functions:
        fn_name = fn['def'].split("(")[0]
        if fn_name not in merged_raw:
            merged_raw[fn_name] = fn['raw_rules']
        else:
            merged_raw[fn_name] += "\n" + fn['raw_rules']
    
    for fn in functions:

        prompts = [
            promptfn(fn['def'], merged_raw[fn['def'].split("(")[0]]) if name not in fn.get('extracted', {}) else None
            for name, promptfn in promptfns
        ]

        for name, promptfn in promptfns:
            llm_logger.info(f"ID=0 Label=ext_fn_{name}\nPrompt=\n{promptfn(fn['def'], merged_raw[fn['def'].split("(")[0]])}")
        
        for name, promptfn in promptfns:
            p = name if name not in fn.get('extracted', {}) else None
            if p:
                logger.debug(f"Extracting {name} for {fn['def']}")
            else:
                pass
                # logger.debug(f"Skipping {name} for {fn['def']}")

        coroutines = [
            openai.chat.completions.create(
                messages=[
                    {
                        "content":prompt,
                        "role":"user"
                    }
                ],
                reasoning_effort="high",
                model="gpt-5",
            ) if prompt else empty()
            for prompt 
            in prompts
        ]
    
        results = await asyncio.gather(*coroutines)
        
        
        for (res, (name, _)) in zip(results, promptfns):
            if "extracted" not in fn:
                fn["extracted"] = {}
            if res is None:
                if name in fn["extract_debug"]:
                    llm_logger.info(f"ID=0 Label=ext_fn_{name}\nReplies=\n0:\n{fn["extract_debug"][name]}")
                if name not in fn["extracted"]:
                    fn["extracted"][name] = None
                continue
            try:
                if name == "semantic_return":
                    fn["extracted"][name] = res.choices[0].message.content
                else:
                    fn["extracted"][name] = json.loads(trim_json_markers(res.choices[0].message.content))
            except Exception as ex:
                print(ex)
            if "extract_debug" not in fn or isinstance(fn['extract_debug'], str):
                fn['extract_debug'] = {}
            fn["extract_debug"][name] = res.choices[0].message.content
            
            # extract pattern in the `...`
            reg = r"`(.*?)`"
            if "assign" in fn["extracted"][name] and not isinstance(fn["extracted"][name], str):
                rules = fn["extracted"][name]["assign"]
                fdef = fn['def']
                frules = []
                for rule in rules: 
                    matches = re.findall(reg, rule)
                    if matches:
                        for m in matches:
                            if fdef.find(m+",") == -1:
                                continue
                    frules.append(rule)
                fn["extracted"][name]["assign"] = frules
                        

def if_view(fn_or_evt_obj):
    return fn_or_evt_obj['def'].find("view") != -1 or fn_or_evt_obj['def'].find("pure") != -1

class ExtractRule(ErcPipeline):
    def name(self) -> str:
        return "ext"
    def __init__(self, openai:AsyncOpenAI, erc_str:str) -> None:
        super().__init__()
        self._openai = openai
        self._erc_str = erc_str
        # rule cateogry, extract function, skip function
        prompt_fns: List[Tuple[str, Callable ]] = []
        prompt_fns.append(("throw", get_check_rules_prompt))
        prompt_fns.append(("semantic_return", get_semantic_return_rule_prompt))
        prompt_fns.append(("return", get_return_rule_prompt))
        prompt_fns.append(("emit", get_emit_rule_in_func_prompt))
        prompt_fns.append(("assign", get_state_assign_rule_prompt))
        prompt_fns.append(("call", get_call_rule_prompt))
        prompt_fns.append(("order", get_order_rule_prompt))
        
        evt_prompt_fns: List[Tuple[str, Callable]] = []
        evt_prompt_fns.append(("emit", get_emit_rule_prompt))
        evt_prompt_fns.append(("assign", get_state_assign_rule_prompt))

        self._prompt_fns = prompt_fns
        self._evt_prompt_fns = evt_prompt_fns
    
    async def run(self, ei: Erc) -> Erc:
        await parse_fn_rules(self._openai, ei, self._prompt_fns)
        await parse_evt_rules(self._openai, ei, self._evt_prompt_fns)
        ei["rules"] = []
        for (fn_or_evt, rule_type, rule, cond) in iterate_rules(ei):
            rule_obj = {
                'rule': rule,
                'type': rule_type,
                'interface':fn_or_evt['def'] if fn_or_evt else None,
            }
            
            if cond:
                rule_obj['if'] = cond
                
            # simple ways to filter out the wrong rule
            # 1. make sure target function in type 'call' is function
            if rule_type == "call":
                callee_name = rule.split(" ")[1]
                if self._erc_str.find(f"function {callee_name}") == -1:
                    logger.info(f"Skip rule {rule} for {fn_or_evt['def']}")
                    continue
            ei["rules"].append(rule_obj)
        return ei