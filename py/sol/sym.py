from collections import defaultdict
from dataclasses import dataclass, field
from enum import Enum
from dataclasses_json import dataclass_json

from typing import Any, List, Optional, Tuple
from z3 import *
from sol.utils import compile, get_anchored_state_variable, get_the_function
from slither.core.cfg.node import Node, NodeType
from slither.slithir.operations import SolidityCall, Binary, Unary,UnaryType, BinaryType, TypeConversion, \
    HighLevelCall, InternalCall, LibraryCall, Condition, Assignment, Index, Length, Return, EventCall, Member, \
    NewArray, Transfer, InitArray, Send, Delete, Unpack, NewElementaryType, LowLevelCall
from slither.slithir.operations.codesize import CodeSize
from slither.core.variables import StateVariable
from slither.slithir.variables import Constant
from slither.core.solidity_types import ElementaryType, MappingType, ArrayType
from slither.core.declarations import FunctionContract, SolidityVariableComposed
from slither.slither import SlitherCompilationUnit 


import logging
logger = logging.getLogger(__name__)

set_param("memory_max_size", 12288)

@dataclass_json
@dataclass
class TypedBase:
    type: str = field(default=None, init=False, repr=False)


@dataclass_json
@dataclass
class FuncParamSelector(TypedBase):
    index: int

    def __post_init__(self):
        self.type = "FuncParamSelector"

@dataclass_json
@dataclass
class EventParamSelector(TypedBase):
    index: int

    def __post_init__(self):
        self.type = "EventParamSelector"


@dataclass_json
@dataclass
class FnCallParamSelector(TypedBase):
    index: int

    def __post_init__(self):
        self.type = "FnCallParamSelector"

@dataclass_json
@dataclass
class StateVarSelector(TypedBase):
    anchor_fn: str
     # if the state variable is a mapping, the keys should be provided
    keys: 'Optional[List[FuncParamSelector | str | StateVarSelector | MsgSenderSelector | EventParamSelector]]' = None
    def __post_init__(self):
        self.type = "StateVarSelector"



@dataclass_json
@dataclass
class ConstantSelector(TypedBase):
    value: bool | int | str

    def __post_init__(self):
        self.type = "ConstantSelector"
        
@dataclass_json
@dataclass
class MsgSenderSelector(TypedBase):
    def __post_init__(self):
        self.type = "MsgSenderSelector"

@dataclass_json
@dataclass
class ArrLengthSelector(TypedBase):
    value: FuncParamSelector

    def __post_init__(self):
        self.type = "ArrLengthSelector"

@dataclass_json
@dataclass
class FnCallRetSelector(TypedBase):
    fn_name: str

    def __post_init__(self):
        self.type = "FnCallRetSelector"
        
@dataclass_json
@dataclass
class CompCondition(TypedBase):
    left: FuncParamSelector |ArrLengthSelector| ConstantSelector | StateVarSelector | FnCallRetSelector | MsgSenderSelector  
    right: FuncParamSelector |ArrLengthSelector| ConstantSelector | StateVarSelector | FnCallRetSelector| MsgSenderSelector  
    # not_eq, eq, gt, lt, gte, lte
    op: str

    def __post_init__(self):
        self.type = "CompCondition"







@dataclass_json
@dataclass
class WrittenCondition(TypedBase):
    
    value: StateVarSelector
    
    # # increment, change, decrement
    # change_type: str = "change" 
    
    # # one or None(many)
    # written_cnt: Optional[str] = None 
    
    # token_creation, token_burn
    change_type: str = None
    
    def __post_init__(self):
        self.type = "WrittenCondition"

@dataclass_json
@dataclass
class UsedInCheckCondition(TypedBase):
    value: FuncParamSelector | StateVarSelector | MsgSenderSelector

    def __post_init__(self):
        self.type = "UsedInCheckCondition"

@dataclass_json
@dataclass
class LogicCondition(TypedBase):
    
    cond: 'List[CompCondition | WrittenCondition | LogicCondition]'
    op: str = "or" 
    
    def __post_init__(self):
        self.type = "LogicCondition"

@dataclass_json
@dataclass
class ThrowVerify(TypedBase):
    cond: CompCondition | LogicCondition
    # Default: throw, not_throw
    op: str = "throw"

    def __post_init__(self):
        self.type = "ThrowVerify"

@dataclass_json
@dataclass
class NotSelector(TypedBase):
    value: ConstantSelector 

    def __post_init__(self):
        self.type = "NotCondition"

@dataclass_json
@dataclass
class ReturnVerify(TypedBase):
    ret_val: ConstantSelector
    cond: CompCondition
    at_least_one: bool = True
    def __post_init__(self):
        self.type = "ReturnVerify"


@dataclass_json
@dataclass
class ArgVerify(TypedBase):
    # index of the event/function parameter
    arg_index: int

    value: FuncParamSelector | ConstantSelector | MsgSenderSelector
    cond: CompCondition | LogicCondition = None

    def __post_init__(self):
        self.type = "ArgVerify"

@dataclass_json
@dataclass
class EmitVerify(TypedBase):
    
    sv_cond: WrittenCondition 
    event: str 
    
    alternative_events: Optional[List[str]] = None
    cond: LogicCondition | CompCondition = None
    within_call_fn: str = None
    error_if_no_sv_cond: bool = False
    arg_verifiers: List[ArgVerify] = None
    def __post_init__(self):
        self.type = "EmitVerify"

@dataclass_json
@dataclass
class EventEmitRecordSelector:
    event: str
    arg_idx: int
    
    def __post_init__(self):
        self.type = "EventEmitSelector"

@dataclass_json
@dataclass
class WrittenRecordSelector:
    sv: StateVarSelector
    arg_idx: int
    
    def __post_init__(self):
        self.type = "WrittenSelector"
    
@dataclass_json
@dataclass
class OrderVerify(TypedBase):
    target: EventEmitRecordSelector | WrittenRecordSelector
    ordered_by: FuncParamSelector

    def __post_init__(self):
        self.type = "OrderVerify"

@dataclass_json
@dataclass
class NoneValueSelector():
    def __post_init__(self):
        self.type = "NoneValueSelector"

@dataclass_json
@dataclass
class StateAssignVerify(TypedBase):
    state: StateVarSelector
    value: FuncParamSelector | NoneValueSelector
    op: str = "overwrite"
    
    # check state assign only if event emitted
    event: str = None
    def __post_init__(self):
        self.type = "StateAssignVerify"
        
@dataclass_json
@dataclass
class CallVerify(TypedBase):
    callee: str
    on: FuncParamSelector
    cond: str = "is_contract"
    arg_verifiers: List[ArgVerify] = None
    alternative_callees: List[str] = None
    def __post_init__(self):
        self.type = "CallVerify"

def deserialize_verify(json_data: str | dict) -> TypedBase:
    type_map = {
            "ThrowVerify": ThrowVerify,
            "ReturnVerify": ReturnVerify,
            "EmitVerify": EmitVerify,
            "StateAssignVerify": StateAssignVerify,
            "CallVerify": CallVerify,
            "OrderVerify": OrderVerify,
    }
    if isinstance(json_data, dict):
        data = json_data
        if any([t in json_data for t in type_map.keys()]):
            for t in type_map.keys():
                if t in json_data:
                    data = json_data.get(t)
                    break
                
        if data.get('type') in type_map:
            return type_map[data['type']].from_dict(data)
        else:
            raise ValueError("Unknown verify type")
    else:
        import json
        data = json.loads(json_data)
        if any([t in data for t in type_map.keys()]):
            for t in type_map.keys():
                if t in data:
                    data = data.get(t)
                    break
        if data.get('type') in type_map:
            return type_map[data['type']].from_dict(data)
        else:
            raise ValueError("Unknown verify type")



# def create_z3var_used_in_throw_from_cond(cond: UsedInThrowCondition, f: FunctionContract):
#     if isinstance(cond.value, FuncParamSelector):
#         return Bool(f"p{cond.value.index}#throw-used")
#     elif isinstance(cond.value, StateVarSelector):
#         anchor_fn = get_the_function(f.contract.compilation_unit, f.contract.name, fname=cond.value.anchor_fn)
#         sv = get_anchored_state_variable(anchor_fn)
#         return Bool(f"{sv.name}#throw-used")
#     elif isinstance(cond.value, MsgSenderSelector):
#         return Bool("msg.sender#throw-used")
#     else:
#         raise Exception(f"not yet supported: {cond}")
    
def mapping_types_as_arr(ty: MappingType) -> List[ElementaryType]:
    types = []     
    curr_type = ty
    while isinstance(curr_type, MappingType):
        types.append(curr_type.type_from)
        curr_type = curr_type.type_to
    
    types.append(curr_type)
    return types

def create_z3var_used_in_check_from_cond(cond: UsedInCheckCondition, f: FunctionContract):
    if isinstance(cond.value, FuncParamSelector):
        return Bool(f"p{cond.value.index}#check-used")
    elif isinstance(cond.value, StateVarSelector):
        anchor_fn = get_the_function(f.contract.compilation_unit, f.contract.name, fname=cond.value.anchor_fn)
        sv = get_anchored_state_variable(anchor_fn)
        return Bool(f"{sv.name}#check-used")
    elif isinstance(cond.value, MsgSenderSelector):
        return Bool("msg.sender#check-used")
    else:
        raise Exception(f"not yet supported: {cond}")
    

# def create_z3var_written_from_cond(cond: WrittenCondition, f: FunctionContract):
#     if isinstance(cond.value, StateVarSelector):
#         anchor_fn = get_the_function(f.contract.compilation_unit, f.contract.name, fname=cond.value.anchor_fn)
#         if anchor_fn is None:
#             raise StateVarAnchorFnNotFound(cond.value.anchor_fn, f.contract.name)
#         sv = get_anchored_state_variable(anchor_fn)
#         return Bool(f"{sv.name}#written")
#     else:
#         raise Exception(f"not yet supported: {cond}")

def create_z3var_used_in_throw(var):
    return Bool(f"{var.name}#throw-used")

class ExecutionState(Enum):
    Executing = 1
    Throwed = 2
    Unsat = 3 # could be due to verifier's precondition, or bug
    Finished = 4
    SymError = 5

def create_z3var_for_sol_type(var_type: str, name: str):
    if isinstance(var_type, ElementaryType) and var_type.type == "bool":
        sym = Bool(name)
    elif isinstance(var_type, ElementaryType) and var_type.type.startswith("string"):
        sym = String(name)
    elif isinstance(var_type, MappingType):
        to_ty = var_type.type_to
        to_tys:List[MappingType] = []
        while isinstance(to_ty, MappingType):
            to_tys.append(to_ty)
            to_ty = to_ty.type_to
        to_tys.reverse()
        
        array_sort = IntSort()
        if len(to_tys) > 0:
            if isinstance(to_tys[0].type_to, ElementaryType) and to_tys[0].type_to.type == "bool":
                array_sort = BoolSort()
        else:
            if isinstance(to_ty, ElementaryType) and to_ty.type == "bool":
                array_sort = BoolSort()
        for to_ty in to_tys:
            # nested array
            array_sort = ArraySort(IntSort(), array_sort)
        # outermost array
        array_sort = Array(name,IntSort(), array_sort)
        sym = array_sort
    elif isinstance(var_type, ArrayType):
        sym = Array(name, IntSort(), IntSort())
    else:
        sym = Int(name)
    return sym
    

