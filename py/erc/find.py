from dataclasses import dataclass
from typing import List, Optional
from erc.types import Erc
import json



@dataclass(frozen=True)
class ErcSuite:
    erc: str
    main_erc: Erc
    optional_ercs: Optional[List[Erc]] = None


erc_cache = {
    "20": ErcSuite(
        "20",
        json.loads(open("erc/build/ERC20_ERC20.json").read())
    ),
    "721": ErcSuite(
        "721",
        json.loads(open("erc/build/ERC721_ERC721.json").read()),
        [
            json.loads(open("erc/build/ERC721_ERC721Metadata.json").read()),
            json.loads(open("erc/build/ERC721_ERC721Enumerable.json").read()),
            json.loads(open("erc/build/ERC721_ERC165.json").read())
        ]
    ),
    "1155": ErcSuite(
        "1155",
        json.loads(open("erc/build/ERC1155_ERC1155.json").read()),
        [
            json.loads(open("erc/build/ERC1155_ERC165.json").read()),
            json.loads(open("erc/build/ERC1155_ERC1155Metadata_URI.json").read())
        ]
    ),
    "3525": ErcSuite(
        "3525",
        json.loads(open("erc/build/ERC3525_IERC3525.json").read()),
        [
            json.loads(open("erc/build/ERC3525_IERC3525Metadata.json").read()),
            json.loads(open("erc/build/ERC3525_IERC3525SlotApprovable.json").read()),
            json.loads(open("erc/build/ERC3525_IERC3525SlotEnumerable.json").read()),
        ]
    ),
}

def get_erc_suit(erc: str) -> ErcSuite:
    erc = erc.lower()
    if erc in erc_cache:
        return erc_cache[erc]
    return None
