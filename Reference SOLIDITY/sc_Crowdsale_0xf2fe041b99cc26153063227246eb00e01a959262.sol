/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

library SafeMath { //standart library for uint
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0 || b == 0){
        return 0;
    }
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

//standart contract to identify owner
contract Ownable {

  address public owner;

  address public newOwner;

  address public techSupport;

  address public newTechSupport;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyTechSupport() {
    require(msg.sender == techSupport);
    _;
  }

  function Ownable() public {
    owner = msg.sender;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    newOwner = _newOwner;
  }

  function acceptOwnership() public {
    if (msg.sender == newOwner) {
      owner = newOwner;
    }
  }

  function transferTechSupport (address _newSupport) public{
    require (msg.sender == owner || msg.sender == techSupport);
    newTechSupport = _newSupport;
  }

  function acceptSupport() public{
    if(msg.sender == newTechSupport){
      techSupport = newTechSupport;
    }
  }

}

//Abstract Token contract
contract CQTToken{
  function setCrowdsaleContract (address) public{}
  function sendCrowdsaleTokens(address, uint256)  public {}
  function burnTokens(address) {}
  function getCrowdsaleTokens() public view returns(uint) {}
  function burnSomeTokens(uint _value) public{}
}

//Crowdsale contract
contract Crowdsale is Ownable{

  using SafeMath for uint;
  function pow(uint256 a, uint256 b) public pure returns (uint256){ //power function
   return (a**b);
  }

  uint decimals = 8;
  // Token contract address
  CQTToken public token;

  // Constructor
  function Crowdsale(address _tokenAddress, address _owner) public{
    token = CQTToken(_tokenAddress);
    owner = _owner;
    techSupport = msg.sender;
    //test parameter
    // techSupport = 0x8C0F5211A006bB28D4c694dC76632901664230f9;
    token.setCrowdsaleContract(this);
  }

  // Buy constants
  uint minDeposit = 10000000000000000;

  //Canadian time - (-5 hours to UTC)
  // preIco constants
  uint public preIcoStart = 1519189260; //21.02.2018 1519189260
  uint public preIcoFinish = 1521694740; //21.03.2018

  uint preIcoMaxCap = 60000000*pow(10,decimals);
  uint tokenPrice = 50000000000000;


  // Ico constants
  uint public icoStart = 1521867660; //24.03.2018
  uint public icoFinish = 1524632340; //24.04.2018

  uint icoMinCap = 100000000*pow(10,decimals);
  uint icoMaxCap = 550000000*pow(10,decimals);

  //check is now preICO
  function isPreIco(uint _time) public view returns (bool){
    if((preIcoStart <= _time) && (_time <= preIcoFinish)){
      return true;
    }
    return false;
  }

  //check is now ICO
  function isIco(uint _time) public view returns (bool){
    if((icoStart <= _time) && (_time <= icoFinish)){
      return true;
    }
    return false;
  }

  //Crowdsale variables
  uint public preIcoTokensSold = 0;
  uint public icoTokensSold = 0;
  uint public tokensSold = 0;
  uint public ethCollected = 0;

  //investors ether balance contains here
  mapping (address => uint) investorBalances;

  //fallback function (when investor send ether to contract)
  function() public payable{
    if (now > icoFinish){
      finishCrowdsale();
    }
    require(isIco(now) || isPreIco(now));
    require(msg.value >= minDeposit);
    require(buy(msg.sender,msg.value,now)); //redirect to func buy
  }

  function sendTokensManually(address _address, uint _value) public onlyTechSupport{
    token.sendCrowdsaleTokens(_address, _value);
    if(isPreIco(now)){
      preIcoTokensSold = preIcoTokensSold.add(_value);
    }
    if(isIco(now)){
      icoTokensSold = icoTokensSold.add(_value);
    }
    tokensSold = tokensSold.add(_value);
  }
  
  //function buy Tokens
  function buy(address _address, uint _value, uint _time/*, bool _manual*/) internal returns (bool){
    require(token.getCrowdsaleTokens() > 0);

    uint tokensForSend = 0;

    if (isPreIco(_time)){
      require (preIcoMaxCap > preIcoTokensSold);
      tokensForSend = etherToTokens(_value);
      preIcoTokensSold = preIcoTokensSold.add(tokensForSend);
      owner.transfer(this.balance);
    }

    if (isIco(_time)){
      // Token contract will automatically throws if Crowdsale balance < tokensForSend
      // require (icoMaxCap > icoTokensSold);
      tokensForSend = etherToTokens(_value);

      //If user cant buy all tokens we need to give ether back for him 
      if(tokensForSend.add(tokensSold) > token.getCrowdsaleTokens()){
        tokensForSend = token.getCrowdsaleTokens();
        uint ethToTake = tokensForSend.mul(tokenPrice).div(pow(10,decimals));

        uint etherSendBack = _value.sub(ethToTake);
        _address.transfer(etherSendBack);
        icoTokensSold = icoTokensSold.add(tokensForSend);

        tokensSold = tokensSold.add(tokensForSend);
        token.sendCrowdsaleTokens(_address, tokensForSend);

        ethCollected = ethCollected.add(ethToTake);
        investorBalances[_address] = investorBalances[_address].add(ethToTake);
        owner.transfer(this.balance);

        return true;
      }

      investorBalances[_address] = investorBalances[_address].add(_value);
      icoTokensSold = icoTokensSold.add(tokensForSend);
    }

    tokensSold = tokensSold.add(tokensForSend);
    token.sendCrowdsaleTokens(_address, tokensForSend);

    if (isIcoTrue()){
      owner.transfer(this.balance);
    }

    ethCollected = ethCollected.add(_value);
    return true;
  }

  //convert ether to tokens (without decimals)
  function etherToTokens(uint _value) public view returns(uint) {
    uint res = _value.mul(pow(10,decimals)).div(tokenPrice);

    if (now < preIcoStart || isPreIco(now)){
      return res.add(res*40/100);
    }

    if (now > preIcoFinish && now < icoStart){
      return res.add(res*30/100);
    }

    if (isIco(now)){
      if(icoStart + 7 days <= now){
        return res.add(res*30/100);
      }
      if(icoStart + 14 days <= now){
        return res.add(res*20/100);
      }
      if(icoStart + 21 days <= now){
        return res.add(res*10/100);
      }
    return res;
    }

    return 0;
  }

  //function check is ICO complete (minCap exceeded)
  function isIcoTrue() public view returns (bool){
    if (tokensSold >= icoMinCap){
      return true;
    }
  return false;
  }

  //Contract can change ICO finish date up to 7 days, but only one time
  bool public isTryedFinishCrowdsale = false;
  bool public isBurnActive = false;

  function finishCrowdsale () public {
    require (now > icoFinish);

    if(!isTryedFinishCrowdsale){
      if(tokensSold >= 610000000*pow(10,decimals)){
        isBurnActive = true;  
      }else{
        icoFinish = icoFinish + 7 days;
      }
      isTryedFinishCrowdsale = true;
    }else{
      isBurnActive = true;
    }
  }
  
  //Owner can burn some tokens in Token Contract
  function burnSomeTokens (uint _value) public onlyOwner{
    require(isBurnActive);
    token.burnSomeTokens(_value);
  }

  //if ICO failed and now = ICO finished date +3 days then investor can withdrow his ether
  function refund() public{
    require (!isIcoTrue());
    require (icoFinish + 3 days <= now);

    token.burnTokens(msg.sender);
    msg.sender.transfer(investorBalances[msg.sender]);
    investorBalances[msg.sender] = 0;
  }
}