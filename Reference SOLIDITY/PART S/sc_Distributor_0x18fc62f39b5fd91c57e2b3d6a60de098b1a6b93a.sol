/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract ERC20Cutted {
    
  function balanceOf(address who) public constant returns (uint256);
  
  function transfer(address to, uint256 value) public returns (bool);
  
}

contract Distributor {

  address public owner;

  mapping (address => uint) public received;
    
  mapping (address => uint) public balances;

  address[] public stopList;

  mapping (address => uint) public stopAddresses;

  uint public stopAddressesTotal;

  address[] public receivers;
  
  uint public index;
  
  uint public total;

  uint public receivedTotal;

  ERC20Cutted public token = ERC20Cutted(0xE2FB6529EF566a080e6d23dE0bd351311087D567);

  modifier onlyOwner() {
    require(owner == msg.sender);
    _;
  }
  
  function Distributor() public {
      owner = msg.sender;
  }

  function isContract(address _addr) private view returns (bool) {
    uint length;
    assembly {
      length := extcodesize(_addr)
    }
    return (length>0);
  }
  
  function setToken(address newToken) public onlyOwner {
    token = ERC20Cutted(newToken);
  }
  
  function receiversCount() public view returns(uint) {
    return receivers.length;
  }

  function receivedCount() public view returns(uint) {
    return index;
  }

  function addReceivers(address[] _receivers, uint[] _balances) public onlyOwner {
    for(uint i = 0; i < _receivers.length; i++) {
      address receiver = _receivers[i];
      uint balance = _balances[i];
      if(balance > 0) {
        if(isContract(receiver)) {
          if(stopAddresses[receiver] == 0) stopList.push(receiver);
          stopAddresses[receiver] += balance;
          stopAddressesTotal += balance;
        } else {
          if(balances[receiver] == 0) receivers.push(receiver); 
          balances[receiver] += balance;
          total += balance;
        }
      }
    }
  }

  function changeBalance(address to, uint newValue) public onlyOwner {
    require(balances[to] > 0);
    total -= balances[to]; 
    balances[to] = newValue;
    total += newValue;
  }

  function process(uint count) public onlyOwner {
    address receiver;
    uint value;
    for(uint i = 0; index < receivers.length && i < count; i++) {
      receiver = receivers[index];
      value = balances[receiver];
      token.transfer(receiver, value);
      received[receiver] = value;
      receivedTotal += value;
      index++;
    }
  }

  function retrieveCurrentTokensToOwner() public {
    retrieveTokens(owner, address(token));
  }

  function retrieveTokens(address to, address anotherToken) public onlyOwner {
    ERC20Cutted alienToken = ERC20Cutted(anotherToken);
    alienToken.transfer(to, alienToken.balanceOf(this));
  }

  function () public payable {
  }
  
  function retreive() public onlyOwner {
    owner.transfer(this.balance);
  }
    
}