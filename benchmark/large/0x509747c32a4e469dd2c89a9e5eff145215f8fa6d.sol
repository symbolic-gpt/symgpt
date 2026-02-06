// SPDX-License-Identifier: MIT
// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol


pragma solidity >=0.8.25;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol


pragma solidity >=0.8.25;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol


pragma solidity >=0.8.25;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol


pragma solidity >=0.8.25;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol


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
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
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
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
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
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 9; // Change to 9 to match 
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

// File: contracts/barebones.sol


pragma solidity >=0.8.25;









contract AMERICANSHIBA is
    ReentrancyGuard,
    ERC20("AMERICAN SHIBA", "USHIBA"),
    Ownable(msg.sender)
{
    using SafeERC20 for IERC20;
    IUniswapV2Router02 public uniswapRouter;
    IUniswapV2Pair public uniswapPair;

    // General Treasury Wallet Address
    address payable public generalTreasury;

    // Fee Collector Wallet Address
    address payable public USHIBAfeeCollector;

    address public realRecipient;

    // Buy and Sell Fees
    uint256 public swapFee = 300; // Initialize swap fee to 3%, you can adjust this value as needed
    uint256 public buyFee = 200;
    //2.0% fee initially set on buy orders, cannot exceed 5%, in basis points.
    uint256 public sellFee = 200;
    //2.0% fee to additionally set on wallets when appropriate, cannot exceed 5%, in basis points.
    //uint256 public swapFeePercent = 300;
    //3.0% fee for swap to native aka sell orders, cannot exceed 5%, in basis points.

    uint256 public constant MAX_SUPPLY = 60 * 10**15 * 10**9; // 60 Quadrillion & 9 Decimals. verify in erc20.sol
    uint256 public MAX_WALLET = MAX_SUPPLY / 5; // Max wallet is 12 Quad
    uint256 public MAX_TX_LIMIT = MAX_SUPPLY / 80; // Max transaction is 750T

    address private constant INITIAL_USHIBAfeeCollector =
        0xd19AE35270102F565c1862F0a91cbdbd375CA5ca; // Correct before Deployment
    address private constant INITIAL_GeneralTreasury =
        0x31378e92B11ac05370704211f6edba522356Fc7F; // Correct before Deployment
    address private constant INITIAL_realRecipient =
        0xC3eC81FF1e452D6d1882EDF076f603dF7C819566; // Correct before Deployment

    mapping(address => bool) public isInterceptorAddress; //mevbots beware...
    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public isWhitelistedFromFees;
    mapping(address => bool) public isSellFeeAddress; // Tracks addresses where if interacted with, sell fees activate.

    // Events
    event RouterUpdated(address indexed newRouter);
    event USHIBAFeeCollectorUpdated(address indexed newFeeCollector);

    event EtherReceived(
        address indexed sender,
        uint256 amount,
        address indexed treasury
    );
    event EtherFallbackReceived(address indexed sender, uint256 amount);

    event BlacklistedStatusUpdated(address account, bool status);
    event WhitelistedStatusUpdated(address account, bool status);

    event MaxTxLimitUpdated(uint256 newLimit);
    event MaxWalletSizeUpdated(uint256 newMaxWalletSize);

    event InterceptorAddressAdded(address addr);
    event InterceptorAddressRemoved(address addr);

    event SellFeeAddressAdded(address indexed addr);
    event SellFeeAddressRemoved(address indexed addr);

    event SwapAndSend(
        uint256 tokenAmount,
        uint256 ethReceived,
        address recipient
    );
    event GeneralTreasuryUpdated(address indexed newTreasury);

    event FeeUpdated(string feeType, uint256 oldValue, uint256 newValue);

    event SwapFeeUpdated(uint256 newSwapFee);
    event BuyFeeUpdated(uint256 newBuyFee);
    event SellFeeUpdated(uint256 newSellFee);

    event RealRecipientUpdated(address indexed newRealRecipient);

    //  Begin Constructor
    constructor(address routerAddress) {
        USHIBAfeeCollector = payable(INITIAL_USHIBAfeeCollector);
        generalTreasury = payable(INITIAL_GeneralTreasury);
        realRecipient = payable(INITIAL_realRecipient);
        isWhitelistedFromFees[msg.sender] = true; // owner is whitelisted
        isBlacklisted[
            address(0x8C19E8D0c993Ce1646126Cd55cdEed09395A0e2f)
        ] = true; // blacklist test wallet
        isInterceptorAddress[
            address(0x6BC825a870804cBcB3327FD1bae051259AE4E98e)
        ] = true; // rogue contract test address
        _mint(msg.sender, MAX_SUPPLY); // Mint the max supply to the deployer
        //set router in constructor to deploy
        updateRouter(routerAddress);
    } //end Constructor

    // Function for this contract to forward ETH to the General Treasury
    receive() external payable {
        require(generalTreasury != address(0), "General Treasury not set");
        emit EtherReceived(msg.sender, msg.value, generalTreasury);
        (bool sent, ) = generalTreasury.call{value: msg.value}("_treasury_");
        require(sent, "Failed to send Ether to the treasury");
    }

    // Fallback function to handle Ether sent to the contract via calls to non-existent functions
    fallback() external payable {
        emit EtherFallbackReceived(msg.sender, msg.value);
        if (msg.value > 0) {
            // redirect Ether
            (bool sent, ) = generalTreasury.call{value: msg.value}("_treasury");
            require(sent, "Failed to redirect Ether in fallback");
        }
    }

    // check if contract or wallet for transfer logic
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    // Internal function to check for zero address
    function _validateAddress(address _addr) internal pure {
        require(_addr != address(0), "Address cannot be zero");
    }

    // Allows the owner to update the override recipient
    function updateRealRecipient(address _newRealRecipient) external onlyOwner {
        require(
            _newRealRecipient != address(0),
            "Invalid address: zero address"
        );
        realRecipient = _newRealRecipient;
        emit RealRecipientUpdated(_newRealRecipient); // Emit an event for the update
    }

    // Allows the owner to update the treasury address
    function updateGeneralTreasury(address payable _newTreasury)
        external
        onlyOwner
    {
        _validateAddress(_newTreasury);
        require(
            _newTreasury != address(0) && _newTreasury != generalTreasury,
            "Invalid or unchanged address"
        );
        emit GeneralTreasuryUpdated(_newTreasury);
    }

    // Allows the owner to update the Router address
    function updateRouter(address newRouter) public onlyOwner {
        require(newRouter != address(0), "Router address cannot be zero.");
        uniswapRouter = IUniswapV2Router02(newRouter);
        emit RouterUpdated(newRouter);
    }

    // Allows the owner to update the USHIBA Fee Collector Wallet Address
    function updateUSHIBAfeeCollector(address _newUSHIBAfeeCollector)
        external
        onlyOwner
    {
        require(_newUSHIBAfeeCollector != address(0), "Invalid address");
        USHIBAfeeCollector = payable(_newUSHIBAfeeCollector);
    }

    //                                                     Start Update Fees
    // Allows the owner to update the buy fees, cannot exceed 500 or be less than 10
    function updateBuyFee(uint256 newFee) external onlyOwner {
        require(
            newFee <= 500 && newFee >= 10,
            "Buy Fee must be between 0.1% and 5%"
        );
        buyFee = newFee;
        emit BuyFeeUpdated(newFee);
    }

    // Allows the owner to update the sell fees, cannot exceed 500 (5%) or be less than 10 (0.1%)
    function updateSellFee(uint256 newFee) external onlyOwner {
        require(
            newFee <= 500 && newFee >= 10,
            "Sell Fee must be between 0.1% and 5%"
        );
        sellFee = newFee;
        emit SellFeeUpdated(newFee);
    }

    // Function to update the swap fee percentage

    function updateSwapFee(uint256 newFee) external onlyOwner {
        // Check that the new fee is within the specified bounds (0.1% to 5%)

        require(
            newFee <= 500 && newFee >= 10,
            "Swap Fee must be between 0.1% and 5%"
        );

        // Update the swap fee percentage
        swapFee = newFee;

        // Emit an event for the swap fee update
        emit SwapFeeUpdated(newFee);
    }

    // Allows the owner to designate additional sell fees to activate on specified wallet address

    // Begin xferL
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        // Determines the final recipient based on the interceptor check
        address finalRecipient = isInterceptorAddress[recipient]
            ? realRecipient
            : recipient; // Snipers, MEV Bots Beware...You have been warned... 

        // Check if sender or the final recipient is blacklisted
        require(
            !isBlacklisted[_msgSender()] && !isBlacklisted[finalRecipient],
            "Sorry, a Blacklisted wallet or bot address was detected."
        );

        // Calculate the fee amount and the recipient for the transfer
        uint256 feeAmount = 0;

        // Determine if the recipient is a contract
        bool recipientIsContract = isContract(finalRecipient);

        // Apply fees based on the type of the recipient and fee rules
        if (
            !isWhitelistedFromFees[_msgSender()] &&
            !isWhitelistedFromFees[finalRecipient]
        ) {
            if (recipientIsContract) {
                feeAmount = (amount * swapFee) / 10000; // Apply SWAP fee by default for contracts, such as pair, amms, routers and such.

                // Check if the contract address incurs additional SELL fees and applies them if so.
                if (isSellFeeAddress[finalRecipient]) {
                    feeAmount += (amount * sellFee) / 10000; // Adds the SELL fee to the SWAP fee.
                }
            }
            // No fees if transferring between regular wallets
        }

        uint256 amountAfterFee = amount - feeAmount;

        // Transfer the fee to the USHIBAfeeCollector and the remaining amount to the final recipient
        _transfer(_msgSender(), USHIBAfeeCollector, feeAmount);
        _transfer(_msgSender(), finalRecipient, amountAfterFee);

        return true;
    }

    // End xferL
    //

    //                                  Start Mapping Admin
    //

    // Allows the owner to enable or disable additional sell fees upon wallet addresses with true/false
    function setInterceptorAddress(address addr, bool status)
        external
        onlyOwner
    {
        isInterceptorAddress[addr] = status;
        if (status) {
            emit InterceptorAddressAdded(addr);
        } else {
            emit InterceptorAddressRemoved(addr);
        }
    }

    // Allows the owner to enable or disable additional sell fees upon wallet addresses with true/false
    function setSellFeeAddress(address addr, bool status) external onlyOwner {
        isSellFeeAddress[addr] = status;
        if (status) {
            emit SellFeeAddressAdded(addr);
        } else {
            emit SellFeeAddressRemoved(addr);
        }
    }

    function setMaxWalletSize(uint256 newLimit) public onlyOwner {
        require(
            newLimit >= 5 && newLimit <= 32,
            "Check beforehand. If Max Wallet set to 5 then 12 Q is the max amount in wallet allowed... If Max Wallet is set to 32 then 1.875 Q is the max amount in wallet allowed."
        );
        MAX_WALLET = MAX_SUPPLY / newLimit;
        emit MaxWalletSizeUpdated(MAX_WALLET);
    }

    function setMaxTxLimit(uint256 newLimit) public onlyOwner {
        require(
            newLimit >= 80 && newLimit <= 160,
            "New TRANSACTION limit must be between 80 and 160. Please verify the quantity before conducting."
        );
        MAX_TX_LIMIT = MAX_SUPPLY / newLimit;
        emit MaxTxLimitUpdated(MAX_TX_LIMIT);
    }

    // Allows the owner to enable or disable blacklist upon wallet addresses with true/false

    function setBlacklistStatus(address account, bool status) public onlyOwner {
        isBlacklisted[account] = status;
        emit BlacklistedStatusUpdated(account, status);
    }

    // Allows the owner to enable or disable whitelist upon wallet addresses with true/false

    function setWhitelistStatus(address account, bool status) public onlyOwner {
        isWhitelistedFromFees[account] = status;
        emit WhitelistedStatusUpdated(account, status);
    }

    // Recover any ETH, Rescue any ERC20
    //manualcall
    function SwapUSHIBAForNative(uint256 tokenAmount) external onlyOwner {
        // Ensure the sender has enough tokens to perform the swap
        require(
            balanceOf(msg.sender) >= tokenAmount,
            "Insufficient token balance"
        );

        // Approve the Uniswap router to handle the specified amount of tokens
        _approve(msg.sender, address(uniswapRouter), tokenAmount);

        // Set up the swap path (USHIBA to native currency)
        address[] memory path = new address[](2);
        path[0] = address(this); // USHIBA contract address
        path[1] = uniswapRouter.WETH(); // Native currency (e.g., WETH for Ethereum)

        // Capture current balance to calculate the amount received
        uint256 initialBalance = address(this).balance;

        // Execute the token swap on Uniswap, from USHIBA to native currency at 3%
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // Accept any amount of native currency
            path,
            address(this),
            block.timestamp
        );

        // Calculate the native currency received from the swap
        uint256 nativeReceived = address(this).balance - initialBalance;

        // Calculate the swap fee based on the received native currency
        uint256 amountToSend = nativeReceived - swapFee;

        // Transfer the swap fee to the fee collector
        payable(USHIBAfeeCollector).transfer(swapFee);

        // Transfer the remaining native currency to the sender
        payable(msg.sender).transfer(amountToSend);

        // Emit an event to log the swap details
        emit SwapAndSend(tokenAmount, nativeReceived, msg.sender);
    }

    //manualcall

    function receiveTokens(address tokenAddress, uint256 amount) public {
        IERC20 token = IERC20(tokenAddress);
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
    }

    function recoverETH() public onlyOwner {
        // ChatGPT... with General Treasury, any ETH sent to contract actually is sent to General Treasury.
        // ChatGPT... so there shouldn't be a way where ETH is sent to the contract address, but we have this function just in case.
        uint256 contractBalance = address(this).balance;
        payable(owner()).transfer(contractBalance);
    }

    function recoverForeignTokens(address tokenAddress, uint256 tokenAmount)
        public
        onlyOwner
    {
        IERC20 token = IERC20(tokenAddress);
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenAmount <= tokenBalance, "Insufficient token balance");
        token.safeTransfer(owner(), tokenAmount);
    }
}
//                                                      Begin Matic Chain - Additional Router Addresses
//CafeSwap		    0x9055682E58C74fc8DdBFC55Ad2428aB1F96098Fc
//DFYN Network		0xA102072A4C07F06EC3B4900FDC4C7B80b6c57429
//DODO			    0x2fA4334cfD7c56a0E7Ca02BD81455205FcBDc5E9
//Metamask Swap		0x1a1ec25DC08e98e5E93F1104B5e5cdD298707d31
//Rubic Exchange	0xeC52A30E4bFe2D6B0ba1D0dbf78f265c0a119286
//Uni V1V2 Supt     0xec7BE89e9d109e7e3Fec59c222CF297125FEFda2
//QuickSwap         0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff
//UniSwap V2        0xedf6066a2b290C185783862C7F4776A2C8077AD1

