from typing import Tuple
from erc.types import ErcRule
from slither.core.declarations import Contract, FunctionContract, SolidityFunction
from slither.slithir.operations import Binary, Length, SolidityCall, HighLevelCall, InternalCall, LibraryCall, EventCall, Operation, HighLevelCall, Return, Assignment, Index


def check_call(rule: ErcRule, f: FunctionContract, target_call:str) -> Tuple[bool, str]:
    code_vars = set()
    code_length_vars = set()
    code_length_compares = set()
    target_called = False
    for ir in f.all_slithir_operations():
        # print(ir, type(ir), ir.node, ir.node.function.name)
        if isinstance(ir, SolidityCall):
            if ir.function.name == "code(address)":
                code_vars.add(ir.lvalue)
        elif isinstance(ir, Length):
            # print(ir, type(ir), ir.node, ir.node.function.name, ir.value)
            # print(type(ir.value))
            if ir.value in code_vars:
                code_length_vars.add(ir.lvalue)
    for ir in f.all_slithir_operations():
        if isinstance(ir, Binary):
            if ir.variable_left in code_length_vars or ir.variable_right in code_length_vars:
                print(ir, ir.node)
                code_length_compares.add(ir)
        elif isinstance(ir, HighLevelCall):
            if ir.function.name == target_call:
                target_called = True
    return len(code_length_compares) > 0 and target_called
    
    