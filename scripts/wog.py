import sys
sys.path.append("./py")
import asyncio
from glob import glob
import json
import os
from audit.utils import find_all_callees, shrink_file, slice as solslice, slithir_funcs_to_text
import re
from openai import AsyncOpenAI

from sol.metadata import get_contract_metadata
from sol.utils import get_contracts_and_ercs, compile

erc_files = [
    "erc/build/ERC20_ERC20.json",
    "erc/build/ERC721_ERC721.json",
    "erc/build/ERC1155_ERC1155.json"
]
cname2ercs = {
    "TokenERC20": 20,
    "MyToken": 20,
    "KIMEX": 20,
    "HBToken": 20,
    "CustomToken": 20,
    "ArthurStandardToken": 20,
    "KINGSGLOBAL": 20,
    "AxpireToken": 20,
    "xEuro": 20,
    "ZRXToken": 20,
    "IOSToken": 20,
    "Egypt": 20,
    "WiT": 20,
    "GEIMCOIN": 20,
    "BAToken": 20,
    "BITCOINSVGOLD": 20,
    "BNB": 20
}
async def audit_from_file(file_path):
    client = AsyncOpenAI(
        api_key=""
    )
    basename = file_path.split("/")[-1].split(".")[0]
    output_file = f"local/wog/{basename}.json"
    if os.path.exists(output_file):
        return
    with open(file_path, "r") as f:
        clines = f.read().splitlines(True)
    
    if file_path.find('721') != -1:
        erc_file = erc_files[1]
    elif file_path.find('1155') != -1:
        erc_file = erc_files[2]
    else:
        erc_file = erc_files[0]
    with open(erc_file, "r") as f:
        erc = json.load(f)

    v, cu = compile(file_path)
    print(f"Compiling {file_path} with {v}")
    c2ercs = get_contracts_and_ercs(cu, cname2ercs=cname2ercs)
    c, ercs = list(c2ercs.items())[0]
    cmeta = get_contract_metadata(c, ercs, clines)
    print(f"Contract {c.name} at {file_path}")
    print(cmeta.func2str.keys())
    no_return_func2str = {}
    for key, value in cmeta.func2str.items():
        no_return_func2str[key.split(" ")[0]] = value
    
    coroutines = []
    executed_rules = []
    for rule in erc["rules"]:
        if rule["type"] == "semantic_return" or rule["type"] == "return":
            continue
        codes = []
        if rule["interface"].startswith("event"):
            # loop through all functions
            for func_name, func_code in no_return_func2str.items():
                if func_name.startswith("name(") or \
                    func_name.startswith("symbol(") or \
                    func_name.startswith("event("):
                    continue
                codes.append((func_name, func_code))
        else:
            short_int = extract_function_signature_simple(rule["interface"])
            
            short_int = short_int.split(" ")[0]
            code = no_return_func2str.get(short_int, "")
            if code == "":
                print(f"not found {short_int}")
                continue
            else:
                print(f"found {short_int}")
                codes.append((short_int, code))

        for idx, (short_int, code) in enumerate(codes):
            prompt = get_audit_prompt(code, rule)
            print(prompt)
            coroutines.append(
                client.chat.completions.create(
                messages=[
                    {
                        "content":prompt,
                        "role":"user"
                    }
                ],
                model="gpt-5"
            ))
            executed_rules.append(str(short_int)+":"+rule["interface"]+rule["rule"])
    
    results = await asyncio.gather(*coroutines)
    erc_result = {
        "results": []
    }
    
    for result, rule in zip(results, executed_rules):
        print(f"Result for {rule}: {result.choices[0].message.content}")
        erc_result["results"].append({
            "rule": rule,
            "violated": result.choices[0].message.content.find("YES") != -1
        })
    par_dir = os.path.dirname(output_file)
    if not os.path.exists(par_dir):
        os.makedirs(par_dir)
    with open(output_file, "w") as f:
        json.dump(erc_result, f, indent=4)



def get_audit_prompt(code, rule, rule_schema):
    if "sym_debug" in rule:
        del rule["sym_debug"]
    prompt = f"Audit the following code against the"
    prompt += f" provided rule:\"\"\""
    prompt += json.dumps(rule, indent=2)
    prompt += "\"\"\"\n"
    prompt += "Rule Schema:\"\"\"\n"
    prompt += f"{rule_schema}\n"
    prompt += "\"\"\"\n"
    prompt += "Code:\"\"\"\n"
    prompt += f"{code}\n"
    prompt += "\"\"\"\n"
    prompt += "Return YES if violated. NO otherwise. DO NOT EXPLAIN ANYTHING ELSE"
    return prompt

async def main():
    for code_file in glob("benchmark/baseline/*.sol"):
        try:
            await audit_from_file(code_file)
        except Exception as e:
            print(f"Error processing {code_file}: {e}")

def extract_function_signature_simple(func_string):
    """
    Simplified version for common function patterns.
    """
    # Remove function keyword and modifiers
    func_string = re.sub(r'\s+', ' ', func_string.strip())
    
    # Extract function name
    name_match = re.search(r'function\s+([a-zA-Z_][a-zA-Z0-9_]*)', func_string)
    if not name_match:
        return None
    
    func_name = name_match.group(1)
    
    # Extract parameters in parentheses
    params_match = re.search(r'\(([^)]*)\)', func_string)
    params = params_match.group(1) if params_match else ""
    
    # Clean parameters - remove variable names
    cleaned_params = []
    if params.strip():
        for param in params.split(','):
            param = param.strip()
            # Take only the type (first word, or handle arrays/mappings)
            if 'mapping' in param:
                # Handle mapping types
                mapping_match = re.search(r'mapping\s*\([^)]+\)', param)
                if mapping_match:
                    cleaned_params.append(mapping_match.group(0))
            else:
                # Regular types - take first word before variable name
                type_match = re.search(r'^(\w+(?:\[\])*)', param)
                if type_match:
                    cleaned_params.append(type_match.group(1))
    
    # Extract returns
    returns_match = re.search(r'returns\s*\(([^)]*)\)', func_string)
    returns = returns_match.group(1) if returns_match else ""
    
    # Clean return types
    cleaned_returns = []
    if returns.strip():
        for return_param in returns.split(','):
            return_param = return_param.strip()
            if 'mapping' in return_param:
                mapping_match = re.search(r'mapping\s*\([^)]+\)', return_param)
                if mapping_match:
                    cleaned_returns.append(mapping_match.group(0))
            else:
                type_match = re.search(r'^(\w+(?:\[\])*)', return_param)
                if type_match:
                    cleaned_returns.append(type_match.group(1))
    
    # Build signature
    signature = f"{func_name}({','.join(cleaned_params)})"
    if cleaned_returns:
        signature += f" returns({','.join(cleaned_returns)})"
    
    return signature

if __name__ == "__main__":

    asyncio.run(main())

    


