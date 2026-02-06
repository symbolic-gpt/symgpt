import asyncio
from glob import glob
from openai import AsyncOpenAI

from erc.utils import iterate_rules
import json
import os

ir_doc = """
The following variables can be used to describe the constraints of the rule.
#throwed: boolean, true if the function is throwed
p{num}, represent parameter at position num
p{num}.{callee}#called, represent the function {callee} called by the parameter at position num
p{num}.code.length: integer, the length of the code of the parameter at position num
p{num}.codehash: string, the hash of the code of the parameter at position num
{event}#emitted: boolean, true if the event {event} is emitted
{var}.length: integer, the length of the array {var}
{var}(field1, field2, ...): index access of the mapping variable {var} with the fields field1, field2, ...
{var}#writtencnt: integer, the number of times the variable {var} is written
{var}#postexec: integer, the value of the variable {var} after the execution
msg.sender: integer, the address of the sender
this: integer, the address of the contract
"""



def get_prompt(interface:str, rule:str):
    prompt = f"""
Given the rule and the constraints syntax, generate the buggy constraints for the given rule.
Constraints can be concatenated with the ==, !=, <, <=, >, >=, &, ||, !, and ().
Interface:\"\"\"
{interface}
\"\"\"
Rule: \"\"\"
{rule}
\"\"\"
Constraints Syntax:\"\"\"
{ir_doc}
\"\"\"
Return Format (json): {{\"constraints\": \"<string, the buggy constraints>\"}}
"""
    return prompt

def get_prompt_with_code(interface:str, rule:str, code:str):
    prompt = f"""
Given the rule and the constraints syntax, generate the buggy constraints for the given rule and code.
Constraints can be concatenated with the ==, !=, <, <=, >, >=, &, ||, !, and ().
Interface:\"\"\"
{interface}
\"\"\"
Rule: \"\"\"
{rule}
\"\"\"
Code:\"\"\"
{code}
\"\"\"
Constraints Syntax:\"\"\"
{ir_doc}
\"\"\"
Return Format (json): {{\"constraints\": \"<string, the buggy constraints>\"}}
"""
    return prompt

                
async def main_ir_with_code():
    client = AsyncOpenAI(
            api_key=""
    )
    erc_files = [
        "erc/build/ERC20_ERC20.json",
        "erc/build/ERC721_ERC721.json",
        "erc/build/ERC1155_ERC1155.json"
    ]
    executed_rules = []


    for code_file in glob("benchmark/smallext/*.sol"):
        with open(code_file, "r") as f:
            code = f.read()
        coroutines = []
        
        if code_file.find('721') != -1:
            erc_file = erc_files[1]
        elif code_file.find('1155') != -1:
            erc_file = erc_files[2]
        else:
            erc_file = erc_files[0]
        with open(erc_file, "r") as f:
            erc = json.load(f)
            
        out_file = "local/rationality/wc/" + erc_file.split("/")[-1].split(".")[0] + "_" + code_file.split("/")[-1].split(".")[0]
        
        if os.path.exists(out_file):
            print("Skipping", out_file)
            continue
        
        for obj, rtype, rule, cond in iterate_rules(erc):
            if rtype == "semantic_return" or rtype == "return":
                continue
            prompt = get_prompt_with_code(obj['def'], rule if cond is None else rule + " if " + cond['if'], code)
            coroutines.append(
                client.chat.completions.create(
                messages=[
                    {
                        "content":prompt,
                        "role":"user"
                    }
                ],
                model="gpt-5",
                response_format={ "type": "json_object" }
            ))
            executed_rules.append(rule)
        results = await asyncio.gather(*coroutines)
        erc_result = {
            "erc": erc_file,
            "code": code_file,
            "rules": []
        }
        print(out_file)
        for result, rule in zip(results, executed_rules):
            erc_result["rules"].append({
                "rule": rule,
                "constraints": json.loads(result.choices[0].message.content)["constraints"]
            })
        with open(out_file, "w") as f:
            json.dump(erc_result, f, indent=4)
            
        
            
            

        
if __name__ == "__main__":
    asyncio.run(main_ir_with_code())