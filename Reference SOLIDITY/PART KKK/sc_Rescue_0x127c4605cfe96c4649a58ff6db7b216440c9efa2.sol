/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

/**
 * @title Teambrella Rescue map
 */
 
interface IRescue {
    function canRescue(address _addr) external returns (bool);
}

contract Rescue is IRescue {
    
    address public owner;
    mapping (address => bool) canRescueMap;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _; 
    }
    
    constructor() public payable {
		owner = msg.sender;
    }
    
    function setRescue(address _addr, bool _canRescue) onlyOwner external {
        canRescueMap[_addr] = _canRescue;
    }
    
    function canRescue(address _addr) public constant returns (bool) {
        return canRescueMap[_addr];
    }
}