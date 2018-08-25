/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract crowdsale  {

mapping(address => bool) public whiteList;
event logWL(address wallet, uint256 currenttime);

    function addToWhiteList(address _wallet) public  {
        whiteList[_wallet] = true;
        logWL (_wallet, now);
    }
}