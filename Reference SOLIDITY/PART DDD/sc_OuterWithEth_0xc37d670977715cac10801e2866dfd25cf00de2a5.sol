/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract OuterWithEth {
    Inner1WithEth public myInner1 = new Inner1WithEth();
    
    function callSomeFunctionViaOuter() public payable {
        myInner1.callSomeFunctionViaInner1.value(msg.value)();
    }
}

contract Inner1WithEth {
    Inner2WithEth public myInner2 = new Inner2WithEth();
    
    function callSomeFunctionViaInner1() public payable{
        myInner2.doSomething.value(msg.value)();
    }
}

contract Inner2WithEth {
    uint256 someValue;
    event SetValue(uint256 val);
    
    function doSomething() public payable {
        someValue = block.timestamp;
        emit SetValue(someValue);
        msg.sender.transfer(msg.value);
    }
}