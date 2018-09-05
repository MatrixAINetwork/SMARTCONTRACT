/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract MyMap {
    address public owner;
    mapping(bytes32=>bytes15) map;

    function MyMap() public {
        owner = msg.sender;
    }
    
    function setValue(bytes32 a, bytes15 b) public {
        if(owner == msg.sender) {
            map[a] = b;
        }
    }
}