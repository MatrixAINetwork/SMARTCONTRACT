/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;
contract countGame {

    address public best_gamer;
    uint public count = 0;
    uint public endTime = 1504969200;
    
    function fund() payable {
        require(now <= endTime);
    }
    
    function (){
        require(now<=endTime && count<50);
        best_gamer = msg.sender;
        count++;
    }
    
    function endGame(){
        require(now>endTime || count == 50);
        best_gamer.transfer(this.balance);
    }
    
}