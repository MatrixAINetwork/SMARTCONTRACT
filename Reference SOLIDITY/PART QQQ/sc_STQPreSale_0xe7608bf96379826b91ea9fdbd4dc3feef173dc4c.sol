/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.15;

interface STQToken {
    function mint(address _to, uint256 _amount) external;
}

/**
 * @title Helps contracts guard agains rentrancy attacks.
 * @author Remco Bloemen <