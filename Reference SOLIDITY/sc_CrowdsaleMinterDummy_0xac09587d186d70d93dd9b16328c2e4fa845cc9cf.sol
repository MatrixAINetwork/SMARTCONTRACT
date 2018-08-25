/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract CrowdsaleMinterDummy {
  
    function withdrawFundsAndStartToken() external
    {
        FundsWithdrawnAndTokenStareted(msg.sender);
    }
    event FundsWithdrawnAndTokenStareted(address msgSender);

    function mintAllBonuses() external
    {
        BonusesAllMinted(msg.sender);
    }
    event BonusesAllMinted(address msgSender);

    function abort() external
    {
        Aborted(msg.sender);
    }
    event Aborted(address msgSender);
}