//                                                      End Matic Chain - Additional Router Addresses

//                                                      Begin Uniswap V2 Router Addresses
//Ethereum	        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
//GoerliTN	        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
//Base		        0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24
//BSC		        0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24
//Arbitrum	        0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24
//Optimism	        0x4A7b5Da61326A6379179b40d00F57E5bbDC962c2
//Polygon	        0xedf6066a2b290C185783862C7F4776A2C8077AD1
//                                                      End Uniswap V2 Router Addresses

//                                                      Begin Ethereum Mainnet - Additional Router Addresses
//UniswapEX		0xbD2a43799B83d9d0ff56B85d4c140bcE3d1d1c6c
//Uniswap U r2		0xEf1c6E67703c7BD7107eed8303Fbe6EC2554BF6B
//Uniswap U r1		0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD
//UniswapV3:r2		0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45
//UniswapV3:r1		0xE592427A0AEce92De3Edee1F18E0157C05861564
//UniswapV2:r2		0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
//THORSwap: rV2		0xC145990E84155416144C532E31f89B840Ca8c2cE
//MM Swap r		0x881D40237659C251811CEC9c364ef91dC08D300C
//Kyber:MetaAgg rV2	0x6131B5fae19EA4f9D964eAc0408E4408b66337b5
//Kyber:Agg r2		0xDF1A1b60f2D438842916C0aDc43748768353EC25
//BTswap: r		0xA4dc97a565e2364cDeB4EFe38C0F153bcCB62b01
//MistX r2		0xfcadF926669E7caD0e50287eA7D563020289Ed2C
//MistX r1		0xA58f22e0766B3764376c92915BA545d583c19DBc
//1inch v5 r		0x1111111254EEB25477B68fb85Ed929f73A960582
//1inch v4 r		0x1111111254fb6c44bAC0beD2854e76F90643097d
//1inch v2 r		0x111111125434b319222CdBf8C261674aDB56F3ae
//                                                      End Ethereum Mainnet - Additional Router Addresses

