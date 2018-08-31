/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;
pragma solidity ^0.4.18;

contract EtherealFoundationOwned {
	address private Owner;
    
	function IsOwner(address addr) view public returns(bool)
	{
	    return Owner == addr;
	}
	
	function TransferOwner(address newOwner) public onlyOwner
	{
	    Owner = newOwner;
	}
	
	function EtherealFoundationOwned() public
	{
	    Owner = msg.sender;
	}
	
	function Terminate() public onlyOwner
	{
	    selfdestruct(Owner);
	}
	
	modifier onlyOwner(){
        require(msg.sender == Owner);
        _;
    }
}

contract EtherealCharity  is EtherealFoundationOwned{
    string public constant CONTRACT_NAME = "EtherealCharity";
    string public constant CONTRACT_VERSION = "A";
    string public constant CAUSE = "EtherealCharity Creation";
    string public constant URL = "none";
    string public constant QUOTE = "'A man who procrastinates in his choosing will inevitably have his choice made for him by circumstance.' -Hunter S. Thompson";
    
    
    event RecievedDonation(address indexed from, uint256 value, string note);
    function Donate(string note)  public payable{
        RecievedDonation(msg.sender, msg.value, note);
    }
    
    //this is the fallback
    event RecievedAnonDonation(address indexed from, uint256 value);
	function () payable public {
		RecievedAnonDonation(msg.sender, msg.value);		
	}
	
	event TransferedEth(address indexed to, uint256 value);
	function TransferEth(address to, uint256 value) public onlyOwner{
	    require(this.balance >= value);
	    
        if(value >0)
		{
			to.transfer(value);
			TransferedEth(to, value);
		}   
	}
}