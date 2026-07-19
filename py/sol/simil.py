import collections
from typing import Dict, List
from solidity_parser import parser
import zss

def node_label(node):
    if node is None:
        return ""
    return node['type']

def children(node):
    if node is None:
        return []
    node_type = node['type']
    if node_type == 'SourceUnit':
        return node['children']
    elif node_type == 'ContractDefinition':
        return node['subNodes']
    elif node_type == 'FunctionDefinition':
        ret_params = node.get('returnParameters', {})
        if isinstance(ret_params, collections.abc.Sequence):
            ret_params = {}
        body = node.get('body', {})
        if isinstance(body, collections.abc.Sequence):
            body = {}
        return node.get('parameters', {}).get('parameters', []) + \
            ret_params.get('parameters', []) + \
                body.get('statements', [])
    elif node_type == 'BinaryOperation':
        return [node['left'], node['right']]
    elif node_type == 'IfStatement':
        children = [node['condition'], node['TrueBody'], node['FalseBody']]
        return list(filter(lambda e: e is not None, children))
    # loop
    else:
        return []

def insert_cost(node):
    return 1

def remove_cost(node):
    return 1

def update_cost(a, b):
    return 0 if a == b else 1

def label_dist(a, b):
    if a == "" or b == "":
        return 1
    else:
        return update_cost(a, b)

def zss_distance(source_unit1: Dict, source_unit2: Dict) -> float:
    """Tree distance

    Args:
        source_unit1 (Dict): Output of solidity_parser's parser
        source_unit2 (Dict): Output of solidity_parser's parser

    Returns:
        int: distance of the two given AST tree
    """
    distance = zss.simple_distance(source_unit1, source_unit2, get_children=children, label_dist=label_dist, get_label=node_label)
    su1 = num_of_children(source_unit1)
    su2 = num_of_children(source_unit2)
    return distance / (su1+su2)

def num_of_children(node) -> int:
    to_explore = [node]
    cnt = 0
    while to_explore:
        curr = to_explore.pop()
        child_nodes = children(curr)
        if child_nodes:
            to_explore.extend(child_nodes)
        cnt += 1
    return cnt
        
    


def diversity(source_unit: Dict, source_units: List[Dict]):
    distances = [zss_distance(source_unit, su) for su in source_units]
    print(distances)