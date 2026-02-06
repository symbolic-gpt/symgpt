import logging
from typing import List
from abc import ABC, abstractmethod
import asyncio
import json
import os

from erc.types import Erc

logger = logging.getLogger(__name__)

class ErcPipeline(ABC):
    
    @abstractmethod
    def name(self) -> str:
        raise NotImplementedError()

    @abstractmethod
    async def run(self, erc: Erc) -> Erc:
        raise NotImplementedError()
    

class ErcPipelineManager:
    def __init__(self, pipelines: List[ErcPipeline]) -> None:
        self.pipelines = pipelines
    
    async def run(self, erc_obj: Erc, cache_dir:str = None, cache_prefix = "") -> Erc:
        curr = erc_obj
        prev_changed = False
        for pl in self.pipelines:
            pl_name = pl.name()
            if cache_dir:
                dst = os.path.join(cache_dir, f"{cache_prefix}_{erc_obj['name']}_{pl_name}.json")
                if not prev_changed and os.path.exists(dst):
                    with open(dst, "r") as f:
                        curr = json.load(f)
                        logger.debug(f"loaded {dst} from cache")
                else:
                    prev_changed = True
            curr = await pl.run(curr)
            if cache_dir:
                with open(dst, "w") as f:
                    json.dump(curr, f, indent=4)
        return curr