def try_to_find_const_assignment_at_constructor(sv: StateVariable) -> Constant :
    const_vars = {}
    for c in sv.contract.constructors:
        for node in c.nodes:
            for ir in node.irs:
                if isinstance(ir, Assignment):
                    if isinstance(ir.rvalue, Constant):
                        const_vars[ir.lvalue] = ir.rvalue
                    elif ir.rvalue in const_vars:
                        const_vars[ir.lvalue] = const_vars[ir.rvalue]
                    if ir.lvalue == sv:
                        if ir.lvalue in const_vars:
                            return const_vars[ir.lvalue]
                elif isinstance(ir, TypeConversion):
                    if isinstance(ir.variable, Constant):
                        const_vars[ir.lvalue] = ir.variable

    return None

class Execution:
    def __init__(self, id:int, entry_point: Node, logger:logging.Logger = None):
        self.id = id
        self.logger = logger
        
        self.step = 0
        
        # current node is the node going to be executed
        self.curr_node = entry_point
        
        # A node may have multiple IRs, this is the offset of the current IR
        self.curr_ir_offset = 0
        
        # z3 solver
        self.solver = Solver()

        self.exec_state:ExecutionState = ExecutionState.Executing

        # record call stack, contains the callsite's node
        self.stack = []

        # mapping from slither variable to z3 symbol
        self.var2symbol = {}
        
        # pre conditions, if unsat, we can stop/skip the execution
        self.stop_if_unsat = []
        self.called_functions = set()
        self.vars_alias = defaultdict(set)
        self.vars_def_by = defaultdict(set)
        self.vars_used_in_throw = set()
        self.vars_rw_cnt = defaultdict(int)
        self.vars_used_in_if = set()
        self.state_variables_ref = {}



         # key: variable (usually a local variable), values is keys [slither mapping var, z3arr, slither key var, z3key]
        self.indexed_track = defaultdict(list)
           
        self._add_to_solver_if_not_throwed = []
        # self.var_array = {}
        
        # code length vars related
        self.code_vars = {
            # key is the solidity variable, value is the code variable
        }
        self.code_length_vars = {
            # key is the code variable, value is the length variable
        }
        self.msg_sender_only_sv = set()
        self.sv_cond_constraints = []
        self.retofcall_should_be_tracked = set()
        self.sv_written_should_be_tracked = set()
        self.sv_written = set()
        self.sv_written_cnt = defaultdict(int)
        self.sv_written_key_should_be_tracked = defaultdict(set)
        self.event_emitted = set()
        self.event_emitted_cnt = defaultdict(int)
        self.event_emitted_arg_should_be_tracked = {
            # key is the event name, value is the set of argument index
        }
        # if return value is constant, return value is stored here
        self.return_value = None
        self.loop_exec_cnt = defaultdict(int)
        # if return value is an variable, then it's z3 variable is stored here
        self.return_z3 = None
        self.sym_error = None
    
    def fork(self, id):
        new_execution = Execution(id, self.curr_node, self.logger)

        # copy the current state
        new_execution.curr_ir_offset = self.curr_ir_offset
        new_execution.exec_state = self.exec_state
        new_execution.stop_if_unsat = self.stop_if_unsat.copy()
        new_execution.stack = self.stack.copy()
        new_execution.var2symbol = self.var2symbol.copy()
        new_execution.vars_alias = self.vars_alias.copy()
        new_execution.vars_rw_cnt = self.vars_rw_cnt.copy()
        new_execution.vars_def_by = self.vars_def_by.copy()
        new_execution.vars_used_in_throw = self.vars_used_in_throw.copy()
        new_execution.vars_used_in_if = self.vars_used_in_if.copy()
        # new_execution.var_array = self.var_array.copy()
        new_execution.state_variables_ref = self.state_variables_ref.copy()
        new_execution.indexed_track = self.indexed_track.copy()
        new_execution.code_length_vars = self.code_length_vars.copy()
        new_execution.sv_written_should_be_tracked = self.sv_written_should_be_tracked.copy()
        new_execution.sv_written = self.sv_written.copy()
        new_execution.called_functions = self.called_functions.copy()
        new_execution.event_emitted = self.event_emitted.copy()
        new_execution.msg_sender_only_sv = self.msg_sender_only_sv.copy()
        new_execution.sv_written_cnt = self.sv_written_cnt.copy()
        new_execution.event_emitted_cnt = self.event_emitted_cnt.copy()
        new_execution.event_emitted_arg_should_be_tracked = self.event_emitted_arg_should_be_tracked.copy()
        new_execution.sv_written_key_should_be_tracked = self.sv_written_key_should_be_tracked.copy()
        new_execution.step = self.step
        new_execution.retofcall_should_be_tracked = self.retofcall_should_be_tracked.copy()
        new_execution.loop_exec_cnt = self.loop_exec_cnt.copy()
        new_execution._add_to_solver_if_not_throwed = self._add_to_solver_if_not_throwed.copy()
        # Deep copy the z3 solver
        for assertion in self.solver.assertions():
            new_execution.solver.add(assertion)

        return new_execution
    
    

    def prepare_essential_vars(self):
        # initialize the function parameters
        for pid, param in enumerate(self.curr_node.function.parameters):
            sym = self.get_sym(param, f"p{pid}")

            if isinstance(param.type, ElementaryType) and param.type.type.startswith("uint"):
                self.solver.add(sym >= 0)

            
        # initialize the state variables
        for svid, sv in enumerate(set(self.curr_node.function.all_state_variables_read()+self.curr_node.function.all_state_variables_written())):
            sym = self.get_sym(sv)
        
            if isinstance(sv.type, ElementaryType) and sv.type.type.startswith("uint"):
                self.solver.add(sym >= 0)

        # initialize the solidity variables
        for svid, sv in enumerate( self.curr_node.function.all_solidity_variables_read()):
            self.var2symbol[sv] = Int(sv.name)

    
    def get_sym(self, var, override_name:str = None, arr_len:int = None):
        # self.logger.debug(f"get_sym {var} {type(var)}")
        if isinstance(var, Constant):
            return var.value
        elif isinstance(var, StateVariable):
            if var in self.var2symbol:
                return self.var2symbol[var]
            else:
                if var not in self.vars_rw_cnt:
                    const_val = None
                    if var.initialized:
                        if var.node_initialization:
                            for ir in var.node_initialization.irs:
                                if isinstance(ir, Assignment):
                                    if isinstance(ir.rvalue, Constant):
                                        const_val = ir.rvalue.value
                                        break
                    
                    constructor_const = try_to_find_const_assignment_at_constructor(var)
                    if constructor_const is not None:
                        # FIXME: if value is address(this), we should mark some constraints like:
                        # 1. value != 0
                        # 2. value != msg.sender
                        const_val = constructor_const.value

                    sv_z3 = create_z3var_for_sol_type(var.type, override_name if override_name else var.name)
                    self.var2symbol[var] = sv_z3

                    if const_val:
                        self.solver.add(sv_z3 == const_val)
                        self.logger.debug(f"initialized state variable {var} = {const_val}")
                        self.vars_rw_cnt[var] = 1
                    
                    return sv_z3
                        
        var_type = var.type
        if var_type is None:
            self.logger.debug(f"var {var} type={type(var)} has no type.\n IR={var.node}")
            return None
        if var not in self.var2symbol:
            sym = None
            if isinstance(var_type, ElementaryType) and var.type.type == "bool":
                sym = Bool(override_name if override_name else var.name)
            elif isinstance(var_type, ElementaryType) and var.type.type.startswith("string"):
                sym = String(override_name if override_name else var.name)
            elif isinstance(var_type, MappingType):
                to_ty = var_type.type_to
                to_tys:List[MappingType] = []
                while isinstance(to_ty, MappingType):
                    to_tys.append(to_ty)
                    to_ty = to_ty.type_to
                to_tys.reverse()
                
                array_sort = IntSort()
                if len(to_tys) > 0:
                    if isinstance(to_tys[0].type_to, ElementaryType) and to_tys[0].type_to.type == "bool":
                        array_sort = BoolSort()
                else:
                    if isinstance(to_ty, ElementaryType) and to_ty.type == "bool":
                        array_sort = BoolSort()
                for to_ty in to_tys:
                    # nested array
                    array_sort = ArraySort(IntSort(), array_sort)
                # outermost array
                array_sort = Array(override_name if override_name else var.name,IntSort(), array_sort)
                sym = array_sort
                # self.var_array[var] = sym
            elif isinstance(var_type, ArrayType):
                name = override_name if override_name else var.name
                sym = Array(name, IntSort(), IntSort())
                if arr_len is not None:
                    self.solver.add(Int(f"{name}.length") == arr_len)
                # self.var_array[var] = sym
            elif isinstance(var_type, list):
                tuple_sym = []
                for i in range(len(var_type)):
                    tuple_sym.append(
                        create_z3var_for_sol_type(var_type[i], f"{var.name}_{i}")
                    )
                sym = tuple_sym
            else:
                sym = Int(override_name if override_name else var.name)
            self.var2symbol[var] = sym
        else:
            sym = self.var2symbol[var]
            if var in self.vars_rw_cnt  and  str(sym) != (override_name if override_name else var.name):
                self.logger.debug(f"override {var.name} from {self.var2symbol[var]} with {override_name}")
                del self.var2symbol[var]
                self.get_sym(var, override_name)
        return self.var2symbol[var]
    
def get_var_from_selector(selector: FuncParamSelector | ConstantSelector | StateVarSelector | MsgSenderSelector | EventParamSelector | FnCallParamSelector | NoneValueSelector | FnCallRetSelector, 
                          f: FunctionContract, exec: Execution,
                          override_state_var_base_z3_arr = None,
                          z3_is_unsigned:List[Any] = None,
                          event:str = None, # used for EventParamSelector
                          fn_call:str=None, # used for FnCallParamSelector
                          retofcall_to_track:List[str] = None,
                          use_index_at_arr:int=None
                          ):
    if isinstance(selector, FuncParamSelector):
        param = f.parameters[selector.index]
        return exec.get_sym(param)
    elif isinstance(selector, NoneValueSelector):
        return 0
    elif isinstance(selector, ArrLengthSelector):
        return Int(f"p{selector.value.index}.length")
    elif isinstance(selector, ConstantSelector):
        if isinstance(selector.value, str) and selector.value.startswith("0x"):
            return int(selector.value, 16)
        return selector.value
    elif isinstance(selector, EventParamSelector):
        if event is None:
            raise Exception("event is None")
        evt = [evt for evt in f.contract.events if evt.name == event][0]
        param = evt.elems[selector.index]
        return create_z3var_for_sol_type(param.type, f"{event}#1#{selector.index}")
    elif isinstance(selector, FnCallParamSelector):
        if fn_call is None:
            raise Exception("fn_call is None")
        f = [fn for fn in f.all_high_level_calls() if fn.name == fn_call][0]
        param = f.parameters[selector.index]
        return create_z3var_for_sol_type(param.type, f"{fn_call}#1#{selector.index}")
    elif isinstance(selector, FnCallRetSelector):
        # FIXME: Need to find the correct type by looking at the function signature
        if retofcall_to_track is not None:
            retofcall_to_track.append(selector.fn_name)
        return Int(f"{selector.fn_name}#ret")
    elif isinstance(selector, StateVarSelector):
        if override_state_var_base_z3_arr is None:
            anchor_fn = get_the_function(f.contract.compilation_unit, f.contract.name, fname=selector.anchor_fn)
            sv = get_anchored_state_variable(anchor_fn)
            if sv in exec.var2symbol:
                z3arr = exec.var2symbol[sv]
            else:
                z3arr = exec.get_sym(sv)
            res = z3arr
        else:
            res = override_state_var_base_z3_arr

        if selector.keys is not None:
            for key in selector.keys:
                if key == "msg.sender" or isinstance(key, MsgSenderSelector):
                    # sv = [sv for sv in f.all_solidity_variables_read() if sv.name == "msg.sender"][0]
                    sv = SolidityVariableComposed("msg.sender")
                    res = Select(res, exec.get_sym(sv))
                elif isinstance(key, FuncParamSelector):
                    # check if the key is the array
                    # if the key is the array, we need to expand the array
                    key_z3 = get_var_from_selector(key, f, exec)
                    if isinstance(key_z3, ArrayRef):
                        key_z3 = Select(key_z3, use_index_at_arr)
                    res = Select(res, key_z3)
                elif isinstance(key, StateVarSelector):
                    res = Select(res, get_var_from_selector(key, f, exec))
                elif isinstance(key, EventParamSelector):
                    res = Select(res, get_var_from_selector(key, f, exec, event=event))
                else:
                    raise Exception(f"not yet supported: {key}")
        type_str = str(sv.type)
        if type_str.find("uint") != -1 or type_str.find("address") != -1:
            if z3_is_unsigned is not None:
                z3_is_unsigned.append(res)
                
        return res
    elif isinstance(selector, MsgSenderSelector):
        # sv = [sv for sv in f.all_solidity_variables_read() if sv.name == "msg.sender"][0]
        sv = SolidityVariableComposed("msg.sender")
        return exec.get_sym(sv)
    else:
        raise Exception(f"not yet supported: {selector}")    



