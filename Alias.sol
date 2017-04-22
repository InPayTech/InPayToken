pragma solidity ^0.4.8;
import "Token.sol";

contract Alias is Token {
  mapping(string => address) addressesList;
  mapping(address => string) aliasesList;
  address public devAddress;

  function Alias() {
    devAddress = msg.sender;
  }

  event CreateAlias(address _address, string _alias, uint256 _fee);

  function createAlias(string alias) {
    if(isEmpty(alias) || (addressesList[alias] != 0)) throw;
    uint256 cost = getAliasCost(alias) * COIN;
    if(!payAliasFee(cost)) throw;
    addressesList[alias] = msg.sender;
    aliasesList[msg.sender] = alias;
    CreateAlias(msg.sender, alias, cost);
  }

  function invalidAmount(uint256 amount) internal returns (bool) {
    return ((amount > balanceOf(msg.sender)) || (amount > totalSupply) || (amount <= 0));
  }

  function payAliasFee(uint256 _fee) private returns (bool) {
    if(invalidAmount(_fee)) return false;
    uint256 amount = (_fee/2);
    if(!burnTokens(amount)) return false;
    return payDevReward(amount);
  }

  function transferByAlias(string alias, uint256 value) {
    if(isEmpty(alias)) throw;
    address recipient = addressesList[alias];
    if(recipient == 0) throw;
    if(!transfer(recipient, value)) throw;
  }

  function balanceOfAlias(string _alias) constant returns (bool success, uint256 balance) {
    address _owner = addressesList[_alias];
    return ((_owner != 0), balanceOf(_owner));
  }

  function swapBalanceOfAlias(string _alias) constant returns (bool success, uint256 balance) {
    address _owner = addressesList[_alias];
    return ((_owner != 0), swapBalanceOf(_owner));
  }

  function getAliasCost(string alias) constant returns (uint256) {
    uint256 length = bytes(alias).length;
    if(length == 1) return 32768;
    if(length == 2) return 4096;
    if(length == 3) return 512;
    if(length == 4) return 64;
    if(length == 5) return 8;
    return 1;
  }

  function getAddressByAlias(string _alias) constant returns (bool success, address accountAddress) {
    if(isEmpty(_alias)) {
      success = false;
      return;
    }
    address _address = addressesList[_alias];
    return ((_address != 0), _address);
  }

  function getAliasByAddress(address _address) constant returns (bool success, string alias) {
    if(_address == 0) {
      success = false;
      return;
    }
    string _alias = aliasesList[_address];
    return ((!isEmpty(_alias)), _alias);
  }

  function isEmpty(string str) internal returns (bool) {
    return (bytes(str).length == 0);
  }
}
