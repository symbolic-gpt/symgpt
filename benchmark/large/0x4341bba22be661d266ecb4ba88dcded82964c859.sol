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
        return 18;
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

// File: Riggy.sol



// Official Riggy X account, Telegram and website:
// https://x.com/RIGGYeth
// https://t.me/RIGGYeth
// https://www.riggy.org

pragma solidity ^0.8.26;




/**
 * @title IUniswapV2Factory
 * @dev Interface for the Uniswap V2 Factory contract, which is responsible for creating Uniswap pairs.
 */
interface IUniswapV2Factory {
    /**
     * @dev Creates a pair for two tokens.
     * @param tokenA The address of the first token in the pair.
     * @param tokenB The address of the second token in the pair.
     * @return pair The address of the created pair.
     */
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

/**
 * @title IUniswapV2Router01
 * @dev Interface for the basic functions of the Uniswap V2 Router.
 */
interface IUniswapV2Router01 {
    /**
     * @dev Returns the address of the Uniswap V2 Factory.
     * @return The address of the factory.
     */
    function factory() external pure returns (address);

    /**
     * @dev Returns the address of WETH (Wrapped Ether).
     * @return The address of WETH.
     */
    function WETH() external pure returns (address);
}

/**
 * @title IUniswapV2Router02
 * @dev Interface for the extended functions of the Uniswap V2 Router, including liquidity provision.
 * Inherits from IUniswapV2Router01.
 */
interface IUniswapV2Router02 is IUniswapV2Router01 {
    /**
     * @dev Adds liquidity to a Uniswap pair consisting of the token and ETH.
     * @param token The address of the token to add to the liquidity pool.
     * @param desiredTokenAmount The amount of the token to add to the liquidity pool.
     * @param minTokenAmount The minimum amount of the token to add (to account for slippage).
     * @param minETHAmount The minimum amount of ETH to add (to account for slippage).
     * @param to The address to receive the liquidity tokens.
     * @param deadline The timestamp by which the transaction must be completed.
     * @return amountToken The actual amount of the token added to the liquidity pool.
     * @return amountETH The actual amount of ETH added to the liquidity pool.
     * @return liquidity The amount of liquidity tokens minted.
     */
    function addLiquidityETH(
        address token,
        uint256 desiredTokenAmount,
        uint256 minTokenAmount,
        uint256 minETHAmount,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

/**
 * @title RiggyToken
 * @dev Implementation of the RiggyToken, an ERC20 token with additional functionalities including liquidity provision and airdrops.
 * Inherits ERC20 for standard token functionality, Ownable for access control, and ReentrancyGuard to prevent reentrancy attacks.
 */
contract RiggyToken is ERC20, Ownable, ReentrancyGuard {
    /// @dev The Uniswap V2 Router used for liquidity provision, marked as immutable.
    IUniswapV2Router02 public immutable dexRouter;
    
    /// @dev The address of the Uniswap pair for the token, marked as immutable.
    address public immutable dexPair;

    /// @dev The address for the marketing wallet, where 5% of the total supply is allocated.
    address public marketingAddress = 0x00A57CE3c6b1E98F79E546D112932C92C2acacd1;

    /// @dev The total supply of the token, set to 10 billion tokens.
    uint256 public constant TOTAL_SUPPLY = 10_000_000_000 * 10**18;

    /// @dev The burn address where tokens can be sent to be effectively removed from circulation.
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    /// @dev A mapping that tracks whether an address is recognized as a Uniswap pair.
    /// The key is the address of the potential Uniswap pair, and the value is a boolean indicating whether it is recognized as such.
    /// This mapping is used to identify and manage addresses that are Uniswap pairs for the token's liquidity pool.
    mapping(address => bool) public uniswapPairs;

    /// @dev A boolean flag that indicates whether trading of the token is currently active.
    /// Initially set to `false`, it can be toggled to `true` by the contract owner using the `enableTrading` function.
    /// This flag is used to control when trading can start, ensuring it only begins after necessary initial setup and liquidity provision.
    bool public tradingActive = false;
    
    /// @dev A mapping that tracks the amount of ETH sent by each address to the contract.
    /// The key is the sender's address, and the value is the total amount of ETH (in wei) that the address has sent to the contract.
    /// This mapping is used to keep a record of contributions made by different addresses, which can be referenced for various purposes
    /// such as calculating the percentage of the total ETH balance contributed by each address.
    mapping(address => uint256) public ethSent;

    event UniswapPairUpdated(address indexed pair, bool isPair); // Emitted when the status of a Uniswap pair is updated.
    event MarketingAddressUpdated(address indexed newAddress, address indexed oldAddress); // Emitted when the marketing address is changed.
    event TradingEnabled(); // Emitted when trading is enabled.
    event LiquidityProvided(uint256 tokensSupplied, uint256 ethSupplied, uint256 liquidityTokens); // Emitted when liquidity is provided to Uniswap.
    event TokensAirdropped(uint256 numOfRecipients, uint256 totalTokens); // Emitted when tokens are airdropped to multiple addresses.
    event FundReceived(address indexed sender, uint256 amount); // Emitted when ETH is received by the contract.
    event EthWithdrawn(address indexed owner, uint256 amount); // Emitted when ETH is withdrawn by the owner.
    event EthSent(address indexed sender, uint256 amount); // Emitted when ETH is sent by an address.

    constructor() ERC20("Riggy", "RIGGY") Ownable(msg.sender) {
        uint256 ownerSupply = TOTAL_SUPPLY * 10 / 100; // 10% to owner
        uint256 marketingSupply = TOTAL_SUPPLY * 5 / 100; // 5% to marketing address
        uint256 contractSupply = TOTAL_SUPPLY * 85 / 100; // 85% to contract itself

        // Initialize the Uniswap V2 router
        IUniswapV2Router02 _dexRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D // Uniswap V2 Router address
        );
        dexRouter = _dexRouter;

        // Create a pair for this token on Uniswap
        dexPair = IUniswapV2Factory(_dexRouter.factory())
            .createPair(address(this), _dexRouter.WETH());

        _approve(address(this), address(_dexRouter), type(uint256).max);

        _mint(msg.sender, ownerSupply);
        _mint(marketingAddress, marketingSupply);
        _mint(address(this), contractSupply);
    }

    /**
    * @dev Updates the status of an address as a Uniswap pair. This function is only callable by the contract owner.
    * It allows the owner to specify whether a given address is a recognized Uniswap pair.
    *
    * @param pair The address of the Uniswap pair to be updated.
    * @param isPair A boolean value indicating whether the specified address should be marked as a Uniswap pair.
    *
    * Steps:
    * 1. Updates the mapping `uniswapPairs` to reflect whether the given address is a recognized Uniswap pair.
    * 2. Emits an `UniswapPairUpdated` event with the address of the pair and its new status.
    *
    * @notice This function allows the contract owner to manage the recognition of Uniswap pairs, 
    * which is useful for functionalities that depend on identifying such pairs.
    */
    function updateUniswapPair(address pair, bool isPair) external onlyOwner {
        uniswapPairs[pair] = isPair;
        emit UniswapPairUpdated(pair, isPair);
    }

    /**
    * @dev Updates the marketing wallet address. This function is only callable by the contract owner.
    * The new marketing wallet address must not be the zero address.
    *
    * Requirements:
    * - The new marketing wallet address must not be the zero address.
    *
    * Steps:
    * 1. Ensures that the new marketing wallet address is not the zero address.
    * 2. Updates the `marketingAddress` to the new address.
    * 3. Emits a `MarketingAddressUpdated` event with the new and old marketing wallet addresses.
    *
    * @param _marketingWallet The new address to be set as the marketing wallet.
    *
    * @notice This function allows the contract owner to update the address that will receive marketing funds.
    */
    function setMarketingWallet(address _marketingWallet) external onlyOwner {
        require(_marketingWallet != address(0), "Invalid marketing wallet address");
        address oldWallet = marketingAddress;
        marketingAddress = _marketingWallet;
        emit MarketingAddressUpdated(_marketingWallet, oldWallet);
    }

    /**
    * @dev Enables trading for the Riggy token. This function is only callable by the contract owner.
    * Once trading is enabled, it cannot be disabled again.
    *
    * Requirements:
    * - Trading must not already be active.
    *
    * Steps:
    * 1. Ensures that trading is not already active.
    * 2. Sets the `tradingActive` flag to true.
    * 3. Emits a `TradingEnabled` event to signal that trading has been enabled.
    */
    function enableTrading() external onlyOwner {
        require(!tradingActive, "Trading already active.");
        tradingActive = true;
        emit TradingEnabled();
    }

    /**
    * @dev Allows the contract owner to withdraw all Riggy tokens that are stuck in the contract.
    * This function ensures that there are Riggy tokens to withdraw before attempting the transfer.
    * The tokens are transferred to the owner's address.
    *
    * Requirements:
    * - The contract must have a balance of Riggy tokens greater than 0.
    *
    * Steps:
    * 1. Checks the balance of Riggy tokens in the contract.
    * 2. Ensures that the contract has more than 0 Riggy tokens to withdraw.
    * 3. Transfers the entire balance of Riggy tokens from the contract to the owner's address.
    *
    * @notice This function is useful to recover tokens that are accidentally sent to the contract address.
    */
    function withdrawStuckRiggy() external onlyOwner nonReentrant {
        uint256 contractBalance = balanceOf(address(this));
        require(contractBalance > 0, "No Riggy tokens to withdraw");
        _transfer(address(this), msg.sender, contractBalance);
    }

    /**
    * @dev Distributes specified amounts of Riggy tokens to a list of recipient addresses.
    * This function is only callable by the contract owner and ensures that the contract has enough tokens
    * to fulfill the airdrop before attempting the transfers.
    *
    * Requirements:
    * - The number of recipient addresses must not exceed 250.
    * - The lengths of the recipient address array and token amounts array must match.
    * - The contract must have a sufficient balance to cover the airdrop.
    *
    * Steps:
    * 1. Ensures that the number of recipient addresses does not exceed 250.
    * 2. Ensures that the lengths of the recipient address array and token amounts array match.
    * 3. Calculates the total amount of tokens to be airdropped.
    * 4. Ensures that the contract has a sufficient balance to cover the airdrop.
    * 5. Transfers the specified amounts of tokens to each recipient address.
    * 6. Emits a `TokensAirdropped` event with the total number of recipients and the total amount of tokens airdropped.
    *
    * @param addresses An array of recipient addresses.
    * @param tokenAmounts An array of amounts of tokens to be transferred to the corresponding recipient addresses.
    *
    * @notice This function allows the contract owner to distribute tokens to multiple addresses in a single transaction,
    * which is useful for airdrop campaigns or rewarding community members.
    */
    function airdropRiggy(address[] calldata addresses, uint256[] calldata tokenAmounts) external onlyOwner nonReentrant {
        require(addresses.length <= 250, "More than 250 wallets");
        require(addresses.length == tokenAmounts.length, "List length mismatch");

        uint256 airdropTotal = 0;
        for (uint i = 0; i < addresses.length; i++) {
            airdropTotal += tokenAmounts[i];
        }
        require(balanceOf(address(this)) >= airdropTotal, "Token balance too low");

        for (uint i = 0; i < addresses.length; i++) {
            _transfer(address(this), addresses[i], tokenAmounts[i]);
        }

        emit TokensAirdropped(addresses.length, airdropTotal);
    }

    /**
    * @dev Adds liquidity to Uniswap.
    * This function can only be called by the owner of the contract.
    * Requires that trading is active to add liquidity.
    *
    * Steps:
    * 1. Ensures that trading is active.
    * 2. Calculates the contract's token balance.
    * 3. Calculates 90% of the contract's ETH balance.
    * 4. Calls the Uniswap router to add liquidity.
    * 5. Emits a LiquidityProvided event with the amounts of tokens and ETH supplied and the liquidity tokens received.
    */
    function provideLiquidity() external onlyOwner {
        require(tradingActive, "Trading must be active to add liquidity.");

        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 ethBalance = address(this).balance * 90 / 100; // Use 90% of the contract's ETH balance

        // Add liquidity to Uniswap
        (uint256 tokenAmount, uint256 ethAmount, uint256 liquidity) = dexRouter.addLiquidityETH{value: ethBalance}(
            address(this),
            contractTokenBalance,
            0, // Allow some slippage
            0, // Allow some slippage
            BURN_ADDRESS, // Send LP tokens to the burn address
            block.timestamp
        );

        emit LiquidityProvided(tokenAmount, ethAmount, liquidity);
    }

    /**
    * @dev Withdraws any LP (Liquidity Provider) tokens that are stuck in the contract.
    * This function can only be called by the owner of the contract.
    *
    * Steps:
    * 1. Retrieves the LP token balance of the contract.
    * 2. Ensures that there is a positive balance of LP tokens to withdraw.
    * 3. Transfers the LP tokens to the owner's address.
    *
    * @notice This function is used to recover any LP tokens that may be unintentionally locked within the contract.
    * Only callable by the contract owner.
    * The contract must have a positive balance of LP tokens.
    */
    function withdrawStuckLPTokens() external onlyOwner {
        IERC20 lpToken = IERC20(dexPair);
        uint256 lpTokenBalance = lpToken.balanceOf(address(this));
        require(lpTokenBalance > 0, "No LP tokens to withdraw");
        lpToken.transfer(owner(), lpTokenBalance);
    }

    /**
    * @dev Function to receive ETH. This function is triggered whenever ETH is sent to the contract address.
    * It emits a FundReceived event with the sender's address and the amount of ETH received.
    *
    * @notice This function allows the contract to accept ETH transfers.
    *
    * Emits a {FundReceived} event.
    */
    receive() external payable {
         // Emit an event to log the receipt of ETH
        emit FundReceived(msg.sender, msg.value);
    }

    /**
    * @dev Withdraws all ETH from the contract to the owner's address.
    * This function can only be called by the owner of the contract.
    * It ensures that there is ETH available to withdraw and transfers it to the owner.
    * The function is protected against reentrancy attacks.
    *
    * Steps:
    * 1. Retrieves the ETH balance of the contract.
    * 2. Ensures that there is a positive ETH balance to withdraw.
    * 3. Transfers the ETH balance to the owner's address.
    * 4. Emits an EthWithdrawn event with the owner's address and the amount of ETH withdrawn.
    *
    * @notice This function allows the owner to withdraw all ETH held by the contract.
    *
    * Emits a {EthWithdrawn} event.
    */
    function withdrawEth() external onlyOwner nonReentrant {
        // Get the balance of ETH held by the contract
        uint256 ethBalance = address(this).balance;
        
        // Ensure there is a positive balance of ETH to withdraw
        require(ethBalance > 0, "No ETH to withdraw");
        
        // Transfer the ETH balance to the owner's address
        (bool success, ) = msg.sender.call{value: ethBalance}("");
        require(success, "Transfer failed.");
        
        // Emit an event to log the withdrawal of ETH
        emit EthWithdrawn(msg.sender, ethBalance);
    }

    /**
    * @dev Burns a specified amount of Riggy tokens by transferring them to the burn address.
    * This function can only be called by the owner of the contract.
    *
    * Steps:
    * 1. Transfers the specified amount of Riggy tokens from the contract's address to the burn address.
    *
    * @param amount The amount of Riggy tokens to burn.
    *
    * @notice This function permanently removes the specified amount of Riggy tokens from circulation.
    */
    function burnRiggy(uint256 amount) external onlyOwner {
        _transfer(address(this), BURN_ADDRESS, amount);
    }

    /**
    * @dev View-only function that returns the ETH balance of the contract.
    * This function can be called by anyone and does not modify the state.
    *
    * @return The ETH balance of the contract.
    *
    * @notice This function allows users to view the current ETH balance held by the contract.
    */
    function viewEthBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev View-only function that returns the percentage of the current ETH balance of the contract that was sent by a specific address.
     * This function can be called by anyone and does not modify the state.
     *
     * Steps:
     * 1. Ensures that the contract has a positive ETH balance.
     * 2. Calculates the percentage of the current ETH balance that was sent by the specified address.
     *
     * @param sender The address to check the percentage of ETH sent.
     * @return The percentage of the current ETH balance of the contract that was sent by the specified address.
     *
     * @notice This function allows users to view the contribution percentage of a specific address based on the current ETH balance of the contract.
     */
    function getEthSentPercentage(address sender) external view returns (uint256) {
        uint256 currentEthBalance = address(this).balance;

        // Ensure that the contract has a positive ETH balance
        require(currentEthBalance > 0, "No ETH in contract");

        // Calculate and return the percentage of the current ETH balance that was sent by the specified address
        return (ethSent[sender] * 100) / currentEthBalance;
    }
}