/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Zhtong {
    address public owner;
      uint private result;
      function Set(){
          owner = msg.sender;
      }
      function assign(uint x, uint y) returns (uint){
          result = x + y;
      }
}