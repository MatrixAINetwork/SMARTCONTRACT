/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract ConsultingServices {

  address public owner;
  uint256 public yearlyFee = 500 ether;
  mapping(address => Retainer) public retainers;

  event Retained(address);

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  struct Retainer {
    uint256 startDate;
    uint256 paidFee;
  }

  function ConsultingServices() public {
    owner = msg.sender;
  }

  function changeOwner(address _newOwner) public onlyOwner {
    owner = _newOwner;
  }

  function withdraw() public onlyOwner {
    owner.transfer(this.balance);
  }

  function changeFee(uint256 _newFee) public onlyOwner {
    yearlyFee = _newFee;
  }

  function createRetainer() public payable {
    require(msg.value >= yearlyFee);
    require(retainers[msg.sender].startDate < now - 1 years);
    retainers[msg.sender] = Retainer(now, msg.value);
    Retained(msg.sender);
  }

  function() public payable {
    createRetainer();
  }
}