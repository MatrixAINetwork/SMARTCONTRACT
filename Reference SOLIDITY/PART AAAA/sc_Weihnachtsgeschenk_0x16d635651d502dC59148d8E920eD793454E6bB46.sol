/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.14;

contract Weihnachtsgeschenk {
	address public admin;
	string public from;
	string public to;
	string public message;
	string public gift;

	function Weihnachtsgeschenk(address admin_, string from_, string to_, string message_, string gift_) {
		admin = admin_;
		from = from_;
		to = to_;
		message = message_;
		gift = gift_;
	}

	function giftIsFrom() constant returns(string) {
		return from;
	}

	function giftIsTo() constant returns(string) {
		return to;
	}

	function giftMessage() constant returns(string) {
		return message;
	}

	function gift() constant returns(string) {
		return gift;
	}
}