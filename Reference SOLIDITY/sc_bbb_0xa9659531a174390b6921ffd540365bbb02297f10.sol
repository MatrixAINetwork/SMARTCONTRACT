/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract bbb{
    /* Define variable owner of the type address*/
    address owner;
	event EmailSent(address Sender, uint256 PricePaid, string EmailAddress, string Message);
	
    function bbb() { 
        owner = msg.sender; 
    }
    function Kill() { 
		if(msg.sender==owner){
			suicide(owner); 
		}		
    }
	function Withdraw(uint256 AmountToWithdraw){
		owner.send(AmountToWithdraw);
	}
    function SendEmail(string EmailAddress, string Message) { 
        EmailSent(msg.sender, msg.value, EmailAddress, Message);
    }    
}