/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract Ownable {
    address public owner;
    
    function Ownable() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract CompanyTest is Ownable {
    address public owner;

    uint public largestStake;

    function purchaseStake() public payable {
        // if you own a largest stake in a company, you own a company
        if (msg.value > largestStake) {
            owner = msg.sender;
            largestStake = msg.value;
        }
    }

    function withdraw() public onlyOwner {
        // only owner can withdraw funds
        msg.sender.transfer(this.balance);
    }
}