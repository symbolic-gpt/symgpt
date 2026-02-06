// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

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

//
// begin code
//

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
pragma solidity ^0.8.20;
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;}
    modifier nonReentrant() {_nonReentrantBefore();_;_nonReentrantAfter();}
    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;}
    function _nonReentrantAfter() private {_status = _NOT_ENTERED;}
    function _reentrancyGuardEntered() internal view returns (bool) {return _status == _ENTERED;}}

// Errors
pragma solidity ^0.8.25;
interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);}

interface IERC721Errors {
error ERC721InvalidOwner(address owner);
error ERC721NonexistentToken(uint256 tokenId);
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);
    error ERC721InvalidSender(address sender);
    error ERC721InvalidReceiver(address receiver);
    error ERC721InsufficientApproval(address operator, uint256 tokenId);
    error ERC721InvalidApprover(address approver);
    error ERC721InvalidOperator(address operator);}

interface IERC1155Errors {
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);
    error ERC1155InvalidSender(address sender);
    error ERC1155InvalidReceiver(address receiver);
    error ERC1155MissingApprovalForAll(address operator, address owner);
    error ERC1155InvalidApprover(address approver);
    error ERC1155InvalidOperator(address operator);
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);}

pragma solidity ^0.8.25;
abstract contract Context {
function _msgSender() internal view virtual returns (address) {return msg.sender;}
function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}
function _contextSuffixLength() internal view virtual returns (uint256) {return 0;}}

pragma solidity ^0.8.25;

abstract contract Ownable is Context {
    address private _owner;
    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));}
        _transferOwnership(initialOwner);} modifier onlyOwner() {_checkOwner();_;}
    function owner() public view virtual returns (address) {return _owner;}
    function _checkOwner() internal view virtual {if (owner() != _msgSender()) {
    revert OwnableUnauthorizedAccount(_msgSender());}}

    function renounceOwnership() public virtual onlyOwner {_transferOwnership(address(0));}

    function transferOwnership(address newOwner) public virtual onlyOwner {
    if (newOwner == address(0)) {revert OwnableInvalidOwner(address(0));}
        _transferOwnership(newOwner);}

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;_owner = newOwner;emit OwnershipTransferred(oldOwner, newOwner);}}

pragma solidity ^0.8.25;
library Address {error AddressInsufficientBalance(address account);error AddressEmptyCode(address target);error FailedInnerCall();
function sendValue(address payable recipient, uint256 amount) internal {if (address(this).balance < amount) {revert AddressInsufficientBalance(address(this));}
(bool success, ) = recipient.call{value: amount}("");if (!success) {revert FailedInnerCall();}}
function functionCall(address target, bytes memory data) internal returns (bytes memory) {return functionCallWithValue(target, data, 0);}
function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {if (address(this).balance < value) {
revert AddressInsufficientBalance(address(this));}(bool success, bytes memory returndata) = target.call{value: value}(data);
return verifyCallResultFromTarget(target, success, returndata);}
function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {(bool success, bytes memory returndata) = target.staticcall(data);
return verifyCallResultFromTarget(target, success, returndata);}
function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {(bool success, bytes memory returndata) = target.delegatecall(data);
return verifyCallResultFromTarget(target, success, returndata);}
function verifyCallResultFromTarget(address target,bool success,bytes memory returndata) internal view returns (bytes memory) {if (!success) {_revert(returndata);
} else {if (returndata.length == 0 && target.code.length == 0) {revert AddressEmptyCode(target);}return returndata;}}
function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {if (!success) {_revert(returndata);} else {return returndata;}}
function _revert(bytes memory returndata) private pure {if (returndata.length > 0) {assembly {let returndata_size 
:= mload(returndata)revert(add(32, returndata), returndata_size)}} else {revert FailedInnerCall();}}}

pragma solidity ^0.8.25;
interface IERC20Permit {
    function permit(address owner,address spender,uint256 value,uint256 deadline,uint8 v,bytes32 r,bytes32 s) external;
    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);}

pragma solidity ^0.8.25;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);}

pragma solidity ^0.8.25;

interface IERC20Metadata is IERC20 {
function name() external view returns (string memory);
function symbol() external view returns (string memory);
function decimals() external view returns (uint8);}

pragma solidity ^0.8.25;

abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;
    mapping(address account => mapping(address spender => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {_name = name_;_symbol = symbol_;}
    function name() public view virtual returns (string memory) {return _name;}
    function symbol() public view virtual returns (string memory) {return _symbol;}
    function decimals() public view virtual returns (uint8) {return 9;} //set to 9, as the ERC20 variant of USHIBA has 9 decimals
    function totalSupply() public view virtual returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view virtual returns (uint256) {return _balances[account];}
    function transfer(address to, uint256 value) public virtual returns (bool) {address owner = _msgSender();
        _transfer(owner, to, value);return true;}
    function allowance(address owner, address spender) public view virtual returns (uint256) 
    {return _allowances[owner][spender];}
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();_approve(owner, spender, value);return true;}
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool)
     {address spender = _msgSender();_spendAllowance(from, spender, value);_transfer(from, to, value);
        return true;}
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {revert ERC20InvalidSender(address(0));}
        if (to == address(0)) {revert ERC20InvalidReceiver(address(0));}_update(from, to, value);}
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) { _totalSupply += value;} else {uint256 fromBalance = _balances[from];
            if (fromBalance < value) {revert ERC20InsufficientBalance(from, fromBalance, value);}
            unchecked {_balances[from] = fromBalance - value;}}
        if (to == address(0)) {unchecked {_totalSupply -= value;}} else {unchecked {_balances[to] += value;}}
        emit Transfer(from, to, value);}
    function _mint(address account, uint256 value) internal {if (account == address(0)) {revert ERC20InvalidReceiver(address(0));}
        _update(address(0), account, value);}
    function _burn(address account, uint256 value) internal {if (account == address(0)) {revert ERC20InvalidSender(address(0));}
        _update(account, address(0), value);}
    function _approve(address owner, address spender, uint256 value) internal {_approve(owner, spender, value, true);}
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {if (owner == address(0)) 
    {revert ERC20InvalidApprover(address(0));}if (spender == address(0)) {revert ERC20InvalidSpender(address(0));}
        _allowances[owner][spender] = value;if (emitEvent) {emit Approval(owner, spender, value);}}
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);if (currentAllowance != type(uint256).max) {if (currentAllowance < value) {
    revert ERC20InsufficientAllowance(spender, currentAllowance, value);}unchecked {_approve(owner, spender, currentAllowance - value, false);}}}}

pragma solidity ^0.8.25;
library SafeERC20 {
    using Address for address;
    error SafeERC20FailedOperation(address token);
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));}
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));}
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);}
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {unchecked {uint256 currentAllowance = 
    token.allowance(address(this), spender);if (currentAllowance < requestedDecrease) {revert SafeERC20FailedDecreaseAllowance(spender, 
    currentAllowance, requestedDecrease);}forceApprove(token, spender, currentAllowance - requestedDecrease);}}
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));if (!_callOptionalReturnBool(token, approvalCall)) {
    _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));_callOptionalReturn(token, approvalCall);}}
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));} }
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;}}
pragma solidity >=0.8.25;

contract AMERICANSHIBA is ReentrancyGuard, ERC20("AMERICAN SHIBA", "USHIBA"), Ownable(msg.sender) {
    using SafeERC20 for IERC20;
	IUniswapV2Router02 public uniswapRouter;

	// General Treasury Wallet Address
    address payable public generalTreasury;

	// Fee Collector Wallet Address
    address payable public USHIBAfeeCollector;

    // Buy and Sell Fees
    uint256 public buyFee = 100; //test 
    //1.0% fee initially on buy orders, cannot exceed 5%
    uint256 public sellFee = 200; //test 
    //2.0% fee initially set on sell orders, cannot exceed 5%
    uint256 public swapFeePercent = 300; //test 
    //3% fee swap to native 

    uint256 public constant MAX_SUPPLY = 60 * 10**15 * 10**9; // 60 Quadrillion & 9 Decimals.

    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public isWhitelistedFromFees;
    mapping(address => bool) public isSellFeeAddress; // Tracks addresses where if interacted with, sell fees activate.

    // Events
    event RouterUpdated(address indexed newRouter);
    event FeeCollectorUpdated(address indexed newFeeCollector);

    event EtherReceived(address indexed sender, uint256 amount, address indexed treasury);

    event BlacklistedStatusUpdated(address account, bool status);
    event WhitelistedStatusUpdated(address account, bool status);

    event SellFeeAddressAdded(address indexed addr);
    event SellFeeAddressRemoved(address indexed addr);

    event SwapAndSend(uint256 tokenAmount, uint256 ethReceived, address recipient);
    event GeneralTreasuryUpdated(address indexed newTreasury);

    event SwapFeeUpdated(uint256 newSwapFee);
    event BuyFeeUpdated(uint256 newFee);
    event SellFeeUpdated(uint256 newFee);

//  Begin Constructor

    constructor(address routerAddress, address _USHIBAfeeCollector, address _newGeneralTreasury) {
        USHIBAfeeCollector = payable(_USHIBAfeeCollector);
        _mint(msg.sender, MAX_SUPPLY); // Mint the max supply to the deployer
        isWhitelistedFromFees[msg.sender] = true; // owner is whitelisted
        updateRouter(routerAddress);
        generalTreasury = payable(_newGeneralTreasury);
    }

    receive() external payable // to general treasury
	{
        require(generalTreasury != address(0), "General Treasury not set");
        emit EtherReceived(msg.sender, msg.value, generalTreasury);
        (bool sent, ) = generalTreasury.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
    // check if contract or wallet
function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(account) }
    return size > 0;
}
    // Allows the owner to update the treasury address
    function updateGeneralTreasury(address payable _newTreasury) public onlyOwner {
        require(_newTreasury != address(0), "Invalid address");
        generalTreasury = _newTreasury;
        emit GeneralTreasuryUpdated(_newTreasury);
    }
    // Allows the owner to update the Router address
    function updateRouter(address newRouter) public onlyOwner {
        require(newRouter != address(0), "Router address cannot be zero.");
        uniswapRouter = IUniswapV2Router02(newRouter);
        emit RouterUpdated(newRouter);
    }
    // Allows the owner to update the USHIBA Fee Collector Wallet Address
    function updateUSHIBAfeeCollector(address _newUSHIBAfeeCollector) public onlyOwner {
    require(_newUSHIBAfeeCollector != address(0), "Invalid address");
    USHIBAfeeCollector = payable(_newUSHIBAfeeCollector);
}
    // Allows the owner to update the buy fees, cannot exceed 500 or be less than 10
    function updateBuyFee(uint256 newFee) public onlyOwner {
        require(newFee <= 500 && newFee >= 10, "Buy Fee must be between 0.1% and 5%");
        buyFee = newFee;
        emit BuyFeeUpdated(newFee);
    }
    // Allows the owner to update the sell fees, cannot exceed 500 (5%) or be less than 10 (0.1%)
    function updateSellFee(uint256 newFee) public onlyOwner {
        require(newFee <= 500 && newFee >= 10, "Sell Fee must be between 0.1% and 5%");
        sellFee = newFee;
        emit SellFeeUpdated(newFee);
    }
    // Function to update the swap fee percentage
    function updateSwapFeePercent(uint256 newSwapFee) public onlyOwner {
        // Check that the new fee is within the specified bounds (0.1% to 5%)
        require(newSwapFee >= 10 && newSwapFee <= 500, "Swap Fee must be between 0.1% and 5%");

        // Update the swap fee percentage
        swapFeePercent = newSwapFee;

        // Emit an event for the swap fee update
        emit SwapFeeUpdated(newSwapFee);
    }
    // Allows the owner to designate sell fees activate on specified wallet address(es)
    function setSellFeeAddress(address addr, bool status) public onlyOwner {
        isSellFeeAddress[addr] = status;
        if (status) {
            emit SellFeeAddressAdded(addr);
        } else {
            emit SellFeeAddressRemoved(addr);
        }}

