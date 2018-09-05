/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;
contract S9token {
	
	address owner;
	string public name="S9token";
	uint8 public constant decimals = 0;
	string public constant version = "1";
	uint256 _totalSupply;
	mapping (address => uint256) public balances;

	function S9token() {
		owner=msg.sender;
		_totalSupply=200;
		balances[msg.sender]=200;
	}

	event Transfer( address indexed from, address indexed to, uint value);

	function totalSupply() public constant returns (uint supply){
		return _totalSupply;
	}

    function balanceOf(address _owner) constant returns(uint256 balanceof){
		return balances[_owner];
	}

    function transfer(address _to, uint256 _amount) returns (bool success){
    	require(msg.sender==owner);
		if (balances[msg.sender] >= _amount 
			&& _amount > 0 
			&& balances[_to] + _amount > balances[_to]){
			balances[msg.sender] -= _amount;
			balances[_to] += _amount;
			return true;
			Transfer(msg.sender,_to,_amount);
		}
		else{
			return false;
		}
	}
    

}