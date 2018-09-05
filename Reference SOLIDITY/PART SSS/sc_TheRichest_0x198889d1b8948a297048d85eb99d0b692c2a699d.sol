/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract TheRichest {
    address owner;
    
    address public theAddress;
    uint256 public theBid;

    function TheRichest() public {
        owner = msg.sender;
        theAddress = msg.sender;
        theBid = 1;
    }
    
    //pay to become theAddress with richest label
    function () public payable {
        if (msg.value > theBid) {
            theAddress = msg.sender;
            theBid = msg.value;
        }
    }
    
    // all money will go to dogcharity projects
    function gameOver() public {
        if (msg.sender == owner) {
          selfdestruct(owner);
        }
    }
    
}