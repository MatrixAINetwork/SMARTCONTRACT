/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

contract BitcoinBravado {
    
    address public owner;
    
    mapping(address => bool) paidUsers;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function BitcoinBravado() public {
        owner = msg.sender;
    }
    
    function payEntryFee() public payable  {
        if (msg.value >= 0.1 ether) {
            paidUsers[msg.sender] = true;
        }
    }
    
    function getUser (address _user) public view returns (bool _isUser) {
        return paidUsers[_user];
    }
    
    function withdrawAll() onlyOwner() public {
        owner.transfer(address(this).balance);
    }
}