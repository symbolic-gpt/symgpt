from typing import Dict, List, Set
from solidity_parser import parser
import json
import logging
logger = logging.getLogger(__name__)

def remove_empty_ifelse_blocks(code_lines:List[str], lines_need: Set[int]):

    while True:
        lines = list(lines_need)
        lines.sort()
        changed = False
        for idx, line_idx in enumerate(lines):
            line = code_lines[line_idx].strip()
            if line.startswith("if") or "else " in line:
                next_line_idx = lines[idx + 1]
                next_line = code_lines[next_line_idx].strip()
                if next_line_idx in lines_need and next_line == "}":
                    lines_need.remove(line_idx)
                    lines_need.remove(next_line_idx)
                    changed = True

        if not changed:
            break


def complete_multiline_statements(code_lines: List[str], lines_need: Set[int]):
    new_added_lines = set()
    for idx in lines_need:
        line =  code_lines[idx].strip()

        if line.endswith("("):
            i = idx + 1
            while i < len(code_lines):
                new_added_lines.add(i)
                line = code_lines[i].strip()
                if line.endswith(";") or line.endswith("{"):
                    break
                i += 1
    [lines_need.add(i) for i in new_added_lines]

def find_fn(su, contract, fn):
    nodes:List[Dict] = [su]
    candidates = []
    while nodes:
        node = nodes.pop()
        node_type = node["type"]
        if node_type == "SourceUnit":
            nodes.extend(node.get("children", []))
        elif node_type == "FunctionDefinition":
            if node["name"] == fn: 
                if contract is not None:
                    return [node]
                else:
                    candidates.append(node)
        elif node_type == "ContractDefinition":
            if contract is None:
                nodes.extend(node.get("subNodes", []))
            elif node["name"] == contract:
                nodes.extend(node.get("subNodes", []))
    return candidates

def find_contract_of_fn(su, fn):
    nodes:List[Dict] = [su]
    
    while nodes:
        node = nodes.pop()
        node_type = node["type"]
        if node_type == "SourceUnit":
            nodes.extend(node.get("children", []))
        elif node_type == "ContractDefinition":
            if node["loc"]["start"]["line"] <= fn["loc"]["start"]["line"] and \
                node["loc"]["end"]["line"] >= fn["loc"]["end"]["line"]:
                    return node
    
    return None

def get_function_parameter_at(node, index):
    pms_node = node.get("parameters", {})
    params = pms_node.get("parameters", [])
    return params[index]

def super_slice_function(
    source_unit,
    code_lines,
    node, 
    fn_params,
    keywords,
    fn_elms: List,
    lines_need:Set[int],
    cond_lines, 
    keep_state_var_access = False,
    keep_emits = False,
    keep_throws = False
):
    # print(f"fn={node['name']}, params={fn_params}, keywords={keywords}")
    # print(json.dumps(node, indent=4))
    nodes:List[Dict] = [*node.get("body").get("statements")]
    while nodes:
        node = nodes.pop()
        node_type = node["type"]
        if node_type == "ExpressionStatement":
            exp_node = node.get("expression")
            nodes.append(exp_node)
        elif node_type == "BinaryOperation":
            if keep_state_var_access:
                lines_need.add(node["loc"]["start"]["line"]-1)
        elif node_type == "IfStatement":
            lines_need.add(node["loc"]["start"]["line"]-1)
            lines_need.add(node["loc"]["end"]["line"]-1)

            tb = node.get("TrueBody")
            if tb:
                if "statements" in tb:
                    nodes.extend(tb["statements"])
            fb = node.get("FalseBody")
            if fb:
                if "statements" in fb:
                    nodes.extend(fb["statements"])
        elif node_type == "FunctionCall":
            callee_name = node.get("expression").get("name")
            # print(f"found call={callee_name}")
            callsite_args = node.get("arguments", [])
            target_arg_ids = []
            for idx, arg in enumerate(callsite_args):
                if is_target_arg(source_unit, code_lines, fn_elms, arg, fn_params, keywords):
                    target_arg_ids.append(idx)

            if callee_name == "require":
                if keep_throws and len(target_arg_ids) != 0:
                    # found target argument pass to function call
                    lines_need.add(node["loc"]["start"]["line"]-1)
            else:
                
                if len(target_arg_ids) != 0:
                    lines_need.add(node["loc"]["start"]["line"]-1)
                    # add to fn_elms
                    candidates = find_fn(source_unit, None, callee_name)
                    for candidate in candidates:
                        if len(candidate["parameters"]["parameters"]) != len(callsite_args):
                            continue
                        fn_elms.append((candidate, keywords,target_arg_ids))
                    

        elif node_type == "EmitStatement":
            emit_exp = node["eventCall"]["expression"]
            event_name = emit_exp["name"]
            
            if keep_emits:
                # check arguments
                
                for i in range(node["loc"]["start"]["line"],
                               node["loc"]["end"]["line"]+1):
                    lines_need.add(i-1)
                    
        elif node_type == "Identifier" or node_type == "BooleanLiteral" or node_type == "MemberAccess":
            # print("found return")
            lines_need.add(node["loc"]["start"]["line"]-1)
                    
