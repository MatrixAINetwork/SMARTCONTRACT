/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

contract Marvin {
    address owner;
    string flag = "9KByjrJNbaRuux4tPd8868";
    bytes32 hashedflag = 0x44ad5cdba0469b29dd12b95d69bcf3b82bb7e2519a4e24b8ce0473028273d5c6;
    
    event statusCode(int32 code);

    function Marvin() payable {
        owner = msg.sender;
    }

    function freeBeerOnMe(string sha512flag) {
        if (hashedflag == keccak256(sha512flag)){
            msg.sender.transfer(this.balance);
            statusCode(42);
        }
        else{
            statusCode(-1);
        }
    }

}