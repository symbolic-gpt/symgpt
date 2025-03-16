from dataclasses import asdict, dataclass, fields
import os
from typing import Dict, List, Tuple, TypedDict
import json
import logging
from erc.types import Erc
from sol.metadata import ContractMetadata, get_contract_metadata
from sol.utils import get_contracts_and_ercs, compile
from slither.core.slither_core import SlitherCompilationUnit
logger = logging.getLogger(__name__)



@dataclass
class SolMetadata:
    solc_ver: str
    contracts: List[ContractMetadata]

@dataclass
class SolAuditContext:
    sol_file_or_dir:str
    metadata: SolMetadata
    
    @staticmethod
    def serialize(obj):
        # Serialize a dataclass to JSON
        return json.dumps(obj, 
                          indent=4,
                          default=lambda o: asdict(o) if isinstance(o, SolAuditContext) or isinstance(o, SolMetadata) or isinstance(o, ContractMetadata) else o)

    @staticmethod
    def deserialize(data:str):
        # Deserialize JSON back to a dataclass
        json_data = json.loads(data)

        def _deserialize_field(cls, field_name, value):
            field_type = next(f for f in fields(cls) if f.name == field_name).type
            if field_type == List[ContractMetadata]:
                return [ContractMetadata(**contract) for contract in value]
            return value

        sol_metadata = SolMetadata(solc_ver=json_data['metadata']['solc_ver'],
                                contracts=[ContractMetadata(**contract) for contract in json_data['metadata']['contracts']])
        sol_audit_context = SolAuditContext(sol_file_or_dir=json_data['sol_file_or_dir'],
                                            metadata=sol_metadata)
        return sol_audit_context


@dataclass
class SolContractERCAuditReport:
    contract: ContractMetadata
    erc: Erc

    @staticmethod
    def serialize(obj):
        return json.dumps(
            asdict(obj), indent=4 )
    
    @staticmethod
    def deserialize(data:str):
        # Deserialize JSON back to a dataclass
        json_data = json.loads(data)
        contract = ContractMetadata(**json_data["contract"])
        erc = json_data["erc"]
        audit_report = SolContractERCAuditReport(contract=contract, erc=erc)
        return audit_report



def no_contracts_with_erc(self) -> bool:
    return len(self.contracts_ercs) == 0


def init_sol_audit_context(sol_file_or_dir: str, solc_version=None, 
                           cname=None, cname2ercs = None, no_func_slice=False,
                           solc_lock=None) -> Tuple[SlitherCompilationUnit, SolAuditContext]:
    current_pid = os.getpid()

    if solc_lock is not None:
        print(f"Locking {current_pid}")
        solc_lock.acquire()
        print(f"Lock acquired by {current_pid}")
    try:
        (solc_ver, cu) = compile(sol_file_or_dir, solc_version=solc_version)
    finally:
        if solc_lock is not None:
            print(f"Releasing lock {current_pid}")
            solc_lock.release()
            print(f"Lock released by {current_pid}")
    c2ercs = get_contracts_and_ercs(cu, cname=cname, cname2ercs=cname2ercs)
    sol_metadata = SolMetadata(
        solc_ver=solc_ver,
        contracts=[]
    )
    ctx = SolAuditContext(
        sol_file_or_dir,
        metadata=sol_metadata
    )

    with open(sol_file_or_dir, "r") as f:
        clines = f.read().splitlines(True)

    # we only need to slice functions for contract implemented for ERC
    for c, ercs in c2ercs.items():
        cmeta = get_contract_metadata(c, ercs, clines, no_func_slice=no_func_slice)
        ctx.metadata.contracts.append(cmeta)

    return cu, ctx


