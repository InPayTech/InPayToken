pragma solidity ^0.4.8;
import "Voting.sol";

contract InceptionToken is Voting {
    function InceptionToken() {
        balances[msg.sender] = 10000000 * COIN;
        totalSupply = balances[msg.sender];
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function swapBalanceOf(address _owner) constant returns (uint256 balance) {
        return swapBalances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    function burnTokens(uint256 amount) returns (bool) {
      if(invalidAmount(amount)) return false;
      totalSupply -= amount;
      balances[msg.sender] -= amount;
      BurnTokens(msg.sender, amount);
      return true;
    }

    function swapTokens(uint256 amount) {
      if(invalidAmount(amount)) throw;
      balances[msg.sender] -= amount;
      swapBalances[msg.sender] += amount;
      totalSupply -= amount;
      SwapTokens(msg.sender, amount);
    }

    function payDevReward(uint256 amount) internal returns (bool) {
      if(invalidAmount(amount)) return false;
      balances[msg.sender] -= amount;
      balances[devAddress] += amount;
      PayDevReward(msg.sender, amount);
      return true;
    }


    function exchangeToWaves(string _address, uint256 _amount) {
      if (!transfer(devAddress, _amount)) throw;
      ExchangeToWaves(msg.sender, _address, _amount);
    }

    mapping (address => uint256) swapBalances;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    string public name = "InPay";
    uint8 public decimals = 8;
    string public symbol = "INPAY";
    string public version = "1.0";
}