def get_z3expr_from_cond(cond: LogicCondition | CompCondition | WrittenCondition, f: FunctionContract, exec: Execution, 
                         z3_is_unsigned = None, retofcall_to_track:List[str] = None,
                         use_index_at_arr:int=None):
    if isinstance(cond, LogicCondition):
        return get_z3expr_from_logiccond(cond, f, exec, z3_is_unsigned, use_index_at_arr=use_index_at_arr)
    elif isinstance(cond, CompCondition):
        return get_z3expr_from_compcond(cond, f, exec, z3_is_unsigned, retofcall_to_track, use_index_at_arr=use_index_at_arr)
    elif isinstance(cond, WrittenCondition):
        return get_z3expr_from_writtencond(cond, f, exec)
    else:
        raise Exception(f"Unsupported condition type: {cond}")

def get_z3expr_from_logiccond(cond: LogicCondition, f: FunctionContract, exec: Execution, z3_is_unsigned = None, use_index_at_arr:int=None):
    exprs = []
    for subcond in cond.cond:
        exprs.append(get_z3expr_from_cond(subcond, f, exec, use_index_at_arr=use_index_at_arr))
    if cond.op == "or":
        return Or(*exprs)
    elif cond.op == "and":
        return And(*exprs)
    else:
        raise Exception(f"not yet supported: {cond.op} in {cond} {type(cond)}")

def get_z3expr_from_compcond(cond: CompCondition, f: FunctionContract, exec: Execution, 
                             z3_is_unsigned = None, retofcall_to_track:List[str] = None,
                             use_index_at_arr:int=None):
    left = get_var_from_selector(cond.left, f, exec, z3_is_unsigned = z3_is_unsigned, 
                                 retofcall_to_track=retofcall_to_track,
                                 use_index_at_arr=use_index_at_arr)
    right = get_var_from_selector(cond.right, f, exec, z3_is_unsigned = z3_is_unsigned, 
                                  retofcall_to_track=retofcall_to_track,
                                  use_index_at_arr=use_index_at_arr)
    if isinstance(left, ArrayRef):
        left = Select(left, use_index_at_arr)
    elif isinstance(right, ArrayRef):
        right = Select(right, use_index_at_arr)
    if cond.op == "not_eq":
        return left != right
    elif cond.op == "eq":
        return left == right
    elif cond.op == "gt":
        return left > right
    elif cond.op == "lt":
        
        return left < right
    else:
        raise Exception(f"not yet supported: {cond.op}")

def get_z3expr_from_writtencond(cond: WrittenCondition, f: FunctionContract, exec: Execution):
    z3expr = None
    if isinstance(cond.value, StateVarSelector):
        anchor_fn = get_the_function(f.contract.compilation_unit, f.contract.name, fname=cond.value.anchor_fn)
        if anchor_fn is None:
            raise StateVarAnchorFnNotFound(cond.value.anchor_fn, f.contract.name)
        sv = get_anchored_state_variable(anchor_fn)
        z3expr = Bool(f"{sv.name}#written") == True
    else:
        raise Exception(f"not yet supported: {cond}")
    
    # if cond.written_cnt == "one":
    #     z3expr = And(z3expr, Int(f"{sv.name}#writtencnt") == 1)
        
    

    return z3expr

class FnNotFound(Exception):
    def __init__(self, fn:str, contract:str) -> None:
        super().__init__(f"cannot find function {fn} in contract {contract}")

class StateVarAnchorFnNotFound(Exception):
    def __init__(self, fn:str, contract:str) -> None:
        super().__init__(f"cannot find state var anchor function {fn} in contract {contract}")

class CompilationUnitNotSet(Exception):
    def __init__(self) -> None:
        super().__init__("no compilation unit is set")

def fork_if_parameters_has_array(f: FunctionContract, exec: Execution, fork_at_arr_lens:List[int]) -> List[Execution]:
    arr_arg_idxs = [idx for idx, param in enumerate(f.parameters) if isinstance(param.type, ArrayType)]
    if len(arr_arg_idxs) > 0 :
        # if the function has array parameters, fork the execution 3 times: px.length = 0, 1, 2
        execs = []
        for i, arr_len in enumerate(fork_at_arr_lens):
            forked_exec = exec.fork(exec.id+i)
            for idx in arr_arg_idxs:
                forked_exec.solver.add(Int(f"p{idx}.length") == arr_len)
            execs.append(forked_exec)
        return execs
    else:
        return [exec]

