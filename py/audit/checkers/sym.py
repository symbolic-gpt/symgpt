import json
import logging
from typing import Dict, Tuple

from audit.checkers import ErcChecker
from erc.types import ErcRule
from llm.utils import trim_json_markers
logger = logging.getLogger(__name__)

class SymChecker(ErcChecker):
    def check(self, rule: ErcRule, code: str) -> Tuple[bool | json.Any]:
        raise NotImplementedError

    
    