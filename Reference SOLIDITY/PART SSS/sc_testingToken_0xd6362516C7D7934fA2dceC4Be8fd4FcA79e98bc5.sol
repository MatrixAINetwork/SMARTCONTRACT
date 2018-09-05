/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.8;

contract testingToken {
	mapping (address => uint256) public balanceOf;
	mapping (address => uint256) public weiWantedOf;
	mapping (address => uint256) public tokensOfferedOf;
	mapping (address => bool) public tradeActive;
	mapping (address => address) public tradeIntentOf;
	address public owner;
	function testingToken() {
		owner = msg.sender;
		balanceOf[msg.sender] = 100000;
	}
	function send(address _to, uint256 _value) { //give tokens to someone
		if (balanceOf[msg.sender]<_value) throw;
		if (balanceOf[_to]+_value<balanceOf[_to]) throw;
		if (_value<0) throw;
		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;
	}
	function offerTrade(uint256 _weiWanted, uint256 _tokensOffered) { //offer the amt of ether you want and the amt of tokens youd give
	    weiWantedOf[msg.sender] = _weiWanted;
	    tokensOfferedOf[msg.sender] = _tokensOffered;
	    tradeActive[msg.sender] = true;
	}
	function signalTradeIntent(address _from) { //choose a trade you want to agree to; you then have to actually put in coins
	    tradeIntentOf[msg.sender] = _from;
	}
	function () payable {
	    if (!tradeActive[tradeIntentOf[msg.sender]]) throw;
	    if (weiWantedOf[tradeIntentOf[msg.sender]]!=msg.value) throw;
	    if (balanceOf[tradeIntentOf[msg.sender]]<tokensOfferedOf[tradeIntentOf[msg.sender]]) throw;
	    if (!tradeIntentOf[msg.sender].send((msg.value/100)*90)) throw;
	    balanceOf[tradeIntentOf[msg.sender]] -= tokensOfferedOf[tradeIntentOf[msg.sender]];
	    balanceOf[msg.sender] += (tokensOfferedOf[tradeIntentOf[msg.sender]]/100)*90;
	}
}