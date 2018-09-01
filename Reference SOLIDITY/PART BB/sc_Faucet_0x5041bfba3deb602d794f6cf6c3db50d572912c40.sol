/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.10;

contract Token{
	function transfer(address to, uint value) returns (bool ok);
}

contract Faucet {

	address public tokenAddress;
	Token token;

	function Faucet(address _tokenAddress) {
		tokenAddress = _tokenAddress;
		token = Token(tokenAddress);
	}
  
	function getToken() {
		if(!token.transfer(msg.sender, 1)) throw;
	}

	function () {
		getToken();
	}

}