// Begin xferL
function transfer(address recipient, uint256 amount) public override returns (bool) {
    // Check if sender or recipient is blacklisted
    require(!isBlacklisted[_msgSender()] && !isBlacklisted[recipient], "Sorry, a Blacklisted wallet or bot address was detected.");
    // Check for fee exemptions
    if (isWhitelistedFromFees[_msgSender()] || isWhitelistedFromFees[recipient] || (!isContract(_msgSender()) && !isContract(recipient))) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    uint256 feeAmount;
    uint256 amountAfterFee;

    // Check if recipient incurs sell fees
    if (isSellFeeAddress[recipient]) {
        feeAmount = (amount * sellFee) / 10000;

    } else {
        feeAmount = (amount * buyFee) / 10000;

    }
    
    amountAfterFee = amount - feeAmount;
    
    // Transfer the fee to the feeCollector and the remaining amount to the recipient
    _transfer(_msgSender(), USHIBAfeeCollector, feeAmount);
    _transfer(_msgSender(), recipient, amountAfterFee);
    
    return true;
}
// End xferL


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
function SwapUSHIBAForNative(uint256 tokenAmount) public {

    // Ensure the sender has enough tokens to perform the swap
    require(balanceOf(msg.sender) >= tokenAmount, "Insufficient token balance");

    // Approve the Uniswap router to handle the specified amount of tokens
    _approve(msg.sender, address(uniswapRouter), tokenAmount);

    // Set up the swap path (USHIBA to native currency)
    address[] memory path = new address[](2);
    path[0] = address(this);  // USHIBA contract address
    path[1] = uniswapRouter.WETH();  // Native currency (e.g., WETH for Ethereum)

    // Capture current balance to calculate the amount received
    uint256 initialBalance = address(this).balance;

    // Execute the token swap on Uniswap, from USHIBA to native currency
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
    uint256 swapFee = nativeReceived * swapFeePercent / 10000;
    uint256 amountToSend = nativeReceived - swapFee;

    // Transfer the swap fee to the fee collector
    payable(USHIBAfeeCollector).transfer(swapFee);
    // Transfer the remaining native currency to the sender
    payable(msg.sender).transfer(amountToSend);

    // Emit an event to log the swap details
    emit SwapAndSend(tokenAmount, nativeReceived, msg.sender);
}
//manualcall
    function recoverETH() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        payable(owner()).transfer(contractBalance);
    }

    function recoverForeignTokens(address tokenAddress, uint256 tokenAmount) public onlyOwner {
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