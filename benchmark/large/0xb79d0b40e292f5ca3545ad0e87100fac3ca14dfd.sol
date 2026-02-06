// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

library SafeMath {
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

interface IERC1155Errors {
    error ERC1155InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed,
        uint256 tokenId
    );
    error ERC1155InvalidSender(address sender);
    error ERC1155InvalidReceiver(address receiver);
    error ERC1155MissingApprovalForAll(address operator, address owner);
    error ERC1155InvalidApprover(address approver);
    error ERC1155InvalidOperator(address operator);
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

library StorageSlot {
    struct AddressSlot {
        address value;
    }
    struct BooleanSlot {
        bool value;
    }
    struct Bytes32Slot {
        bytes32 value;
    }
    struct Uint256Slot {
        uint256 value;
    }
    struct StringSlot {
        string value;
    }
    struct BytesSlot {
        bytes value;
    }

    function getAddressSlot(
        bytes32 slot
    ) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(
        bytes32 slot
    ) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(
        bytes32 slot
    ) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(
        bytes32 slot
    ) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    function getStringSlot(
        bytes32 slot
    ) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    function getStringSlot(
        string storage store
    ) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    function getBytesSlot(
        bytes32 slot
    ) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    function getBytesSlot(
        bytes storage store
    ) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}

library Math {
    error MathOverflowedMulDiv();
    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }
            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)
                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.
            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)
                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)
                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }
            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;
            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;
            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256
            result = prod0 * inverse;
            return result;
        }
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 result = 1 << (log2(a) >> 1);
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    function sqrt(
        uint256 a,
        Rounding rounding
    ) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return
                result +
                (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    function log2(
        uint256 value,
        Rounding rounding
    ) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return
                result +
                (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    function log10(
        uint256 value,
        Rounding rounding
    ) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return
                result +
                (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    function log256(
        uint256 value,
        Rounding rounding
    ) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return
                result +
                (
                    unsignedRoundsUp(rounding) && 1 << (result << 3) < value
                        ? 1
                        : 0
                );
        }
    }

    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

library Arrays {
    using StorageSlot for bytes32;

    function findUpperBound(
        uint256[] storage array,
        uint256 element
    ) internal view returns (uint256) {
        uint256 low = 0;
        uint256 high = array.length;
        if (high == 0) {
            return 0;
        }
        while (low < high) {
            uint256 mid = Math.average(low, high);
            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds towards zero (it does integer division with truncation).
            if (unsafeAccess(array, mid).value > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && unsafeAccess(array, low - 1).value == element) {
            return low - 1;
        } else {
            return low;
        }
    }

    function unsafeAccess(
        address[] storage arr,
        uint256 pos
    ) internal pure returns (StorageSlot.AddressSlot storage) {
        bytes32 slot;
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getAddressSlot();
    }

    function unsafeAccess(
        bytes32[] storage arr,
        uint256 pos
    ) internal pure returns (StorageSlot.Bytes32Slot storage) {
        bytes32 slot;
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getBytes32Slot();
    }

    function unsafeAccess(
        uint256[] storage arr,
        uint256 pos
    ) internal pure returns (StorageSlot.Uint256Slot storage) {
        bytes32 slot;
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getUint256Slot();
    }

    function unsafeMemoryAccess(
        uint256[] memory arr,
        uint256 pos
    ) internal pure returns (uint256 res) {
        assembly {
            res := mload(add(add(arr, 0x20), mul(pos, 0x20)))
        }
    }

    function unsafeMemoryAccess(
        address[] memory arr,
        uint256 pos
    ) internal pure returns (address res) {
        assembly {
            res := mload(add(add(arr, 0x20), mul(pos, 0x20)))
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC1155 is IERC165 {
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );
    event URI(string value, uint256 indexed id);

    function balanceOf(
        address account,
        uint256 id
    ) external view returns (uint256);

    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(
        address account,
        address operator
    ) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;
}

interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns (string memory);
}

abstract contract ERC1155 is
    Context,
    ERC165,
    IERC1155,
    IERC1155MetadataURI,
    IERC1155Errors
{
    using Arrays for uint256[];
    using Arrays for address[];
    mapping(uint256 => mapping(address => uint256)) private _balances;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256 /* id */) public view virtual returns (string memory) {
        return _uri;
    }

    function balanceOf(
        address account,
        uint256 id
    ) public view virtual returns (uint256) {
        return _balances[id][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    ) public view virtual returns (uint256[] memory) {
        if (accounts.length != ids.length) {
            revert ERC1155InvalidArrayLength(ids.length, accounts.length);
        }
        uint256[] memory batchBalances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(
                accounts.unsafeMemoryAccess(i),
                ids.unsafeMemoryAccess(i)
            );
        }
        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(
        address account,
        address operator
    ) public view virtual returns (bool) {
        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public virtual {
        address sender = _msgSender();
        if (from != sender && !isApprovedForAll(from, sender)) {
            revert ERC1155MissingApprovalForAll(sender, from);
        }
        _safeTransferFrom(from, to, id, value, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual {
        address sender = _msgSender();
        if (from != sender && !isApprovedForAll(from, sender)) {
            revert ERC1155MissingApprovalForAll(sender, from);
        }
        _safeBatchTransferFrom(from, to, ids, values, data);
    }

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal virtual {
        if (ids.length != values.length) {
            revert ERC1155InvalidArrayLength(ids.length, values.length);
        }
        address operator = _msgSender();
        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids.unsafeMemoryAccess(i);
            uint256 value = values.unsafeMemoryAccess(i);
            if (from != address(0)) {
                uint256 fromBalance = _balances[id][from];
                if (fromBalance < value) {
                    revert ERC1155InsufficientBalance(
                        from,
                        fromBalance,
                        value,
                        id
                    );
                }
                unchecked {
                    // Overflow not possible: value <= fromBalance
                    _balances[id][from] = fromBalance - value;
                }
            }
            if (to != address(0)) {
                _balances[id][to] += value;
            }
        }
        if (ids.length == 1) {
            uint256 id = ids.unsafeMemoryAccess(0);
            uint256 value = values.unsafeMemoryAccess(0);
            emit TransferSingle(operator, from, to, id, value);
        } else {
            emit TransferBatch(operator, from, to, ids, values);
        }
    }

    function _updateWithAcceptanceCheck(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal virtual {
        _update(from, to, ids, values);
        if (to != address(0)) {
            address operator = _msgSender();
            if (ids.length == 1) {
                uint256 id = ids.unsafeMemoryAccess(0);
                uint256 value = values.unsafeMemoryAccess(0);
                _doSafeTransferAcceptanceCheck(
                    operator,
                    from,
                    to,
                    id,
                    value,
                    data
                );
            } else {
                _doSafeBatchTransferAcceptanceCheck(
                    operator,
                    from,
                    to,
                    ids,
                    values,
                    data
                );
            }
        }
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(
            id,
            value
        );
        _updateWithAcceptanceCheck(from, to, ids, values, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        _updateWithAcceptanceCheck(from, to, ids, values, data);
    }

    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    function _mint(
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(
            id,
            value
        );
        _updateWithAcceptanceCheck(address(0), to, ids, values, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        _updateWithAcceptanceCheck(address(0), to, ids, values, data);
    }

    function _burn(address from, uint256 id, uint256 value) internal {
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(
            id,
            value
        );
        _updateWithAcceptanceCheck(from, address(0), ids, values, "");
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory values
    ) internal {
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        _updateWithAcceptanceCheck(from, address(0), ids, values, "");
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        if (operator == address(0)) {
            revert ERC1155InvalidOperator(address(0));
        }
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) private {
        if (to.code.length > 0) {
            try
                IERC1155Receiver(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    value,
                    data
                )
            returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    // Tokens rejected
                    revert ERC1155InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    // non-ERC1155Receiver implementer
                    revert ERC1155InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) private {
        if (to.code.length > 0) {
            try
                IERC1155Receiver(to).onERC1155BatchReceived(
                    operator,
                    from,
                    ids,
                    values,
                    data
                )
            returns (bytes4 response) {
                if (
                    response != IERC1155Receiver.onERC1155BatchReceived.selector
                ) {
                    // Tokens rejected
                    revert ERC1155InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    // non-ERC1155Receiver implementer
                    revert ERC1155InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    function _asSingletonArrays(
        uint256 element1,
        uint256 element2
    ) private pure returns (uint256[] memory array1, uint256[] memory array2) {
        /// @solidity memory-safe-assembly
        assembly {
            // Load the free memory pointer
            array1 := mload(0x40)
            // Set array length to 1
            mstore(array1, 1)
            // Store the single element at the next word after the length (where content starts)
            mstore(add(array1, 0x20), element1)
            // Repeat for next array locating it right after the first array
            array2 := add(array1, 0x40)
            mstore(array2, 1)
            mstore(add(array2, 0x20), element2)
            // Update the free memory pointer by pointing after the second array
            mstore(0x40, add(array2, 0x40))
        }
    }
}

contract Banana2024 is ERC1155 {
    using SafeMath for uint256;
    string  name; // The name of the token
    string  symbol; // The symbol of the token
    uint256 nftCounter;
    uint256 price;
    uint256 fixedNumberCopies;
// sale start Time and end time 
    uint256 saleStartTime;
    uint256 saleEndTime;
    uint256 totalAcres = 700;
//referralar reward percentages
    uint256 referral1Percentage = 3;
    uint256 referralPercentage = 1;
// marketing wallet percentage if referralar not found
    uint256 marketPercentage = 6;
// percentages of wallets
    uint256 marketting = 5;
    uint256 landAssestLease = 63;
    uint256 adminstration = 2;
    uint256 remuneration = 8;
    uint256 finanaceLegal = 0;
// addresses 
    address public farmOperatorWallet = 0xFD84919da41171D8EFdE6b1F7cb15bfB126C1169 ;
    address public markettingWallet = 0x771aCf997AB3DB26ab5D7a8f14E5515696F63682;
    address public landAssestLeaseWallet = 0xEBc7e67DcED23260cABF632Befebe808886b5c59;
    address public administrationWallet = 0x39002659F2Cee83A4b0D4e97772a006CF3148C72;
    address public remunerationWallet = 0xFfBB5dF0bEF768457CBEC913b5CB3908355ff514;
    address public finanaceLegalWallet = 0x607caf1284DcDe213dEA4B4eD7e1F2fc794cb2F7;

    address paymentToken ;
    bool initialized;
    uint256 pricePerCopy;
    struct sale {
        uint256[] id;
        uint256[] noOfCopies;
        uint256[] time;
        address[] referralAddress;
    }
    mapping(address => sale) saleInfo;
    mapping(address => mapping(address => bool)) isparent;
    mapping(address => address) parentNodes;
    struct childData {
        address[] referrer;
        mapping(address => bool) ischild;
    }
    enum rewardType {
        Direct,
        Indirect
    }
    struct info {
        address[] user;
        uint256[] amount;
        rewardType[] RewardType;
    }
    mapping(address => info) information;
    mapping(address => uint256[]) tokendIds;
    mapping(address => childData) childAddress;
    mapping(address => uint256) reward;
    mapping(address => address[]) referralarAddresses;
    mapping(address => bool) referralarstatus;
    mapping(uint256 => uint256) mintedAmount;
    mapping(uint256 => string) private _tokenURIs;
    event BUY(uint256 noOfCopies, address referralAddress);
    event TERMINATESALE();
    event UPDATEPRICE(uint256 newPrice);

    constructor(
        string memory uri,
        address _paymentToken,
        uint256 _saleStartTime,
        uint256 _saleEndTime   
    ) ERC1155(uri) {
        name = "Banana 2024";
        symbol = "BNNA24";
        paymentToken = _paymentToken;
        price = 160 * 5430000 ;
        initialized = true;
        pricePerCopy = price.div(160);
        referralarstatus[farmOperatorWallet] = true;
        fixedNumberCopies = 160;
        saleStartTime = _saleStartTime;
        saleEndTime = _saleEndTime;
    }

    modifier onlyadministrationWallet() {
        require(
            msg.sender == administrationWallet,
            "administrationWallet can be called"
        );
        _;
    }

    function setPaymentAddress(
        address _paymentToken
    ) public onlyadministrationWallet {
        paymentToken = _paymentToken;
    }

    // terminate the sale 
    function terminateSale() public onlyadministrationWallet {
        initialized = false;
        emit TERMINATESALE();
    }

    // update the price 
    function updatePrice(uint256 newPrice) public onlyadministrationWallet {
        require(newPrice > 0, "price should greater than 0");
        price = newPrice;
        pricePerCopy = price.div(160);
        emit UPDATEPRICE(newPrice);
    }

    function toRefferars(uint256 noOfcopies, address _referrer) internal {
        IERC20 tokenAddress = IERC20(paymentToken);
        uint256 _price = getPricePerCopy().mul(noOfcopies);
        uint256 _referralReward1 = (referral1Percentage * _price) / 100;
        uint256 _referralReward = (referralPercentage * _price) / 100;
        uint256 total;
        if (_referrer != address(0)) {
            tokenAddress.transfer(_referrer, _referralReward1);
            reward[_referrer] += _referralReward1;
            total += _referralReward1;
            information[_referrer].user.push(msg.sender);
            information[_referrer].amount.push(_referralReward1);
            information[_referrer].RewardType.push(rewardType.Direct);
        }
        address current = _referrer;
        for (uint256 i = 0; i <= 2; i++) {
            current = getparent(current);
            if (current != address(0)) {
                tokenAddress.transfer(current, _referralReward);
                reward[current] += _referralReward;
                information[current].user.push(msg.sender);
                information[current].amount.push(_referralReward);
                information[current].RewardType.push(rewardType.Indirect);
                total += _referralReward;
            }
        }
        total = _price - total;
        uint256 _marketting = (total.mul(marketting)).div(100);
        uint256 _landAssestLease = (total.mul(landAssestLease)).div(100);
        uint256 _adminstration = (total.mul(adminstration)).div(100);
        uint256 _remuneration = (total.mul(remuneration)).div(100);
        uint256 _finanaceLegal =  (total.mul(finanaceLegal)).div(100);
        uint256 _farmOperator = _marketting.add(_landAssestLease).add(_adminstration).add(_remuneration).add(_finanaceLegal);
        _farmOperator = total.sub(_farmOperator);
        IERC20(paymentToken).transfer(markettingWallet, _marketting);        
        IERC20(paymentToken).transfer(landAssestLeaseWallet,_landAssestLease);
        IERC20(paymentToken).transfer(administrationWallet, _adminstration);
        IERC20(paymentToken).transfer(remunerationWallet, _remuneration);
        IERC20(paymentToken).transfer(finanaceLegalWallet, _finanaceLegal);
        IERC20(paymentToken).transfer(farmOperatorWallet, _farmOperator);
    }

    // marketing transfer reward
    function marketingReward(uint256 noOfcopies, uint256 percent) internal {
        IERC20 tokenAddress = IERC20(paymentToken);
        uint256 _price = getPricePerCopy().mul(noOfcopies);
        require(percent <= marketPercentage, "1 to 6 marketing");
        uint256 referralReward = percent.mul(_price);
        referralReward = referralReward.div(100);
        tokenAddress.transfer(markettingWallet, referralReward);
        reward[markettingWallet] += referralReward;
        referralarstatus[msg.sender] = true;
        information[markettingWallet].user.push(msg.sender);
        information[markettingWallet].amount.push(referralReward);
        uint256 remain = _price.sub(referralReward);
        uint256 _marketting = (remain.mul(marketting)).div(100);
        uint256 _landAssestLease = (remain.mul(landAssestLease)).div(100);
        uint256 _adminstration = (remain.mul(adminstration)).div(100);
        uint256 _remuneration = (remain.mul(remuneration)).div(100);
        uint256 _finanaceLegal =  (remain.mul(finanaceLegal)).div(100);
        uint256 _farmOperator = _marketting.add(_landAssestLease).add(_adminstration).add(_remuneration).add(_finanaceLegal);
        _farmOperator = remain.sub(_farmOperator);
        IERC20(paymentToken).transfer(markettingWallet, _marketting);        
        IERC20(paymentToken).transfer(landAssestLeaseWallet,_landAssestLease);
        IERC20(paymentToken).transfer(administrationWallet, _adminstration);
        IERC20(paymentToken).transfer(remunerationWallet, _remuneration);
        IERC20(paymentToken).transfer(finanaceLegalWallet, _finanaceLegal);
        IERC20(paymentToken).transfer(farmOperatorWallet, _farmOperator);
    }

    // buy nft by passing initailCounter ,price and referral Address
    function buy(uint256 noOfcopies, address referralAddress) public {
        uint256 _price = getPricePerCopy().mul(noOfcopies);
        require(referralAddress != msg.sender, "invalid referralAddress");
        transferFromUSDT(_price);
        if (referralarstatus[referralAddress] == true) {
            referralar(referralAddress);
            toRefferars(noOfcopies, referralAddress);
            buyCalculation(noOfcopies, referralAddress);
        } else {
            marketingReward(noOfcopies, marketPercentage);
            buyCalculation(noOfcopies, referralAddress);
        }
        emit BUY(price, referralAddress);
    }

    // get initialize information
    function getInitailizeInfo() public view returns (uint256, uint256, bool) {
        return (price, pricePerCopy, initialized);
    }

    // get buy informationf
    function getBuyInfo(
        address user
    )
        public
        view
        returns (
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            address[] memory
        )
    {
        sale memory s = saleInfo[user];
        return (s.id, s.noOfCopies, s.time, s.referralAddress);
    }

    // update marketing wallet and percentage
    function updateMarketing(
        address _newMarketingWallet,
        uint256 _newMarketPercentage
    ) public onlyadministrationWallet {
        require(
            _newMarketingWallet != address(0x0) && _newMarketPercentage > 0,
            "invalid inputs"
        );
        markettingWallet = _newMarketingWallet;
        marketPercentage = _newMarketPercentage;
    }

    function getChildCount(address _address) public view returns (uint256) {
        return childAddress[_address].referrer.length;
    }

    function getChildByIndex(
        address _address,
        uint256 index
    ) public view returns (address) {
        require(
            index < childAddress[_address].referrer.length,
            "Invalid index"
        );
        return childAddress[_address].referrer[index];
    }

    function getChildAddress(
        address _address
    ) public view returns (address[] memory) {
        return (childAddress[_address].referrer);
    }

    function setURI(
        uint256 tokenId,
        string memory tokenURI
    ) public onlyadministrationWallet {
        _tokenURIs[tokenId] = tokenURI;
        emit URI(uri(tokenId), tokenId);
    }

    function getTotalIds() public view returns (uint256) {
        return nftCounter;
    }

    function getReward(address referral) public view returns (uint256) {
        return reward[referral];
    }

    function getPrice() public view returns (uint256) {
        return price;
    }

    function buyCalculation(
        uint256 noOfcopies,
        address referralAddress
    ) public  {
        require(nftCounter <= totalAcres,"cap reached ");
                require(block.timestamp >= saleStartTime && block.timestamp <= saleEndTime,"sale is out of time");
        uint256 tokenId = nftCounter;
        uint256 mintedValues = mintedAmount[tokenId];
        if ((mintedValues + noOfcopies) <= fixedNumberCopies) {
            _mint(msg.sender, tokenId, noOfcopies, "");
            mintedAmount[tokenId] += noOfcopies;
            saleInfo[msg.sender].id.push(tokenId);
            saleInfo[msg.sender].noOfCopies.push(noOfcopies);
            saleInfo[msg.sender].time.push(block.timestamp);
            saleInfo[msg.sender].referralAddress.push(referralAddress);
            tokendIds[msg.sender].push(tokenId);
        } else {
            uint256 remaining = fixedNumberCopies - mintedValues;
            mintedAmount[tokenId] += remaining;
            _mint(msg.sender, tokenId, remaining, "");
            tokendIds[msg.sender].push(tokenId);
            saleInfo[msg.sender].id.push(tokenId);
            saleInfo[msg.sender].noOfCopies.push(remaining);
            saleInfo[msg.sender].time.push(block.timestamp);
            saleInfo[msg.sender].referralAddress.push(referralAddress);
            // If there are still remaining copies, continue minting in the next token ID
            if (noOfcopies > remaining) {
                nftCounter++;
                buyCalculation(noOfcopies - remaining, referralAddress);
            }
        }
    }

    function getPricePerCopy() public view returns (uint256) {
        return pricePerCopy;
    }

    function transferFromUSDT(uint256 amount) internal {
        IERC20 tokenAddress = IERC20(paymentToken);
        require(
            tokenAddress.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
    }

    function referralar(address _referrer) internal {
        require(!isparent[_referrer][msg.sender], "child cannot be parent");
        if (isparent[msg.sender][_referrer] == false) {
            parentNodes[msg.sender] = _referrer;
            isparent[msg.sender][_referrer] = true;
        }
        // Register the sender as a child for the referrer
        if (childAddress[_referrer].ischild[msg.sender] == false) {
            childAddress[_referrer].referrer.push(msg.sender);
            childAddress[_referrer].ischild[msg.sender] = true;
        }
        // Mark sender as having successfully referred
        referralarstatus[msg.sender] = true;
    }

    function getparent(address child) public view returns (address) {
        return parentNodes[child];
    }

    function getAllParents(
        address user
    ) public view returns (address[] memory) {
        uint256 count = 0;
        address current = user;

        // Determine the number of parent addresses associated with the user
        while (current != address(0)) {
            current = getparent(current);
            count++;
        }

        // Create an array to store the parent addresses
        address[] memory allParents = new address[](count);
        current = user;

        // Retrieve and store all parent addresses
        for (uint256 i = 0; i < count; i++) {
            current = getparent(current);
            allParents[i] = current;
        }

        return allParents;
    }

    function getParentsCount(address user) public view returns (uint256) {
        uint256 count = 0;
        address current = user;
        while (current != address(0)) {
            current = getparent(current);
            count++;
        }

        return count;
    }

    function getParentAtIndex(
        address user,
        uint256 index
    ) public view returns (address) {
        address[] memory allParents = getAllParents(user);
        require(index < getParentsCount(user), "invalid index");
        return allParents[index];
    }

    function withdraw(address _token, address to) public onlyadministrationWallet {
        IERC20 token = IERC20(_token);
        token.transfer(to, token.balanceOf(address(this)));
    }

    function upateName(
        string memory _name
    ) public onlyadministrationWallet returns (string memory) {
        name = _name;
        return _name;
    }

    function upateSybmol(
        string memory _symbol
    ) public onlyadministrationWallet returns (string memory) {
        symbol = _symbol;
        return _symbol;
    }

    function getTokenIds(address user) public view returns (uint256[] memory) {
        return tokendIds[user];
    }

    function getmintedAmount(uint256 tokenId) public view returns (uint256) {
        return mintedAmount[tokenId];
    }

    function getInfoReward(
        address user
    )
        public
        view
        returns (address[] memory, uint256[] memory, rewardType[] memory)
    {
        return (
            information[user].user,
            information[user].amount,
            information[user].RewardType
        );
    }

    function updateLevelPercentage(
        uint256 level1Percentage,
        uint256 otherLevelPercentage
    ) public onlyadministrationWallet {
        referral1Percentage = level1Percentage;
        referralPercentage = otherLevelPercentage;
    }

    function updateMarket(
        uint256 _marketting
    ) public onlyadministrationWallet {
        require( _marketting > 0,"invalid inputs");
        marketting = _marketting;
    }

    function updateLandLease(
        address _landAssestLeaseWallet,
        uint256 _landAssestLease
    ) public onlyadministrationWallet {
        require(
            _landAssestLeaseWallet != address(0x0) && _landAssestLease > 0,
            "invalid inputs"
        );
        landAssestLeaseWallet = _landAssestLeaseWallet;
        landAssestLease = _landAssestLease;
    }
    function updateAdminstrationWallet(
        address _administrationWallet,
        uint256 _adminstration
    ) public onlyadministrationWallet {
        require(
            _administrationWallet != address(0x0) && _adminstration > 0,
            "invalid inputs"
        );
        administrationWallet = _administrationWallet;
        adminstration = _adminstration;
    }
    function updateRemunerationWallet(
        address _remunerationWallet,
        uint256 _remuneration
    ) public onlyadministrationWallet {
        require(
            _remunerationWallet != address(0x0) && _remuneration > 0,
            "invalid inputs"
        );
        remunerationWallet = _remunerationWallet;
        remuneration = _remuneration;
    }
    function updateFinanaceLegalWallet(
        address _finanaceLegalWallet,
        uint256 _finanaceLegal
    ) public onlyadministrationWallet {
        require(
            _finanaceLegalWallet != address(0x0) && _finanaceLegal > 0,
            "invalid inputs"
        );
        finanaceLegalWallet = _finanaceLegalWallet;
        finanaceLegal = _finanaceLegal;
    }
    function updateSaleTime(uint256 _saleStartTime,uint256 _saleEndTime) public onlyadministrationWallet {
        saleStartTime = _saleStartTime;
        saleEndTime = _saleEndTime;
    }
    function updateAcres(uint256 _totalAcres) public onlyadministrationWallet {
        totalAcres = _totalAcres;
    }
    function getTime() public view returns(uint256 _saleStartTime,uint256 _saleEndTime){
        return(saleStartTime,saleEndTime);
    }
}