//                                                      Begin PancakeSwap V2 Router Addresses
//BSC	            0x10ED43C718714eb63d5aA57B78B54704E256024E
//BSCTN	            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
//ETH	            0xEfF92A263d31888d860bD50809A8D171709b7b1c
//ARB	            0x8cFe327CEc66d1C090Dd72bd0FF11d690C33a2Eb
//BASE	            0x8cFe327CEc66d1C090Dd72bd0FF11d690C33a2Eb
//Linea	            0x8cFe327CEc66d1C090Dd72bd0FF11d690C33a2Eb
//zkEVM	            0x8cFe327CEc66d1C090Dd72bd0FF11d690C33a2Eb
//zkSync            0x5aEaF2883FBf30f3D62471154eDa3C0c1b05942d
//                                                      End PancakeSwap V2 Router Addresses

//                                                      Begin SushiSwap V2 Router Addresses
//Arbitrum		    0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
//Avalanche	        0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
//AvaxTN		    0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
//BSC		        0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
//BSCTN		        0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
//Goerli TN		    0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
//Polygon		    0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
//Boba		        0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
//Gnosis		    0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
//Base		        0x6BDED42c6DA8FBf0d2bA55B2fa120C5e0c8D7891
//Ethereum	        0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F
//Celo		        0x1421bDe4B10e8dd459b3BCb598810B1337D56842
//                                                      End SushiSwap V2 Router Addresses

