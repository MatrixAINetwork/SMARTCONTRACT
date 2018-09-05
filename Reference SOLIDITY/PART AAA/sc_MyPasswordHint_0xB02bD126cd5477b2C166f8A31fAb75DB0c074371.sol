/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.8;

contract MyPasswordHint {
    string public hint;
    address public owner;
    /* Constructor */
    function MyPasswordHint() {
        hint = "";
        owner = msg.sender;
    }
    function setHint(string nHint) {
        if (msg.sender == owner) {
            hint = nHint;
        }
    }
    function kill() {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
}