class ErcVerifier:
    def __init__(self,  contract_path:str=None, cu:SlitherCompilationUnit = None, logger:logging.Logger = None, llm: bool = False):
        self._contract_path = contract_path
        if cu is not None:
            self.cu = cu
        else:
            _, self.cu = compile(contract_path)
        
        if logger is None:
            logger = logging.getLogger(__name__)
        self.execs: List[Execution] = []

        # True if the operation to verify requires recording the variable used in throw
        self._record_vars_used_in_throw = False
        self._record_vars_used_in_if = False
        self._record_vars_def_by = False
        self._record_emit = False
        self._record_emit_arg = False
        self._record_sv_write = False
        self._record_sv_write_cnt = False
        self._record_sv_written_key = False
        self._record_code_length_vars = False
        self._llm = llm # use llm to audit instead of symbolic execution
        self.logger = logger

    def print_exec_summary(self, f: FunctionContract):
        self.logger.info(f"function {f.name} summary:")
        self.logger.info(f"execs: {len(self.execs)}")
        for exec in self.execs:
            self.logger.info(f"exec {exec.id} {exec.exec_state}")



    def run(self, contract_name:str, function_name:str, fnumofargs:int, vop, fn:FunctionContract=None) -> bool:
        if self.cu is None:
            raise CompilationUnitNotSet()
        if fn is None:
            fn = get_the_function(self.cu, contract_name, fname=function_name, fnumofargs=fnumofargs)
            if fn is None:
                raise FnNotFound(function_name, contract_name)
        self.logger.info(f"[sym] run contract={fn.contract.name} function={fn.name}") 

        # get_nodes_dominate_statevar_writes(f)
        exec_id = 0
        base_exec = Execution(exec_id, fn.entry_point, self.logger)
        
        base_exec.prepare_essential_vars()
        base_exec.called_functions.add(fn)
        buggy_z3 = None
        
        base_exec.solver.add(Int("msg.sender") != 0)
        base_exec.solver.add(Int("msg.sender") != Int("this"))
        base_exec.solver.add(Int("this") != 0)
        
        if isinstance(vop, ThrowVerify):
            forks_at_array_lens = [1, 2]
        else:
            forks_at_array_lens = [0, 1, 2]
        to_exec = fork_if_parameters_has_array(fn, base_exec, forks_at_array_lens)

        for i, init_exec in enumerate(to_exec):
            curr_arr_len = None
            if len(to_exec) > 1:
                curr_arr_len = forks_at_array_lens[i]

            # prepare the following things
            # 1. stop_if_unsat (if execution path is unsat, we can skip the execution)
            # mainly for ignore path that is not possible to reach the verification operation
            # 2. buggy_z3 (sat this z3 expr means the we found the violation)
            # 3. flags (to record some actions, such as #written, #emitted, etc)
            if isinstance(vop, ThrowVerify):
                self._record_sv_write = True
                
                all_setters = [i for i in fn.contract.functions if i.all_state_variables_written() and (i.visibility == "public" or i.visibility == "external")]
                sv_setters = defaultdict(set)
                for setter in all_setters:
                    for sv in setter.all_state_variables_written():
                        sv_setters[sv].add(setter)
                
                for sv, setters in sv_setters.items():
                    # self.logger.debug(f"state variable {sv.name} can be written by {len(setters)} functions: {[st.name for st in setters]}")
                    
                    if sv.name == "_operatorApprovals":
                        init_exec.msg_sender_only_sv.add(sv)
                    # elif sv.name == "_allowances":
                    #     init_exec.msg_sender_only_sv.add(sv)

                # prepare pre-exec-condition
                if isinstance(vop.cond, LogicCondition) or isinstance(vop.cond, CompCondition):
                    need_to_add_lgrz = []
                    need_to_track_retofcall = []
                    expr = get_z3expr_from_cond(vop.cond, fn, init_exec, need_to_add_lgrz, need_to_track_retofcall, use_index_at_arr=curr_arr_len-1 if curr_arr_len is not None else None)
                    init_exec.stop_if_unsat.append(expr)
                    # if state variable is used in expr, check whether it is unsigned int
                    # if so, add the constraint that the state variable should be greater than 0
                    
                    if need_to_add_lgrz:
                        for z3var in need_to_add_lgrz:
                            init_exec.solver.add(z3var >= 0)
                    if need_to_track_retofcall:
                        for fn_name in need_to_track_retofcall:
                            init_exec.retofcall_should_be_tracked.add(fn_name)
                            init_exec.stop_if_unsat.append(Bool(f"{fn_name}#called") == True)
                            
                    self.logger.debug(f"need_to_add_lgrz: {need_to_add_lgrz}")
                    self.logger.debug(f"verify cond: {init_exec.stop_if_unsat}")
                else:
                    raise Exception(f"not yet supported: {vop.cond}")
                
                
                
            elif isinstance(vop, ReturnVerify):
                if isinstance(vop.cond, CompCondition): 
                    expr = get_z3expr_from_compcond(vop.cond, fn, init_exec)
                    init_exec.stop_if_unsat.append(expr)
                    self.logger.debug(f"verify cond: {init_exec.stop_if_unsat}")
                    # init_exec.solver.add(expr)
                else:
                    raise Exception(f"not yet supported: {vop}")
            elif isinstance(vop, CallVerify):
                self._record_vars_def_by = True
                self._record_code_length_vars = True
                # self._record_vars_used_in_if = True



                expect_behavior = [Bool(f"p{vop.on.index}.{vop.callee}#called")]
                not_expect_behavior = [Bool(f"p{vop.on.index}.{vop.callee}#called") == False]
                if vop.alternative_callees:
                    for cl in vop.alternative_callees:
                        expect_behavior.append(Bool(f"p{vop.on.index}.{cl}#called"))
                        not_expect_behavior.append(Bool(f"p{vop.on.index}.{cl}#called") == False)
                expect_behavior = Or(*expect_behavior)
                not_expect_behavior = And(*not_expect_behavior)
                is_code1 = Int(f"p{vop.on.index}.code.length") > 0
                is_code2 = And(Int(f"p{vop.on.index}.codehash") != 0,
                        Int(f"p{vop.on.index}.codehash") != 89477152217924674838424037953991966239322087453347756267410168184682657981552,
                    )
                
                behavior_cond = Or(
                    is_code1,
                    is_code2
                )
                

                init_exec.solver.add(If(is_code1, is_code2, True))
                init_exec.solver.add(If(is_code2, is_code1, True))

                
                init_exec.stop_if_unsat.append(Int(f"p{vop.on.index}") != 0)
                    
                buggy_ors = [
                    And(not_expect_behavior, behavior_cond), 
                    And(expect_behavior, Not(behavior_cond))
                ]
                

                if vop.arg_verifiers:
                    for arg_verifier in vop.arg_verifiers:
                        arg_z3 = get_var_from_selector(FnCallParamSelector(arg_verifier.arg_index), fn, init_exec)
                        value_z3 = get_var_from_selector(arg_verifier.value, fn, init_exec)
                        buggy_ors.append(And(expect_behavior, behavior_cond, arg_z3 != value_z3))
                buggy_z3 = Or(
                    *buggy_ors
                )
                        
                        
            elif isinstance(vop, EmitVerify):
                if vop.event is None:
                    raise Exception("events should be provided")
                
    
                self._record_emit = True
                self._record_emit_arg = True
                self._record_sv_write = True
                self._record_sv_write_cnt = True
                

                
                
                if vop.cond is not None:
                    expr = get_z3expr_from_cond(vop.cond, fn, init_exec)
                    init_exec.stop_if_unsat.append(expr)
                
                events = [vop.event]
                if vop.alternative_events:
                    events.extend(vop.alternative_events)
                if vop.sv_cond is not None:
                    if isinstance(vop.sv_cond, WrittenCondition) and isinstance(vop.sv_cond.value, StateVarSelector):
                        anchor_fn = get_the_function(fn.contract.compilation_unit, fn.contract.name, fname=vop.sv_cond.value.anchor_fn)
                        sv = get_anchored_state_variable(anchor_fn)
                        if sv not in fn.all_state_variables_written():
                            return True
                        if sv:
                            init_exec.sv_written_should_be_tracked.add(sv)
                            self.logger.debug(f"added {sv.name} to be tracked for written")
                        else:
                            raise StateVarAnchorFnNotFound(vop.sv_cond.value.anchor_fn, fn.contract.name)
                    else:
                        raise Exception(f"expect WrittenCondition but got: {vop.sv_cond}")
                    
                    sv_expr = get_z3expr_from_cond(vop.sv_cond, fn, init_exec)
                    
                    events_emitted_z3 = Or([Bool(f"{evt}#emitted") == True for evt in events])
                    events_not_emitted_z3 = And([Bool(f"{evt}#emitted") == False for evt in events])

                    buggy_ors = []
                    
                    shared_cond = []
                    # if vop.sv_cond.written_cnt == "one":
                    #     sv_write_cnt_z3int = Int(f"{sv.name}#writtencnt")
                    #     shared_cond.append(sv_write_cnt_z3int == 1)
                    
                    if vop.sv_cond.change_type is not None:
                        sv_types = mapping_types_as_arr(sv.type)
                        if len(sv_types) < 2:
                            raise Exception("balance types should be mapping")
                        
                        # since the state variable represents balance
                        # and token creation or token burn can be represented as increment or decrement to any address
                        # so we will use a placeholder instead of some concrete address(0, msg.sender, etc) 
                        # to represent the minting/burning address.
                        # the placeholder is a z3 variable, and it looks like this:
                        # <sv name>#1#0, <sv name>#1#1 (if it is a mapping of mapping)
                        self._record_sv_written_key = True
                        post_exec_value = create_z3var_for_sol_type(sv.type, f"{sv.name}#postexec")
                        pre_exec_value = create_z3var_for_sol_type(sv.type, f"{sv.name}")
                        for i in range(len(sv_types)-1):
                            init_exec.sv_written_key_should_be_tracked[sv].add(i)
                            post_exec_value = Select(post_exec_value, create_z3var_for_sol_type(sv_types[i], f"{sv.name}#1#{i}"))
                            pre_exec_value = Select(pre_exec_value, create_z3var_for_sol_type(sv_types[i], f"{sv.name}#1#{i}"))
                        if vop.sv_cond.change_type == "token_creation":
                            shared_cond.append(post_exec_value > pre_exec_value )
                            sv_write_cnt_z3int = Int(f"{sv.name}#writtencnt")
                            shared_cond.append(sv_write_cnt_z3int == 1)
                        elif vop.sv_cond.change_type == "token_burn":
                            shared_cond.append(post_exec_value < pre_exec_value )
                            sv_write_cnt_z3int = Int(f"{sv.name}#writtencnt")
                            shared_cond.append(sv_write_cnt_z3int == 1)
                        

                    # if no state variable is an error 
                    # (usually happens in the case of function requires to emit an event)
                    if vop.error_if_no_sv_cond:
                        # state variable written but no event emitted
                        buggy_ors.append(And(sv_expr, events_not_emitted_z3, *shared_cond))
                        
                        # no state variable written but event emitted
                        buggy_ors.append(And(Not(sv_expr), events_emitted_z3, *shared_cond))
                        
                        # no state variable written
                        buggy_ors.append(Not(sv_expr))
                    else:
                        buggy_ors.append(
                            And(sv_expr, events_not_emitted_z3, *shared_cond)
                        )
                    
                    # handle arg verify if any
                    if vop.arg_verifiers:
                        evt_decl = [e for e in fn.contract.events if e.name == vop.event][0]
                        for arg_verifier in vop.arg_verifiers:
                            arg_type = evt_decl.elems[arg_verifier.arg_index].type
                            if vop.event not in init_exec.event_emitted_arg_should_be_tracked:
                                init_exec.event_emitted_arg_should_be_tracked[vop.event] = set()
                            init_exec.event_emitted_arg_should_be_tracked[vop.event].add(arg_verifier.arg_index)
                            arg_z3 = create_z3var_for_sol_type(arg_type, f"{vop.event}#{arg_verifier.arg_index}")
                            arg_buggy = arg_z3 !=  get_var_from_selector(arg_verifier.value, fn, init_exec)
                            buggy_ors.append(And(sv_expr, events_emitted_z3, arg_buggy, *shared_cond))  
                            if arg_verifier.cond is not None:
                                arg_verify_expr = get_z3expr_from_cond(arg_verifier.cond, fn, init_exec)
                                buggy_ors.append(And(sv_expr, events_emitted_z3, Not(arg_verify_expr), *shared_cond))  

                else:
                    for evt in events:
                        buggy_ors.append(Bool(f"{evt}#emitted") == False)
                        
                
                buggy_z3 = Or(*buggy_ors)
            elif isinstance(vop, OrderVerify):
                if isinstance(vop.target, EventEmitRecordSelector):
                    self._record_emit_arg = True
                    self._record_emit = True
                elif isinstance(vop.target, WrittenRecordSelector):
                    self._record_sv_write = True
                    self._record_sv_write_cnt = True
                    self._record_sv_written_key = True
                    anchor_fn = get_the_function(fn.contract.compilation_unit, fn.contract.name, fname=vop.target.sv.anchor_fn)
                    sv = get_anchored_state_variable(anchor_fn)
                    if sv:
                        init_exec.sv_written_should_be_tracked.add(sv)
                        init_exec.sv_written_key_should_be_tracked[sv].add(vop.target.arg_idx)

                        self.logger.debug(f"added {sv.name} and key at {vop.target.arg_idx} to be tracked for written")
                    else:
                        raise StateVarAnchorFnNotFound(vop.sv_cond.value.anchor_fn, fn.contract.name)
                

                
            elif isinstance(vop, StateAssignVerify):
                self._record_sv_write = True
                if vop.event is not None:
                    self._record_emit = True
                    self._record_emit_arg = True
                    # fixme: check vop to get more accurate information(which event arg is used)
                    init_exec.event_emitted_arg_should_be_tracked[vop.event] = {0,1,2}
                    
            else:
                raise Exception(f"not yet supported: {vop}")

        if self._llm:
            # if _llm flag is on, when directly put generated constraints
            # and contract into the prompt
            return audit_by_llm_sliced(self._contract_path, to_exec[0], buggy_z3, function_name, self.cu)
        self.execs.extend(to_exec)
        exec_id += (len(to_exec) - 1)
        while to_exec:
            selected_exec = to_exec.pop()
            try:
                nexts = self.exec(selected_exec)

                if selected_exec.stop_if_unsat and selected_exec.solver.check(*selected_exec.stop_if_unsat) == unsat:
                    selected_exec.exec_state = ExecutionState.Unsat
                    continue

                to_add = []
                if len(nexts) == 0:
                    selected_exec.exec_state = ExecutionState.Finished
                    selected_exec.solver.add(Bool("#throwed") == False)
                elif len(nexts) == 1:
                    selected_exec.curr_node = nexts[0][0]
                    selected_exec.curr_ir_offset = nexts[0][1]
                    throwed = nexts[0][3]
                    
                    if throwed:
                        selected_exec.exec_state = ExecutionState.Throwed
                        selected_exec.solver.add(Bool("#throwed") == True)
                    elif selected_exec.curr_node is None:
                        selected_exec.exec_state = ExecutionState.Finished

                        selected_exec.solver.add(Bool("#throwed") == False)
                    else:
                        to_add.append(selected_exec)
                else:
                    forked_execs = []
                    for i, next in enumerate(nexts):
                        if i == 0:
                            curr_exec = selected_exec
                        else:
                            exec_id += 1
                            curr_exec = selected_exec.fork(exec_id)
                            self.logger.debug(f"forked {curr_exec.id}")                            
                            self.execs.append(curr_exec)
                        forked_execs.append(curr_exec)
                    
                    for next, curr_exec in zip(nexts, forked_execs):
                        
                        [next_node, next_ir_offset, next_constraints, throwed] = next
                        if throwed:
                            curr_exec.solver.append(*next_constraints)
                            curr_exec.exec_state = ExecutionState.Throwed
                            curr_exec.solver.append(Bool("#throwed") == True)
                        else:
                            curr_exec.solver.append(*next_constraints)
                            possible = curr_exec.solver.check(*curr_exec.stop_if_unsat)
                            if possible != sat:
                                self.logger.debug(f"unsat path constraint: [{curr_exec.id}]")
                                self.logger.debug(curr_exec.solver)
                                curr_exec.exec_state = ExecutionState.Unsat
                            else:
                                curr_exec.curr_node = next_node
                                curr_exec.curr_ir_offset = next_ir_offset
                                to_add.append(curr_exec)
                to_exec.extend(to_add)
            except Exception as ex:
                # self.logger.error(f"Error: {ex}", exc_info=True)
                selected_exec.sym_error = str(ex)
                selected_exec.exec_state = ExecutionState.SymError
            
        
        self.print_exec_summary(fn)
        # finished the execution, check the verification operation
        
        # before checking the verification, mark some default variables
        if isinstance(vop, EmitVerify):
            for exec in self.execs:
                if exec.exec_state != ExecutionState.Finished:
                    continue
                for sv in exec.sv_written_should_be_tracked:
                    if sv not in exec.sv_written:
                        sv_write_z3bool = Bool(f"{sv.name}#written")
                        exec.solver.add(sv_write_z3bool == False)
                    
                    if self._record_sv_write_cnt:
                        sv_write_cnt_z3int = Int(f"{sv.name}#writtencnt")
                        exec.solver.add(sv_write_cnt_z3int == exec.sv_written_cnt[sv])
                    
                    post_exec_arr = create_z3var_for_sol_type(sv.type, f"{sv.name}#postexec")
                    exec.solver.add(post_exec_arr == exec.var2symbol[sv])
                        
                if vop.event not in exec.event_emitted:
                    exec.solver.add(Bool(f"{vop.event}#emitted") == False)
        elif isinstance(vop, ThrowVerify):
            for exec in self.execs:
                if exec.exec_state != ExecutionState.Finished:
                    continue
                for track_ret in exec.retofcall_should_be_tracked:
                    if track_ret not in [cf.name for cf in exec.called_functions]:
                        exec.solver.add(Bool(f"{track_ret}#called") == False)
                for constraint in exec._add_to_solver_if_not_throwed:
                    exec.solver.add(constraint)
                
                if exec.solver.check(*exec.stop_if_unsat) == unsat:
                    exec.exec_state = ExecutionState.Unsat
                
        elif isinstance(vop, CallVerify):
            for exec in self.execs:
                if exec.exec_state != ExecutionState.Finished:
                    continue
                called_fn_names = set([cf.name for cf in exec.called_functions])
                if vop.callee not in called_fn_names:
                    exec.solver.add(Bool(f"p{vop.on.index}.{vop.callee}#called") == False)
                if vop.alternative_callees:
                    for cl in vop.alternative_callees:
                        if cl not in called_fn_names:
                            exec.solver.add(Bool(f"p{vop.on.index}.{cl}#called") == False)
                for constraint in exec._add_to_solver_if_not_throwed:
                    exec.solver.add(constraint)
        
        elif isinstance(vop, StateAssignVerify):
            for exec in self.execs:
                if exec.exec_state != ExecutionState.Finished:
                    continue
                if vop.event not in exec.event_emitted:
                    exec.solver.add(Bool(f"{vop.event}#emitted") == False)
            
                

        # Start checking buggy
        self.logger.debug(f"buggy z3: {buggy_z3}")
        if isinstance(vop, ThrowVerify):
            
            for exec in self.execs:
                if exec.exec_state == ExecutionState.SymError:
                    continue
                if exec.exec_state == ExecutionState.Unsat:
                    continue
                if exec.exec_state == ExecutionState.Executing:
                    continue
                if vop.op == "throw":
                    if exec.exec_state == ExecutionState.Finished:
                        if buggy_z3 is not None:
                            if exec.solver.check(buggy_z3) == sat:
                                self.logger.debug(f"{exec.id} finished but expected to throw")
                                self.logger.debug(exec.solver)
                                return False
                        else:
                            if exec.solver.check(*exec.stop_if_unsat) == sat:
                                self.logger.debug(f"{exec.id} finished but expected to throw, stop if unsat={exec.stop_if_unsat}")
                                self.logger.debug(f"called functions={[f.name for f in exec.called_functions]}")
                                self.logger.debug(f"retofcall_should_be_tracked = {exec.retofcall_should_be_tracked}")
                                self.logger.debug(exec.solver)
                                self.logger.debug(exec.solver.model())
                                return False
                            
                else:
                    # what we tryin to verify is not throw under certain condition
                    if exec.exec_state == ExecutionState.Throwed:
                        if exec.solver.check(*exec.stop_if_unsat) == sat:
                            if not exec.solver.check(*[Not(e) for e  in exec.stop_if_unsat]) == sat:
                                self.logger.debug(f"{exec.id} throwed but expect not to due to {exec.stop_if_unsat}")
                                
                                self.logger.debug(exec.solver)
                                self.logger.debug("\n".join(str(constraint) for constraint in exec.solver.assertions()))
                                self.logger.debug(exec.solver.model())
                                return False
            
            if not any([exec.exec_state == ExecutionState.Finished for exec in self.execs]) and vop.op == "not_throw":
                return False
        elif isinstance(vop, StateAssignVerify):
            for exec in self.execs:
                if exec.exec_state == ExecutionState.SymError:
                    continue
                if exec.exec_state == ExecutionState.Unsat or exec.exec_state == ExecutionState.Throwed:
                    continue
                state_var = get_var_from_selector(vop.state, fn, exec, event=vop.event)
                value = get_var_from_selector(vop.value, fn, exec, event=vop.event)
                buggy_and = []
                if vop.op == "overwrite":
                    buggy_and.append(state_var != value)
                
                if vop.event:
                    buggy_and.append(Bool(f"{vop.event}#emitted") == True)
                if exec.solver.check(And(*buggy_and)) == sat:
                    self.logger.debug(f"exec id={exec.id}, solver={exec.solver}")
                    return False
        elif isinstance(vop, EmitVerify):
            for exec in self.execs:
                if exec.exec_state != ExecutionState.Finished:
                    continue
                
                if vop.within_call_fn:
                    if vop.within_call_fn not in [cf.name for cf in exec.called_functions]:
                        continue
                if exec.solver.check(buggy_z3) == sat:
                    self.logger.debug(f"expect {exec.id} to emit '{vop.event}' but no")
                    self.logger.debug(f"called functions={[f.name for f in exec.called_functions]}")
                    self.logger.debug(exec.solver)
                    self.logger.debug(exec.solver.model())
                    return False
                self.logger.debug(exec.solver)
                
        elif isinstance(vop, CallVerify):
            if not self.execs:
                return True

            for exec in self.execs:
                if exec.exec_state != ExecutionState.Finished:
                    continue
                
                if exec.solver.check(buggy_z3) == sat:
                    self.logger.debug(f"exec id={exec.id}")
                    self.logger.debug([f.name for f in exec.called_functions])
                    self.logger.debug(exec.solver)
                    
                    return False
        elif isinstance(vop, ReturnVerify):
            
            if not self.execs:
                return False
            
            at_least_one_sat = False
            for exec in self.execs: 
                if exec.exec_state != ExecutionState.Finished:
                    continue
                # make sure return is the same as the expected
                if exec.return_value is not None:
                    if exec.return_value != vop.ret_val.value:
                        self.logger.debug(f"expected={vop.ret_val.value}, but got={exec.return_value}")
                        if vop.at_least_one:
                            continue
                        else:
                            return False
                elif exec.return_z3 is not None:
                    if exec.solver.check(exec.return_z3 == vop.ret_val.value) == unsat:
                        self.logger.debug(f"expected={vop.ret_val.value}, but got={exec.return_value}")
                        if vop.at_least_one:
                            continue
                        else:
                            return False
                else:
                    self.logger.debug(f"expected={vop.ret_val.value}, but got=None")

                    if vop.at_least_one:
                        # since we expect the return something but function does not return anything
                        continue
                    else:
                        return False
                    
                at_least_one_sat = True
            
            if vop.at_least_one and not at_least_one_sat:
                return False
        elif isinstance(vop, OrderVerify):
            for exec in self.execs:
                if exec.exec_state == ExecutionState.SymError:
                    continue
                if exec.exec_state == ExecutionState.Unsat or exec.exec_state == ExecutionState.Throwed:
                    continue
                
                if isinstance(vop.target, EventEmitRecordSelector):
                    # check if the event is emitted
                    if vop.target.event not in exec.event_emitted:
                        logger.debug(f"exec id={exec.id} did not emit {vop.target.event}, skip")
                        continue
                    
                    # if event emitted, check the order
                    emitted_cnt = exec.event_emitted_cnt[vop.target.event]
                    if emitted_cnt == 1:
                        # no order to check
                        logger.debug(f"exec id={exec.id} emitted only one {vop.target.event}, skip")
                        continue
                    
                    evt_decl = [e for e in fn.contract.events if e.name == vop.target.event][0]
                    target_arg_type = evt_decl.elems[vop.target.arg_idx].type
                    order_buggy = []
                    
                    # this is a z3 variable which type is array
                    ordered_by = get_var_from_selector(vop.ordered_by, fn, exec)
                    for i in range(1, emitted_cnt+1):
                        emitted_arg = create_z3var_for_sol_type(target_arg_type, f"{vop.target.event}#{i}#{vop.target.arg_idx}")
                        order_buggy.append(emitted_arg != Select(ordered_by, i))
                    
                    buggy_z3 = Or(*order_buggy)
                    self.logger.debug(f"order buggy z3: {buggy_z3}")
                    if exec.solver.check(buggy_z3) == sat:
                        self.logger.debug(f"exec id={exec.id}, solver={exec.solver}")
                        return False
                        
                elif isinstance(vop.target, WrittenRecordSelector):
                    sv_z3 = get_var_from_selector(vop.target.sv, fn, exec)
                    anchor_fn = get_the_function(fn.contract.compilation_unit, fn.contract.name, fname=vop.target.sv.anchor_fn)

                    sv = get_anchored_state_variable(anchor_fn)

                    if sv not in exec.sv_written:
                        self.logger.debug(f"exec id={exec.id} did not write {sv.name}, skip")
                        continue
                    

                    if exec.sv_written_cnt[sv] == 1:
                        self.logger.debug(f"exec id={exec.id} written only one {sv.name}, skip")
                        continue
                    

                    # this is a z3 variable which type is array
                    ordered_by = get_var_from_selector(vop.ordered_by, fn, exec)
                    ordered_by_length_z3 = Int(f"{ordered_by}.length")
                    exec.solver.check()
                    model = exec.solver.model()
                    ordered_by_length = model.eval(ordered_by_length_z3)
                    ordered_by_length = ordered_by_length.as_long()
                    if ordered_by_length is None:
                        raise Exception(f"cannot get accurate length of {ordered_by} in model")
                    self.logger.debug(f"ordered_by_length={ordered_by_length}")
                    
                    types = []
                    
                    curr_type = sv.type
                    while isinstance(curr_type, MappingType):
                        types.append(curr_type.type_from)
                        curr_type = curr_type.type_to
                    
                    types.append(curr_type)
                    target_arg_type = types[vop.target.arg_idx]
                    self.logger.debug(f"target_arg_type={target_arg_type}")
                    for i in range(ordered_by_length):
                        # if the state variable is written, the value should be in the ordered_by array
                        # FIXME: not perfect solution. (i+1)*2 means we assume that the state variable (when key is target) is written twice per loop
                        # What we actually need is written of the state variable reference by target[1] cannot happen before written of the state variable reference by target[0]
                        sv_arg_z3 = create_z3var_for_sol_type(target_arg_type, f"{sv.name}#{(i+1)*2}#{vop.target.arg_idx}")
                        written_expect_arg = Select(ordered_by, i)
                        self.logger.debug(f"sv_arg_z3={sv_arg_z3}, type={type(sv_arg_z3)}, written_expect_arg={written_expect_arg}, type={type(written_expect_arg)}")
                        order_buggy = sv_arg_z3 != written_expect_arg
                        self.logger.debug(f"order_buggy={order_buggy}")
                        if exec.solver.check(order_buggy) == sat:
                            self.logger.debug(f"exec id={exec.id}, buggy sat={order_buggy} solver={exec.solver}")
                            return False 
                else:
                    raise Exception(f"not yet supported: {vop.target}")
        else:
            raise Exception(f"not yet supported: {vop}")
        return True
        
    def _handle_var_used_in_throw(self, exec: Execution, var):
        self.logger.debug(f"record var used in throw: {var}")
        
        explored = set()
        to_explore = [var]
        while to_explore:
            curr = to_explore.pop()
            if curr in explored:
                continue
            explored.add(curr)
            if curr in exec.vars_def_by:
                for part in exec.vars_def_by[curr]:
                    to_explore.append(part)
            if curr in exec.vars_alias:
                for alias in exec.vars_alias[curr]:
                    to_explore.append(alias)
            used_in_throw_mark = create_z3var_used_in_throw(curr)
            exec.solver.add(used_in_throw_mark == True)
            exec.vars_used_in_throw.add(curr)
    
    def _handle_var_used_in_if(self, exec: Execution, var):       
        explored = set()
        to_explore = [var]
        while to_explore:
            curr = to_explore.pop()
            if curr in explored:
                continue
            explored.add(curr)
            if curr in exec.vars_def_by:
                for part in exec.vars_def_by[curr]:
                    to_explore.append(part)
            if curr in exec.vars_alias:
                for alias in exec.vars_alias[curr]:
                    to_explore.append(alias)
            used_in_throw_mark = create_z3var_used_in_throw(curr)
            exec.solver.add(used_in_throw_mark == True)
            exec.vars_used_in_if.add(curr)

    def exec(self, exec: Execution) -> List[Tuple[Node, int, List, bool]]:
        self.logger.debug(f"[node] {exec.curr_node} line {exec.curr_node.source_mapping.lines}")
        for ir in exec.curr_node.irs:
            self.logger.debug(f"\t[ir] {ir}")
        if exec.curr_node.type == NodeType.THROW:
            return [(None, None, None, True)]
        if exec.curr_node.type == NodeType.VARIABLE:
            new_var = exec.curr_node.variable_declaration
            exec.get_sym(new_var)
            if not exec.curr_node.irs:
                # no irs, just a variable declaration
                # which means, if type is elementary type, 
                # we need to initialize the defualt value
                if isinstance(new_var.type, ElementaryType):
                    if new_var.type.name.startswith("uint") or new_var.type.name.startswith("int"):
                        exec.solver.add(exec.var2symbol[new_var] == 0)
                
     
        for iroffset, i in enumerate(exec.curr_node.irs):
            if iroffset < exec.curr_ir_offset:
                continue

            self.logger.debug(f"[exec-ir][{exec.id}] {i} {type(i)}")
            if isinstance(i, SolidityCall):
                if i.function.name == "require(bool,string)" or i.function.name == "require(bool)":
                    # Assume that the first argument of the require function is the condition
                    condition = i.arguments[0]
                    if self._record_vars_used_in_throw:
                        self._handle_var_used_in_throw(exec, condition)
                    if condition not in exec.var2symbol:
                        self.logger.error(f"cannot find {condition}")
                        continue
                    expr = exec.var2symbol[condition]
                    # exec.solver.add(expr)
                    nexts = []
                    nexts.append((
                        exec.curr_node,
                        iroffset+1,
                        [expr],
                        False
                    ))

                    nexts.append((
                        exec.curr_node,
                        iroffset+1,
                        [Not(expr)],
                        True
                    ))
                    return nexts
                elif i.function.name == "assert(bool)":
                    condition = i.arguments[0]

                    if self._record_vars_used_in_throw:
                        self._handle_var_used_in_throw(exec, condition)
                    if condition not in exec.var2symbol:
                        self.logger.error(f"cannot find {condition}")
                        continue
                    expr = exec.var2symbol[condition]
                    exec.solver.add(expr)
                elif i.function.name == "code(address)":
                    # if self._record_code_length_vars:
                    #     exec.code_vars[i.arguments[0]] = i.lvalue
                    whose_code = i.arguments[0]
                    exec.get_sym(i.lvalue, f"{exec.get_sym(whose_code)}.code")
                elif i.function.name == "extcodehash(uint256)":
                    whose_code = i.arguments[0]
                    exec.get_sym(i.lvalue, f"{exec.get_sym(whose_code)}.codehash")
                elif i.function.name.startswith("revert("):
                    return [(None, None, None, True)]
                elif i.function.name.startswith("revert "):
                    return [(None, None, None, True)]
                elif i.function.name == "keccak256()":
                    # TODO: handle keccak256, this is calculatable in Python
                    # need to find crypto library that support this 
                    exec.get_sym(i.lvalue)
                elif i.function.name == "sha3()":
                    # TODO: similiar above
                    exec.get_sym(i.lvalue)
                elif i.function.name == "balance(address)":
                    exec.get_sym(i.lvalue)
                elif i.function.name == "mload(uint256)":
                    # FIXME: fix this later
                    exec.get_sym(i.lvalue)
                elif i.function.name == "mstore(uint256,uint256)":
                    pass
                elif i.function.name == "abi.encodePacked()": 
                    exec.get_sym(i.lvalue)
                else:
                    # self.logger.error(f"not yet supported: {i.function.name}")
                    pass
            elif isinstance(i, Assignment):
                if self._record_vars_def_by:
                    exec.vars_def_by[i.lvalue].add(i.rvalue)
                
                sv = None
                if self._record_sv_write:
                    if i.lvalue in exec.state_variables_ref:
                        sv = exec.state_variables_ref[i.lvalue]
                        if sv not in exec.sv_written:
                            sv_write_z3bool = Bool(f"{sv.name}#written")
                            exec.sv_written.add(sv)
                            exec.solver.add(sv_write_z3bool == True)
                        if self._record_sv_write_cnt:
                            exec.sv_written_cnt[sv] += 1
                        
                        
                    elif isinstance(i.lvalue, StateVariable):
                        sv_write_z3bool = Bool(f"{i.lvalue.name}#written")
                        if i.lvalue not in exec.sv_written:
                            exec.sv_written.add(i.lvalue)
                            exec.solver.add(sv_write_z3bool == True)
                        if self._record_sv_write_cnt:
                            exec.sv_written_cnt[i.lvalue] += 1
                    else:
                        exec.state_variables_ref[i.rvalue] = i.lvalue
                
                
                    
                expr = exec.var2symbol[i.rvalue] if i.rvalue in exec.var2symbol else exec.get_sym(i.rvalue)
                
                
                exec.vars_rw_cnt[i.lvalue] += 1
                if i.lvalue in exec.var2symbol:
                    del exec.var2symbol[i.lvalue]
                if i.lvalue in exec.indexed_track:
                    # if i.lvalue is reference for a memory(ex. mapping)
                    [orig, orig_arr, keyvar, key] = exec.indexed_track[i.lvalue]

                    updated_arr = Store(orig_arr, key, expr)

                    # update the current ir's destination variable(usually the reference)
                    exec.var2symbol[i.lvalue] = updated_arr[key]

                    # update the z3 variable of the array
                    subarr = updated_arr
                    curr = orig
                    reversed_keys = [key]
                    while curr in exec.indexed_track:
                        [orig, orig_arr, keyvar, key] = exec.indexed_track[curr]
                        reversed_keys.append(key)
                        subarr = Store(orig_arr, key, subarr)
                        curr = orig

                    
                    reversed_keys.reverse()
                    
                    if self._record_sv_written_key:
                        if sv:
                            written_cnt = exec.sv_written_cnt[sv]
                            for key_idx in exec.sv_written_key_should_be_tracked.get(sv, []):
                                self.logger.debug(f"record key at {key_idx} of {sv} cnt {written_cnt}")
                                if key_idx >= len(reversed_keys):
                                    self.logger.error(f"key index {key_idx} is out of range for {sv.name}")
                                    continue
                                # get the key at current index
                                key_expr = reversed_keys[key_idx]
                                self.logger.debug(f"record key at {key_idx} of {sv} cnt {written_cnt} written value is {key_expr}")
                                exec.solver.add(Int(f"{sv}#{written_cnt}#{key_idx}") == key_expr)
                        
                    sv = exec.state_variables_ref[i.lvalue]
                    self.logger.debug(f"update z3 of sv={sv} to {subarr}")
                    exec.var2symbol[sv] = subarr

                    
                else:
                    try:
                        exec.solver.add(exec.get_sym(i.lvalue, i.lvalue.name+f"_{exec.vars_rw_cnt[i.lvalue]}") == expr)
                    except Exception:
                        # FIXME: this is a workaround for the case that the variable is not properly defined in the solver
                        # self.logger.error(f"error: {ex}", exc_info=True)
                        self.logger.error(f"i.lvalue={i.lvalue}, expr={expr}")
                        exec.var2symbol[i.lvalue] = create_z3var_for_sol_type(i.lvalue.type, i.lvalue.name+f"_{exec.vars_rw_cnt[i.lvalue]}")
                    # exec.var2symbol[i.lvalue] = expr

                # if isinstance(i.lvalue.type, ElementaryType) and i.lvalue.type.type.startswith("uint"):
                #     exec.solver.add(exec.var2symbol[i.lvalue] >= 0)
            elif isinstance(i, TypeConversion):
                if self._record_vars_def_by:
                    exec.vars_def_by[i.lvalue].add(i.variable)
                if isinstance(i.variable, Constant):
                    value = i.variable.value
                    if isinstance(value, bool):
                        exec.var2symbol[i.lvalue] = Bool(i.lvalue.name)
                        exec.solver.add(exec.var2symbol[i.lvalue] == value)
                    elif isinstance(value, int):
                        exec.var2symbol[i.lvalue] = Int(i.lvalue.name)
                        exec.solver.add(exec.var2symbol[i.lvalue] == value)
                else:
                    exec.var2symbol[i.lvalue] = exec.var2symbol[i.variable]
            elif isinstance(i, InternalCall) or isinstance(i, LibraryCall):
                exec.called_functions.add(i.function)
                exec.stack.append((exec.curr_node, iroffset+1))
                next_node = i.function.entry_point

                # handle parameter passing
                for aid, arg in enumerate(i.arguments):
                    fparam = i.function.parameters[aid]
                    exec.vars_alias[fparam].add(arg)

                    callee_param = None
                    callee_param_sym = None
                    for var, sym in exec.var2symbol.items():
                        if arg == var:
                            callee_param = i.function.parameters[aid]
                            callee_param_sym = sym
                            break
                    # make sure the callee's param's z3 variable is the same as the argument passed in
                    if callee_param:
                        exec.var2symbol[callee_param] = callee_param_sym
                    else:
                        if isinstance(arg, Constant):
                            exec.var2symbol[fparam] = arg.value
                    
                    if self._record_vars_def_by:
                        exec.vars_def_by[fparam].add(arg)

                # handle return value
                if i.lvalue:
                    exec.get_sym(i.lvalue)
                    
                
                return [(next_node, 0, None, False)]         
            elif isinstance(i, Unary):
                if self._record_vars_def_by:
                    exec.vars_def_by[i.lvalue].add(i.rvalue)
                var = exec.get_sym(i.rvalue)
                expr = None
                if i.type == UnaryType.BANG:
                    expr = Not(var)
                elif i.type == UnaryType.TILD:
                    expr = ~var
                else:
                    # self.logger.error(f"not yet supported: {i}")
                    pass
                if expr is not None:
                    # exec.var2symbol[i.lvalue] = expr
                    exec.solver.add(exec.get_sym(i.lvalue) == expr)
                else:
                    exec.var2symbol[i.lvalue] = Bool(i.lvalue.name)
            elif isinstance(i, Length):
                # exec.var2symbol[i.lvalue] = Int(f"{i.value.name}.length")
                
                exec.get_sym(i.lvalue, f"{str(exec.get_sym(i.value))}.length")
                if self._record_vars_def_by:
                    exec.vars_def_by[i.lvalue].add(i.value)
            elif isinstance(i, EventCall):
                if self._record_emit:
                    emit_z3bool = Bool(f"{i.name}#emitted")
                    if i.name not in exec.event_emitted:
                        exec.solver.add(emit_z3bool == True)
                        exec.event_emitted.add(i.name)
                    exec.event_emitted_cnt[i.name] += 1
                    if self._record_emit_arg:
                        emit_cnt = exec.event_emitted_cnt[i.name]
                        if i.name in exec.event_emitted_arg_should_be_tracked:
                            for arg_idx in exec.event_emitted_arg_should_be_tracked[i.name]:
                                if arg_idx >= len(i.arguments):
                                    self.logger.error(f"arg index {arg_idx} is out of range for {i.name}")
                                    continue
                                arg = i.arguments[arg_idx]
                                record = create_z3var_for_sol_type(arg.type, f"{i.name}#{emit_cnt}#{arg_idx}")
                                exec.solver.add(record == exec.var2symbol[arg])
                                
                                if emit_cnt == 1:
                                    record = create_z3var_for_sol_type(arg.type, f"{i.name}#{arg_idx}")
                                    exec.solver.add(record == exec.var2symbol[arg])
                    
                    # if self._record_emit_arg_order:
                    #     if i.name in exec.event_emitted_arg_should_be_tracked:
                    #         for arg_idx in exec.event_emitted_arg_should_be_tracked[i.name]:
                    #             arg = i.arguments[arg_idx]
                    #             record = create_z3var_for_sol_type(arg.type, f"{i.name}#{emit_cnt}#{arg_idx}")
                    #             exec.solver.add(record == exec.step)
                        
            elif isinstance(i, Index):
                if self._record_vars_def_by:
                    exec.vars_def_by[i.lvalue].add(i.variable_right)
                    exec.vars_def_by[i.lvalue].add(i.variable_left)
                
                # find and record top level state variable
                if i.variable_left in exec.state_variables_ref:
                    exec.state_variables_ref[i.lvalue] = exec.state_variables_ref[i.variable_left]
                else:
                    exec.state_variables_ref[i.lvalue] = i.variable_left
                
                mapping_z3arr = exec.var2symbol[i.variable_left] if i.variable_left in exec.var2symbol else exec.get_sym(i.variable_left)
                key = exec.var2symbol[i.variable_right] if i.variable_right in exec.var2symbol else exec.get_sym(i.variable_right)
                exec.vars_rw_cnt[i.lvalue] += 1
                self.logger.debug(f"track index cnt {exec.id} {i.lvalue} {exec.vars_rw_cnt[i.lvalue]}")
                if i.lvalue in exec.var2symbol:
                    del exec.var2symbol[i.lvalue]
                lvalue_z3 = exec.get_sym(i.lvalue, i.lvalue.name+f"_{exec.vars_rw_cnt[i.lvalue]}")
                try:
                    exec.solver.add(lvalue_z3 == mapping_z3arr[key])
                except Exception:
                    # could have exception if mapping_z3arr is mapping(string => xxx), 
                    # supporting string key is TODO
                    pass
                exec.indexed_track[i.lvalue] = [i.variable_left, mapping_z3arr, i.variable_right, key]
                
                if isinstance(i.lvalue.type, ElementaryType) and i.lvalue.type.type.startswith("uint"):
                    exec.solver.add(lvalue_z3 >= 0)
                
                # find root of the array
                curr = i.variable_left
                ref_len = 1
                keys_z3 = [key]
                while curr in exec.indexed_track:
                    [orig, orig_arr, keyvar, key] = exec.indexed_track[curr]
                    curr = orig
                    keys_z3.append(key)
                    ref_len += 1

                mtypes = mapping_types_as_arr(curr.type)
                self.logger.debug(f"mtypes={[mt.type for mt in mtypes]}, ref_len={ref_len}, mapping={curr}")
                self.logger.debug(f"keys_z3={keys_z3}")
                # make sure this is the last level of the array
                if ref_len + 1 == len(mtypes):
                    if curr in exec.msg_sender_only_sv:
                        self.logger.debug(f"record msg.sender only sv: {curr}")
                        if isinstance(i.lvalue.type, ElementaryType):
                            if i.lvalue.type.type == "bool":
                                exec.solver.add(If(0 == keys_z3[-1], lvalue_z3 == False, True))
                            elif i.lvalue.type.type.startswith("uint"):
                                exec.solver.add(If(0 == keys_z3[-1], lvalue_z3 == 0, True))
                    elif curr.name == "_tokenApprovals":
                        exec.solver.add(lvalue_z3 != Int('msg.sender'))
                        
                    
            # Handle binary operations like comparisons
            elif isinstance(i, Binary):
                if self._record_vars_def_by:
                    exec.vars_def_by[i.lvalue].add(i.variable_left)
                    exec.vars_def_by[i.lvalue].add(i.variable_right)
                
                # Example: translating a binary operation into a Z3 constraint
                left = None
                right = None
                if i.variable_left not in exec.var2symbol:
                    for var, sym in exec.var2symbol.items():
                        if i.variable_left.name == var.name:
                            left = sym
                            break
                    if left is None:
                        if isinstance(i.variable_left, Constant):
                            value = i.variable_left.value
                            if isinstance(value, bool):
                                left = value
                            elif isinstance(value, int):
                                left = value
                    if left is None:
                        self.logger.error(f"cannot find {i.variable_left}")
                        continue
                else:
                    left = exec.var2symbol[i.variable_left]
                if i.variable_right not in exec.var2symbol:
                    for var, sym in exec.var2symbol.items():
                        if i.variable_right.name == var.name:
                            right = sym
                            break
                    if right is None:
                        if isinstance(i.variable_right, Constant):
                            value = i.variable_right.value
                            if isinstance(value, bool):
                                right = value
                            elif isinstance(value, int):
                                right = value
                    if right is None:
                        self.logger.error(f"cannot find {i.variable_right}")
                        continue
                else:
                    right = exec.var2symbol[i.variable_right]

                try:
                    # after we get the left and right in z3 repr, we can perform the operation
                    if i.type == BinaryType.EQUAL:
                        expr = left == right
                    elif i.type == BinaryType.LESS:
                        expr = left < right
                    elif i.type == BinaryType.GREATER:
                        expr = left > right
                    elif i.type == BinaryType.LESS_EQUAL:
                        expr = left <= right
                    elif i.type == BinaryType.GREATER_EQUAL:
                        expr = left >= right
                    elif i.type == BinaryType.NOT_EQUAL:
                        expr = left != right
                    elif i.type == BinaryType.ANDAND:
                        expr = And(left, right)
                    elif i.type == BinaryType.ADDITION:
                        expr = left + right
                    elif i.type == BinaryType.MULTIPLICATION:
                        expr = left * right
                    elif i.type == BinaryType.SUBTRACTION:
                        expr = left - right
                    elif i.type == BinaryType.DIVISION:
                        expr = left / right
                    elif i.type == BinaryType.AND:
                        expr = left & right
                    elif i.type == BinaryType.MODULO:
                        expr = left % right
                    elif i.type == BinaryType.POWER:
                        expr = left ** right
                    elif i.type == BinaryType.OROR:
                        expr = Or(left, right)
                    else:
                        self.logger.error(f"does not handle {i} type={i.type}")
                        continue  # Skip if operation type is not handled
                except Exception:
                    # self.logger.error(f"error: {ex}", exc_info=True)
                    expr = create_z3var_for_sol_type(i.lvalue.type, i.lvalue.name)

                
                exec.vars_rw_cnt[i.lvalue] += 1
                if i.lvalue in exec.indexed_track:
                    [orig, orig_arr, keyvar, key] = exec.indexed_track[i.lvalue]

                    try:
                        exec.var2symbol[i.lvalue] = Store(orig_arr, key, expr)[key]

                        if i.type_str.find("(c)") != -1:
                            exec.solver.add(exec.var2symbol[i.lvalue] >= 0)
                    except Exception:
                        # self.logger.error(f"orig_arr={orig_arr}, key={key}, expr={expr}.\nerror: {ex}", exc_info=True)
                        exec.var2symbol[i.lvalue] = create_z3var_for_sol_type(i.lvalue.type, i.lvalue.name)

                else:
                    # exec.var2symbol[i.lvalue] = expr
                    # exec.solver.add(exec.get_sym(i.lvalue) == expr)
                    dest_sym = exec.get_sym(i.lvalue, i.lvalue.name+f"_{exec.vars_rw_cnt[i.lvalue]}")
                    exec.solver.add(dest_sym == expr)
                
                    if i.type_str.find("(c)") != -1:
                        exec.solver.add(dest_sym >= 0)


                if self._record_sv_write:
                    if i.lvalue in exec.state_variables_ref:
                        sv = exec.state_variables_ref[i.lvalue]
                        if sv not in exec.sv_written:
                            sv_write_z3bool = Bool(f"{sv.name}#written")
                            exec.sv_written.add(sv)
                            exec.solver.add(sv_write_z3bool == True)
                        if self._record_sv_write_cnt:
                            exec.sv_written_cnt[sv] += 1
                    elif isinstance(i.lvalue, StateVariable):
                        if i.lvalue not in exec.sv_written:
                            sv_write_z3bool = Bool(f"{i.lvalue.name}#written")
                            exec.sv_written.add(i.lvalue)
                            exec.solver.add(sv_write_z3bool == True)
                        if self._record_sv_write_cnt:
                            exec.sv_written_cnt[i.lvalue] += 1
                
                if i.lvalue in exec.indexed_track:
                    # if i.lvalue is reference for a memory(ex. mapping)
                    [orig, orig_arr, keyvar, key] = exec.indexed_track[i.lvalue]

                    try:
                        updated_arr = Store(orig_arr, key, expr)
                         # update the current ir's destination variable(usually the reference)
                        exec.var2symbol[i.lvalue] = updated_arr[key]

                        # update the z3 variable of the array
                        subarr = updated_arr
                        curr = orig
                        reversed_keys = [key]
                        while curr in exec.indexed_track:
                            [orig, orig_arr, keyvar, key] = exec.indexed_track[curr]
                            reversed_keys.append(key)
                            subarr = Store(orig_arr, key, subarr)
                            curr = orig
                        reversed_keys.reverse()
                        
                        if self._record_sv_written_key:
                            if sv:

                                written_cnt = exec.sv_written_cnt[sv]
                                for key_idx in exec.sv_written_key_should_be_tracked.get(sv, []):
                                    if key_idx >= len(reversed_keys):
                                        self.logger.error(f"key index {key_idx} is out of range for {sv.name}")
                                        continue
                                    # get the key at current index
                                    key_expr = reversed_keys[key_idx]
                                    self.logger.debug(f"record key at {key_idx} of {sv} cnt {written_cnt} written value is {key_expr}")
                                    exec.solver.add(Int(f"{sv}#{written_cnt}#{key_idx}") == key_expr)
                            
                        sv = exec.state_variables_ref[i.lvalue]
                        self.logger.debug(f"update z3 of sv={sv} to {subarr}")
                        exec.var2symbol[sv] = subarr
                    except Exception:
                        # self.logger.error(f"orig_arr={orig_arr}, key={key}, expr={expr}.\nerror: {ex}", exc_info=True)
                        exec.var2symbol[i.lvalue] = create_z3var_for_sol_type(i.lvalue.type, i.lvalue.name)
            elif isinstance(i, Delete):
                if i.variable in exec.indexed_track:
                    [orig, orig_arr, keyvar, key] = exec.indexed_track[i.variable]
                    exec.var2symbol[i.lvalue] = Store(orig_arr, key, 0)
                if self._record_sv_write:
                    if i.variable in exec.state_variables_ref:
                        sv = exec.state_variables_ref[i.variable]
                        if sv not in exec.sv_written:
                            sv_write_z3bool = Bool(f"{sv.name}#written")
                            exec.sv_written.add(sv)
                            exec.solver.add(sv_write_z3bool == True)
                        if self._record_sv_write_cnt:
                            exec.sv_written_cnt[sv] += 1
            elif isinstance(i, NewElementaryType):
                if i.type.name == "string":
                    # exec.var2symbol[i.lvalue] = String(i.lvalue.name)
                    # FIXME: support string(mstore, ptr calculation, length, etc..) is not a simple task, since
                    # it does not effect the erc compliance check, do it later
                    exec.var2symbol[i.lvalue] = Int(i.lvalue.name)
                else:
                    # self.logger.error(f"not yet supported: {i}")
                    pass
            elif isinstance(i, LowLevelCall):
                # treat it as black box
                exec.get_sym(i.lvalue)
            elif isinstance(i, Return):
                ret_val = None
                ret_tuple = None
                if i.values:
                    if len(i.values) == 1:
                        ret_val = i.values[0]
                    else:
                        ret_tuple = i.values
                if ret_val:
                    if not exec.stack:
                        if isinstance(ret_val, Constant):
                            exec.return_value = ret_val.value
                        else:
                            z3var = exec.get_sym(ret_val)
                            exec.return_z3 = z3var
                    else:
                        callsite, offset = exec.stack[-1]
                        ret_var = callsite.irs[offset-1].lvalue
                        if isinstance(ret_val, Constant):
                            # print("add solver(c)", ret_var, ret_val.value)
                            exec.var2symbol[ret_var] = ret_val.value
                           # exec.solver.add( exec.var2symbol[ret_var] == ret_val.value)
                        else:
                            # print("add solver", ret_var,  exec.var2symbol[ret_val])
                            exec.var2symbol[ret_var] = exec.var2symbol[ret_val]
                            if self._record_vars_def_by:
                                exec.vars_def_by[ret_var].add(ret_val)
                            # exec.solver.add( exec.var2symbol[ret_var] == exec.var2symbol[ret_val])
                elif ret_tuple:
                    if not exec.stack:
                        exec.return_z3 = [exec.get_sym(ir_var) for ir_var in ret_tuple]
                    else:
                        callsite, offset = exec.stack[-1]
                        ret_var = callsite.irs[offset-1].lvalue
                        exec.var2symbol[ret_var] = [exec.var2symbol[ir_var] for ir_var in ret_tuple]
                        logger.debug(f"return tuple: {ret_var} = {exec.var2symbol[ret_var]}")
            elif isinstance(i, Unpack):
                logger.debug(f"unpack: {i.tuple} index={i.index} to {i.lvalue}")
                exec.var2symbol[i.lvalue] = exec.var2symbol[i.tuple][i.index]
            elif isinstance(i, HighLevelCall):
                # print("high level call", i, i.function.name, i.destination, exec.var2symbol[i.destination])
                
                z3sym = exec.var2symbol[i.destination]
                exec.solver.add(Bool(f"{z3sym}.{i.function.name}#called") == True)
                exec._add_to_solver_if_not_throwed.append(Int(f"{z3sym}.code.length") > 0)
                # since this is an contract, which is impossible to be msg.sender
                exec._add_to_solver_if_not_throwed.append(Int(f"{z3sym}") != Int('msg.sender'))
                exec.called_functions.add(i.function)
                # if i.destination in exec.vars_def_by:
                    
                #     toppest = []
                #     to_explore = [i.destination]
                #     explored = set()
                #     while to_explore:
                #         curr = to_explore.pop()
                #         if curr in explored:
                #             continue
                #         explored.add(curr)
                #         if curr in exec.vars_def_by:
                #             for part in exec.vars_def_by[curr]:
                #                 to_explore.append(part)
                #         else:
                #             toppest.append(curr)
                #     for t in toppest:
                #         print("toppest",t)
                        # exec.solver.add(Bool(f"{defby}.{defby.name}#called") == True)
                # Since we have no way to get the actual code, 
                # simply create a z3 symbol for the return
                if i.lvalue:
                    exec.get_sym(i.lvalue)
                
                if i.function.name in exec.retofcall_should_be_tracked:
                    if i.lvalue:
                        exec.solver.add(Int(f"{i.function.name}#ret") == exec.var2symbol[i.lvalue])
                    else:
                        self.logger.error(f"return value of {i.function.name} should be tracked but it does not have a return value")
            elif isinstance(i, Member):
                # Usually, the ERC related verification does not need to handle Member
                # However, if usecases are extended, then Member need to be handled
                # FIXME: handle Member
                exec.get_sym(i.lvalue)
            elif isinstance(i, Condition):
                # will be handled at curr_node.sons if-block
                pass
            elif isinstance(i, Transfer):
                # ether transfer does not need to be handled in auditing ERC
                pass
            elif isinstance(i, Send):
                # ether send does not need to be handled in auditing ERC
                pass
            elif isinstance(i, NewArray):
                # self.logger.debug(f"new array: {i}, {[f"{arg.name} type={type(arg)}" for arg in i.arguments]}")
                arr_len = None
                if len(i.arguments) > 0:
                    arr_len = exec.get_sym(i.arguments[0])
                
                exec.get_sym(i.lvalue, arr_len=arr_len)
            elif isinstance(i, InitArray):
                self.logger.debug(f"init array: {i}, init_values={i.init_values}")
                # FIXME: not sure init_values is the right way to get the array values
                # Ex. init array: path(address[]) = ['TMP_156(address[])']
                exec.var2symbol[i.lvalue] = exec.var2symbol[i.init_values[0]]
            elif isinstance(i, CodeSize):
                exec.get_sym(i.lvalue, f"{str(exec.get_sym(i.value))}.code.length")
            else:
                # self.logger.error(f"not yet supported: {i} type={type(i)}")
                pass
            
            # self.logger.debug("debug", exec.solver, exec.solver.check())
        exec.step += 1
        if len(exec.curr_node.sons) > 1:
            
            for son in exec.curr_node.sons:
                self.logger.debug(f"son true={exec.curr_node.son_true==son} {son} {son.source_mapping.lines}")
            
            next_node_and_constraints = []
            last_ir = exec.curr_node.irs[-1]
            
            if not isinstance(last_ir, Condition):
                self.logger.debug("probably try-catch block")
                for son in exec.curr_node.sons:
                    if len(exec.curr_node.sons) >= 3 and son.type == NodeType.ENDIF:
                        continue
                    next_node_and_constraints.append((
                        son,
                        0,
                        [],
                        False
                    ))
                return next_node_and_constraints

            #assert(isinstance(last_ir, Condition))
            # exec.path_conditions.append(last_ir)
            
            if self._record_vars_used_in_if:
                self._handle_var_used_in_if(exec, last_ir.value)
            
            # we need to sure whehter the condition will lead to throw or not
            # simply go through the sons see wether irs contains throw
            is_throw_cond = any([node.type == NodeType.THROW or any([isinstance(ir, SolidityCall) and (ir.function.name == "require(bool,string)" or ir.function.name == "require(bool)") for ir in node.irs]) for node in exec.curr_node.sons])

            # count if-block that can lead to throw as well
            if self._record_vars_used_in_throw:
                if is_throw_cond:
                    self._handle_var_used_in_throw(exec, last_ir.value)
            
            if isinstance(last_ir.value, Constant):
                cond_sym = last_ir.value.value
            else:
                cond_sym = exec.var2symbol[last_ir.value]
            # cond_sym = exec.get_sym(last_ir.value)
            skip_son_true = False
            if exec.curr_node.type == NodeType.IFLOOP:
                exec.loop_exec_cnt[exec.curr_node] += 1
                if exec.loop_exec_cnt[exec.curr_node] > 2:
                    self.logger.debug(f"loop {exec.curr_node} executed more than 2 times, skip son_true")
                    skip_son_true = True
            
            # son true in loop means the loop will continue
            if exec.curr_node.son_true and not skip_son_true:
                next_node_and_constraints.append((
                    exec.curr_node.son_true,
                    0,
                    [cond_sym],
                    False
                ))
            
            # son false in loop means the go out of the loop
            if exec.curr_node.son_false:
                next_node_and_constraints.append((
                    exec.curr_node.son_false,
                    0,
                    [Not(cond_sym)],
                    False
                ))
            return next_node_and_constraints
        else:
            next_node = exec.curr_node.sons[0] if len(exec.curr_node.sons) == 1 else None
            if next_node is None:
                if exec.stack:
                    callsite, iroffset = exec.stack.pop()
                    return [(callsite, iroffset,  None, False)]
            return [(next_node, 0,  None, False)]
        

