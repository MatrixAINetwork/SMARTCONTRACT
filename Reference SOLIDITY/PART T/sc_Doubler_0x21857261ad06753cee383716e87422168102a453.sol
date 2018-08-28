/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract Doubler{
    uint public price = 1 wei;
    address public winner = msg.sender;
    
    function() public payable {
        require(msg.value >= price); 
        if (msg.value > price){
            msg.sender.transfer(msg.value - price);
        }
        if (!winner.send(price)){
            msg.sender.transfer(price);
        }
        winner = msg.sender;
        price = price * 2;
    }
    
    
}