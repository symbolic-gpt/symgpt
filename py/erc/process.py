import traceback
from erc.pipeline import ErcPipelineManager
from erc.pipelines.extract_rule import ExtractRule
from erc.pipelines.gen_sym import GenSym
from erc.pre import preprocess
import asyncio
import os
import json
from openai import AsyncOpenAI
import logging
import config
logger = logging.getLogger(__name__)


async def process_erc(erc_file:str, out_dir:str, cache_dir:str=None, preprocess_only = False):
    try:
        with open(erc_file, "r") as f:
            erc_str = f.read()
            erc_filename = os.path.basename(erc_file)
            erc_objs = preprocess(erc_str, erc_filename, cache_dir)
        
        erc_objs = [erc_obj for erc_obj in erc_objs if erc_obj['name'].find("Receiver") == -1]
        if cache_dir:
            paths =  [ os.path.join(cache_dir, f"{erc_filename}_{erc_obj['name']}_pre.json") for erc_obj in erc_objs ]
            for path, erc_obj in zip(paths, erc_objs):
                os.makedirs(os.path.dirname(path), exist_ok=True)
                with open(path, "w") as f:
                    json.dump(erc_obj, f, indent=4)
        
        if preprocess_only:
            return
        client = AsyncOpenAI(
        )
        ppl_manager = ErcPipelineManager([
            ExtractRule(client, erc_str),
            GenSym(client)
        ])
        
        results = await asyncio.gather(*[ppl_manager.run(erc_obj, cache_dir, erc_filename) for erc_obj in erc_objs])
        results_dst =  [ os.path.join(out_dir, f"{erc_filename}_{erc_obj['name']}.json") for erc_obj in erc_objs ]

        for result, dst in zip(results, results_dst):
            with open(dst, "w") as f:
                json.dump(result, f, indent=4)

    except Exception as ex:
        logger.error(f"failed to handle ERC file '{erc_file}': {ex}")
        traceback.print_exc() 


