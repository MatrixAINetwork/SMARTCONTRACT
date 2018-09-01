/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.24;
 

interface IArbitrage {
    function executeArbitrage(
      address token,
      uint256 amount,
      address dest,
      bytes data
    )
      external
      returns (bool);
}

pragma solidity 0.4.24;


contract IBank {
    function totalSupplyOf(address token) public view returns (uint256 balance);
    function borrowFor(address token, address borrower, uint256 amount) public;
    function repay(address token, uint256 amount) external payable;
}


/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <