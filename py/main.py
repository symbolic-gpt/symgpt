import logging
logger = logging.getLogger(__name__)

from audit.llm import FullLLMERCAuditor, SlicedLLMSolAuditor

from audit.batch import batch_process
from typing import List
from audit.process import process_sol
import asyncio
import click
from erc.process import process_erc
from llm.adapters import OpenAILLMAdapter
import os

import warnings

for name in ("ContractSolcParsing", "SlitherSolc", "crytic_compile", "slither"):
    logging.getLogger(name).setLevel(logging.CRITICAL)
warnings.filterwarnings("ignore", category=UserWarning)
warnings.filterwarnings("ignore", category=RuntimeWarning)

@click.group()
def main():
    pass


@main.command()
@click.argument("erc_files", nargs=-1, type=click.Path(exists=True))
@click.option("--out-dir")
@click.option("--no-cache", is_flag=True, default=False)
@click.option("--pre-only", is_flag=True, default=False)
def erc(erc_files: List[str], out_dir: str, no_cache: bool, pre_only: bool):
    logger.debug(
        f"extracting erc from {erc_files}, out='{out_dir}'"
        f" no-cache='{no_cache}' pre-only={pre_only}"
    )
    tasks = []
    for erc_file in erc_files:
        output_dir = out_dir if out_dir else os.path.dirname(erc_file)
        cache_dir = None if no_cache else os.path.join(output_dir, ".cache")
        os.makedirs(cache_dir, exist_ok=True)
        os.makedirs(output_dir, exist_ok=True)
        tasks.append(
            process_erc(erc_file, output_dir, cache_dir, preprocess_only=pre_only)
        )

    async def process_all():
        return await asyncio.gather(*tasks)

    asyncio.run(process_all())
    

    
@main.command()
@click.argument("sol_file_or_dirs", nargs=-1, type=click.Path(exists=True))
@click.option("--out-dir", default="out")
@click.option("--cname2ercs", multiple=True)
@click.option("--erc", multiple=True)
@click.option("--debug", is_flag=True, default=False)
@click.option("--no-cache", is_flag=True, default=False)
@click.option("--batch", is_flag=True, default=False)
@click.option("--concurrency", default=4, type=int)
@click.option("--mode", type=click.Choice(["sym", "llm", "llm-sliced","constraintsllmaudit"]), default="sym")
@click.option("--only-erc", type=click.Choice(["20", "721", "1155"]), multiple=True, default=None)
@click.option("--only-rtype", type=click.Choice(["throw", "call", "return","emit","assign", "interface","order"]),  multiple=True, default=None)
@click.option("--only-rule", type=click.STRING, multiple=True, default=None)
@click.option("--erc-spec", type=click.STRING, default=None)
def audit(
    sol_file_or_dirs: str,
    out_dir: str,
    cname2ercs: List[str],
    erc: List[str],
    debug: bool,
    no_cache: bool,
    batch: bool,
    concurrency: int,
    mode: str,
    only_erc: List[str],
    only_rtype: List[str],
    only_rule: List[str],
    erc_spec: str = None
):

    def parse_cname2ercs(input_str):
        name, numbers = input_str.split(":")
        numbers = numbers.split(",")
        return name, numbers

    # contract name => a list of ERC in string
    cname2ercs_dict = {}
    if cname2ercs:
        cname2ercs = [parse_cname2ercs(c) for c in cname2ercs]
        for name, numbers in cname2ercs:
            cname2ercs_dict[name] = numbers

    # erc name => rule index
    def parse_only_rule(rule):
        erc, rule_ids = rule.split(":")
        return erc, [int(id) for id in rule_ids.split(",")]

    ercs2rule_ids = {}
    if only_rule:
        only_rule = [parse_only_rule(oc) for oc in only_rule]
        for erc, rule_ids in only_rule:
            if erc not in ercs2rule_ids:
                ercs2rule_ids[erc] = []
            ercs2rule_ids[erc].extend(rule_ids)

    for sol_file_or_dir in sol_file_or_dirs:
        if os.path.isdir(sol_file_or_dir):
            # Just need a way to automatically merge into one file
            # Merging one file is need for the code slicing.
            logger.error("Support solidity directory is working in process.")
            return

    os.makedirs(out_dir, exist_ok=True)

    if mode == "sym" or mode == "constraintsllmaudit":
        if batch:
            broker_url = "redis://localhost:6379/0"
            return batch_process(
                broker_url, 
                sol_file_or_dirs, 
                out_dir, 
                cname2ercs_dict, 
                erc, 
                ercs2rule_ids, 
                no_cache,
                concurrency=concurrency,
                filter_erc=only_erc,
                filter_rtype=only_rtype
            )
        else:
            logger.info(f"start to audit {len(sol_file_or_dirs)} files")

            for sol_file_or_dir in sol_file_or_dirs:
                # create logger for each sol file
                filename = os.path.basename(sol_file_or_dir).split(".")[0]
                sol_log_file = os.path.join(out_dir, f"{filename}.log")
                log_level = logging.DEBUG if debug else logging.INFO
                sol_logger = None

                process_sol(
                    sol_file_or_dir,
                    out_dir,
                    cname2ercs_dict,
                    erc,
                    only_rules_at=ercs2rule_ids,
                    no_cache=no_cache,
                    logger=sol_logger,
                    filter_erc=only_erc,
                    filter_rtype=only_rtype,
                    constraintsllmaudit=mode == "constraintsllmaudit",
                    erc_spec=erc_spec
                )
            logger.info(f"finish auditing {len(sol_file_or_dirs)} files")

    elif mode == "llm":
        auditor = FullLLMERCAuditor(OpenAILLMAdapter(model="gpt-5"))
        for sol_file_or_dir in sol_file_or_dirs:
            auditor.process(sol_file_or_dir, out_dir, 
                            skip_if_exists=True, 
                            erc=erc[0] if erc else None)
    elif mode == "llm-sliced":
        auditor = SlicedLLMSolAuditor(OpenAILLMAdapter(model="gpt-5"))
        for sol_file_or_dir in sol_file_or_dirs:
            auditor.process(sol_file_or_dir, out_dir, 
                            skip_if_exists=True, 
                            erc=erc[0] if erc else None,
                            cname2ercs=cname2ercs_dict)
    else:
        logger.error(f"unsupported mode: {mode}")



