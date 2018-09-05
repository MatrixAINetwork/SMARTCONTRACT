/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract TopListICOToken {
    uint256 public totalSupply;
    mapping (address => uint256) public balances;
    address public owner;    
	
	event Transfer(address indexed from, address indexed to, uint256 value);

	string public name = "Gems Protocol";              
    uint8 public decimals = 18;        
    string public symbol = "GEM";
	
    function TopListICOToken() public {		
        totalSupply = 1000000000 * 10**uint256(decimals);
        balances[msg.sender] = totalSupply;
		owner = msg.sender;
		Transfer(0x0, owner, totalSupply);
    }	
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
        
    function changeToken(string cName, string cSymbol) onlyOwner public {
        name = cName;
        symbol = cSymbol;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
		balances[msg.sender] -= _value;
        balances[_to] += _value;
		Transfer(msg.sender, _to, _value);
        return true;
    }
	
	function withdrawEther(uint amount) onlyOwner public {
		owner.transfer(amount);
	}
	
	function buy() payable public {
	    balances[msg.sender] += msg.value * 1000 * 10**uint256(decimals);
	    Transfer(owner, msg.sender, msg.value * 1000 * 10**uint256(decimals));
    }	
}