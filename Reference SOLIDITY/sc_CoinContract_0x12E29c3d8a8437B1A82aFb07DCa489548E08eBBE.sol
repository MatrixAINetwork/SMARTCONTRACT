/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract CoinContract {
  bool private workingState = false;
  address public owner;
  address public proxy;
  uint256 public x = 100; //coin multiplier
  mapping (address => uint256) private etherClients;
  event FundsGot(address indexed _sender, uint256 _value);
  event ContractEnabled();
  event ContractDisabled();

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  modifier proxyAndOwner {
    require((msg.sender == proxy)||(msg.sender == owner));
    _;
  }
  modifier workingFlag {
    require(workingState == true);
    _;
  }
  //@title Constructor
  function CoinContract() {
    owner = msg.sender;
    enableContract();
  }
  //@title Destructor
  function kill() public onlyOwner {
    require(workingState == false);
    selfdestruct(owner);
  }
  //@title Contract enabler
  function enableContract() onlyOwner {
    workingState = true;
    ContractEnabled();
  }
  //@title Contract disabler
  function disableContract() onlyOwner {
    workingState = false;
    ContractDisabled();
  }
  //@title Contract proxy setter
  function setProxy(address _proxy) onlyOwner {
    proxy = _proxy;
  }
  //@title Contract payment function
  function pay(address _client, uint256 _amount) workingFlag returns (bool ret) {
    require(x > 0);
    etherClients[_client] += _amount;
    uint256 value = x * _amount;
    FundsGot(_client, etherClients[_client]);
    ret = proxy.call(bytes4(sha3("generateTokens(address,uint256)")), _client, value);
  }
  //@title Sender funds getter
  function getSenderFunds(address _sender) workingFlag returns (uint256 amount) {
    return etherClients[_sender];
  }
  //@title Universal call
  function universalCall(string data) proxyAndOwner workingFlag returns (bool result) {
    data;
    bool ret = false;
    return ret;
  }
}