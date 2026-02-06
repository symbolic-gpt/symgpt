pragma solidity 0.8.20;

/*
 
/*
 *
 * Creator: WiToken Foundation Limited
 * WiToken Token Contract
 *
 */

/*
 * Safe Math Smart Contract.
 * https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */

contract SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * ERC-20 standard token interface, as defined
 * <a href="http://github.com/ethereum/EIPs/issues/20">here</a>.
 */
abstract contract Token {
    function totalSupply() public view virtual returns (uint256 supply);

    function balanceOf(address _owner) public view virtual returns (uint256 balance);

    function transfer(
        address _to,
        uint256 _value
    ) public virtual returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public virtual returns (bool success);

    function approve(
        address _spender,
        uint256 _value
    ) public virtual returns (bool success);

    function allowance(
        address _owner,
        address _spender
    ) public view virtual returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

/**
 * Abstract Token Smart Contract that could be used as a base contract for
 * ERC-20 token contracts.
 */
abstract contract AbstractToken is Token, SafeMath {
    /**
     * Create new Abstract Token contract.
     */
    constructor() {
        // Do nothing
    }

    
    function balanceOf(address _owner) public view override returns (uint256 balance) {
        return accounts[_owner];
    }

    function transfer(
        address _to,
        uint256 _value
    ) public       virtual
      override
returns (bool success) {
        require(_to != address(0));
        if (accounts[msg.sender] < _value) return false;
        if (_value > 0 && msg.sender != _to) {
            accounts[msg.sender] = safeSub(accounts[msg.sender], _value);
            accounts[_to] = safeAdd(accounts[_to], _value);
        }
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public       virtual
      override
returns (bool success) {
        require(_to != address(0));
        if (allowances[_from][msg.sender] < _value) return false;
        if (accounts[_from] < _value) return false;

        if (_value > 0 && _from != _to) {
            allowances[_from][msg.sender] = safeSub(
                allowances[_from][msg.sender],
                _value
            );
            accounts[_from] = safeSub(accounts[_from], _value);
            accounts[_to] = safeAdd(accounts[_to], _value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(
        address _spender,
        uint256 _value
    ) public       virtual
      override
returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    
    function allowance(
        address _owner,
        address _spender
    ) public view       override
returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    /**
     * Mapping from addresses of token holders to the numbers of tokens belonging
     * to these token holders.
     */
    mapping(address => uint256) accounts;

    /**
     * Mapping from addresses of token holders to the mapping of addresses of
     * spenders to the allowances set by these token holders to these spenders.
     */
    mapping(address => mapping(address => uint256)) private allowances;
}

/**
 * WiToken smart contract.
 */
contract WiT is AbstractToken {
    /**
     * Maximum allowed number of tokens in circulation.
     * tokenSupply = tokensIActuallyWant * (10 ^ decimals)
     */

    uint256 constant MAX_TOKEN_COUNT = 60000000000 * (10 ** 16);

    /**
     * Address of the owner of this smart contract.
     */
    address private owner;

    /**
     * Frozen account list holder
     */
    mapping(address => bool) private frozenAccount;

    /**
     * Current number of tokens in circulation.
     */
    uint256 tokenCount = 0;

    /**
     * True if tokens transfers are currently frozen, false otherwise.
     */
    bool frozen = false;

    /**
     * Create new token smart contract and make msg.sender the
     * owner of this smart contract.
     */
    constructor() {
        owner = msg.sender;
    }

    function totalSupply() public view override returns (uint256 supply) {
        return tokenCount;
    }

    string public constant name = "WiToken";
    string public constant symbol = "WiT";
    uint8 public constant decimals = 16;

   
    function transfer(
        address _to,
        uint256 _value
    ) public       override
returns (bool success) {
        require(!frozenAccount[msg.sender]);
        if (frozen) return false;
        else return AbstractToken.transfer(_to, _value);
    }

   
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public       override
returns (bool success) {
        require(!frozenAccount[_from]);
        if (frozen) return false;
        else return AbstractToken.transferFrom(_from, _to, _value);
    }

    
    function approve(
        address _spender,
        uint256 _value
    ) public       override
returns (bool success) {
        require(allowance(msg.sender, _spender) == 0 || _value == 0);
        return AbstractToken.approve(_spender, _value);
    }

    
    function createTokens(uint256 _value) public returns (bool success) {
        require(msg.sender == owner);

        if (_value > 0) {
            if (_value > safeSub(MAX_TOKEN_COUNT, tokenCount)) return false;

            accounts[msg.sender] = safeAdd(accounts[msg.sender], _value);
            tokenCount = safeAdd(tokenCount, _value);

            // adding transfer event and _from address as null address
            emit Transfer(address(0), msg.sender, _value);

            return true;
        }

        return false;
    }


    function mintToken(
        address target,
        uint256 mintedAmount
    ) public returns (bool success) {
        require(msg.sender == owner);
        if (mintedAmount > 0) {
            accounts[target] = safeAdd(accounts[target], mintedAmount);
            tokenCount = safeAdd(tokenCount, mintedAmount);

            // adding transfer event and _from address as null address
            emit Transfer(address(0), target, mintedAmount);

            return true;
        }
        return false;
    }

    /**
     * Set new owner for the smart contract.
     * May only be called by smart contract owner.
     *
     * @param _newOwner address of new owner of the smart contract
     */
    function setOwner(address _newOwner) public {
        require(msg.sender == owner);

        owner = _newOwner;
    }

    /**
     * Freeze ALL token transfers.
     * May only be called by smart contract owner.
     */
    function freezeTransfers() public {
        require(msg.sender == owner);

        if (!frozen) {
            frozen = true;
            emit Freeze();
        }
    }

    /**
     * Unfreeze ALL token transfers.
     * May only be called by smart contract owner.
     */
    function unfreezeTransfers() public {
        require(msg.sender == owner);

        if (frozen) {
            frozen = false;
            emit Unfreeze();
        }
    }

    /*A user is able to unintentionally send tokens to a contract
     * and if the contract is not prepared to refund them they will get stuck in the contract.
     * The same issue used to happen for Ether too but new Solidity versions added the payable modifier to
     * prevent unintended Ether transfers. However, there’s no such mechanism for token transfers.
     * so the below function is created
     */

    function refundTokens(
        address _token,
        address _refund,
        uint256 _value
    ) public {
        require(msg.sender == owner);
        require(_token != address(this));
        AbstractToken token = AbstractToken(_token);
        token.transfer(_refund, _value);
        emit RefundTokens(_token, _refund, _value);
    }

    /**
     * Freeze specific account
     * May only be called by smart contract owner.
     */
    function freezeAccount(address _target, bool freeze) public {
        require(msg.sender == owner);
        require(msg.sender != _target);
        frozenAccount[_target] = freeze;
        emit FrozenFunds(_target, freeze);
    }

    /**
     * Logged when token transfers were frozen.
     */
    event Freeze();

    /**
     * Logged when token transfers were unfrozen.
     */
    event Unfreeze();

    /**
     * Logged when a particular account is frozen.
     */

    event FrozenFunds(address target, bool frozen);

    /**
     * when accidentally send other tokens are refunded
     */

    event RefundTokens(address _token, address _refund, uint256 _value);
}
