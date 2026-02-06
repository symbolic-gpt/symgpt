import re
import os
from typing import List
from erc.types import Erc
from sol.utils import parse_event_declaration, parse_function_signature

def extract_interfaces(block:str) -> List[Erc]:
    interfaces = []
    interface = Erc(
        functions=[],
        events=[],
        name=None
    )
    
    lines = block.splitlines(keepends=True)
    prev = 0
    for i, line in enumerate(lines):
        
        if line.strip().startswith("function "):
            line = line.strip()
            if line.endswith("\n"):
                line = line[:-1]
            
            if line.endswith(";") :
                line = line[:-1]
            
            # the interface is multi-line
            # Ex. function xxx(
            #          uint256 a,
            #          uint256 b
            #      ) external returns (uint256);
            fn_def = line
            multi_line = 0
            if line.endswith("("):
                found_end = False
                multi_line = 1
                while i+multi_line < len(lines):
                    ll = lines[i+multi_line].strip()
                    if ll.endswith(";"):
                        fn_def += ll[:-1]
                        found_end = True
                        break
                    fn_def += ll
                    multi_line += 1
                if not found_end:
                    raise ValueError(f"function definition not ended at line {i+1}: {line}")
            fn_def = fn_def.replace("\n", "")
            interface["functions"].append({
                "def": fn_def,
                "raw_rules": "".join(l for l in lines[prev: i] if l.find("@notice") == -1)
            })
            
            # check if function has body
            if line.endswith("{"):
                ii = i+1
                ident = 1
                while ii < len(lines):
                    ll =  lines[ii].strip()
                    if ll.endswith("{"):
                        ident += 1
                    elif ll.endswith("}"):
                        ident -= 1
                    if ident == 0:
                        break
                    ii += 1
                interface["functions"][-1]["raw_rules"] += "\n"
                interface["functions"][-1]["raw_rules"] += "".join(lines[i:ii+1])
            
            prev = i+1
            i += multi_line
        elif line.strip().startswith("event "):
            line = line.strip()
            interface["events"].append({
                "def": line,
                "raw_rules": "".join(lines[prev: i])
            })
            prev = i+1
        elif line.strip().startswith("interface "):
            match = re.match(r'\binterface\s+(\w+)\s*', line)
            new_interface = Erc(
                functions=[],
                events=[],
                name=None
            )
            if match:
                new_interface["name"] = match.group(1)
            else:
                new_interface["name"] = line
            interface = new_interface
            interfaces.append(interface)
            prev = i + 1
    
    if interface["name"] is None and len(interface["functions"]) != 0:
        # smart guess if no interface name and has function(s)
        if block.find("function supportsInterface(bytes4 interfaceID)") != -1:
            interface["name"] = "ERC165"
            
        
        interfaces.append(interface)
    return interfaces


def extract_interface_blocks(erc_doc:str):
    lines = erc_doc.splitlines(keepends=True)
    spec_start_at = None
    spec_end_at = len(lines) - 1
    blocks = []
    
    solidity_block_start = "```solidity"
    solidity_block_start_at = None
    for i, line in enumerate(lines):
        if spec_start_at is None:
            if line.find("Specification") != -1:
                spec_start_at = i
            else:
                continue
        if line.startswith("Implementation"):
            spec_end_at = i - 1
            break

        if line.find(solidity_block_start) != -1:
            solidity_block_start_at = i
            continue
        elif line.find("```") != -1:
            if solidity_block_start_at is not None:
                blocks.append(
                    "".join(lines[solidity_block_start_at+1:i])
                )
                solidity_block_start_at = None
            continue
    
    if len(blocks) == 0:
        blocks.append("".join(lines[spec_start_at+1:spec_end_at+1]))
    
    return blocks


                    

def format_interface(raw_interface_obj):
    for fn in raw_interface_obj["functions"]:
        fn["format"] = parse_function_signature(fn["def"])
    
    for event in raw_interface_obj["events"]:
        event["format"] = parse_event_declaration(event["def"])
        
        


def preprocess(raw_content:str, erc_filename:str, cache_dir:str = None) -> List[Erc]:
    erc_filename = erc_filename.split(".")[0]
    blocks = extract_interface_blocks(raw_content)
    
    # suppose that there is only one interface in a block
    found_interface_in_block = any([block.find("interface") != -1 for block in blocks])
    if found_interface_in_block:
        blocks = [block for block in blocks if block.find("interface") != -1]
    
    interface_objs = []
    for i, block in enumerate(blocks): 
        if cache_dir:
            block_dst = os.path.join(cache_dir, f"{erc_filename}_block_{i}")
            with open(block_dst, "w") as f:
                f.write(block)
        interfaces = extract_interfaces(block)
        for interface in interfaces:
            if interface["name"] is None:
                interface["name"] = erc_filename
            format_interface(interface)
            interface_objs.append(interface)
    return interface_objs