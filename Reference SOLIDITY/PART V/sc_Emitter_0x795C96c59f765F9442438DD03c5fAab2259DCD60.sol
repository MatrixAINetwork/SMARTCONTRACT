/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity >=0.4.13;

contract Emitter {
    event Emit(uint x);
    function emit(uint x) {
        Emit(x);
    }
}

contract Caller {
    address emitter;
    function setEmitter(address e) {
        if (emitter == 0x0) {
            emitter = e;
        }
    }
    function callEmitter(uint x) {
        Emitter(emitter).emit(x);
    }
}