def is_target_arg(source_unit, code_lines, fn_elms, arg_node, fn_params, keywords):
    nodes:List[Dict] = [arg_node]
    while nodes:
        
        node = nodes.pop()
        node_type = node["type"]
        if node_type == "BinaryOperation":
            nodes.append(node["left"])
            nodes.append(node["right"])
        elif node_type == "Identifier":
            identifier = node["name"]
            if identifier in fn_params or identifier in keywords:
                return True
        elif node_type == "FunctionCall":
            callee_name = node.get("expression").get("name")
            # print(f"found call={callee_name} in arg")
            callsite_args = node.get("arguments", [])
            target_arg_ids = []
            for idx, arg in enumerate(callsite_args):
                if is_target_arg(source_unit, code_lines, fn_elms, arg, fn_params, keywords):
                    target_arg_ids.append(idx)
            if len(target_arg_ids) != 0:
                return True
            candidates = find_fn(source_unit, None, callee_name)
            # print(f"found call={callee_name} {len(candidates)} candidates")

            for candidate in candidates:
                if len(candidate["parameters"]["parameters"]) != len(callsite_args):
                    continue
                fn_lines = code_lines[candidate["loc"]["start"]["line"]-1:candidate["loc"]["end"]["line"]]
                if return_target(fn_lines, keywords):
                    fn_elms.append((candidate, keywords, target_arg_ids))
                    return True
                
        
    return False

def return_target(code_lines, keywords):
    for line in code_lines:
        line = line.strip()
        if line.startswith("return"):
            for kw in keywords:
                if kw in line:
                    return True
    return False
    


