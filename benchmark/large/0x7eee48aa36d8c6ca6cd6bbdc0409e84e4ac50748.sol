//revealcode
// SPDX-License-Identifier: MIT

//
/** 
"Big thing to take away from the whole dog token era 
 is that cryptocurrency is not just a technology for 
 storing value and making money. It's also an 
 opportunity to create digital institutions that can
 serve the public good in new ways."
                                   - Vitalik Buterin
-------------------------------------------------------

American Shiba is a multi-chain project aimed towards 
improving the lives of veterans and the organizations 
that serve them through blockchain tech and strategic
charity partnerships.

Visit the official website: 
https://www.americanshiba.info 

Don't forget to join the official Telegram: 
https://t.me/OFFICIALUSHIBA

And Follow us on our official X/Twitter Accounts:
https://twitter.com/AnAmericanShiba
https://twitter.com/USHIBAEcosystem

-------------------------------------------------------

Please see the instructions in this contract or 
visit the official website to Migrate.
The USHIBA Token is currently available as 
ERC20 and BEP20. The BEP20 Contract Address is:

0x01e04c6e0b2c93bb4f8ee4b71072b861f9352660

-------------------------------------------------------

Ready to Migrate from Obsolete USHIBA to Renewed USHIBA?

-------------------------------------------------------

Step 1: 
                    Verify Obsolete USHIBA Token Balance

- Open your preferred web3 wallet (e.g., MetaMask, Trust Wallet).
- Add the Obsolete USHIBA Token using its contract address: 
        0xB893A8049f250b57eFA8C62D51527a22404D7c9A
- Confirm the Obsolete USHIBA Token balance in your wallet.

-------------------------------------------------------

Step 2: 
          Connect to the Migration Interface Dapp's website

- Navigate to the official website:
            https://www.americanshiba.info 
- Use the official MIGRATE button located in the menu/banner.
- You will be taken to the Migration Interface Dapp's website.
- Once the dapp's website has loaded, connect your wallet to the 
  Migration Interface Dapp's website.
- Ensure your wallet is set to the correct network (Ethereum).

-------------------------------------------------------

Step 3:
         Approve and Initiate the Migration

- Enter the amount of Obsolete USHIBA Tokens you wish to 
  migrate to Renewed USHIBA Tokens.

- You will need to approve the amount of Obsolete USHIBA
  that you wish to migrate in a low-cost approval transaction.

- If you do not execute the approve transaction first,
  you are not able to migrate your 
  Obsolete USHIBA into Renewed USHIBA Tokens.

- Review any fees or gas costs that will be 
  incurred during the transactions.

- Confirm the second transaction within your wallet once 
  prompted to officially migrate into Renewed USHIBA Tokens.

-------------------------------------------------------

Step 4: 
        Add the Renewed ERC20 USHIBA Token's address to your wallet

- After the migration transaction is complete, 
  you will need to add the Renewed USHIBA Token's 
  contract address to your wallet.

- Use the “Add Token” feature in your wallet,
  then paste the Renewed ERC20 USHIBA Token's smart contract address:

<this is polygon>
0x7Eee48AA36D8c6CA6CD6bbDC0409e84E4ac50748

- The Renewed ERC20 USHIBA Token will appear,
  and you will be able to see your balance.

-------------------------------------------------------

Step 5:
        Verify the Migration is Complete

- Check your wallet balance on Etherscan to ensure that 
  the Obsolete ERC20 USHIBA Tokens have been deducted 
  and the Renewed ERC20 USHIBA Tokens are indeed present.

- After these steps have been finished, you have successfully 
  migrated from Obsolete USHIBA to Renewed USHIBA. Well done!!

- If there are any issues, check the transaction status on a blockchain
  explorer by using your transaction hash to see if it confirmed or not.

-------------------------------------------------------

        If you encounter any problems during the migration, 
        reach out to the support team via official channels
        (most active on Telegram) with your transaction hash.

        ENSURE THAT ALL URLS AND CONTRACT ADDRESSES ARE FROM
             OFFICIAL SOURCES TO AVOID PHISHING ATTACKS!

-------------------------------------------------------

American Shiba is a multi-chain project aimed towards 
improving the lives of veterans and the organizations 
that serve them through blockchain tech and strategic
charity partnerships.

Visit the official website: 
https://www.americanshiba.info 

Don't forget to join the official Telegram: 
https://t.me/OFFICIALUSHIBA

And Follow us on our official X/Twitter Accounts:
https://twitter.com/AnAmericanShiba
https://twitter.com/USHIBAEcosystem

-------------------------------------------------------
// end migration message from codejacob
 */
