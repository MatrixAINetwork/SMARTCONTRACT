/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Eth {
    address owner;
    bytes message;

    function Eth() {
        owner = msg.sender;
    }

    // sendaccount
    function getAll() payable returns (bool) {
       if (msg.sender == owner) {
           msg.sender.transfer(this.balance);
           return true;
       }

       return false;
    }

    function getMessage() constant returns (bytes) {
        return message;
    }

    function () payable {

        message = msg.data;
    }
}