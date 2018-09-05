/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.6;

/* 
    There is a limit of how much gas can be spent in a single block. This limit is flexible, but it is quite hard to increase it. 
    This means that every single function in your contract should stay below a certain amount of gas in all (reasonable) situations.
    This applies to anything that uses loops.

    https://blog.ethereum.org/2016/06/10/smart-contract-security/

    Looper is a public utility which can be used to put a limit on loops, so that they stay within the gas limit
*/

contract Looper {

function maximumNumberOfLoops(uint _costSansLoops, uint _loopCost) public constant returns (uint loopLimit) {
    uint gasLimit = getGasLimit();
    uint gasForLoops = gasLimit - _costSansLoops;
    return loopLimit = getLoopLimit(gasForLoops, _loopCost);
}

function canDoLoop(uint _costSansLoops, uint _loopCost, uint _numberOfLoops) public constant returns (bool) {
    uint loopLimit = maximumNumberOfLoops(_costSansLoops, _loopCost);
    if(_numberOfLoops < loopLimit) return true;
    return false;
}

function getGasLimit() internal constant returns (uint) {
    uint gasLimit;

    assembly {
        gasLimit := gaslimit
    }
    return gasLimit;
}

function getLoopLimit(uint _gasForLoops, uint _loopCost) internal constant returns (uint) {
    uint loopLimit = _gasForLoops / _loopCost;
    return loopLimit;
}

}