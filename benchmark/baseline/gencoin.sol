/**
 *Submitted for verification at Etherscan.io on 2019-02-20
 */

pragma solidity 0.8.20;

contract Token {
    // function totalSupply() public view virtual returns (uint256 supply) {}


    function balanceOf(address _owner) public view virtual returns (uint256 balance) {}

    function transfer(address _to, uint256 _value) public virtual returns (bool success) {}


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public virtual returns (bool success) {}


    function approve(address _spender, uint256 _value) public virtual returns (bool success) {}


    function allowance(
        address _owner,
        address _spender
    ) public view virtual returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

contract StandardToken is Token {
    function transfer(address _to, uint256 _value) public override returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        if (
            balances[_from] >= _value &&
            allowed[_from][msg.sender] >= _value &&
            _value > 0
        ) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function balanceOf(address _owner) public view override returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view override returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    uint256 public totalSupply;
}

contract GEIMCOIN is StandardToken {
    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = "GEIMCOIN.1";
    uint256 public unitsOneEthCanBuy;
    uint256 public totalEthInWei;
    address payable  fundsWallet;

    constructor() {
        balances[msg.sender] = 500000000000000000000000;
        totalSupply = 500000000000000000000000;
        name = "GEIMCOIN";
        decimals = 18;
        symbol = "GMC";
        unitsOneEthCanBuy = 1000;
        fundsWallet = payable(msg.sender);
    }

    receive() external payable {}

    fallback() external payable {
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);

        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        emit Transfer(fundsWallet, msg.sender, amount);

        fundsWallet.transfer(msg.value);
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(
        address _spender,
        uint256 _value,
        bytes memory _extraData
    ) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        (bool success, ) = _spender.call(
            abi.encodeWithSignature(
                "receiveApproval(address,uint256,address,bytes)",
                msg.sender,
                _value,
                address(this),
                _extraData
            )
        );
        if (!success) {
            
            revert();
        }
        return true;
    }
}
