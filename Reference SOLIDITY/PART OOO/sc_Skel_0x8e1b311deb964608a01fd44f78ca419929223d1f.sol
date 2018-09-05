/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Skel {
  string public name;
  address public owner;
  function Skel() public {
      name = "test";
      owner = msg.sender;
  }
  modifier onlyowner {
      require(msg.sender == owner);
      _;
  }
function emptyTo(address addr) onlyowner public {
    addr.transfer(address(this).balance);
}
}