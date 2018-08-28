/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;
contract Distribute {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    //批量转账  
    function transferETHS(address[] _tos) payable public returns(bool) {
        require(_tos.length > 0);
        uint val = this.balance / _tos.length;
        for (uint32 i = 0; i < _tos.length; i++) {
            _tos[i].transfer(val);
        }
        return true;
    }

    function () payable public {
        owner.transfer(this.balance);
    }
}