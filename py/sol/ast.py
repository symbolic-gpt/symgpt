from typing import Dict
from solidity_parser import parser
import logging
logger = logging.getLogger(__name__)

def get_sol_ast(code: str) -> Dict:
    try:
        return parser.parse(code, loc=True)
    except Exception as ex:
        logger.error(f'failed to get ast: {ex}.')
        logger.error(f'failed code is: {code}.')
        return None
    
