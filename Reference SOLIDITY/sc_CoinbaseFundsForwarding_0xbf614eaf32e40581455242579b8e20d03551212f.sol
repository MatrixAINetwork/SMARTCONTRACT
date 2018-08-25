/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract CoinbaseFundsForwarding
{
	address public coinbaseWallet = 0x919C812f1a0f2eA5a2c8724C910eC0B61F020Ff0;

	function () payable {
		coinbaseWallet.transfer(msg.value);
	}
}