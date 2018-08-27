/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract Calculator {
    function getAmount(uint value) constant returns (uint);
}

contract BonusCalculator {
    function getBonus() constant returns (uint);
}

contract BonusAwareCalculator is Calculator {
    Calculator delegate;

    BonusCalculator bonusCalculator;

    function BonusAwareCalculator(address delegateAddress, address bonusCalculatorAddress) {
        delegate = Calculator(delegateAddress);
        bonusCalculator = BonusCalculator(bonusCalculatorAddress);
    }

    function getAmount(uint value) constant returns (uint) {
        uint withoutBonus = delegate.getAmount(value);
        uint bonusPercent = bonusCalculator.getBonus();
        uint bonus = withoutBonus * bonusPercent / 100;
        return withoutBonus + bonus;
    }
}