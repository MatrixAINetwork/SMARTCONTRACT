/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;
contract OWN_ME {
    address public owner = msg.sender;
    uint256 public price = 1 finney;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function change_price(uint256 newprice) onlyOwner public {
        price = newprice;
    }
   
    function BUY_ME() public payable {
        require(msg.value >= price);
        address tmp = owner;
        owner = msg.sender;
        tmp.transfer(msg.value);
    }
}