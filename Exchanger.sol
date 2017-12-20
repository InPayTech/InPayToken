pragma solidity ^0.4.18;
import "./Torrents.sol";

contract Exchanger is Torrents {
    event ExchangeToWaves(address indexed _from, string _to, uint256 _amount);
    event ExchangeTransfer(string _from, address indexed _to, uint256 _amount);

    address constant EXCHANGER_ADDRESS = 0x06fb2b1b112C7FC24114c59eB9514e270b9F9638;

    function exchangeToWaves(string wavesAddress, uint256 amount) stopInEmergency public {
        require(transfer(EXCHANGER_ADDRESS, amount));
        ExchangeToWaves(msg.sender, wavesAddress, amount);
    }

    function exchangeTransfer(string from, address to, uint256 amount) stopInEmergency public {
        require(msg.sender == EXCHANGER_ADDRESS);
        require(transfer(to, amount));
        ExchangeTransfer(from, to, amount);
    }
}
