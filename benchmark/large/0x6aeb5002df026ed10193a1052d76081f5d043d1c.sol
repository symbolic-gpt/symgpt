// Sources flattened with hardhat v2.22.2 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/interfaces/draft-IERC6093.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`ΓÇÖs `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`ΓÇÖs approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`ΓÇÖs approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}


// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC1155/IERC1155.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.20;

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` amount of tokens of type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the value of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers a `value` amount of tokens of type `id` from `from` to `to`.
     *
     * WARNING: This function can potentially allow a reentrancy attack when transferring tokens
     * to an untrusted contract, when invoking {onERC1155Received} on the receiver.
     * Ensure to follow the checks-effects-interactions pattern and consider employing
     * reentrancy guards when interacting with untrusted contracts.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `value` amount.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * WARNING: This function can potentially allow a reentrancy attack when transferring tokens
     * to an untrusted contract, when invoking {onERC1155BatchReceived} on the receiver.
     * Ensure to follow the checks-effects-interactions pattern and consider employing
     * reentrancy guards when interacting with untrusted contracts.
     *
     * Emits either a {TransferSingle} or a {TransferBatch} event, depending on the length of the array arguments.
     *
     * Requirements:
     *
     * - `ids` and `values` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;
}


// File @openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}


// File @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface that must be implemented by smart contracts in order to receive
 * ERC-1155 token transfers.
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}


// File @openzeppelin/contracts/utils/math/Math.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
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

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

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

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // ΓåÆ `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // ΓåÆ `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
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

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
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

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
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

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
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

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}


// File @openzeppelin/contracts/utils/StorageSlot.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 */
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

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}


// File @openzeppelin/contracts/utils/Arrays.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Arrays.sol)

pragma solidity ^0.8.20;


/**
 * @dev Collection of functions related to array types.
 */
