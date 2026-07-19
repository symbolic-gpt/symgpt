// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.25;

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

pragma solidity 0.8.25;

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

pragma solidity 0.8.25;


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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
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
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
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
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity 0.8.25;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// File: Contracts/iSilver.sol



// ISLAMI Silver iSilver

pragma solidity 0.8.25;







interface IPMMContract {
    enum RState {
        ONE,
        ABOVE_ONE,
        BELOW_ONE
    }

    function querySellQuote(address trader, uint256 payQuoteAmount)
        external
        view
        returns (
            uint256 receiveBaseAmount,
            uint256 mtFee,
            RState newRState,
            uint256 newQuoteTarget
        );
}

interface IiSilverNFT {
    function mint(address) external returns (uint256);

    function burn(address, uint256) external;

    function ownerOf(uint256) external returns (address);

    function totalSupply() external view returns (uint256);
}

interface IBuyAndBurn{
    function buyAndBurn(address, uint256) external returns(uint256);
}

contract iSilver is ERC20, Ownable {
    using SafeMath for uint256;

    IPMMContract public pmmContract;
    IiSilverNFT public iSilverNFT;
    IBuyAndBurn public BAB;

    address public constant deadWallet =
        0x000000000000000000000000000000000000dEaD;

    IERC20 public iSilverToken;
    IERC20 public usdtToken;
    AggregatorV3Interface public silverPriceFeed;

    mapping(address => bool) public admins;

    modifier onlyAdmin() {
        require(admins[msg.sender], "Caller is not admin");
        _;
    }

    modifier notPausedTrade() {
        require(!isPaused, "Trading is paused");
        _;
    }

    // Define a modifier that checks if it's between Monday 00:00 GMT and Friday 20:55 GMT
    modifier onlyWeekdays() {
        uint256 dayOfWeek = (block.timestamp / 86400 + 3) % 7; // Monday as day 0
        uint256 timeOfDay = block.timestamp % 86400; // Seconds since midnight

        // Monday to Thursday are allowed, and Friday before 20:55 GMT is allowed
        require(
            (dayOfWeek >= 0 && dayOfWeek <= 3) || (dayOfWeek == 4 && timeOfDay < (20 * 3600 + 55 * 60)),
            "iSilver trading between Monday 00:00 GMT and Friday 20:55 GMT."
        );
        _;
    }

    event iSilverNFTMinted(address indexed user, uint256 nftId);
    event iSilverNFTReturned(address indexed user, uint256 indexed nftId);
    event silverReserved(
        string Type,
        uint256 silverAddedInGrams,
        uint256 totalSilverInGrams
    );
    event trade(
        string Type,
        uint256 iSilver,
        int256 priceInUSD,
        uint256 amountPay,
        uint256 feesInUSDT
    );
    event PhysicalSilverRequest(
        address indexed user,
        uint256 silverAmount,
        string deliveryDetails
    );
    event TokensWithdrawn(
        address indexed token,
        address indexed owner,
        uint256 amount
    );
    event tradingPaused(bool status);

    uint256 constant MAX_UINT = 2**256 - 1;
    uint256 public constant iSilverTokensPerOunce = 31103476800; // 311.03476800   (8 Decimals)
    int256 public constant gramsPerOunce = 3110347680; // 31.10347680  (8 Decimals)
    uint256 public silverReserve; // in grams with 8 decimals
    uint256 public usdtVault;
    uint256 public feesBurned;
    uint256 public physicalSilverFee = 50 * 1e6;
    uint256 public physicalSilverFeeSwiss = 200 * 1e6;
    uint256 public minBuy = 1000000; // 1 USDT

    uint256 private mUSDT = 1; // multiply by value
    uint256 private dUSDT = 100; // divide by value

    bool isPaused;

    function decimals() public view virtual override returns (uint8) {
        return 8; //same decimals as price of Silver returned from ChainLink
    }

    constructor(
    ) ERC20("iSilver", "iSilver") Ownable(msg.sender){
        BAB = IBuyAndBurn(0xd73501d9111FF2DE47acBD52D2eAeaaA9e02b4Dd);
        usdtToken = IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
        iSilverToken = IERC20(address(this));
        pmmContract = IPMMContract(0x14afbB9E6Ab4Ab761f067fA131e46760125301Fc);
        silverPriceFeed = AggregatorV3Interface(0x461c7B8D370a240DdB46B402748381C3210136b3);
        admins[msg.sender] = true;
    }

    function addAdmin(address _admin) external onlyOwner{
        require(_admin != address(0x0), "zero address");
        admins[_admin] = true;
    }

    function removeAdmin(address _admin) external onlyOwner{
        require(_admin != address(0x0), "zero address");
        admins[_admin] = false;
    }

    function editMinBuy(uint256 _minBuy) external onlyOwner{
        require(_minBuy > 0, "Zero value not allowed");
        minBuy = _minBuy;
    }

    function editUSDTFee(uint256 _m, uint256 _d) external onlyOwner{
        require(_m >= 1 && _d > 99, "Multiply equal or over 1 and divide over 99");
        mUSDT = _m;
        dUSDT = _d;
    }

    function depositeUSDT(uint256 _amount) external {
        require(
            usdtToken.transferFrom(msg.sender, address(this), _amount),
            "Check USDT balance or allowance"
        );
        usdtVault += _amount;
    }

    function setNFTContractAddress(address _iSilverNFT) external onlyOwner {
        require(_iSilverNFT != address(0x0), "Zero address");
        iSilverNFT = IiSilverNFT(_iSilverNFT);
    }

    function pause(bool _status) external onlyOwner returns (bool) {
        int256 _silverPrice = getLatestSilverPriceOunce();
        if (_status) {
            require(_silverPrice == 0, "Silver price is not zero");
        } else {
            require(_silverPrice > 0, "Silver price is zero");
        }
        isPaused = _status;
        emit tradingPaused(_status);
        return (_status);
    }

    function setPhysicalSilverFee(uint256 newFeeLocal, uint256 newFeeSwiss)
        external
        onlyOwner
    {
        physicalSilverFee = newFeeLocal * 1e6;
        physicalSilverFeeSwiss = newFeeSwiss * 1e6;
    }

    function setUSDTAddress(address _USDT) external onlyOwner {
        require(_USDT != address(0x0), "Zero address");
        usdtToken = IERC20(_USDT);
    }

    function setIslamiPriceAddress(address _pmmContract) external onlyOwner {
        require(_pmmContract != address(0x0), "Zero address");
        pmmContract = IPMMContract(_pmmContract);
    }

    function setSilverPriceAddress(address _silverPriceFeed) external onlyOwner {
        require(_silverPriceFeed != address(0x0), "Zero address");
        silverPriceFeed = AggregatorV3Interface(_silverPriceFeed);
    }

    function setBabContractAddress(address _BAB) external onlyOwner {
        require(_BAB != address(0), "Zero Address");
        BAB = IBuyAndBurn(_BAB);
    }

    function getIslamiPrice(uint256 payQuoteAmount)
        public
        view
        returns (uint256 _price)
    {
        address trader = address(this);
        // Call the querySellQuote function from the PMMContract
        (uint256 receiveBaseAmount, , , ) = pmmContract.querySellQuote(
            trader,
            payQuoteAmount
        );
        _price = receiveBaseAmount;
        return _price;
    }

    function getLatestSilverPriceOunce() public view returns (int256) {
        (, int256 pricePerOunce, , , ) = silverPriceFeed.latestRoundData();
        return pricePerOunce;
    }

    function getLatestSilverPriceGram() public view returns (int256) {
        int256 pricePerGram = (getLatestSilverPriceOunce() * 1e8) / gramsPerOunce; // Multiplied by 10^8 to handle decimals

        return pricePerGram;
    }

    function getiSilverPrice() public view returns (int256) {
        int256 iSilverPrice = (getLatestSilverPriceGram()) / 10;
        return iSilverPrice;
    }

    function addSilverReserve(uint256 amountSilver) external onlyAdmin {
        //The function is always tracked by Crypto Halal Office after physical Silver check
        amountSilver = amountSilver.mul(1e8);
        silverReserve += amountSilver;
        emit silverReserved("Add", amountSilver, silverReserve);
    }

    function removeSilverReserve(uint256 amountSilver) external onlyOwner {
        //The function is always tracked by Crypto Halal Office after physical silver check
        silverReserve -= amountSilver;
        emit silverReserved("Remove", amountSilver, silverReserve);
    }

    function approveBAB() external onlyOwner{
        usdtToken.approve(address(BAB), MAX_UINT);
    }

    function checkMaxSupply() public view returns(uint256){
        return silverReserve.mul(10);
    }

    function mintable() public view returns(uint256){
        return checkMaxSupply() - totalSupply();
    }

    function buy(uint256 _usdtAmount)
        external
        notPausedTrade
        onlyWeekdays
        returns (uint256)
    {
        require(_usdtAmount >= minBuy, "Check Minimum Buy");
        int256 silverPrice = getLatestSilverPriceGram();
        require(silverPrice > 0, "Invalid Silver price");
        uint256 usdtFee = _usdtAmount.mul(mUSDT).div(dUSDT); // 1% fee
        uint256 adjustedUSDTAmount = _usdtAmount.sub(usdtFee);
        uint256 _iSilverAmount = adjustedUSDTAmount.mul(1e2).mul(1e1).mul(1e8).div(
            uint256(silverPrice)
        ); // 0.1g per token
        require(_iSilverAmount <= mintable(), "Silver reserve reached");
        
        uint256 toBurn = usdtFee / 2;

        emit trade(
            "Buy",
            _iSilverAmount,
            silverPrice,
            adjustedUSDTAmount,
            usdtFee
        );

        require(
            usdtToken.transferFrom(msg.sender, address(this), _usdtAmount),
            "Check USDT allowance or user balance"
        );

        uint256 _feesBurned = BAB.buyAndBurn(address(usdtToken), toBurn);

        usdtVault = usdtVault.add(_usdtAmount - toBurn);

        feesBurned = feesBurned.add(_feesBurned);

        _mint(msg.sender, _iSilverAmount);
        return _iSilverAmount;
    }

    function sell(uint256 _iSilverAmount) public notPausedTrade onlyWeekdays returns (uint256){
        int256 silverPrice = getLatestSilverPriceGram();
        require(silverPrice > 0, "Invalid silver price");

        uint256 _usdtAmount = _iSilverAmount
            .mul(uint256(silverPrice))
            .div(1e2) // handle decimal difference between silver and usdt
            .div(1e1) // Divid by 10 where each 10 iSilver = 1 Gram of silver
            .div(1e8); // Calculate the value of minted iSilver tokens in USDT
        uint256 usdtFee = _usdtAmount.mul(mUSDT).div(dUSDT); // 1% fee 
        uint256 adjustedUSDTAmount = _usdtAmount - usdtFee;
        
        uint256 toBurn = usdtFee / 2;

        emit trade("Sell", _iSilverAmount, silverPrice, adjustedUSDTAmount, usdtFee);

        _burn(msg.sender, _iSilverAmount);
        require(
            usdtToken.transfer(msg.sender, adjustedUSDTAmount),
            "USDT amount in contract does not cover your sell!"
        );

        uint256 _feesBurned = BAB.buyAndBurn(address(usdtToken), toBurn); // buy ISLAMI and burn

        usdtVault = usdtVault.sub(adjustedUSDTAmount + toBurn);

        feesBurned = feesBurned.add(_feesBurned);

        return (adjustedUSDTAmount);
    }

    function receivePhysicalSilver(
        uint256 ounceId,
        uint256 ounceType,
        string calldata deliveryDetails
    ) external notPausedTrade {
        uint256 feeInUSDT;
        if (ounceType == 0) {
            feeInUSDT = physicalSilverFee;
        } else {
            feeInUSDT = physicalSilverFeeSwiss;
        }

        require(
            usdtToken.balanceOf(msg.sender) >= feeInUSDT,
            "Insufficient USDT balance"
        );
        require(
            usdtToken.allowance(msg.sender, address(this)) >= feeInUSDT,
            "Insufficient USDT allowance"
        );

        iSilverNFT.burn(msg.sender, ounceId);
        silverReserve = (silverReserve.mul(10).sub(iSilverTokensPerOunce)).div(10);

        usdtToken.transferFrom(msg.sender, address(this), feeInUSDT);
        usdtVault = usdtVault.add(feeInUSDT);

        emit PhysicalSilverRequest(
            msg.sender,
            iSilverTokensPerOunce,
            deliveryDetails
        );
    }

    function checkReserves()
        public
        view
        returns (uint256 silverValue, uint256 usdtInVault)
    {
        int256 silverPrice = getLatestSilverPriceGram();
        require(silverPrice > 0, "Invalid silver price");
        uint256 iSilverInNFT = 0;
        if(iSilverNFT.totalSupply() > 0){
            iSilverInNFT = iSilverTokensPerOunce * (iSilverNFT.totalSupply());
        }
        uint256 totalMintedSilver = totalSupply() + iSilverInNFT; // Total minted iSilver tokens (each token represents 0.1g of Silver)
        silverValue = totalMintedSilver
            .mul(uint256(silverPrice))
            .div(1e2) // handle decimal difference between silver and usdt
            .div(1e1) // Divid by 10 where each 10 iSilver = 1 Gram of silver
            .div(1e8); // Calculate the value of minted iSilver tokens in USDT
        usdtInVault = usdtVault; // Current USDT in the contract

        return (silverValue, usdtInVault);
    }

    function mintiSilverNFT() external {
        uint256 iSilverBalance = balanceOf(msg.sender);

        require(
            iSilverBalance >= iSilverTokensPerOunce,
            "iSilver balance not sufficient for an iSilverNFT"
        );
        _burn(msg.sender, iSilverTokensPerOunce);
        uint256 nftId = iSilverNFT.mint(msg.sender);

        emit iSilverNFTMinted(msg.sender, nftId);
    }

    function returniSilverNFT(uint256 nftId) external {
        require(
            iSilverNFT.ownerOf(nftId) == msg.sender,
            "Caller is not the owner of this NFT"
        );

        iSilverNFT.burn(msg.sender, nftId);
        _mint(msg.sender, iSilverTokensPerOunce);

        emit iSilverNFTReturned(msg.sender, nftId);
    }

    function calculateiSilverReceivedForUSDT(uint256 _usdtAmount) public view returns (uint256) {
        require(_usdtAmount >= minBuy, "USDT amount below minimum buy");
        int256 silverPricePerGram = getLatestSilverPriceGram();
        require(silverPricePerGram > 0, "Invalid silver price");

        uint256 usdtFee = _usdtAmount.mul(mUSDT).div(dUSDT); // 1% fee
       
        uint256 adjustedUSDTAmount = _usdtAmount.sub(usdtFee);

        uint256 iSilverAmount = adjustedUSDTAmount.mul(1e2).mul(1e1).mul(1e8).div(
            uint256(silverPricePerGram)
        );

        return iSilverAmount;
    }

    function calculateUSDTReceivedForiSilver(uint256 _iSilverAmount) public view returns (uint256) {
        int256 silverPricePerGram = getLatestSilverPriceGram();
        require(silverPricePerGram > 0, "Invalid silver price");

        // Calculate the amount of USDT for the iSilver amount based on the silver price per gram
        // Note: Since each iSilver token represents 0.1g of silver, we adjust the calculation accordingly
        uint256 usdtAmountBeforeFees = _iSilverAmount
            .mul(uint256(silverPricePerGram))
            .div(1e2) // handle decimal difference between silver and usdt
            .div(1e1) // Divid by 10 where each 10 iSilver = 1 Gram of silver
            .div(1e8); // Calculate the value of minted iSilver tokens in USDT

        uint256 usdtFee = usdtAmountBeforeFees.mul(mUSDT).div(dUSDT); // 1% fee
        uint256 adjustedUSDTAmount = usdtAmountBeforeFees.sub(usdtFee); // Adjust the USDT amount by subtracting the fee

        return adjustedUSDTAmount;
    }

    function withdrawTokens(address tokenAddress, uint256 amount)
        external
        onlyOwner
    {
        require(
            tokenAddress == address(0x0)
                ? address(this).balance >= amount
                : IERC20(tokenAddress).balanceOf(address(this)) >= amount,
            "Insufficient balance"
        );

        if (tokenAddress == address(usdtToken)) {
            (uint256 _silverValue, ) = checkReserves();
            uint256 difference = usdtVault.sub(_silverValue);
            require(amount <= difference, "No extra USDT in contract");
            usdtVault -= amount;

            IERC20(usdtToken).transfer(msg.sender, amount);
        } else if (tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(amount);
        } else {
            IERC20 token = IERC20(tokenAddress);
            token.transfer(msg.sender, amount);
        }

        emit TokensWithdrawn(tokenAddress, msg.sender, amount);
    }

    // iSilver_V1 to iSilver_V2 Migration functions

    // Add a state variable for the migration contract address
    address private migrationContract;

    // Modifier to restrict function calls to the migration contract
    modifier onlyMigrationContract() {
        require(msg.sender == migrationContract, "Caller is not the migration contract");
        _;
    }

    // Function to set the migration contract address, callable only by the owner
    function setMigrationContract(address _migrationContract) external onlyOwner {
        migrationContract = _migrationContract;
    }

    // Function to mint tokens for a user, callable only by the migration contract
    function mintForMigration(address user, uint256 amount) external onlyMigrationContract {
        _mint(user, amount);
    }
}

                /*********************************************************
                      Developed by Eng. Jaafar Krayem Copyright 2024
                **********************************************************/