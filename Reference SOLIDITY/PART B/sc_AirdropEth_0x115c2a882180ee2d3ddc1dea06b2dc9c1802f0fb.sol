/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract ERC20 {
  function transfer(address _recipient, uint256 _value) public returns (bool success);
}

contract AirdropEth {
  function drop(address[] recipients, uint256[] values) payable public {
    for (uint256 i = 0; i < recipients.length; i++) {
      recipients[i].transfer(values[i]);
    }
  }
}