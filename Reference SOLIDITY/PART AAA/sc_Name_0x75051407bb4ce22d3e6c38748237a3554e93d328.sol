/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.12;

// Reward Channel contract

contract Name{
    address public owner = msg.sender;
    string public name;

    modifier onlyBy(address _account) { require(msg.sender == _account); _; }


    function Name(string myName) public {
      name = myName;
    }

    function() payable public {}

    function withdraw() onlyBy(owner) public {
      owner.transfer(this.balance);
    }

    function destroy() onlyBy(owner) public{
      selfdestruct(this);
    }
}