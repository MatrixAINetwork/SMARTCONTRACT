/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;

contract Money {
    
    address public creator;
    address public buyer;
    
    function Money(address _buyer) public payable {
        creator = msg.sender;
        buyer = _buyer;
    }
    
    function ChangeBuyer(address _buyer) public {
         require(msg.sender==creator);
         buyer = _buyer;
    }
    
    // 0x92d282c1
    function Send() public {
        require(msg.sender==buyer);
        buyer.transfer(this.balance);
    }
    
    function Refund() public {
        require(msg.sender==creator);
        creator.transfer(this.balance);
    }
    
    function() payable {
        
    }
    
    function Delete() {
        require(msg.sender==creator);
        selfdestruct(creator);
    }
    
}