/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Emailer {
    /* Define variable owner of the type address*/
    address owner;
	event Sent(address from, uint256 price, string to, string body);
	
    function Emailer() { 
        owner = msg.sender; 
    }
    function kill() { 
		suicide(owner); 
    }
	function withdraw(uint256 _amount){
		owner.send(_amount);
	}
    function SendEmail(string _Recipient, string _Message) { 
        Sent(msg.sender, msg.value, _Recipient, _Message);
    }    
}