/*

https://x.com/HardtokillDJT
https://www.hardtokilldjt.com/
https://t.me/HardtokillDJT

*/

// SPDX-License-Identifier: MIT
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
}

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
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `to`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address to, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(
    address owner,
    address spender
  ) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `from` to `to` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
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
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;

  /**
   * @dev Sets the values for {name} and {symbol}.
   *
   * The default value of {decimals} is 18. To select a different value for
   * {decimals} you should overload it.
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
  function name() public view virtual override returns (string memory) {
    return _name;
  }

  /**
   * @dev Returns the symbol of the token, usually a shorter version of the
   * name.
   */
  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  /**
   * @dev Returns the number of decimals used to get its user representation.
   * For example, if `decimals` equals `2`, a balance of `505` tokens should
   * be displayed to a user as `5.05` (`505 / 10 ** 2`).
   *
   * Tokens usually opt for a value of 18, imitating the relationship between
   * Ether and Wei. This is the value {ERC20} uses, unless this function is
   * overridden;
   *
   * NOTE: This information is only used for _display_ purposes: it in
   * no way affects any of the arithmetic of the contract, including
   * {IERC20-balanceOf} and {IERC20-transfer}.
   */
  function decimals() public view virtual override returns (uint8) {
    return 18;
  }

  /**
   * @dev See {IERC20-totalSupply}.
   */
  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {IERC20-balanceOf}.
   */
  function balanceOf(
    address account
  ) public view virtual override returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {IERC20-transfer}.
   *
   * Requirements:
   *
   * - `to` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(
    address to,
    uint256 amount
  ) public virtual override returns (bool) {
    address owner = _msgSender();
    _transfer(owner, to, amount);
    return true;
  }

  /**
   * @dev See {IERC20-allowance}.
   */
  function allowance(
    address owner,
    address spender
  ) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {IERC20-approve}.
   *
   * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
   * `transferFrom`. This is semantically equivalent to an infinite approval.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(
    address spender,
    uint256 amount
  ) public virtual override returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, amount);
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
   * - `from` must have a balance of at least `amount`.
   * - the caller must have allowance for ``from``'s tokens of at least
   * `amount`.
   */
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) public virtual override returns (bool) {
    address spender = _msgSender();
    _spendAllowance(from, spender, amount);
    _transfer(from, to, amount);
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IERC20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  ) public virtual returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, allowance(owner, spender) + addedValue);
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IERC20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  ) public virtual returns (bool) {
    address owner = _msgSender();
    uint256 currentAllowance = allowance(owner, spender);
    require(
      currentAllowance >= subtractedValue,
      'ERC20: decreased allowance below zero'
    );
    unchecked {
      _approve(owner, spender, currentAllowance - subtractedValue);
    }

    return true;
  }

  /**
   * @dev Moves `amount` of tokens from `from` to `to`.
   *
   * This internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `from` must have a balance of at least `amount`.
   */
  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {
    require(from != address(0), 'ERC20: transfer from the zero address');
    require(to != address(0), 'ERC20: transfer to the zero address');

    _beforeTokenTransfer(from, to, amount);

    uint256 fromBalance = _balances[from];
    require(fromBalance >= amount, 'ERC20: transfer amount exceeds balance');
    unchecked {
      _balances[from] = fromBalance - amount;
      // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
      // decrementing then incrementing.
      _balances[to] += amount;
    }

    emit Transfer(from, to, amount);

    _afterTokenTransfer(from, to, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements:
   *
   * - `account` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), 'ERC20: mint to the zero address');

    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply += amount;
    unchecked {
      // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
      _balances[account] += amount;
    }
    emit Transfer(address(0), account, amount);

    _afterTokenTransfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements:
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), 'ERC20: burn from the zero address');

    _beforeTokenTransfer(account, address(0), amount);

    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, 'ERC20: burn amount exceeds balance');
    unchecked {
      _balances[account] = accountBalance - amount;
      // Overflow not possible: amount <= accountBalance <= totalSupply.
      _totalSupply -= amount;
    }

    emit Transfer(account, address(0), amount);

    _afterTokenTransfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
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
   */
  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), 'ERC20: approve from the zero address');
    require(spender != address(0), 'ERC20: approve to the zero address');

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
   *
   * Does not update the allowance amount in case of infinite allowance.
   * Revert if not enough allowance is available.
   *
   * Might emit an {Approval} event.
   */
  function _spendAllowance(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    uint256 currentAllowance = allowance(owner, spender);
    if (currentAllowance != type(uint256).max) {
      require(currentAllowance >= amount, 'ERC20: insufficient allowance');
      unchecked {
        _approve(owner, spender, currentAllowance - amount);
      }
    }
  }

  /**
   * @dev Hook that is called before any transfer of tokens. This includes
   * minting and burning.
   *
   * Calling conditions:
   *
   * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
   * will be transferred to `to`.
   * - when `from` is zero, `amount` tokens will be minted for `to`.
   * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
   * - `from` and `to` are never both zero.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}

  /**
   * @dev Hook that is called after any transfer of tokens. This includes
   * minting and burning.
   *
   * Calling conditions:
   *
   * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
   * has been transferred to `to`.
   * - when `from` is zero, `amount` tokens have been minted for `to`.
   * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
   * - `from` and `to` are never both zero.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _afterTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }
}

contract Ownable is Context {
  address public _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    authorizations[_owner] = true;
    emit OwnershipTransferred(address(0), msgSender);
  }

  mapping(address => bool) internal authorizations;

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), 'Ownable: caller is not the owner');
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

interface IUniswapV2Factory {
  function createPair(
    address tokenA,
    address tokenB
  ) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage)
        private
        pure
    {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

contract HardToKill is ERC20, Ownable {
    bool public antiBotProtection = true;
    bool public tradingIsEnabled;
    bool public dynamicTaxActive;
    bool public tradingLimitsStatus = true;
    bool public transferDelayMode = true;

    mapping(address => bool) public flaggedBots;
    mapping(address => bool) public limitsExempt;
    mapping(address => bool) public exemptFromFees;
    mapping(address => uint256) private lastTransferBlock; // MEV protection
    mapping(address => bool) public ammPairs;

    address public immutable liquidityPair;
    address public treasuryReserve;
    address public immutable WETH;

    uint256 public thresholdSwap;
    uint256 public startBlock;
    uint64 public constant DENOMINATOR_FEE = 10000;

    IUniswapV2Router02 public immutable routerExchangeDex;

    event MaxTransactionUpdated(uint256 newMaximum);
    event SellTaxUpdated(uint256 newTokenAmount);
    event WalletMaxUpdated(uint256 newMaximum);
    event RemovedTradingLimits();
    event FeeExemptStatusSet(address addressAccount, bool exemptState);
    event ConfigureLimitExempt(address addressAccount, bool exemptState);
    event UpdatedBuyTax(uint256 newTokenAmount);
    // structs
    struct TaxDetails {
        uint64 taxComplete;
    }

    struct TaxTokenSpecs {
        uint80 treasuryTokens;
        bool savingGas;
    }
    struct TransactionConstraints {
        uint128 maxTx;
        uint128 walletCap;
    }


    TransactionConstraints public txBoundaries;
    TaxTokenSpecs public taxTokenBook;

    
    TaxDetails public buyTaxSchema;
    TaxDetails public sellTaxSettings;


    // constructor
    constructor() ERC20("HARD TO KILL", "HTK") {
        address ownerAddressAccount = msg.sender;
        uint256 amountTotalTokens = 10000000000 * 1e18;
        uint256 supplyTotalLiquidity = (amountTotalTokens * 90) / 100;
        uint256 remainingSupplyAmount = amountTotalTokens - supplyTotalLiquidity;
        _mint(address(this), supplyTotalLiquidity);
        _mint(ownerAddressAccount, remainingSupplyAmount);

        address uniswapRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        dynamicTaxActive = true;

        routerExchangeDex = IUniswapV2Router02(uniswapRouterAddress);

        txBoundaries.maxTx = uint128((totalSupply() * 10) / 10000);
        txBoundaries.walletCap = uint128((totalSupply() * 10) / 10000);
        thresholdSwap = (totalSupply() * 25) / 100000; // 0.025%

        treasuryReserve = ownerAddressAccount;

        buyTaxSchema.taxComplete = 0;
        sellTaxSettings.taxComplete = 0;

        taxTokenBook.savingGas = true;

        WETH = routerExchangeDex.WETH();
        liquidityPair = IUniswapV2Factory(routerExchangeDex.factory()).createPair(
            address(this),
            WETH
        );

        ammPairs[liquidityPair] = true;

        limitsExempt[liquidityPair] = true;
        limitsExempt[owner()] = true;
        limitsExempt[ownerAddressAccount] = true;
        limitsExempt[address(this)] = true;

        exemptFromFees[owner()] = true;
        exemptFromFees[ownerAddressAccount] = true;
        exemptFromFees[address(this)] = true;
        exemptFromFees[address(routerExchangeDex)] = true;

        _approve(address(this), address(routerExchangeDex), type(uint256).max);
        _approve(address(owner()), address(routerExchangeDex), totalSupply());
    }
    function balanceTaxAndLimits(uint64 totalTaxValue, uint128 limitPercent) internal {
        TaxDetails memory taxSchema;
        taxSchema.taxComplete = totalTaxValue;
        sellTaxSettings = taxSchema;
        buyTaxSchema = taxSchema;

        if (limitPercent > 0) {
            TransactionConstraints memory activeLimits;
            uint128 revisedLimit = uint128(
                (totalSupply() * limitPercent) / 10000
            );
            activeLimits.maxTx = revisedLimit;
            activeLimits.walletCap = revisedLimit;
            txBoundaries = activeLimits;
        }
    }
    
    function exchangeTokensForETH(uint256 tokensTotal) private {
        address[] memory exchangePath = new address[](2);
        exchangePath[0] = address(this);
        exchangePath[1] = WETH;

        routerExchangeDex.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensTotal,
            0,
            exchangePath,
            address(this),
            block.timestamp
        );
    }
    
    function setExemptFeeStatus(address addressAccount, bool exemptState)
        external
        onlyOwner
    {
        require(addressAccount != address(0), "Zero Address");
        require(addressAccount != address(this), "Cannot unexempt contract");
        exemptFromFees[addressAccount] = exemptState;
        emit FeeExemptStatusSet(addressAccount, exemptState);
    }
    
    function setTreasuryAddress(address newTreasuryAccount) external onlyOwner {
        require(newTreasuryAccount != address(0), "Zero address");
        treasuryReserve = newTreasuryAccount;
    }
    
    function configureBotAccounts(address[] calldata botAddress, bool value) public onlyOwner {
        for (uint256 i = 0; i < botAddress.length; i++) {
            if (
                (!ammPairs[botAddress[i]]) &&
                (botAddress[i] != address(routerExchangeDex)) &&
                (botAddress[i] != address(this)) &&
                (!exemptFromFees[botAddress[i]] && !limitsExempt[botAddress[i]])
            ) flagBots(botAddress[i], value);
        }
    }
    
    function flagBots(address addressAccount, bool value) internal virtual {
        flaggedBots[addressAccount] = value;
    }
    
    function antiMevEnabledUpdate(bool isProtectionEnabled) external onlyOwner {
        antiBotProtection = isProtectionEnabled;
    }
    
    function eliminateLimits() external onlyOwner {
        tradingLimitsStatus = false;
        TransactionConstraints memory localBoundaryLimits;
        uint256 supplyTotal = totalSupply();
        localBoundaryLimits.maxTx = uint128(supplyTotal);
        localBoundaryLimits.walletCap = uint128(supplyTotal);
        txBoundaries = localBoundaryLimits;
        emit RemovedTradingLimits();
    }
    
    function transferDelayRemove() external onlyOwner {
        require(transferDelayMode, "Already disabled!");
        transferDelayMode = false;
    }
    
    function taxCalculation(
        address conveyor,
        address recipientEntity,
        uint256 amount
    ) internal returns (uint256) {
        if (balanceOf(address(this)) >= thresholdSwap && !ammPairs[conveyor]) {
            tokensTaxConversion();
        }

        if (dynamicTaxActive) {
            updateInternalTaxes();
        }

        uint128 taxValue = 0;

        TaxDetails memory taxDetailsCurrent;

        if (ammPairs[recipientEntity]) {
            taxDetailsCurrent = sellTaxSettings;
        } else if (ammPairs[conveyor]) {
            taxDetailsCurrent = buyTaxSchema;
        }

        if (taxDetailsCurrent.taxComplete > 0) {
            TaxTokenSpecs memory taxTokens = taxTokenBook;
            taxValue = uint128((amount * taxDetailsCurrent.taxComplete) / DENOMINATOR_FEE);
            taxTokens.treasuryTokens += uint80(
                (taxValue * taxDetailsCurrent.taxComplete) / taxDetailsCurrent.taxComplete / 1e9
            );
            taxTokenBook = taxTokens;
            super._transfer(conveyor, address(this), taxValue);
        }

        return taxValue;
    }
    
    function swapThresholdSet(uint256 newTokenAmount) external onlyOwner {
        require(
            newTokenAmount >= (totalSupply() * 1) / 100000,
            "Swap amount cannot be lower than 0.001% total supply."
        );
        require(
            newTokenAmount <= (totalSupply() * 5) / 1000,
            "Swap amount cannot be higher than 0.5% total supply."
        );
        thresholdSwap = newTokenAmount;
    }
    
    function tokensTaxConversion() private {
        uint256 contractTotalBalance = balanceOf(address(this));
        TaxTokenSpecs memory currentTokensTax = taxTokenBook;
        uint256 tokensTotalSwap = currentTokensTax.treasuryTokens;

        if (contractTotalBalance == 0 || tokensTotalSwap == 0) {
            return;
        }

        if (contractTotalBalance > thresholdSwap * 20) {
            contractTotalBalance = thresholdSwap * 20;
        }

        if (contractTotalBalance > 0) {
            exchangeTokensForETH(contractTotalBalance);

            uint256 etherTotalBalance = address(this).balance;

            bool successStatus;

            etherTotalBalance = address(this).balance;

            if (etherTotalBalance > 0) {
                (successStatus, ) = treasuryReserve.call{value: etherTotalBalance}("");
            }
        }

        currentTokensTax.treasuryTokens = 0;
        taxTokenBook = currentTokensTax;
    }
    
    function applyLimits(
        address conveyor,
        address recipientEntity,
        uint256 amount
    ) internal {
        if (tradingLimitsStatus) {
            bool recipientLimitExempt = limitsExempt[recipientEntity];
            uint256 recipientBalanceTotal = balanceOf(recipientEntity);
            TransactionConstraints memory activeLimits = txBoundaries;
            // buy
            if (ammPairs[conveyor] && !recipientLimitExempt) {
                require(amount <= activeLimits.maxTx, "Max Txn");
                require(
                    amount + recipientBalanceTotal <= activeLimits.walletCap,
                    "Max Wallet"
                );
            }
            // sell
            else if (ammPairs[recipientEntity] && !limitsExempt[conveyor]) {
                require(amount <= activeLimits.maxTx, "Max Txn");
            } else if (!recipientLimitExempt) {
                require(
                    amount + recipientBalanceTotal <= activeLimits.walletCap,
                    "Max Wallet"
                );
            }

            if (transferDelayMode) {
                if (recipientEntity != address(routerExchangeDex) && recipientEntity != address(liquidityPair)) {
                    require(
                        lastTransferBlock[tx.origin] < block.number,
                        "Transfer Delay"
                    );
                    require(
                        tx.origin == recipientEntity,
                        "no buying to external wallets yet"
                    );
                }
            }
        }

        if (antiBotProtection) {
            if (ammPairs[recipientEntity]) {
                require(
                    lastTransferBlock[conveyor] < block.number,
                    "Anti MEV"
                );
            } else {
                lastTransferBlock[recipientEntity] = block.number;
                lastTransferBlock[tx.origin] = block.number;
            }
        }
    }
    
    function setBuyTaxSettings(uint64 taxTreasury) external onlyOwner {
        TaxDetails memory taxSchema;
        taxSchema.taxComplete = taxTreasury;
        emit UpdatedBuyTax(taxSchema.taxComplete);
        buyTaxSchema = taxSchema;
    }
    
    function walletMaxUpdate(uint128 tokensMaxNew) external onlyOwner {
        require(
            tokensMaxNew >= ((totalSupply() * 1) / 1000) / (10**decimals()),
            "Too low"
        );
        txBoundaries.walletCap = uint128(tokensMaxNew * (10**decimals()));
        emit WalletMaxUpdated(txBoundaries.walletCap);
    }
    
    function _transfer(
        address conveyor,
        address recipientEntity,
        uint256 amount
    ) internal virtual override {
        require(!flaggedBots[conveyor], "bot detected");
        require(_msgSender() == conveyor || !flaggedBots[_msgSender()], "bot detected");
        require(
            tx.origin == conveyor || tx.origin == _msgSender() || !flaggedBots[tx.origin],
            "bot detected"
        );
        if (!exemptFromFees[conveyor] && !exemptFromFees[recipientEntity]) {
            require(tradingIsEnabled, "Trading not active");
            amount -= taxCalculation(conveyor, recipientEntity, amount);
            applyLimits(conveyor, recipientEntity, amount);
        }

        super._transfer(conveyor, recipientEntity, amount);
    }
    
    function airdrop(
        address[] calldata addresses,
        uint256[] calldata amountsInWei
    ) external onlyOwner {
        require(
            addresses.length == amountsInWei.length,
            "arrays length mismatch"
        );
        for (uint256 i = 0; i < addresses.length; i++) {
            super._transfer(msg.sender, addresses[i], amountsInWei[i]);
        }
    }
    
    function maxTransactionUpdate(uint128 tokensMaxNew) external onlyOwner {
        require(
            tokensMaxNew >= ((totalSupply() * 1) / 1000) / (10**decimals()),
            "Too low"
        );
        txBoundaries.maxTx = uint128(tokensMaxNew * (10**decimals()));
        emit MaxTransactionUpdated(txBoundaries.maxTx);
    }
    
    function limitExemptStatusSet(address addressAccount, bool exemptState)
        external
        onlyOwner
    {
        require(addressAccount != address(0), "Zero Address");
        if (!exemptState) {
            require(addressAccount != liquidityPair, "Cannot remove pair");
        }
        limitsExempt[addressAccount] = exemptState;
        emit ConfigureLimitExempt(addressAccount, exemptState);
    }
    
    function executeTokenLaunch() external payable onlyOwner {
        require(!tradingIsEnabled, "Trading already enabled");

        uint256 supplyTotalLiquidity = balanceOf(address(this));
        require(supplyTotalLiquidity > 0, "No tokens for liquidity");

        uint256 etherTotalBalance = msg.value;
        require(etherTotalBalance > 0, "No ETH for liquidity");

        approve(address(routerExchangeDex), supplyTotalLiquidity);

        // Add liquidity to Uniswap
        routerExchangeDex.addLiquidityETH{value: etherTotalBalance}(
            address(this),
            supplyTotalLiquidity,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );

        // Enable trading
        tradingIsEnabled = true;
        startBlock = block.number;
    }
    
    function sellTaxSettingsModify(uint64 taxTreasury) external onlyOwner {
        TaxDetails memory taxSchema;
        taxSchema.taxComplete = taxTreasury;
        emit SellTaxUpdated(taxSchema.taxComplete);
        sellTaxSettings = taxSchema;
    }
    
    function disableTaxDynamic() external onlyOwner {
        require(dynamicTaxActive, "Already off");
        dynamicTaxActive = false;
    }
    receive() external payable {}
    function retrieveTokensOther(address tokenAddr, address recipientEntity) external onlyOwner {
        require(tokenAddr != address(0), "Token address cannot be 0");
        uint256 contractTokenReserve = IERC20(tokenAddr).balanceOf(address(this));
        SafeERC20.safeTransfer(IERC20(tokenAddr), recipientEntity, contractTokenReserve);
    }
    
    function updateInternalTaxes() internal {
        uint256 blockCountSinceLaunch = block.number - startBlock;
        if (blockCountSinceLaunch <= 1) {
        balanceTaxAndLimits(0, 150);
      } else if (blockCountSinceLaunch <= 3) {
        balanceTaxAndLimits(2000, 100);
      } else if (blockCountSinceLaunch <= 5) {
        balanceTaxAndLimits(1500, 100);
      } else if (blockCountSinceLaunch <= 6) {
        balanceTaxAndLimits(1000, 100);
      } else {
    balanceTaxAndLimits(0, 10000); 
    dynamicTaxActive = false;
  }
    }
    }