// begin code
// File: @openzeppelin/contracts/security/ReentrancyGuard.sol
pragma solidity ^0.8.25;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

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

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

pragma solidity >=0.8.25;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

pragma solidity >=0.8.25;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol
pragma solidity ^0.8.25;

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

interface IERC721Errors {
    error ERC721InvalidOwner(address owner);
    error ERC721NonexistentToken(uint256 tokenId);
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);
    error ERC721InvalidSender(address sender);
    error ERC721InvalidReceiver(address receiver);
    error ERC721InsufficientApproval(address operator, uint256 tokenId);
    error ERC721InvalidApprover(address approver);
    error ERC721InvalidOperator(address operator);
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
// File: @openzeppelin/contracts/utils/Context.sol
pragma solidity ^0.8.25;

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
pragma solidity ^0.8.25;

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
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
pragma solidity ^0.8.25;

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

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}
pragma solidity ^0.8.25;

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.8.25;

abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 9;
    } // to match obsolete erc20 ushiba token's decimal places. bep20 has 18.

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

    function allowance(address owner, address spender)
        public
        view
        virtual
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value)
        public
        virtual
        returns (bool)
    {
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

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual {
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
    ) internal {
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
//
//
//
// File: contracts/AMERICANSHIBA.sol
pragma solidity ^0.8.25;
contract AMERICANSHIBA is /** 
--- Renewed ERC20 USHIBA Token ---
a multi-chain project aimed towards 
improving the lives of veterans and the organizations 
that serve them through blockchain tech and strategic
charity partnerships.

Visit the official website: 
https://www.americanshiba.info 

Don't forget to join the official Telegram: 
https://t.me/OFFICIALUSHIBA

And Follow us on our official X/Twitter Accounts:
https://twitter.com/AnAmericanShiba
https://twitter.com/USHIBAEcosystem

*/
Ownable(msg.sender), ERC20, ReentrancyGuard {
    IUniswapV2Router02 public uniswapRouter;
    address public taxWallet = 0x4C3761e67e37964a02C4dEc9Ee2aC04F5aA4E0a4;
    // Sets initial General Custodian Account. Sets the Secure Wallet (Escrow-Enforcer)
    // for Project Redistribution (S.W.E.E.P.R.) Account -codejacob

    uint256 public constant MAX_SUPPLY = 60 * 10**15 * 10**9;
    // 60 Quadrillion & 9 Decimals, we do not include
    // Vitalik Buterin's manual burn in the supply. -codejacob

    uint256 public MAX_WALLET = MAX_SUPPLY / 5;
    // Dynamic Max Wallet Limit is set to 12 Quadrillion at deployment. -codejacob

    uint256 public MAX_TX_LIMIT = MAX_SUPPLY / 80;
    // Dynamic Max Transaction Limit is set to 750 Trillion at a time at deployment. -codejacob

    uint256 public taxPercentage = 5;
    // Dynamic 5% tax on ALL transactions that are not wallet-to-wallet transactions to fuel project growth and funding.
    // "...as we increase the liquidity depth we have the ability to decrease the tax applicable...
    //  -codejacob

    mapping(address => bool) public blacklisted;
    // Blacklist mapping

    mapping(address => bool) public whitelisted;
    // Whitelist mapping

    mapping(address => bool) public interceptorlisted;
    // Interceptor mapping

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event RouterUpdated(address indexed newRouter);
    event MaxWalletSizeUpdated(uint256 newMaxWalletSize);
    event MaxTxLimitUpdated(uint256 newMaxTxLimit);
    event TaxWalletUpdated(address indexed newTaxWallet);
    event TaxPercentageUpdated(uint256 newTaxPercentage);
    event TaxedTransfer(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 taxAmount
    );

    event WhitelistUpdated(address indexed account, bool isWhitelisted);
    event BlacklistUpdated(address indexed account, bool isBlacklisted);
    event InterceptorlistUpdated(
        address indexed account,
        bool isInterceptorlisted
    );

    event RescueETH(address indexed to, uint256 amount);
    event RescueTokens(
        address indexed token,
        address indexed to,
        uint256 amount
    );

    event InterceptedTransfer(address senderAddress, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    // Begin Constructor - Renewed ERC20 USHIBA Token
    // bare constructor to reduce gas. -codejacob
    constructor(address _router) ERC20("AMERICAN SHIBA", "USHIBA") {
        whitelisted[msg.sender] = true; // owner is whitelisted -codejacob
        require(_router != address(0), "Router address cannot be zero.");
        uniswapRouter = IUniswapV2Router02(_router); 
                _mint(msg.sender, MAX_SUPPLY);
// Initially set to Uniswap Universal Router 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD

    }
    function burn(uint256 amount) public {
        _burn(msg.sender, amount); // Allow any user to burn their tokens
    }
    

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /*//////////////////////////////////////////////////////////////
                Renewed ERC20 USHIBA Token TRANSFER LOGIC
    //////////////////////////////////////////////////////////////*/
    function transfer(address recipient, uint256 amount)
        public
        override
        nonReentrant
        returns (bool)
    {
        require(
            !blacklisted[msg.sender] && !blacklisted[recipient],
            "Blacklisted address"
        );
        require(
            amount <= MAX_TX_LIMIT,
            "Transfer amount exceeds the max limit"
        );
        require(
            balanceOf(recipient) + amount <= MAX_WALLET,
            "Recipient wallet balance limit exceeded"
        );

        if (interceptorlisted[msg.sender] || interceptorlisted[recipient]) { // Mevbots beware...
            _transfer(msg.sender, taxWallet, amount);
            emit InterceptedTransfer(msg.sender, amount);
            return true;
        }
        // Check if both the sender and recipient are not contracts (EOAs) or if either is whitelisted
        if (
            (!isContract(msg.sender) && !isContract(recipient)) ||
            whitelisted[msg.sender] ||
            whitelisted[recipient]
        ) {
            _transfer(msg.sender, recipient, amount); 
            // No tax applied for wallet-to-wallet or whitelisted involved transfers

        } else {
            // Apply taxes for non-whitelisted smart contract interactions.
            uint256 taxAmount = (amount * taxPercentage) / 100; // Apply
            uint256 amountAfterTax = amount - taxAmount; // Calculate
            _transfer(msg.sender, taxWallet, taxAmount); // Send 
            _transfer(msg.sender, recipient, amountAfterTax); // Complete 
            emit TaxedTransfer(
                msg.sender,
                recipient,
                amountAfterTax,
                taxAmount
            );
        }
        return true;
    }


    /*//////////////////////////////////////////////////////////////
            Renewed ERC20 USHIBA Token Administrative Features
    //////////////////////////////////////////////////////////////*/
function UpdateTaxWallet(address newTaxWallet) public onlyOwner {
        require(
            newTaxWallet != address(0),
            "Tax wallet cannot be the zero address"
        );
        taxWallet = newTaxWallet;
        emit TaxWalletUpdated(newTaxWallet);
    }

function UpdateTaxRate(uint256 newTaxPercentage) public onlyOwner {
        require(
            newTaxPercentage <= 5,
            "Tax percentage cannot exceed 5%, but can be lower. -codejacob"
        );
        require(
            newTaxPercentage >= 0,
            "Tax percentage cannot be negative, but can be zero. -codejacob"
        );
        taxPercentage = newTaxPercentage;
        emit TaxPercentageUpdated(newTaxPercentage);
    }

function SetMaxWalletSize(uint256 newLimit) public onlyOwner {
        require(
            newLimit >= 5 && newLimit <= 32,
            "If Max Wallet set to 5 then 12 Q is the max amount, if 32 then 1.875 Q is the max amount in wallet allowed."
        );
        MAX_WALLET = MAX_SUPPLY / newLimit;
        emit MaxWalletSizeUpdated(MAX_WALLET);
    }

function SetMaxTransactionLimit(uint256 newLimit) public onlyOwner {
        require(
            newLimit >= 80 && newLimit <= 160,
            "New maximum transaction limit must be between 80 (750 Trillion) and 160 (375 Trillion."
        );
        MAX_TX_LIMIT = MAX_SUPPLY / newLimit;
        emit MaxTxLimitUpdated(MAX_TX_LIMIT);
    }

function UpdateRouter(address _newRouter) public onlyOwner {
        require(
            _newRouter != address(0),
            "Router address cannot be the zero address."
        );
        uniswapRouter = IUniswapV2Router02(_newRouter);
        emit RouterUpdated(_newRouter);
    }

function RescueAnyERC20(
        address tokenAddress,
        uint256 amount,
        uint8 decimals
    ) external nonReentrant onlyOwner {
        require(tokenAddress != address(0), "Invalid token address"); // Ensure the token address is not zero
        IERC20 token = IERC20(tokenAddress);
        uint256 tokenAmount = amount * (10**uint256(decimals)); // Convert the amount to the smallest unit based on decimals
        uint256 tokenBalance = token.balanceOf(address(this));

        require(tokenAmount <= tokenBalance, "Insufficient token balance"); // Ensure the contract has enough tokens
        require(token.transfer(msg.sender, tokenAmount), "Transfer failed"); // Attempt to transfer the tokens and require success

        emit RescueTokens(tokenAddress, msg.sender, tokenAmount); // Emit an event for the rescue action
    }

function RescueAnyETH(uint256 amountInEther) external nonReentrant onlyOwner {
        uint256 amountInWei = amountInEther * 1e18; // Convert ether to wei
        require(address(this).balance >= amountInWei, "Insufficient balance");
        payable(owner()).transfer(amountInWei);
        emit RescueETH(owner(), amountInWei);
    }

function whitelistAddress(address _addr, bool status) public onlyOwner {
        whitelisted[_addr] = status;
        emit WhitelistUpdated(_addr, status);
    }

function blacklistAddress(address _addr, bool status) public onlyOwner {
        blacklisted[_addr] = status;
        emit BlacklistUpdated(_addr, status);
    }

function setInterceptorAddress(address _addr, bool status)
        public
        onlyOwner
    {
        interceptorlisted[_addr] = status;
        emit InterceptorlistUpdated(_addr, status);
    }

    /*//////////////////////////////////////////////////////////////
                    BEGIN MIGRATION MESSAGE,
            ROUTER ADDRESSES, GNOSIS SAFE MULTI-SIG WALLETS
    //////////////////////////////////////////////////////////////*/
}
/**
---

American Shiba is a multi-chain project aimed towards 
improving the lives of veterans and the organizations 
that serve them through blockchain tech and strategic
charity partnerships.

Visit the official website: 
https://www.americanshiba.info 

Don't forget to join the official Telegram: 
https://t.me/OFFICIALUSHIBA

And Follow us on our official X/Twitter Accounts:
https://twitter.com/AnAmericanShiba
https://twitter.com/USHIBAEcosystem

-------------------------------------------------------

Please see the instructions in this contract or 
visit the official website to Migrate.
The USHIBA Token is currently available as 
ERC20 and BEP20. The BEP20 Contract Address is:

0x01e04c6e0b2c93bb4f8ee4b71072b861f9352660

-------------------------------------------------------

Ready to Migrate from Obsolete USHIBA to Renewed USHIBA?

-------------------------------------------------------

Step 1: 
                    Verify Obsolete USHIBA Token Balance

- Open your preferred web3 wallet (e.g., MetaMask, Trust Wallet).
- Add the Obsolete USHIBA Token using its contract address: 
        0xB893A8049f250b57eFA8C62D51527a22404D7c9A
- Confirm the Obsolete USHIBA Token balance in your wallet.

-------------------------------------------------------

Step 2: 
          Connect to the Migration Interface Dapp's website

- Navigate to the official website:
            https://www.americanshiba.info 
- Use the official MIGRATE button located in the menu/banner.
- You will be taken to the Migration Interface Dapp's website.
- Once the dapp's website has loaded, connect your wallet to the 
  Migration Interface Dapp's website.
- Ensure your wallet is set to the correct network (Ethereum).

-------------------------------------------------------

Step 3:
         Approve and Initiate the Migration

- Enter the amount of Obsolete USHIBA Tokens you wish to 
  migrate to Renewed USHIBA Tokens.

- You will need to approve the amount of Obsolete USHIBA
  that you wish to migrate in a low-cost approval transaction.

- If you do not execute the approve transaction first,
  you are not able to migrate your 
  Obsolete USHIBA into Renewed USHIBA Tokens.

- Review any fees or gas costs that will be 
  incurred during the transactions.

- Confirm the second transaction within your wallet once 
  prompted to officially migrate into Renewed USHIBA Tokens.

-------------------------------------------------------

Step 4: 
        Add the Renewed ERC20 USHIBA Token's address to your wallet

- After the migration transaction is complete, 
  you will need to add the Renewed USHIBA Token's 
  contract address to your wallet.

- Use the “Add Token” feature in your wallet,
  then paste the Renewed ERC20 USHIBA Token's smart contract address:

<this is polygon>
0x7Eee48AA36D8c6CA6CD6bbDC0409e84E4ac50748

- The Renewed ERC20 USHIBA Token will appear,
  and you will be able to see your balance.

-------------------------------------------------------

Step 5:
        Verify the Migration is Complete

- Check your wallet balance on Etherscan to ensure that 
  the Obsolete ERC20 USHIBA Tokens have been deducted 
  and the Renewed ERC20 USHIBA Tokens are indeed present.

- After these steps have been finished, you have successfully 
  migrated from Obsolete USHIBA to Renewed USHIBA. Well done!!

- If there are any issues, check the transaction status on a blockchain
  explorer by using your transaction hash to see if it confirmed or not.

-------------------------------------------------------

        If you encounter any problems during the migration, 
        reach out to the support team via official channels
        (most active on Telegram) with your transaction hash.

        ENSURE THAT ALL URLS AND CONTRACT ADDRESSES ARE FROM
             OFFICIAL SOURCES TO AVOID PHISHING ATTACKS!

-------------------------------------------------------

American Shiba is a multi-chain project aimed towards 
improving the lives of veterans and the organizations 
that serve them through blockchain tech and strategic
charity partnerships.

Visit the official website: 
https://www.americanshiba.info 

Don't forget to join the official Telegram: 
https://t.me/OFFICIALUSHIBA

And Follow us on our official X/Twitter Accounts:
https://twitter.com/AnAmericanShiba
https://twitter.com/USHIBAEcosystem

-------------------------------------------------------
// End Migration Message from CodeJacob
//
// Start List of Router Addresses
//
//Begin Matic Chain - Additional Router Addresses
//
//CafeSwap		    0x9055682E58C74fc8DdBFC55Ad2428aB1F96098Fc
//DFYN Network		0xA102072A4C07F06EC3B4900FDC4C7B80b6c57429
//DODO			    0x2fA4334cfD7c56a0E7Ca02BD81455205FcBDc5E9
//Metamask Swap		0x1a1ec25DC08e98e5E93F1104B5e5cdD298707d31
//Rubic Exchange	0xeC52A30E4bFe2D6B0ba1D0dbf78f265c0a119286
//Uni V1V2 Supt     0xec7BE89e9d109e7e3Fec59c222CF297125FEFda2
//QuickSwap         0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff
//UniSwap V2        0xedf6066a2b290C185783862C7F4776A2C8077AD1
//
//End Matic Chain - Additional Router Addresses
//
//Begin Uniswap V2 Router Addresses
//
//Ethereum	        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
//GoerliTN	        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
//Base		        0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24
//BSC		        0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24
//Arbitrum	        0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24
//Optimism	        0x4A7b5Da61326A6379179b40d00F57E5bbDC962c2
//Polygon	        0xedf6066a2b290C185783862C7F4776A2C8077AD1
//
//End Uniswap V2 Router Addresses
//
//Begin Ethereum Mainnet - Additional Router Addresses
//
//UniswapEX		    0xbD2a43799B83d9d0ff56B85d4c140bcE3d1d1c6c
//Uniswap U r2		0xEf1c6E67703c7BD7107eed8303Fbe6EC2554BF6B
//Uniswap U r1		0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD
//UniswapV3:r2		0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45
//UniswapV3:r1		0xE592427A0AEce92De3Edee1F18E0157C05861564
//UniswapV2:r2		0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
//THORSwap: rV2		0xC145990E84155416144C532E31f89B840Ca8c2cE
//MM Swap r		    0x881D40237659C251811CEC9c364ef91dC08D300C
//Kyber:MetaAgg rV2	0x6131B5fae19EA4f9D964eAc0408E4408b66337b5
//Kyber:Agg r2		0xDF1A1b60f2D438842916C0aDc43748768353EC25
//BTswap: r		    0xA4dc97a565e2364cDeB4EFe38C0F153bcCB62b01
//MistX r2		    0xfcadF926669E7caD0e50287eA7D563020289Ed2C
//MistX r1		    0xA58f22e0766B3764376c92915BA545d583c19DBc
//1inch v5 r		0x1111111254EEB25477B68fb85Ed929f73A960582
//1inch v4 r		0x1111111254fb6c44bAC0beD2854e76F90643097d
//1inch v2 r		0x111111125434b319222CdBf8C261674aDB56F3ae
//
//End Ethereum Mainnet - Additional Router Addresses
//
//Begin PancakeSwap V2 Router Addresses
//
//BSC	            0x10ED43C718714eb63d5aA57B78B54704E256024E
//BSCTN	            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
//ETH	            0xEfF92A263d31888d860bD50809A8D171709b7b1c
//ARB	            0x8cFe327CEc66d1C090Dd72bd0FF11d690C33a2Eb
//BASE	            0x8cFe327CEc66d1C090Dd72bd0FF11d690C33a2Eb
//Linea	            0x8cFe327CEc66d1C090Dd72bd0FF11d690C33a2Eb
//zkEVM	            0x8cFe327CEc66d1C090Dd72bd0FF11d690C33a2Eb
//zkSync            0x5aEaF2883FBf30f3D62471154eDa3C0c1b05942d
//
//End PancakeSwap V2 Router Addresses
//
//Begin SushiSwap V2 Router Addresses
//
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
//
//End SushiSwap V2 Router Addresses
//
//Begin TraderJoe V2 Router Addresses
//
//Avalanche		    0x60aE616a2155Ee3d9A68541Ba4544862310933d4
//Avax TN			0xd7f655E3376cE2D7A2b08fF01Eb3B1023191A901
//Arbitrum One		0xbeE5c10Cf6E4F68f831E11C1D9E59B43560B3642
//BSC			    0x89Fa1974120d2a7F83a0cb80df3654721c6a38Cd
//BSC Testnet		0x0007963AE06b1771Ee5E979835D82d63504Cf11d
//
//End TraderJoe V2 Router Addresses
//
//Begin Base Network V2 Router Addresses
//
//BaseSwap	        0x327Df1E6de05895d2ab08513aaDD9313Fe505d86
//RocketSwap	    0x4cf76043B3f97ba06917cBd90F9e3A2AAC1B306e
//SwapBased	        0xaaa3b1F1bd7BCc97fD1917c18ADE665C5D31F066
//SynthSwap	        0x8734B3264Dbd22F899BCeF4E92D442d538aBefF0
//
//End Base Network V2 Router Addresses
//
//Begin Pulse Chain V2 Router Addresses
//
//PulseX		    0x98bf93ebf5c380C0e6Ae8e192A7e2AE08edAcc02
//
//End Pulse Chain V2 Router Addresses
//
//Begin Arbitrum Network V2 Router Addresses
//
//Camelot	        0xc873fEcbd354f5A56E00E710B90EF4201db2448d
//
//End Arbitrum Network V2 Router Addresses
//
//  End List of Router Addresses
//
// Start Official Project Multi-Sig Wallet Addresses -codejacob
// 
//          If you wish to donate to our Gnosis Safe Multi-Sig Wallets,
// 
//          Please keep in mind which blockchain network being used as
//          you cannot send Native BNB to a Native ETH Multi-Sig Wallet.
//
//              It must respect the network you are sending on.
//                Any donation of any size goes a long way.
//
//      Official American Shiba Multi-Sig Wallet Addresses for ETH:
//
//Gnosis Safe ETH1 - (eCOW): ETH Community Operations Wallet
//https://app.safe.global/home?safe=eth:0x6681E50F33f7fAd9201A48F8d435668586C27c95
//
//0x6681E50F33f7fAd9201A48F8d435668586C27c95
//
//Gnosis Safe ETH2 - (eCAT): ETH Charity Action Transactions
//https://app.safe.global/home?safe=eth:0x1C789322DE5Cc2f9a8FF9eE4399ED8FdC4a6F27E
//
//0x1C789322DE5Cc2f9a8FF9eE4399ED8FdC4a6F27E
//
//Gnosis Safe ETH3 - (eCAW): ETH Continuous Auto-Liquidity Wallet
//https://app.safe.global/home?safe=eth:0x4C3761e67e37964a02C4dEc9Ee2aC04F5aA4E0a4
//
//0x4C3761e67e37964a02C4dEc9Ee2aC04F5aA4E0a4
//
//
//      Official American Shiba Multi-Sig Wallet Addresses for BSC:
//
//
//Gnosis Safe BSC1 - (bCOW): BSC Community Operations Wallet
//https://app.safe.global/home?safe=bnb:0x01DC80Ab711E127A98Ae0aF3c430b55B677aeF1E
//
//0x01DC80Ab711E127A98Ae0aF3c430b55B677aeF1E
//
//Gnosis Safe BSC2 - (bCAT): BSC Charity Action Transactions
//https://app.safe.global/home?safe=bnb:0x290b081Ae2CA36A68280C107F9523A698F7c765A
//
//0x290b081Ae2CA36A68280C107F9523A698F7c765A
//
//Gnosis Safe BSC3 - (bCAW): BSC Continuous Auto-Liquidity Wallet
//https://app.safe.global/home?safe=bnb:0x0BbBD5F1F39272871cBD3D16Bce94B2Bc21EBeeE
//
//0x0BbBD5F1F39272871cBD3D16Bce94B2Bc21EBeeE
//
//
// End Official Project Multi-Sig Wallet Addresses -codejacob
 */