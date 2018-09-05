/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) revert();
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract Registration is owned { 
    
    mapping (address => bool) public isRegistered;   
      
    function () public payable {
        //address sender = msg.sender; 
        if (msg.value == 10000000000000000) {
            isRegistered[msg.sender] = true; 
        } else { 
            revert();
        }
        
    }
    
    function collectFees() onlyOwner public { 
        require(this.balance > 0);
        
        msg.sender.transfer(this.balance);
    }
    
}