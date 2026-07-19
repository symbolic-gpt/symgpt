/**
 *Submitted for verification at Etherscan.io on 2017-08-11
 */

/*

  Copyright 2017 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.8.20;

contract Token {
    // function totalSupply() public virtual  returns (uint supply) {}


    function balanceOf(address _owner) public virtual returns (uint balance) {}

    
    function transfer(address _to, uint _value) public virtual returns (bool success) {}

   
    function transferFrom(
        address _from,
        address _to,
        uint _value
    ) public virtual returns (bool success) {}

   
    function approve(address _spender, uint _value) public virtual returns (bool success) {}

   
    function allowance(
        address _owner,
        address _spender
    )  public virtual returns (uint remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint _value
    );
}

contract StandardToken is Token {
    function transfer(address _to, uint _value) public override returns (bool) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        if (
            balances[msg.sender] >= _value &&
            balances[_to] + _value >= balances[_to]
        ) {
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
        uint _value
    ) public virtual override returns (bool) {
        if (
            balances[_from] >= _value &&
            allowed[_from][msg.sender] >= _value &&
            balances[_to] + _value >= balances[_to]
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

    function balanceOf(address _owner) public override returns (uint) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) public override returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) public override returns (uint) {
        return allowed[_owner][_spender];
    }

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
}

contract UnlimitedAllowanceToken is StandardToken {
    uint constant MAX_UINT = 2 ** 256 - 1;

    /// @dev ERC20 transferFrom, modified such that an allowance of MAX_UINT represents an unlimited allowance.
    /// @param _from Address to transfer from.
    /// @param _to Address to transfer to.
    /// @param _value Amount to transfer.
    /// @return Success of transfer.
    function transferFrom(
        address _from,
        address _to,
        uint _value
    ) public override returns (bool) {
        uint allowance = allowed[_from][msg.sender];
        if (
            balances[_from] >= _value &&
            allowance >= _value &&
            balances[_to] + _value >= balances[_to]
        ) {
            balances[_to] += _value;
            balances[_from] -= _value;
            if (allowance < MAX_UINT) {
                allowed[_from][msg.sender] -= _value;
            }
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }
}

contract ZRXToken is UnlimitedAllowanceToken {
    uint8 public constant decimals = 18;
     uint  public   totalSupply = 10 ** 27; // 1 billion tokens, 18 decimal places
    string public constant name = "0x Protocol Token";
    string public constant symbol = "ZRX";

    constructor() {
        balances[msg.sender] = totalSupply;
    }
}