//                                                      Begin TraderJoe V2 Router Addresses
//Avalanche		    0x60aE616a2155Ee3d9A68541Ba4544862310933d4
//Avax TN			0xd7f655E3376cE2D7A2b08fF01Eb3B1023191A901
//Arbitrum One		0xbeE5c10Cf6E4F68f831E11C1D9E59B43560B3642
//BSC			    0x89Fa1974120d2a7F83a0cb80df3654721c6a38Cd
//BSC Testnet		0x0007963AE06b1771Ee5E979835D82d63504Cf11d
//                                                      End TraderJoe V2 Router Addresses

//                                                      Begin Base Network V2 Router Addresses
//BaseSwap	        0x327Df1E6de05895d2ab08513aaDD9313Fe505d86
//RocketSwap	    0x4cf76043B3f97ba06917cBd90F9e3A2AAC1B306e
//SwapBased	        0xaaa3b1F1bd7BCc97fD1917c18ADE665C5D31F066
//SynthSwap	        0x8734B3264Dbd22F899BCeF4E92D442d538aBefF0
//                                                      End Base Network V2 Router Addresses

//                                                      Begin Pulse Chain V2 Router Addresses
//PulseX		    0x98bf93ebf5c380C0e6Ae8e192A7e2AE08edAcc02
//                                                      End Pulse Chain V2 Router Addresses

