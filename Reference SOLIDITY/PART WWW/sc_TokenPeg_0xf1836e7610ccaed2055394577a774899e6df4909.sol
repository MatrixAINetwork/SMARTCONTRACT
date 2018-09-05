/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract Token {
  function transferFrom(address from, address to, uint256 value) public returns (bool success);
  function transfer(address _to, uint256 _value) public returns (bool success);
}

contract TokenPeg {
  address public minimalToken;
  address public signalToken;
  bool public pegIsSetup;

  event Configured(address minToken, address sigToken);
  event SignalingEnabled(address exchanger, uint tokenCount);
  event SignalingDisabled(address exchanger, uint tokenCount);

  function TokenPeg() public {
    pegIsSetup = false;
  }

  function setupPeg(address _minimalToken, address _signalToken) public {
    require(!pegIsSetup);
    pegIsSetup = true;

    minimalToken = _minimalToken;
    signalToken = _signalToken;

    Configured(_minimalToken, _signalToken);
  }

  function tokenFallback(address _from, uint _value, bytes /*_data*/) public {
    require(pegIsSetup);
    require(msg.sender == signalToken);
    giveMinimalTokens(_from, _value);
  }

  function convertMinimalToSignal(uint amount) public {
    require(Token(minimalToken).transferFrom(msg.sender, this, amount));
    require(Token(signalToken).transfer(msg.sender, amount));

    SignalingEnabled(msg.sender, amount);
  }

  function convertSignalToMinimal(uint amount) public {
    require(Token(signalToken).transferFrom(msg.sender, this, amount));
  }

  function giveMinimalTokens(address from, uint amount) private {
    require(Token(minimalToken).transfer(from, amount));
    
    SignalingDisabled(from, amount);
  }

}