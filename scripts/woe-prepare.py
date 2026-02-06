import asyncio
import json
from openai import AsyncOpenAI


client = AsyncOpenAI()

async def doc2ebnf():
    erc_files = [
        "erc/ERC20",
        "erc/ERC721",
        "erc/ERC1155"
    ]

    vfiles = [
        "docs/sym_input/call_verify.json",
        "docs/sym_input/emit_verify.json",
        "docs/sym_input/throw_verify.json",
        "docs/sym_input/order_verify.json",
        "docs/sym_input/state_assign_verify.json",
        "docs/sym_input/return_verify.json"
    ]
    v_objs = []
    for vf in vfiles:
        with open(vf, "r") as f:
            v = json.load(f)
        v_objs.append(v)
    
    vmerged = merge_definitions(v_objs)
        


    constraints_format = json.dumps(vmerged, indent=2)
    
    coroutines = []
    for erc_file in erc_files:
        with open(erc_file, "r") as f:
            erc = f.read()
        prompt = f"Given the ERC, return all the rules in the ERC with the given constraints.\n" + \
        f'ERC:"""{erc}"""\n' + \
        f'Constraint JSON Schema:"""\n' + \
        f'{constraints_format}\n' + \
        '"""' + \
        f"""
Return all constraints in single JSON array: [
{{
    "function": "string, optional, can either be function interface or event name which rule should apply, or empty if the rule should be applied to every function",
    "constraint": "constraint object, can be one of CallVerify, EmitVerify, OrderVerify, ReturnVerify, StateAssignVerify, or ThrowVerify which follows the constraint JSON schema"
}}
]
        """
        print(prompt)
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
            ) 
        )

    results = await asyncio.gather(*coroutines)
    for result, erc_file in zip(results, erc_files):
        with open(erc_file.replace("/","_")+"_out", "w") as f:
            f.write(result.choices[0].message.content)
    
    
def merge_definitions(definitions_list):
    merged = {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "type": "object",
        "definitions": {},
        "properties": {}
    }
    for d in definitions_list:
        for key, value in d.get("definitions", {}).items():
            if key not in merged["definitions"]:
                merged["definitions"][key] = value
            else:
                # Handle conflicts if necessary
                pass
        for key, value in d.get("properties", {}).items():
            if key not in merged["properties"]:
                merged["properties"][key] = value
            else:
                # Handle conflicts if necessary
                pass
    return merged


async def main():
    await doc2ebnf()


if __name__ == "__main__":
    asyncio.run(main())