pragma solidity ^0.4.18;
import "./Token.sol";
import "./Halting.sol";

contract Aliases is Token,Halting {
    mapping(string => address) private addressList;
    mapping(address => string) private aliasList;

    event AddAlias(address indexed _address, string _alias, uint256 _fee);

    function addAlias(string alias) stopInEmergency public {
        require(!isEmpty(alias) && (addressList[alias] == 0));
        uint256 cost = getAliasCost(alias) * COIN;
        require(payAliasFee(cost));
        addressList[alias] = msg.sender;
        aliasList[msg.sender] = alias;
        AddAlias(msg.sender, alias, cost);
    }
   
    function transferByAlias(string alias, uint256 value) public {
        require(!isEmpty(alias));
        address recipient = addressList[alias];
        require(recipient != 0);
        require(transfer(recipient, value));
    }

    function invalidAmount(uint256 amount) internal view returns (bool) {
        return ((amount > balanceOf(msg.sender)) || (amount > totalSupply) || (amount <= 0));
    }

    function isEmpty(string str) internal pure returns (bool) {
        return (bytes(str).length == 0);
    }

    function payAliasFee(uint256 fee) internal returns (bool) {
        if (invalidAmount(fee)) {
            return false;
        }
        uint256 amount = (fee/2);
        if (!burnTokens(amount)) {
            return false;
        }
        return payDevReward(amount);
    }

    function balanceOfAlias(string _alias) public view returns (bool success, uint256 balance) {
        address _owner = addressList[_alias];
        return ((_owner != 0), balanceOf(_owner));
    }

    function getAliasCost(string _alias) public pure returns (uint256) {
        uint256 length = bytes(_alias).length;
        if (length == 1) { 
            return 32768; 
        }
        if (length == 2) {
            return 4096;
        }
        if (length == 3) {
            return 512;
        }
        if (length == 4) {
            return 64;
        }
        if (length == 5) {
            return 8;
        }
        return 1;
    }

    function getAddressByAlias(string _alias) public view returns (bool success, address accountAddress) {
        if (isEmpty(_alias)) {
          success = false;
          return;
        }
        address _address = addressList[_alias];
        return ((_address != 0), _address);
    }

    function getAliasByAddress(address _address) public view returns (bool success, string alias) {
        if (_address == 0) {
          success = false;
          return;
        }
        string memory _alias = aliasList[_address];
        return ((!isEmpty(_alias)), _alias);
    }
}