def audit_by_llm(contract_path:str, to_exec: Execution, buggy:list, entryfunction:str) -> bool:
    import openai
    init_constraints_str = str(to_exec.solver)
    buggy_str = str(buggy)
    with open(contract_path, "r") as f:
        code = f.read()
    try:
        logger.info(f"audit [{contract_path}] by {init_constraints_str} {buggy_str}")
        prompt = f"""
        Audit the following code with the initial z3 constraints and buggy constraints.
        Verify whether the code is violated the buggy constraints if the entrypoint is the function {entryfunction}
        Initial Z3 Constraints:\"\"\"{init_constraints_str}\"\"\"
        Buggy Constraints:\"\"\"{buggy_str}\"\"\"
        Code:\"\"\"{code}\"\"\"
        Return in YES if violated, NO otherwise
        """
        client = openai.OpenAI()
        res = client.chat.completions.create(
            messages=[
                {
                    "content":prompt,
                    "role":"user"
                }
            ],
            model="gpt-4.1-mini",
            temperature=0
        )
        logger.info("result: %s", res)
        if res.choices[0].message.content.strip().find("YES") != -1:
            return False
        else:
            return True
    except Exception as e:
        logger.error(f"failed to audit [{contract_path}]: {e}")
        return True


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
def audit_by_llm_sliced(contract_path:str, to_exec: Execution, buggy:list, entryfunction:str, cu) -> bool:
    import openai
    from sol.metadata import get_contract_metadata
    from sol.utils import get_contracts_and_ercs
    init_constraints_str = str(to_exec.solver)
    buggy_str = str(buggy)
    c2ercs = get_contracts_and_ercs(cu, cname2ercs=cname2ercs)
    c, ercs = list(c2ercs.items())[0]

    with open(contract_path, "r") as f:
        clines = f.read().splitlines(True)
    cmeta = get_contract_metadata(c, ercs, clines)
    logger.info(f"Contract {c.name} at {contract_path}, entrypoint: {entryfunction}")
    code = None
    for key, value in cmeta.func2str.items():
        if key.startswith(entryfunction+"("):
            code = value
            break
    if code is None:
        logger.error(f"Cannot find entry function {entryfunction} in {contract_path}")
        return True
    try:
        logger.info(f"audit [{contract_path}] by {init_constraints_str} {buggy_str}")
        prompt = f"""
        Audit the following code with the initial z3 constraints and buggy constraints.
        Verify whether the code is violated the buggy constraints if the entrypoint is the function {entryfunction}
        Initial Z3 Constraints:\"\"\"{init_constraints_str}\"\"\"
        Buggy Constraints:\"\"\"{buggy_str}\"\"\"
        Code:\"\"\"{code}\"\"\"
        Return in YES if violated, NO otherwise
        """
        client = openai.OpenAI()
        res = client.chat.completions.create(
            messages=[
                {
                    "content":prompt,
                    "role":"user"
                }
            ],
            model="gpt-5"
        )
        logger.info("result: %s", res)
        if res.choices[0].message.content.strip().find("YES") != -1:
            return False
        else:
            return True
    except Exception as e:
        logger.error(f"failed to audit [{contract_path}]: {e}")
        return True