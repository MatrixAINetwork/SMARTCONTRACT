/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract GameAbstraction {
   function sendBet(address sender, uint choice) payable public;
}

contract TeamChoice {

    address gameAddress;
    uint teamChoice;

    function TeamChoice(address _gameAddress, uint _teamChoice) public {
        gameAddress = _gameAddress;
        teamChoice = _teamChoice;
    }

    function fund() payable public {}

    function() payable public {
        GameAbstraction game = GameAbstraction(gameAddress);
        game.sendBet.value(msg.value)(msg.sender, teamChoice);
    }

}

contract TeamTailsChoice is TeamChoice {

    function TeamTailsChoice(address _gameAddress) TeamChoice(_gameAddress, 2) public {}

}