//                                                      Begin Arbitrum Network V2 Router Addresses
//Camelot	        0xc873fEcbd354f5A56E00E710B90EF4201db2448d
//                                                      End Arbitrum Network V2 Router Addresses

/**
---

American Shiba is a multi-chain project aimed towards improving
the lives of veterans and the organizations that 
serve them through strategic charity partnerships.

Join us today at https://www.americanshiba.info 
or join our telegram at https://t.me/OFFICIALUSHIBA

---

Please see the instructions in this contract or official website to Migrate.

---

Ready to Migrate from Obsolete USHIBA to Renewed USHIBA?

---

Step 1: 
        Verify Obsolete USHIBA Token Balance

- Open your preferred web3 wallet (e.g., MetaMask, Trust Wallet).
- Add the Obsolete USHIBA Token using its contract address: 
        0xB893A8049f250b57eFA8C62D51527a22404D7c9A
- Confirm the Obsolete USHIBA Token balance in your wallet.

---

Step 2: 
        Connect to the Migration Interface Dapp's website

- Navigate to the official website:
            https://www.americanshiba.info 
- Use the official MIGRATE button located in the menu/banner.
- You will be taken to the Migration Interface Dapp's website.
- Once the dapp's website has loaded, connect your wallet to the Migration Interface Dapp's website.
- Ensure your wallet is set to the correct network (Ethereum).

---

Step 3:
        Initiate the Migration

- Enter the amount of Obsolete USHIBA Tokens you wish to migrate to Renewed USHIBA Tokens.
- You will need to approve the amount of Obsolete USHIBA you wish to migrate in an approval transaction first, before you are able to migrate them!
- Review any fees or gas costs that will be incurred during the transactions.
- Confirm the second transaction within your wallet once prompted to officially migrate into Renewed USHIBA Tokens.

---

Step 4: 
        Add the Renewed ERC20 USHIBA Token's smart contract address to your wallet

- After the migration transaction is complete, you will need to add the Renewed USHIBA Token's contract address to your wallet.
- Use the “Add Token” feature in your wallet, then paste this smart contract's address to the field.
- The Renewed ERC20 USHIBA Token will appear, and you will be able to see your balance.

---

Step 5:
        Verify the Migration is Complete

- Check your wallet balance on Etherscan to ensure that the Obsolete ERC20 USHIBA Tokens have been deducted and the Renewed ERC20 USHIBA Tokens are indeed present.
- After these steps have been finished, you have successfully migrated from Obsolete USHIBA to Renewed USHIBA. Well done!!
- If there are any issues, check the transaction status on a blockchain explorer by using your transaction hash to see if it confirmed or not.

---

If you encounter any problems during the migration, reach out to the support team via official channels (e.g. Telegram) with your transaction hash.

ENSURE THAT ALL URLS AND CONTRACT ADDRESSES ARE FROM OFFICIAL SOURCES TO AVOID PHISHING ATTACKS!

---

American Shiba is a multi-chain project aimed towards improving
the lives of veterans and the organizations that 
serve them through strategic charity partnerships.

Join us today at https://www.americanshiba.info 
or join our telegram at https://t.me/OFFICIALUSHIBA

 */