def super_slice(
        code_str:str, 
        target_contract:str, 
        target_fn:str,
        target_fn_param_idx_list=None, 
        target_keyword_list=None, 
        keep_state_var_access = False,
        keep_emits = False,
        keep_throws = False
        ) -> str:
    """Assume code is proper indented

    Args:
        code (str): Solidity code.
        target_fn_contract (str): Target contract name.
        target_fn (str): Target function name. 
        target_fn_param_idx_list (List, optional): Array of parameter index. Defaults to None.
        target_keyword_list (List, optional): "msg.sender". Defaults to None.
        remove_state_var_access: remove state variable accessment
        only_emits: keep only control- and data- dependent to emit
        only_throws: keep only control- and data- dependent to throw(require, revert, assert)

    Returns:
        str: super-sliced code
    """
    if target_contract is None or target_fn is None:
        raise Exception("target_fn and target_fn_param_idx_list are required")
    
    if target_fn_param_idx_list is None and target_keyword_list is None:
        raise Exception("target_fn_param_idx_list and target_keyword_list, at least one of them is required")
    
    code_lines = code_str.splitlines()
    source_unit = parser.parse(code_str, loc=True)

    # print(json.dumps(source_unit, indent=4))
    lines_need = set()

    results = find_fn(source_unit, target_contract, target_fn)
    if len(results) != 1:
        logger.warning(f"super_slice found {len(results)} candidate for contract '{target_contract}' and fn '{target_fn}'")
        return None
    tgt_fn_node = results[0]


    fn_elms = [(tgt_fn_node, target_keyword_list, target_fn_param_idx_list)]

    checked_fn_ids = set()

    # tuple(int, int): if idx 0 is included, then idx 1 should be included as well
    # used mainly for callsite
    cond_lines = []
    while len(fn_elms) != 0:
        (fn_elm, keywords, param_idxs) = fn_elms.pop()
        fn_elm_id = fn_elm["loc"]["start"]['line']
        if fn_elm_id in checked_fn_ids:
            continue
        checked_fn_ids.add(fn_elm_id)

        if keywords is None:
            keywords = []
        
        fn_params = None
        if param_idxs is not None:
            fn_params = []
            for pidx in param_idxs:
                fn_params.append(get_function_parameter_at(fn_elm, pidx)["name"])
        
        prev_lines_need_len = len(lines_need)
        super_slice_function(
            source_unit,
            code_lines,
            fn_elm,
            fn_params,
            keywords,
            fn_elms,
            lines_need,
            cond_lines,
            keep_state_var_access,
            keep_emits,
            keep_throws
        )
        # add function declaration only if at least one line 
        # of the function is needed
        if len(lines_need) != prev_lines_need_len:
            lines_need.add(fn_elm["loc"]["start"]["line"]-1)
            lines_need.add(fn_elm["loc"]["end"]["line"]-1)
            
            # make sure contract is added as well
            contract = find_contract_of_fn(source_unit, fn_elm)
            if contract:
                lines_need.add(contract["loc"]["start"]["line"]-1)
                lines_need.add(contract["loc"]["end"]["line"]-1)
            
    #     # loop function body
    #     for line_idx in range(fn_elm["range"][0]+1, fn_elm["range"][1]):
    #         code_line = code_str_lines[line_idx]
    #         stripped_line = code_line.strip()
            
    #         callee_name, callee_params = parse_function_call(stripped_line)
    #         if callee_name:
    #             if callee_name == "require":
    #                 # print(f"found require, {callee_params}, keywords: {keywords}, fnparams: {fn_params}")
    #                 for cp in callee_params:
    #                     for fnp in fn_params:
    #                         if cp.find(fnp) != -1:
    #                             lines_need.add(line_idx)
    #                             break
    #                     for kw in keywords:
    #                         if cp.find(kw) != -1:
    #                             lines_need.add(line_idx)

    #                             break
    #             else:
    #                 # found a function call, check whether we need to care 
    #                 callee_elm = code.get_elm_by_type_and_name("f", callee_name)
    #                 if callee_elm:
    #                     tgt_pidxs = []
    #                     for cpidx, cp in enumerate(callee_params):
    #                         if cp in fn_params or cp in keywords:
    #                             tgt_pidxs.append(cpidx)
    #                     if len(tgt_pidxs) != 0:
    #                         lines_need.add(line_idx)
    #                     fn_elms.append((callee_elm, keywords.copy(), tgt_pidxs))
    #                     cond_lines.append((line_idx, callee_elm["range"][0]))
    #                     continue
    #         if stripped_line.startswith("emit "):
    #             if target_actions and "emit" in target_actions:
    #                 lines_need.add(line_idx)
    #             else:
    #                 continue
    #         if stripped_line.startswith("if") or stripped_line.endswith("}"):
    #             lines_need.add(line_idx)
    #             continue
    #         for kw in keywords:
    #             if code_line.find(kw) != -1:
    #                 lines_need.add(line_idx)

    #                 break
    #         for kw in fn_params:
    #             if code_line.find(kw) != -1:
    #                 lines_need.add(line_idx)

    #                 break
                    
        

    #         contract_elm = code.get_elm_by_type_and_name("c", fn_elm["contract"])
        
    #         if contract_elm:
    #             lines_need.add(contract_elm["range"][0])
    #             lines_need.add(contract_elm["range"][1])



    remove_empty_ifelse_blocks(code_lines, lines_need)
    complete_multiline_statements(code_lines, lines_need)
    for if_line, then_line in cond_lines:
        if if_line in lines_need:
            lines_need.add(then_line)
    sorted_lines_need = list(lines_need)
    sorted_lines_need.sort()

    return "\n".join([code_lines[idx] for idx in sorted_lines_need])



