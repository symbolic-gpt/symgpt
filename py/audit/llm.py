


from abc import ABC, abstractmethod
import json
import logging
import os
from audit.context import init_sol_audit_context
from erc.utils import iterate_rules
from llm.adapters import LLMAdapter
from sol.utils import get_erc, get_event_interface, get_event_interface_with_pname

logger = logging.getLogger(__name__)

class ERCAuditor(ABC):
    
    @abstractmethod
    def process(self, sol_file:str, output_dir:str, **kwargs):
        raise NotImplementedError()

class LLMERCAuditor(ERCAuditor):

    def __init__(self, llm: LLMAdapter):
        self._llm = llm


class FullLLMERCAuditor(LLMERCAuditor):
    def __init__(self, llm: LLMAdapter, erc_dir:str = "./erc"):
        super().__init__(llm)
        self._erc_dir = erc_dir
    def process(self, sol_file:str, output_dir:str, **kwargs):
        skip_if_exists = kwargs.get("skip_if_exists", False)
        erc = kwargs.get("erc", None)
        output_file = os.path.join(output_dir, f"{os.path.basename(sol_file).split('.')[0]}.txt")
        if os.path.exists(output_file) and skip_if_exists:
            return
        with open(sol_file, "r") as f:
            sol = f.read()

        if erc is None:
            erc = get_erc(sol_file)
        erc_doc_path = os.path.join(self._erc_dir, f"ERC{erc}")
        with open(erc_doc_path, "r") as f:
            erc_doc = f.read()

        result = self._llm.single(f"""By given the following solidity code:\"\"\"
{sol}
\"\"\"
Please check if the code is ERC-{erc} compliant. The ERC-{erc} standard is defined as follows:\"\"\"
{erc_doc}
\"\"\"
""", temperature=0, n=1)[0]
        with open(output_file, "w") as f:
            f.write(result)
        
    

class SlicedLLMSolAuditor(LLMERCAuditor):

    def __init__(self, llm: LLMAdapter, erc_dir:str = "./erc"):
        super().__init__(llm)
        self._erc_dir = erc_dir
    
    def process(self, sol_file:str, output_dir:str, **kwargs):
        print(f"Processing {sol_file}...")
        skip_if_exists = kwargs.get("skip_if_exists", False)
        erc = kwargs.get("erc", None)
        cname2ercs = kwargs.get("cname2ercs", None)
        task_output_dir = os.path.join(output_dir, os.path.basename(sol_file).split('.')[0])
        if os.path.exists(task_output_dir) and skip_if_exists:
            return
        os.makedirs(task_output_dir, exist_ok=True)
        _, ctx = init_sol_audit_context(sol_file, cname2ercs=cname2ercs)
        if erc is None:
            erc = get_erc(sol_file)
        
        print(f"Auditing {sol_file} with ERC{erc} rules...")
        for contract in ctx.metadata.contracts:
            if erc is None:
                erc = contract.ercs[0]
            with open(os.path.join(self._erc_dir, f"ERC{erc}_ERC{erc}.json"), "r") as f:
                erc_obj = json.load(f)
            for idx, (obj, rtype, rule, cond) in enumerate(iterate_rules(erc_obj, True)):
                try:
                    
                    if obj["def"].startswith("event"):
                        if rtype == "interface":
                            print(contract.events)
                            event_interfaces = "\n".join([get_event_interface(evt['name'], evt['params']) for evt in contract.events])
                            prompt = f"""By given the following solidity event interfaces:\"\"\"\n{event_interfaces}\n\"\"\"\nCheck if the code contains the interface "{rule}", "YES" if contains or "NO" otherwise."""
                            res = self._llm.single(prompt, temperature=0, n=1)[0]
                            with open(os.path.join(task_output_dir, f"{idx}.txt"), "w") as f:
                                f.write(f"rule: {rtype} {rule}\n")
                                f.write(res)
                        else:
                            # rule is contract scope, we need to ask every function
                            cnt = 0
                            for fsig, fstr in contract.func2str.items():
                                prompt = f"""By given the following solidity code for "{fsig}":\"\"\"
{fstr}
\"\"\"
Check if the code violated the rule "{rtype} {rule} {("if "+str(cond["if"])) if cond else ""}", return in "YES" or "NO".
"""                         
                                cnt += 1
                                res = self._llm.single(prompt, temperature=0, n=1)[0]
                                with open(os.path.join(task_output_dir, f"{idx}_{cnt}.txt"), "w") as f:
                                    f.write(f"rule: {rtype} {rule} {('if '+str(cond["if"])) if cond else ''}\n")
                                    f.write(res)
                    else:
                        func_def = obj["def"]
                        func_str = None
                        
                        if rtype == "interface":
                            func_str = f"{"\n".join(contract.func2str.keys())}\n{"\n".join(contract.state_var_sigs)}"
                        else:
                            for fsig, fcode in contract.func2str.items():
                                if func_def.split("(")[0].split(" ")[1] == fsig.split("(")[0]:
                                    func_str = fcode
                                    break
                        if func_str is None:
                            continue
                        prompt = f"""By given the following solidity {"code" if rtype != "interface" else "interfaces"}:\"\"\"
{func_str}
\"\"\"
Check if the code {"violated the rule " if rtype != "interface" else "contains "} "{rtype} {rule} {("if "+cond) if cond else ""}" {f"for {func_def}" if rtype != "interface" else ""}, return in "YES" or "NO".
"""             
                        res = self._llm.single(prompt, temperature=0, n=1)[0]
                        with open(os.path.join(task_output_dir, f"{idx}.txt"), "w") as f:
                            f.write(f"rule: {rtype} {rule} {('if '+cond) if cond else ''}\n")
                            f.write(res)
                except Exception as e:
                    logger.error(f"Error in auditing rule {rtype} {rule} {cond} in {sol_file} {contract.name}: {e}")
                    continue

            