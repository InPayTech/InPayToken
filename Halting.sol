pragma solidity ^0.4.18;
import "./Ownable.sol";

contract Halting is Ownable {
    bool private stopped = false;
  
    function toggleContractActive() onlyOwner public {
        stopped = !stopped;
    }

    modifier stopInEmergency { if (!stopped) _; }
    modifier onlyInEmergency { if (stopped) _; }
}

