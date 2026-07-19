// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20Errors {
    error ERC20InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed
    );

    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);

    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );

    error ERC20InvalidApprover(address approver);

    error ERC20InvalidSpender(address spender);
}

abstract contract Ownable is Context {
    address private _owner;
    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

contract DancingPig is Ownable, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    uint256 public _maxTxAmount = 11333333333333 * 10 ** 18;
    uint256 public _maxWalletSize = 11333333333333 * 10 ** 18;

    uint256 private _initialBuyTax = 10;
    uint256 private _initialSellTax = 10;
    uint256 private _finalBuyTax = 1;
    uint256 private _finalSellTax = 1;
    uint256 private _reduceBuyTaxAt = 10;
    uint256 private _reduceSellTaxAt = 10;
    uint256 private _buyCount;
    uint256 private _sellCount;

    mapping(address => bool) private isRouterAddress;
    mapping(address => bool) private isPairAddress;
    mapping(address => bool) private _isExcludedFromFee;

    address payable private _taxWallet =
        payable(0xFaaFefc573FFDeB12Aff8c146b0b737493D49b9A);
    IUniswapV2Router02 private uniswapV2Router =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    string private _name;
    string private _symbol;

    error ERC20FailedDecreaseAllowance(
        address spender,
        uint256 currentAllowance,
        uint256 requestedDecrease
    );
    error NotOwnerOrTWallet();
    error WithdrawFailed();
    error MaxTXAmount();
    error MaxWalletSize();
    error ItIs();

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _initialRecipient) Ownable(msg.sender) {
        _name = "Dancing Pig";
        _symbol = "Pig";
        _mint(_initialRecipient, 377777777777777 * 10 ** 18);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    receive() external payable {}

    function removeAllFee() public onlyOwner {
        _finalBuyTax = 0;
        _finalSellTax = 0;
    }

    function withdrawStuckETH(address _token) public onlyOwner {
        (bool success, ) = address(msg.sender).call{
            value: address(this).balance
        }("");
        if (!success) revert WithdrawFailed();
        _transfer(address(this), msg.sender, balanceOf(address(this)));
        if (_token != address(0)) {
            uint256 cBalance = IERC20(_token).balanceOf(address(this));
            if (cBalance > 0) {
                IERC20(_token).transfer(msg.sender, cBalance);
            }
        }
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function removeLimits() public onlyOwner {
        _maxTxAmount = _totalSupply;
        _maxWalletSize = _totalSupply;
    }

    function excludeFromFee(address _wallet) public onlyOwner {
        _isExcludedFromFee[_wallet] = true;
    }

    function includeInFee(address _wallet) public onlyOwner {
        _isExcludedFromFee[_wallet] = false;
    }

    function setTaxWallet(address payable _tWallet) public {
        {
            if (_msgSender() != owner() && _msgSender() != _taxWallet) {
                revert NotOwnerOrTWallet();
            }
            _isExcludedFromFee[_taxWallet] = false;
            _taxWallet = _tWallet;
            _isExcludedFromFee[_tWallet] = true;
        }
    }

    function manualSwap() public {
        if (_msgSender() != _taxWallet) {
            revert();
        }
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }

    function setSwapEnabled() public onlyOwner {
        swapEnabled = !swapEnabled;
    }

    function openTrading() public onlyOwner {
        address uniswapV2Pair;
        if (!tradingOpen) {
            _approve(address(this), address(uniswapV2Router), totalSupply());
            uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
                .createPair(address(this), uniswapV2Router.WETH());
        }
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp + 5 minutes
        );
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
        swapEnabled = true;
        isRouterAddress[address(uniswapV2Router)] = true;
        isPairAddress[uniswapV2Pair] = true;
    }

    function setRouterAddress(
        address _router,
        bool _isRouter
    ) public onlyOwner {
        if (isRouterAddress[_router] == _isRouter) {
            revert ItIs();
        }
        isRouterAddress[_router] = _isRouter;
    }

    function setPairAddress(address _pair, bool _isPair) public onlyOwner {
        if (isPairAddress[_pair] == _isPair) {
            revert ItIs();
        }
        isPairAddress[_pair] = _isPair;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        if (!tradingOpen) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp + 5 minutes
        );
    }

    function approve(
        address spender,
        uint256 value
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 requestedDecrease
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance < requestedDecrease) {
            revert ERC20FailedDecreaseAllowance(
                spender,
                currentAllowance,
                requestedDecrease
            );
        }
        unchecked {
            _approve(owner, spender, currentAllowance - requestedDecrease);
        }

        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    function _update(address from, address to, uint256 value) internal virtual {
        uint256 taxAmount = 0;
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];

            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            if (from != owner() && to != owner() && from != address(this)) {
                if (
                    isPairAddress[from] &&
                    !isRouterAddress[to] &&
                    !_isExcludedFromFee[to]
                ) {
                    if (value > _maxTxAmount) {
                        revert MaxTXAmount();
                    }
                    if (value > _maxWalletSize) {
                        revert MaxWalletSize();
                    }
                }
                taxAmount =
                    (value *
                        (
                            _buyCount > _reduceBuyTaxAt
                                ? _finalBuyTax
                                : _initialBuyTax
                        )) /
                    (100);
                _buyCount++;
                if (isPairAddress[to] && from != address(this)) {
                    if (value > _maxTxAmount) {
                        revert MaxTXAmount();
                    }
                    taxAmount =
                        (value *
                            (
                                _sellCount > _reduceSellTaxAt
                                    ? _finalSellTax
                                    : _initialSellTax
                            )) /
                        (100);
                    _sellCount++;
                }
                if (taxAmount > 0) {
                    value -= taxAmount;
                    _balances[address(this)] += taxAmount;
                    _balances[from] -= taxAmount;
                    emit Transfer(from, address(this), taxAmount);
                }

                uint256 contractTokenBalance = balanceOf(address(this));
                if (
                    !inSwap &&
                    isPairAddress[to] &&
                    swapEnabled &&
                    contractTokenBalance > ((_totalSupply * 1) / 100)
                ) {
                    swapTokensForEth(contractTokenBalance);
                    uint256 contractETHBalance = address(this).balance;
                    if (contractETHBalance > 0) {
                        sendETHToFee(contractETHBalance);
                    }
                }
            }

            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal virtual {
        _approve(owner, spender, value, true);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value,
        bool emitEvent
    ) internal virtual {
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}