library Arrays {
    using StorageSlot for bytes32;

    /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
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

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(address[] storage arr, uint256 pos) internal pure returns (StorageSlot.AddressSlot storage) {
        bytes32 slot;
        // We use assembly to calculate the storage slot of the element at index `pos` of the dynamic array `arr`
        // following https://docs.soliditylang.org/en/v0.8.20/internals/layout_in_storage.html#mappings-and-dynamic-arrays.

        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getAddressSlot();
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(bytes32[] storage arr, uint256 pos) internal pure returns (StorageSlot.Bytes32Slot storage) {
        bytes32 slot;
        // We use assembly to calculate the storage slot of the element at index `pos` of the dynamic array `arr`
        // following https://docs.soliditylang.org/en/v0.8.20/internals/layout_in_storage.html#mappings-and-dynamic-arrays.

        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getBytes32Slot();
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(uint256[] storage arr, uint256 pos) internal pure returns (StorageSlot.Uint256Slot storage) {
        bytes32 slot;
        // We use assembly to calculate the storage slot of the element at index `pos` of the dynamic array `arr`
        // following https://docs.soliditylang.org/en/v0.8.20/internals/layout_in_storage.html#mappings-and-dynamic-arrays.

        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getUint256Slot();
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeMemoryAccess(uint256[] memory arr, uint256 pos) internal pure returns (uint256 res) {
        assembly {
            res := mload(add(add(arr, 0x20), mul(pos, 0x20)))
        }
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeMemoryAccess(address[] memory arr, uint256 pos) internal pure returns (address res) {
        assembly {
            res := mload(add(add(arr, 0x20), mul(pos, 0x20)))
        }
    }
}


// File @openzeppelin/contracts/utils/introspection/ERC165.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


// File @openzeppelin/contracts/token/ERC1155/ERC1155.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.20;







/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 */
abstract contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI, IERC1155Errors {
    using Arrays for uint256[];
    using Arrays for address[];

    mapping(uint256 id => mapping(address account => uint256)) private _balances;

    mapping(address account => mapping(address operator => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256 /* id */) public view virtual returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     */
    function balanceOf(address account, uint256 id) public view virtual returns (uint256) {
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    ) public view virtual returns (uint256[] memory) {
        if (accounts.length != ids.length) {
            revert ERC1155InvalidArrayLength(ids.length, accounts.length);
        }

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts.unsafeMemoryAccess(i), ids.unsafeMemoryAccess(i));
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) public virtual {
        address sender = _msgSender();
        if (from != sender && !isApprovedForAll(from, sender)) {
            revert ERC1155MissingApprovalForAll(sender, from);
        }
        _safeTransferFrom(from, to, id, value, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
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

    /**
     * @dev Transfers a `value` amount of tokens of type `id` from `from` to `to`. Will mint (or burn) if `from`
     * (or `to`) is the zero address.
     *
     * Emits a {TransferSingle} event if the arrays contain one element, and {TransferBatch} otherwise.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement either {IERC1155Receiver-onERC1155Received}
     *   or {IERC1155Receiver-onERC1155BatchReceived} and return the acceptance magic value.
     * - `ids` and `values` must have the same length.
     *
     * NOTE: The ERC-1155 acceptance check is not performed in this function. See {_updateWithAcceptanceCheck} instead.
     */
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal virtual {
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
                    revert ERC1155InsufficientBalance(from, fromBalance, value, id);
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

    /**
     * @dev Version of {_update} that performs the token acceptance check by calling
     * {IERC1155Receiver-onERC1155Received} or {IERC1155Receiver-onERC1155BatchReceived} on the receiver address if it
     * contains code (eg. is a smart contract at the moment of execution).
     *
     * IMPORTANT: Overriding this function is discouraged because it poses a reentrancy risk from the receiver. So any
     * update to the contract state after this function would break the check-effect-interaction pattern. Consider
     * overriding {_update} instead.
     */
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
                _doSafeTransferAcceptanceCheck(operator, from, to, id, value, data);
            } else {
                _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, values, data);
            }
        }
    }

    /**
     * @dev Transfers a `value` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `value` amount.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
        _updateWithAcceptanceCheck(from, to, ids, values, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     * - `ids` and `values` must have the same length.
     */
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

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the values in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates a `value` amount of tokens of type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address to, uint256 id, uint256 value, bytes memory data) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
        _updateWithAcceptanceCheck(address(0), to, ids, values, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `values` must have the same length.
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory values, bytes memory data) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        _updateWithAcceptanceCheck(address(0), to, ids, values, data);
    }

    /**
     * @dev Destroys a `value` amount of tokens of type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `value` amount of tokens of type `id`.
     */
    function _burn(address from, uint256 id, uint256 value) internal {
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
        _updateWithAcceptanceCheck(from, address(0), ids, values, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `value` amount of tokens of type `id`.
     * - `ids` and `values` must have the same length.
     */
    function _burnBatch(address from, uint256[] memory ids, uint256[] memory values) internal {
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        _updateWithAcceptanceCheck(from, address(0), ids, values, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the zero address.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        if (operator == address(0)) {
            revert ERC1155InvalidOperator(address(0));
        }
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Performs an acceptance check by calling {IERC1155-onERC1155Received} on the `to` address
     * if it contains code at the moment of execution.
     */
    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) private {
        if (to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, value, data) returns (bytes4 response) {
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

    /**
     * @dev Performs a batch acceptance check by calling {IERC1155-onERC1155BatchReceived} on the `to` address
     * if it contains code at the moment of execution.
     */
    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) private {
        if (to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, values, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
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

    /**
     * @dev Creates an array in memory with only one value for each of the elements provided.
     */
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


// File @openzeppelin/contracts/token/ERC721/IERC721.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


// File @openzeppelin/contracts/utils/math/SignedMath.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}


// File @openzeppelin/contracts/utils/Strings.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

pragma solidity ^0.8.20;


/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}


// File contracts/interfaces/IBlueprintData.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;

interface IBlueprintData{
    enum MintPriceUnit {
        ETH,
        USDT,
        USDC
    }

    struct ERC20Data {
        address tokenAddress;
        uint256 amount;
    }

    struct ERC721Data {
        address tokenAddress;
        uint256 tokenId;
    }

    struct ERC1155Data {
        address tokenAddress;
        uint256 tokenId;
        uint256 amount;
    }

    struct BlueprintData {
        ERC20Data[] erc20Data;
        ERC721Data[] erc721Data;
        ERC1155Data[] erc1155Data;
    }

    struct BlueprintNFT {
        uint256 id;
        string name;
        string uri;
        address creator;
        uint256 totalSupply;
        uint256 mintPrice;
        MintPriceUnit mintPriceUnit;
        uint256 mintLimit;
        uint256 mintedAmount;
        BlueprintData data;
    }
}


// File contracts/Blueprint.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;
contract Blueprint is ERC1155, IBlueprintData {

    address public factory;  // Address for Factory contract
    string public baseURI;  // BaseURI for Blueprint contract
    uint256 public totalMintedBlueprintTokens; // Total minted Blueprints amount
    uint256 public currentTokenID = 0; // Current Blueprint ID
    uint256[] private _blueprintIDs; // Blueprint IDs
    address[] private _blueprintCreators; // Blueprint Creators

    mapping(uint256 => bool) private _existBlueprintID; // key: Blueprint ID, value: exist? true: false
    mapping(address => bool) private _existBlueprintCreator; // key: Creator address, value: exist? true: false
    mapping(address => uint256) public blueprintIdsByCreator; // Return created Ids by Creator
    mapping(uint256 => address) public idCreator; // key: Blueprint ID, value: Creator
    mapping(uint256 => uint256) public totalSupply; // key: Blueprint ID, value: totalSupply of token Id
    mapping(uint256 => BlueprintNFT) public BlueprintNFTs; // key: Blueprint ID, value: Blueprint NFT data
    mapping(uint256 => uint256) public BlueprintIDMintedAmount; // key: Blueprint ID, value: total minted amount of token Id


    event BlueprintCreated(
        uint256 indexed id, string name, string uri, address indexed creator, uint256 totalSupply, uint256 mintPrice,
        MintPriceUnit mintPriceUnit, uint256 mintLimit, ERC20Data[] erc20Data, ERC721Data[] erc721Data, ERC1155Data[] erc1155Data
    );
    event BlueprintMinted(
        address indexed to, uint256 indexed id, uint256 amount, uint256 mintedAmountOfId, uint256 totalMintedAmount
    );
    event BlueprintTransferred(address indexed from, address indexed to, uint256 indexed id, uint256 amount);
    event MintPriceUpdated(
        address indexed creator, uint256 indexed id, uint256 originMintPrice, MintPriceUnit originUnit, uint256 newMintPrice, MintPriceUnit newUnit
    );
    event MintLimitUpdated(address indexed creator, uint256 indexed id, uint256 originMintLimit, uint256 newMintLimit);
    event URIUpdated(address indexed creator, uint256 indexed id, string originURI, string newURI);
    event CreatorUpdated(address indexed creator, uint256 indexed id, address newCreator);

    event BlueprintUpdated(
        address indexed creator,
        uint256 indexed id,
        string originURI,
        string newURI,
        uint256 originMintPrice,
        MintPriceUnit originUnit,
        uint256 newMintPrice,
        MintPriceUnit newUnit,
        uint256 originMintLimit,
        uint256 newMintLimit
    );

    constructor(string memory _uri) ERC1155(_uri) {
        factory = msg.sender;
        baseURI = _uri;
    }

    modifier onlyFactory() { // Custom Modifier for enabling only Factory
        _checkOwner();
        _;
    }

    function createBlueprint( // Create Blueprint Token Id
        string memory name, // Name for Token
        string memory blueprintURI, // URI for Blueprint token cos it is ERC1155
        address creator, // Creator for Token
        uint256 idTotalSupply, // Total Supply of Blueprint token
        uint256 mintPrice, // The mint price when user mint this token
        MintPriceUnit mintPriceUnit, // Unit of token for mint price
        uint256 mintLimit, // Mint Limit per Blueprint token
        BlueprintData calldata data // Data for this token
    )
        external
        onlyFactory
        returns (uint256)
    {
        require(creator != address(0), "Invalid creator address");  // Check if creator address is 0
        uint256 newTokenID = ++currentTokenID; // Increase current token Id
        BlueprintNFT storage newBlueprint = BlueprintNFTs[newTokenID]; // Create new BlueprintNFT Instance

        // Insert the values to new BlueprintNFT Instance
        newBlueprint.id = newTokenID;
        newBlueprint.name = name;

        if(keccak256(abi.encodePacked("")) == keccak256(abi.encodePacked(blueprintURI))) {
            newBlueprint.uri = baseURI;
        } else {
            newBlueprint.uri = blueprintURI;
        }

        newBlueprint.creator = creator;
        newBlueprint.totalSupply = idTotalSupply;
        newBlueprint.mintPrice = mintPrice;
        newBlueprint.mintPriceUnit = mintPriceUnit;
        newBlueprint.mintLimit = mintLimit;
        newBlueprint.mintedAmount = 0;

        for (uint256 i = 0; i < data.erc20Data.length; i++) {
            newBlueprint.data.erc20Data.push(data.erc20Data[i]);
        }

        for (uint256 i = 0; i < data.erc721Data.length; i++) {
            newBlueprint.data.erc721Data.push(data.erc721Data[i]);
        }

        for (uint256 i = 0; i < data.erc1155Data.length; i++) {
            newBlueprint.data.erc1155Data.push(data.erc1155Data[i]);
        }

        // Add new Blueprint data to mappings
        _existBlueprintID[newTokenID] = true; // Set the existance of new TokenId to true
        _blueprintIDs.push(newTokenID); // Push the new blueprintId to array of blueprintIds

        if(_existBlueprintCreator[creator] == false) {
        _blueprintCreators.push(creator); // Push new creator to array
        _existBlueprintCreator[creator] = true; // Set existance of creator to true
    }

        idCreator[newTokenID] = creator;  // Mapping newTokenId to creator
        blueprintIdsByCreator[creator]++;
        totalSupply[newTokenID] = idTotalSupply; // Set total supply of id
        _setURI(blueprintURI);

        emit BlueprintCreated(
            newTokenID, name, blueprintURI, creator, idTotalSupply, mintPrice, mintPriceUnit, mintLimit,
            newBlueprint.data.erc20Data, newBlueprint.data.erc721Data, newBlueprint.data.erc1155Data
        ); // Emit event of createToken

        return newTokenID; // Return new token id
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        external
        onlyFactory
    {
        require(to != address(0), "Invalid receiver address"); // Check whether receiver address is 0 or not
        require(isValidBlueprintID(id), "Invalid Blueprint token ID"); // Check the existance of the selected blueprint id
        require(amount > 0, "Invalid Blueprint token amount"); // Check whether amount is more than 0
        require(BlueprintNFTs[id].totalSupply >= BlueprintIDMintedAmount[id] + amount, "Exceeds Blueprint ID total supply");
        if (BlueprintNFTs[id].mintLimit != 0) { // if mint limit is not 0
            require(BlueprintNFTs[id].mintLimit >= amount, "Exceeds Blueprint ID mint Limit"); // Check whether input amount is less than mint limit
        }

        _mint(to, id, amount, data); // Mint BlueprintNFT
        totalMintedBlueprintTokens += amount;
        BlueprintNFTs[id].mintedAmount += amount;
        BlueprintIDMintedAmount[id] += amount; // Add the newly minted amount to BlueprintMintedAmount according to the blueprint id

        emit BlueprintMinted(
            to, id, amount, BlueprintIDMintedAmount[id], totalMintedBlueprintTokens
        ); // Emit the BlueprintMinted event
    }

    function blueprintTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external {
        require(from != address(0), "Invalid sender address");
        require(to != address(0), "Invalid receiver address");
        require(isValidBlueprintID(id), "Invalid Blueprint token ID");
        require(amount > 0, "Invalid Blueprint token ID amount");
        require(balanceOf(from, id) >= amount, "Exceeds Account Blueprint token ID amount");

        safeTransferFrom(from, to, id, amount, data);

        emit BlueprintTransferred(from, to, id, amount);
    }

    function updateCreator(address creator, uint256 id, address newCreator) external onlyFactory {
        require(isValidBlueprintID(id), "Invalid Blueprint token ID");
        require(BlueprintNFTs[id].creator == creator, "Invalid creator");
        require(newCreator != address(0), "Invalid new Creator Address");
        require(blueprintIdsByCreator[creator] > 0, "Invalid creator address");

        idCreator[id] = newCreator;
        BlueprintNFTs[id].creator = newCreator;
        if(_existBlueprintCreator[newCreator] == false) {
            _existBlueprintCreator[newCreator] = true;
            _blueprintCreators.push(newCreator);
        }

        if(blueprintIdsByCreator[creator] == 1) {
            for (uint i = 0; i < _blueprintCreators.length; i++ ) {
                if(_blueprintCreators[i] == creator) {
                    _blueprintCreators[i] = _blueprintCreators[_blueprintCreators.length - 1];
                    _blueprintCreators.pop();
                }
            }
            _existBlueprintCreator[creator] = false;
            blueprintIdsByCreator[creator] = 0;
        } else {
            blueprintIdsByCreator[creator]--;
        }
        emit CreatorUpdated(creator, id, newCreator);
    }

    function updateMintPrice(address creator, uint256 id, uint256 newMintPrice, MintPriceUnit newUnit) external onlyFactory {
        require(isValidBlueprintID(id), "Invalid Blueprint token ID");
        require(BlueprintNFTs[id].creator == creator, "Invalid creator address");

        uint256 originMintPrice = BlueprintNFTs[id].mintPrice;
        MintPriceUnit originUnit = BlueprintNFTs[id].mintPriceUnit;
        BlueprintNFTs[id].mintPrice = newMintPrice;
        BlueprintNFTs[id].mintPriceUnit = newUnit;

        emit MintPriceUpdated(creator, id, originMintPrice, originUnit, newMintPrice, newUnit);
    }

    function updateMintLimit(address creator, uint256 id, uint256 newMintLimit) external onlyFactory {
        require(isValidBlueprintID(id), "Invalid Blueprint token ID");
        require(BlueprintNFTs[id].creator == creator, "Invalid creator address");

        uint256 originMintLimit = BlueprintNFTs[id].mintLimit;
        BlueprintNFTs[id].mintLimit = newMintLimit;

        emit MintLimitUpdated(creator, id, originMintLimit, newMintLimit);
    }

    function updateURI(address creator, uint256 id, string memory newURI) external onlyFactory {
        require(isValidBlueprintID(id), "Invalid Blueprint token ID");
        require(BlueprintNFTs[id].creator == creator, "Invalid creator");

        string memory originURI = BlueprintNFTs[id].uri;
        BlueprintNFTs[id].uri = newURI;

        emit URIUpdated(creator, id, originURI, newURI);
    }

    function updateBlueprint(
        address creator, uint256 id, string memory newURI, uint256 newMintPrice, MintPriceUnit newUnit, uint256 newMintLimit
    ) external onlyFactory {
        require(isValidBlueprintID(id), "Invalid Blueprint token ID");
        require(BlueprintNFTs[id].creator == creator, "Invalid creator");

        string memory originURI = BlueprintNFTs[id].uri;
        uint256 originMintPrice = BlueprintNFTs[id].mintPrice;
        MintPriceUnit originUnit = BlueprintNFTs[id].mintPriceUnit;
        uint256 originMintLimit = BlueprintNFTs[id].mintLimit;

        BlueprintNFTs[id].uri = newURI;
        BlueprintNFTs[id].mintPrice = newMintPrice;
        BlueprintNFTs[id].mintPriceUnit = newUnit;
        BlueprintNFTs[id].mintLimit = newMintLimit;

        emit BlueprintUpdated(
            creator, id, originURI, newURI, originMintPrice, originUnit, newMintPrice, newUnit, originMintLimit, newMintLimit
        );
    }

    function getMintPrice(uint256 tokenId) external view returns (uint256) {
        return BlueprintNFTs[tokenId].mintPrice;
    }

    function getMintPriceUnit(uint256 id) external view returns(MintPriceUnit) {
        return BlueprintNFTs[id].mintPriceUnit;
    }

    function getMintLimit(uint256 tokenId) external view returns (uint256) {
        return BlueprintNFTs[tokenId].mintLimit;
    }

    function getBlueprintNFTData(uint256 id) external view returns (BlueprintNFT memory) {
        return BlueprintNFTs[id];
    }

    function getBlueprintIds() external view returns (uint256[] memory) {
        return _blueprintIDs;
    }

    function getBlueprintCreators() external view returns (address[] memory) {
        return _blueprintCreators;
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        bytes memory uriBytes = bytes(BlueprintNFTs[tokenId].uri);
        if (uriBytes.length == 0) {
            return string(abi.encodePacked(baseURI));
        } else {
            return string(abi.encodePacked(BlueprintNFTs[tokenId].uri));
        }
    }

    function isValidBlueprintID(uint256 id) public view returns (bool) {
        return _existBlueprintID[id];
    }

    function isValidBlueprintCreator(address creator) public view returns (bool) {
        return _existBlueprintCreator[creator];
    }

    function _checkOwner() internal view virtual {
        require(msg.sender == factory, "Only Factory can call this function");
    }
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.20;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


// File contracts/Custody.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;
contract Custody {

  address public factory; // Factory Address
  address public blueprintAddress; // BluePrint Address
  uint256 public blueprintId; // BluePrint ID
  uint256 public blueprintIdAmount; // Amount according to BluePrint
  address[] internal erc20Tokens; // Address Array for ERC20 Tokens deposited
  address[] internal erc721Tokens; // Address Array for ERC721 Tokens deposited
  address[] internal erc1155Tokens; // Address Array for ERC1155 Tokens deposited

  mapping(address => uint256) internal erc20Amount; // Mapping for from ERC20 Address to Amount
  mapping(address => uint256[]) internal erc721Ids; // Mapping for from ERC721 Address to ID Array
  mapping(address => uint256[]) internal erc1155Ids; // Mapping for from ERC1155 Addresses to ID Array
  mapping(address => mapping(uint256 => uint256)) internal erc1155Amounts; // Mapping for from ERC721 Address to ID Array

  event DepositERC20(address indexed owner, address indexed tokenAddress, uint256 tokenAmount, uint256 tokenTotalAmount);
  event WithdrawERC20(address indexed receiver, address indexed tokenAddress, uint256 tokenAmount, uint256 tokenTotalAmount);
  event DepositERC721(address indexed owner, address indexed tokenAddress, uint256 tokenId);
  event WithdrawERC721(address indexed receiver, address indexed tokenAddress, uint256 tokenId);
  event DepositERC1155(address indexed owner, address indexed tokenAddress, uint256 tokenId, uint256 tokenAmount, uint256 tokenTotalAmount);
  event WithdrawERC1155(address indexed receiver, address indexed tokenAddress, uint256 tokenId, uint256 tokenAmount, uint256 tokenTotalAmount);
  event DepositBlueprint(
    address indexed owner, address indexed blueprintAddress, uint256 blueprintId, uint256 amount, uint256 blueprintIdTotalAmount
  );
  event WithdrawBlueprint(
    address indexed receiver, address indexed blueprintAddress, uint256 blueprintId, uint256 amount, uint256 blueprintIdTotalAmount
  );

  modifier onlyFactory() {
    require(msg.sender == factory, "Only Factory can call this function");
    _;
  }

  constructor(address _blueprintAddress, uint256 _blueprintId) {
    factory = msg.sender;
    blueprintAddress = _blueprintAddress;
    blueprintId = _blueprintId;
  }

  // Store ERC-20 tokens
  function depositERC20(address tokenAddress, uint256 amount) external onlyFactory {
    require(tokenAddress != address(0), "Invalid ERC20 Token Address");
    require(amount > 0, "Invalid ERC20 Token Amount");

    // Transfer ERC-20 Token from user to contract
    IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
    erc20Tokens.push(tokenAddress); // Add deposited token to ERC20 token Array
    erc20Amount[tokenAddress] += amount; // Add depoisted ERC20 Token amount to Total Amount

    emit DepositERC20(msg.sender, tokenAddress, amount, erc20Amount[tokenAddress]);
  }

  function withdrawERC20(address to, address tokenAddress, uint256 amount) external onlyFactory {
    // Check for Invalid Access
    require(tokenAddress != address(0), "Invalid ERC20 Token Address");
    require(amount > 0, "Invalid ERC20 Token Amount");
    require(erc20Amount[tokenAddress] >= amount, "Exceeds ERC20 Total Amount");

    IERC20(tokenAddress).transfer(to, amount); // Transfer ERC20 Token to user
    erc20Amount[tokenAddress] -= amount; // Decrease the ERC20 Amount from User Address

    emit WithdrawERC20(msg.sender, tokenAddress, amount, erc20Amount[tokenAddress]);
  }

  function depositERC721(address tokenAddress, uint256 tokenId) external onlyFactory {
    // Check for Invalid Access
    require(tokenAddress != address(0), "Invalid ERC721 Token Address");

    IERC721(tokenAddress).safeTransferFrom(msg.sender, address(this), tokenId); // Transfer NFT from user to contract
    erc721Tokens.push(tokenAddress); // Add deposited token to ERC721 token Array
    erc721Ids[tokenAddress].push(tokenId); // Add ERC721 Token Id to user's token Id array

    emit DepositERC721(msg.sender, tokenAddress, tokenId);
  }

  function withdrawERC721(address to, address tokenAddress, uint256 tokenId) external onlyFactory {
    require(to != address(0), "Invaild Receiver Address");
    require(tokenAddress != address(0), "Invalid ERC721 Token Address");
    (bool isValid, uint256 index) = isValidERC721TokenId(
      tokenAddress, tokenId); // Check the availablity of tokenId and get index of token id from array
    require(isValid, "Invalid ERC721 Token ID");

    IERC721(tokenAddress).approve(to, tokenId); // Approve for transferring token from contract to user
    IERC721(tokenAddress).safeTransferFrom(address(this), to, tokenId); // Transfer ERC721 Token from contract to user

    require(index <= erc721Ids[tokenAddress].length - 1, "Index out of bound");
    // Removing the trasferred tokenId from array
    for(uint256 i = index; i < erc721Ids[tokenAddress].length - 1; i++) {
      erc721Ids[tokenAddress][i] = erc721Ids[tokenAddress][i+1];
    }
    erc721Ids[tokenAddress].pop();

    emit WithdrawERC721(to, tokenAddress, tokenId);
  }

  function depositERC1155(address tokenAddress, uint256 tokenId, uint256 tokenAmount) external onlyFactory {

    // Check for Validation of Deposit ERC1155 Token
    require(tokenAddress != address(0), "Invalid ERC1155 Token Address");
    require(tokenAmount != 0, "ERC1155 token Amount must not be more than 0");

    // Transfer ERC1155 token from user wallet to contract
    IERC1155(tokenAddress).safeTransferFrom(msg.sender, address(this), tokenId, tokenAmount, "");

    erc1155Tokens.push(tokenAddress); // Store the token Address to ERC1155 token Address array
    erc1155Ids[tokenAddress].push(tokenId); // Store the token Id to ERC1155 token Id array
    erc1155Amounts[tokenAddress][tokenId] += tokenAmount; // Add the token Amount to ERC1155 token amount according to the user and id

    emit DepositERC1155(msg.sender, tokenAddress, tokenId, tokenAmount, erc1155Amounts[tokenAddress][tokenId]);
  }

  function withdrawERC1155(address to, address tokenAddress, uint256 tokenId, uint256 tokenAmount) external onlyFactory {
    // Check for Validation of Withdraw ERC1155 Token
    require(to != address(0), "Invalid Receiver Address");
    require(tokenAddress != address(0), "Invalid Token Address");
    bool isValid = isValidERC1155TokenId(tokenAddress, tokenId);
    require(isValid, "Invalid ERC1155 Token Id");
    require(tokenAmount > 0, "Invalid ERC1155 Token Amount");
    require(erc1155Amounts[tokenAddress][tokenId] >= tokenAmount, "Exceeds ERC1155 Total Amount");

    IERC1155(tokenAddress).setApprovalForAll(to, true);
    IERC1155(tokenAddress).safeTransferFrom(address(this), to, tokenId, tokenAmount, "");
    erc1155Amounts[tokenAddress][tokenId] -= tokenAmount;

    emit WithdrawERC1155(msg.sender, tokenAddress, tokenId, tokenAmount, erc1155Amounts[tokenAddress][tokenId]);
  }

  function depositBlueprint(uint256 amount) external onlyFactory {
    require(amount > 0, "Invalid Blueprint Token Amount");

    IERC1155(blueprintAddress).safeTransferFrom(msg.sender, address(this), blueprintId, amount, "");
    blueprintIdAmount += amount;

    emit DepositBlueprint(msg.sender, blueprintAddress, blueprintId, amount, blueprintIdAmount);
  }

  function withdrawBlueprint(address to, uint256 amount) external onlyFactory {
    require(amount > 0, "Invalid Blueprint Token Amount");
    require(blueprintIdAmount >= amount, "Exceeds Blueprint Total Amount");

    IERC1155(blueprintAddress).setApprovalForAll(to, true);
    IERC1155(blueprintAddress).safeTransferFrom(address(this), to, blueprintId, amount, "");
    blueprintIdAmount -= amount;

    emit WithdrawBlueprint(to, blueprintAddress, blueprintId, amount, blueprintIdAmount);
  }

  function isValidERC721TokenId(address tokenAddress, uint256 tokenId) public view returns(bool, uint256) {
    // Search for token Id which will be checked
    for(uint256 i = 0; i < erc721Ids[tokenAddress].length; i++) {
      if(erc721Ids[tokenAddress][i] == tokenId)
      {
        return (true, i);
      }
    }
    return (false, 0);
  }

  function isValidERC1155TokenId(address tokenAddress, uint256 tokenId) public view returns(bool) {
    for(uint256 i = 0; i < erc1155Ids[tokenAddress].length; i++) {
      if(tokenId == erc1155Ids[tokenAddress][i]) {
        return  true;
      }
    }
    return false;
  }

  function getERC20Tokens() external view returns (address[] memory) {
    return erc20Tokens;
  }

  function getERC721Tokens() external view returns (address[] memory) {
    return erc721Tokens;
  }

  function getERC1155Tokens() external view returns (address[] memory) {
    return erc1155Tokens;
  }

  function getERC20Amount(address tokenAddress) external view returns (uint256) {
    return erc20Amount[tokenAddress];
  }

  function getERC721IDs(address tokenAddress) external view returns (uint256[] memory) {
    return erc721Ids[tokenAddress];
  }

  function getERC1155IDs(address tokenAddress) external view returns (uint256[] memory) {
    return erc1155Ids[tokenAddress];
  }

  function getERC1155IDAmount(address tokenAddress, uint256 tokenId) external view returns (uint256) {
    return erc1155Amounts[tokenAddress][tokenId];
  }

  function onERC721Received(address, address, uint256, bytes memory) public pure returns (bytes4) {
    return this.onERC721Received.selector;
  }

  function onERC1155Received(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes calldata data
  )
    public
    pure
    returns (bytes4)
  {
    return this.onERC1155Received.selector;
  }
}


// File contracts/interfaces/ICustody.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;

interface ICustody {
    function factory() external view returns (address);
    function blueprintAddress() external view returns (address);
    function blueprintId() external view returns (uint256);
    function blueprintIdAmount() external view returns (uint256);

    function depositBlueprint(uint256 amount) external;
    function withdrawBlueprint(address to, uint256 amount) external;
    function depositERC20(address tokenAddress, uint256 amount) external;
    function withdrawERC20(address to, address tokenAddress, uint256 amount) external;
    function depositERC721(address tokenAddress, uint256 tokenId) external;
    function withdrawERC721(address to, address tokenAddress, uint256 tokenId) external;
    function depositERC1155(address tokenAddress, uint256 tokenId, uint256 amount) external;
    function withdrawERC1155(address to, address tokenAddress, uint256 tokenId, uint256 amount) external;

    function isValidERC721TokenId(address tokenAddress, uint256 tokenId) external view returns(bool, uint256);
    function isValidERC1155TokenId(address tokenAddress, uint256 tokenId) external view returns(bool);

    function getERC20Tokens() external view returns (address[] memory);
    function getERC721Tokens() external view returns (address[] memory);
    function getERC1155Tokens() external view returns (address[] memory);

    function getERC20Amount(address tokenAddress) external view returns (uint256);
    function getERC721IDs(address tokenAddress) external view returns (uint256[] memory);
    function getERC1155IDs(address tokenAddress) external view returns (uint256[] memory);
    function getERC1155IDAmount(address tokenAddress, uint256 id) external view returns (uint256);
}


// File contracts/Product.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;
contract Product is ERC1155 {

    address public factory; // Factory contract address
    string public baseURI; // URI for Product contract
    uint256 public totalMintedProductToken; // Total Minted Product Token
    uint256[] private _productIDs; // Array of created product ids

    mapping(uint256 => bool) public isValidProductID; // key: Product ID, value: true or false, default: false
    mapping(uint256 => address) public productIDCreators; // key: Product ID, value: Creator
    mapping(uint256 => uint256) public productIDMintedAmount; // key: Product ID, value: minted amount
    mapping(uint256 => string) public productIdUri;

    event ProductCreated(uint256 indexed tokenId, address creator, uint256 indexed blueprintId);
    event ProductMinted(
        address indexed to, uint256 indexed id, uint256 amount, uint256 mintedAmountOfId, uint256 totalMintedAmount
    );
    event ProductBurned(address indexed to, uint256 indexed id, uint256 amount, uint256 mintedAmountOfId, uint256 totalMintedAmount);
    event ProductTransferred(address indexed from, address indexed to, uint256 indexed id, uint256 amount);

    modifier onlyFactory() {
        _checkOwner();
        _;
    }

    constructor(string memory _uri) ERC1155(_uri) {
        factory = msg.sender;
        baseURI = _uri;
        _setURI(_uri); // set base URI
    }

    // Create a new Product
    function createProduct(
        address creator, uint256 blueprintId, string memory blueprintUri
    )
        external
        onlyFactory
        returns (uint256)
    { // create new Product token
        uint256 newTokenID = blueprintId; // create new Product ID
        productIdUri[newTokenID] = blueprintUri;
        isValidProductID[newTokenID] = true; // Set newTokenID to valid Product ID
        productIDCreators[newTokenID] = creator; // Set creator of newTokenID
        _productIDs.push(newTokenID); // Add newTokenID to Product ID array

        emit ProductCreated(newTokenID, creator, blueprintId);
        return newTokenID;
    }

    // Mint Product
    function mint(address to, uint256 id, uint256 amount, bytes memory data) external onlyFactory {
        require(to != address(0), "Invalid Receiver address");
        require(isValidProductID[id], "Invalid Product ID");
        require(amount > 0, "Invalid Product Mint amount");

        _mint(to, id, amount, data); // Mint Product NFT
        totalMintedProductToken += amount;
        productIDMintedAmount[id] += amount;

        emit ProductMinted(to, id, amount, productIDMintedAmount[id], totalMintedProductToken);
    }

    // Burn Product NFT
    function burn(address to, uint256 id, uint256 amount) external onlyFactory {
        require(to != address(0), "Invalid account address");
        require(isValidProductID[id], "Invalid Product ID");
        require(amount > 0, "Invalid Product Burn amount");
        require(balanceOf(to, id) >= amount, "Exceeds Account Product ID amount");

        _burn(to, id, amount); // Burn Product NFT

        totalMintedProductToken -= amount;
        productIDMintedAmount[id] -= amount;

        emit ProductBurned(to, id, amount, productIDMintedAmount[id], totalMintedProductToken);
    }

    function productTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external {
        require(from != address(0), "Invalid sender address");
        require(to != address(0), "Invalid receiver address");
        require(isValidProductID[id], "Invalid Product ID");
        require(amount > 0, "Invalid Product amount");
        require(balanceOf(from, id) >= amount, "Exceeds Account Product ID amount");

        safeTransferFrom(from, to, id, amount, data);
        emit ProductTransferred(from, to, id, amount);
    }

    function getProductIDs() external view returns (uint256[] memory) {
        return _productIDs;
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(productIdUri[tokenId]));
    }

    function _checkOwner() internal view virtual {
        require(msg.sender == factory, "Only Factory can call this function");
    }
}


// File contracts/Factory.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;
contract Factory is IBlueprintData, Ownable {

  uint256 public componentTokenLimit; // Component Total Amount Limit
  uint256 public blueprintCreationFee; // Blueprint Creation Fee
  uint256 public productDecomposeFee; // Product Decompose Fee
  address public treasuryAddress; // Treasury Address
  address public usdt; // USDT address
  address public usdc; // USDC address

  Blueprint public _blueprint;
  Product public _product;
  Custody public _custody;
  mapping(uint256 => Custody) public custodyContracts;

  event ComponentLimitUpdated(address indexed owner, uint256 originLimit, uint256 newLimit);
  event BlueprintCreationFeeUpdated(address indexed owner, uint256 originCreationFee, uint256 newCreationFee);
  event ProductDecomposeFeeUpdated(address indexed owner, uint256 originDecomposeFee, uint256 newDecomposeFee);
  event TreasuryAddressUpdated(address indexed owner, address originTreasury, address newTreasury);
  event ProductDecomposed(address indexed account, uint256 id, uint256 amount);

  constructor (
      string memory blueprintURI,
      string memory productURI,
      uint256 componentLimit,
      uint256 creationFee,
      uint256 decomposeFee,
      address treasury,
      address usdtAddress,
      address usdcAddress
  ) Ownable(msg.sender) {
      _blueprint = new Blueprint(blueprintURI);
      _product = new Product(productURI);

      componentTokenLimit = componentLimit;
      blueprintCreationFee = creationFee;
      productDecomposeFee = decomposeFee;
      treasuryAddress = treasury;
      usdt = usdtAddress;
      usdc = usdcAddress;
  }

  function createBlueprint(
    string memory name,
    string memory uri,
    uint256 totalSupply,
    uint256 mintPrice,
    MintPriceUnit mintPriceUnit,
    uint256 mintLimit,
    BlueprintData calldata data
  )
    external
    returns (uint256)
  {
    // Check Current Component Token Total Amount is less than the Limit, and the BlueprintData is valid
    require(isValidBlueprintData(data), "Invalid BlueprintData");

    // Create new Blueprint ID using Blueprint Contract function
    uint256 blueprintId = _blueprint.createBlueprint(name, uri, msg.sender, totalSupply, mintPrice, mintPriceUnit, mintLimit, data);
    _custody = new Custody(address(_blueprint), blueprintId); // Create new Custody for Blueprint ID
    custodyContracts[blueprintId] = _custody;
    return blueprintId;
  }

  function mintBlueprint(
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
    )
     external
     payable
    {
      require(to != address(0), "Invalid receiver address");
      require(_blueprint.isValidBlueprintID(id), "Invalid Blueprint ID");
      require(amount > 0, "Invalid amount");
      require(_blueprint.totalSupply(id) >= _blueprint.BlueprintIDMintedAmount(id) + amount, "Exceeds Blueprint ID amount");
      if (_blueprint.getMintLimit(id) != 0) { // if mint limit is not 0
          require(_blueprint.getMintLimit(id) >= amount, "Exceeds Blueprint ID mint Limit"); // Check whether input amount is less than mint limit
      }

      MintPriceUnit mintPriceUnit = _blueprint.getMintPriceUnit(id);
      uint256 mintPrice = _blueprint.getMintPrice(id); // Get Blueprint mint price of given id
      address creator = _blueprint.idCreator(id); // Get Blueprint creator of given id

      if (mintPrice != 0) { // if mint price is not 0
          uint256 totalMintFee = mintPrice * amount; // Get Total Mint Fee

          if( mintPriceUnit == MintPriceUnit.ETH ) {
            uint256 fee = totalMintFee + blueprintCreationFee;
            require(msg.value == fee, "Failed to transfer platform fee");

            payable(treasuryAddress).call{value: blueprintCreationFee}("");
            payable(creator).call{value: totalMintFee}("");
          } else if(mintPriceUnit == MintPriceUnit.USDT) {
            require(msg.value == blueprintCreationFee, "Failed to transfer Blueprint creation fee");
            payable(treasuryAddress).call{value: blueprintCreationFee}("");

            IERC20(usdt).transferFrom(msg.sender, address(this), totalMintFee);
            IERC20(usdt).transfer(creator, totalMintFee);
          } else if(mintPriceUnit == MintPriceUnit.USDC) {
            require(msg.value == blueprintCreationFee, "Failed to transfer Blueprint creation fee");
            payable(treasuryAddress).call{value: blueprintCreationFee}("");

            IERC20(usdc).transferFrom(msg.sender, address(this), totalMintFee);
            IERC20(usdc).transfer(creator, totalMintFee);
          }
      } else { // if mint price is 0
        require(msg.value == blueprintCreationFee, "Failed to transfer Blueprint creation fee");
        payable(treasuryAddress).call{value: blueprintCreationFee}("");
      }

      //   Mint Blueprint Token of given id
      _blueprint.mint(to, id, amount, data);
  }

  //  Create Product (Entire Flowchart 20 - 28)
  function createProduct(uint256 blueprintId, uint256 amount, bytes memory data) external {
      require(_blueprint.isValidBlueprintID(blueprintId), "Invalid Blueprint ID");
      require(amount > 0, "Invalid Blueprint amount");
      require(_blueprint.balanceOf(msg.sender, blueprintId) >= amount, "Insufficient Blueprint ID amount"); // Check Blueprint Balance

      // Get BlueprintNFT Data from the Blueprint ID
      BlueprintData memory componentData = _blueprint.getBlueprintNFTData(blueprintId).data;

      ERC20Data[] memory erc20Data = componentData.erc20Data; // ERC20 Tokens
      ERC721Data[] memory erc721Data = componentData.erc721Data; // ERC721 Tokens
      ERC1155Data[] memory erc1155Data = componentData.erc1155Data; // ERC1155 Tokens
      string memory blueprintUri = _blueprint.getBlueprintNFTData(blueprintId).uri;

      address custodyAddress = address(custodyContracts[blueprintId]); // Get Custody Address for given Blueprint ID

      // Approve Blueprint to Custody
      _blueprint.safeTransferFrom(msg.sender, address(this), blueprintId, amount, data);
      _blueprint.setApprovalForAll(custodyAddress, true);

      // Check ERC20 Token Balance and Approve it to Custody
      for (uint i = 0; i < erc20Data.length; i++) {
          address erc20Address = erc20Data[i].tokenAddress;
          uint256 erc20Amount = erc20Data[i].amount;
          uint256 erc20TotalAmount = erc20Amount * amount;

          require(IERC20(erc20Address).balanceOf(msg.sender) >= erc20TotalAmount, "Insufficient ERC20 Token Balance");
          IERC20(erc20Address).transferFrom(msg.sender, address(this), erc20TotalAmount);
          IERC20(erc20Address).approve(custodyAddress, erc20TotalAmount); // Approve ERC20 Token
      }

      // Check ERC721 Token ID and Approve it to Custody
      for (uint j = 0; j < erc721Data.length; j++) {
          address erc721Address = erc721Data[j].tokenAddress;
          uint256 erc721Id = erc721Data[j].tokenId;

          // Check the owner of token id is msg sender
          require(IERC721(erc721Address).ownerOf(erc721Id) == msg.sender, "Insufficient ERC721 Token ID");
          IERC721(erc721Address).transferFrom(msg.sender, address(this), erc721Id);
          IERC721(erc721Address).approve(custodyAddress, erc721Id); // Approve ERC721 Token ID
      }

      // Check ERC1155 Token ID Balance and Approve it to Custody
      for (uint k = 0; k < erc1155Data.length; k++) {
          address erc1155Address = erc1155Data[k].tokenAddress;
          uint256 erc1155Id = erc1155Data[k].tokenId;
          uint256 erc1155Amount = erc1155Data[k].amount;
          uint256 erc1155TotalAmount = erc1155Amount * amount;

          require(IERC1155(erc1155Address).balanceOf(msg.sender, erc1155Id) >= erc1155TotalAmount, "Insufficient ERC1155 Token ID Balance");
          IERC1155(erc1155Address).safeTransferFrom(msg.sender, address(this), erc1155Id, erc1155TotalAmount, "");
          IERC1155(erc1155Address).setApprovalForAll(custodyAddress, true); // Approve ERC1155 Token
      }

      // Transfer Blueprint to Custody
      ICustody(custodyAddress).depositBlueprint(amount);

      // Transfer ERC20 Tokens to Custody
      for (uint i = 0; i < erc20Data.length; i++) {
          address erc20Address = erc20Data[i].tokenAddress;
          uint256 erc20Amount = erc20Data[i].amount;
          uint256 erc20TotalAmount = erc20Amount * amount;

          ICustody(custodyAddress).depositERC20(erc20Address, erc20TotalAmount);
      }

      // Transfer ERC721 Token IDs to Custody contract
      for (uint j = 0; j < erc721Data.length; j++) {
          address erc721Address = erc721Data[j].tokenAddress;
          uint256 erc721Id = erc721Data[j].tokenId;

          ICustody(custodyAddress).depositERC721(erc721Address, erc721Id);
      }

      // Transfer ERC1155 Tokens to Custody contract
      for (uint k = 0; k < erc1155Data.length; k++) {
          address erc1155Address = erc1155Data[k].tokenAddress;
          uint256 erc1155Id = erc1155Data[k].tokenId;
          uint256 erc1155Amount = erc1155Data[k].amount;
          uint256 erc1155TotalAmount = erc1155Amount * amount;

          ICustody(custodyAddress).depositERC1155(erc1155Address, erc1155Id, erc1155TotalAmount);
      }

      // Check exists Product ID for given Blueprint ID
      uint256 productId = blueprintId;
      if ( !_product.isValidProductID(productId)) { // if not exist Product ID for given Blueprint ID
          productId = _product.createProduct(msg.sender, blueprintId, blueprintUri); // Create New Product ID
      }

      // Mint Product ID
      _product.mint(msg.sender, productId, amount, data);
  }

  // Decompose Product (Entire flowchar 29-36)
  function decomposeProduct(uint256 productId, uint256 productAmount) external payable {
      require(_product.isValidProductID(productId), "Invalid Product ID");
      require(productAmount > 0, "Invalid Product amount");
      require(_product.balanceOf(msg.sender, productId) >= productAmount, "Insufficient Product ID amount");

       // Check whether ETH amount sent by user is same as Product exchange fee
      require(msg.value == productDecomposeFee, 'Invalid Product Decompose Fee');

      bool success = payable(treasuryAddress).send(productDecomposeFee); // Send Product Decompose Fee to treasury
      require(success, "Failed send Product Decompose Fee to Treasury");

      // Burn Product Token
      _product.burn(msg.sender, productId, productAmount);

      address custodyAddress = address(custodyContracts[productId]); // Get Custody Address for given Product ID

      // Get BlueprintNFT Data from the Blueprint ID
      BlueprintData memory componentData = _blueprint.getBlueprintNFTData(productId).data;

      ERC20Data[] memory erc20Data = componentData.erc20Data; // ERC20 Tokens
      ERC721Data[] memory erc721Data = componentData.erc721Data; // ERC721 Tokens
      ERC1155Data[] memory erc1155Data = componentData.erc1155Data; // ERC1155 Tokens

      // Transfer Blueprint Token to User
      ICustody(custodyAddress).withdrawBlueprint(msg.sender, productAmount);

      // Transfer ERC20 Tokens to User
      for (uint i = 0; i < erc20Data.length; i++) {
          address erc20Address = erc20Data[i].tokenAddress;
          uint256 erc20Amount = erc20Data[i].amount;
          uint256 erc20TotalAmount = erc20Amount * productAmount;

          ICustody(custodyAddress).withdrawERC20(msg.sender, erc20Address, erc20TotalAmount);
      }

      // Transfer ERC721 Token IDs to User
      for (uint j = 0; j < erc721Data.length; j++) {
          address erc721Address = erc721Data[j].tokenAddress;
          uint256 erc721Id = erc721Data[j].tokenId;

          ICustody(custodyAddress).withdrawERC721(msg.sender, erc721Address, erc721Id);
      }

      // Transfer ERC1155 Tokens to User
      for (uint k = 0; k < erc1155Data.length; k++) {
          address erc1155Address = erc1155Data[k].tokenAddress;
          uint256 erc1155Id = erc1155Data[k].tokenId;
          uint256 erc1155Amount = erc1155Data[k].amount;
          uint256 erc1155TotalAmount = erc1155Amount * productAmount;

          ICustody(custodyAddress).withdrawERC1155(msg.sender, erc1155Address, erc1155Id, erc1155TotalAmount);
      }

      emit ProductDecomposed(msg.sender, productId, productAmount);
  }

  // Only Blueprint Creator can call this function
  function updateBlueprintMintPrice(uint256 id, uint256 newMintPrice, MintPriceUnit newUnit) external {
      _blueprint.updateMintPrice(msg.sender, id, newMintPrice, newUnit);
  }

  // Only Blueprint Creator can call this function
  function updateBlueprintMintLimit(uint256 id, uint256 newMintLimit) external {
      _blueprint.updateMintLimit(msg.sender, id, newMintLimit);
  }

  // Only Blueprint Creator can call this function
  function updateBlueprintURI(uint256 id, string memory newURI) external {
      _blueprint.updateURI(msg.sender, id, newURI);
  }

  // Only Blueprint Creator can call this function
  function updateBlueprintCreator(uint256 id, address newCreator) external {
      _blueprint.updateCreator(msg.sender, id, newCreator);
  }

  // Only Blueprint Creator can call this function
  function updateBlueprintData(
    uint256 id, string memory newURI, uint256 newMintPrice, MintPriceUnit newUnit, uint256 newMintLimit
  ) external {
    _blueprint.updateBlueprint(msg.sender, id, newURI, newMintPrice, newUnit, newMintLimit);
  }

  /* -------------------------------- Owner Setting -------------------------------- */

  // Set Component Limit
  function updateComponentLimit(uint256 newLimit) external onlyOwner {
      uint256 originLimit = componentTokenLimit;
      componentTokenLimit = newLimit;

      emit ComponentLimitUpdated(owner(), originLimit, newLimit);
  }

  // Set Blueprint Creation Fee
  function updateBlueprintCreationFee(uint256 newCreationFee) external onlyOwner {
      uint256 originCreationFee = blueprintCreationFee;
      blueprintCreationFee = newCreationFee;

      emit BlueprintCreationFeeUpdated(owner(), originCreationFee, newCreationFee);
  }

  // Set Product Decompose Fee
  function updateProductDecomposeFee(uint256 newDecomposeFee) external onlyOwner {
      uint256 originDecomposeFee = productDecomposeFee;
      productDecomposeFee = newDecomposeFee;

      emit ProductDecomposeFeeUpdated(owner(), originDecomposeFee, newDecomposeFee);
  }

  // Set Treasury Address
  function updateTreasuryAddress(address newTreasury) external onlyOwner {
      address originTreasury = treasuryAddress;
      treasuryAddress = newTreasury;

      emit TreasuryAddressUpdated(owner(), originTreasury, newTreasury);
  }

  function getCustodyAddress(uint256 blueprintId) external view returns(address) {
    return address(custodyContracts[blueprintId]);
  }

  function isValidBlueprintData(BlueprintData calldata data) internal view returns (bool) {
      uint totalLength = data.erc20Data.length + data.erc721Data.length + data.erc1155Data.length;
      require(totalLength <= componentTokenLimit, "Exceeds Component Token Limit"); // check input Component amount is less than the limit

      if ((data.erc20Data.length == 0) && (data.erc721Data.length == 0) && (data.erc1155Data.length == 0)) {
        return false;
      }
      return true;
  }

  function onERC1155Received(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes calldata data
  )
    public
    pure
    returns (bytes4)
  {
    return this.onERC1155Received.selector;
  }
}