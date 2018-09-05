/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract Incrementer {

    event LogWinner(address winner, uint amount);
    
    uint c = 0;

    function ticket() payable {
        
        uint ethrebuts = msg.value;
        if (ethrebuts != 10) {
            throw;
        }
        c++;
        
        if (c==3) {
            LogWinner(msg.sender,this.balance);
            msg.sender.transfer(this.balance);
            c=0;
        }
    }
}