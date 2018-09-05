/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract KolkhaToken {
  /////////////////////////////////////////////////////////////////////////
  mapping (address => uint) public balanceOf;           //All of the balances of the users (public)
  string  public constant name = "Kolkha";         //Name of the coin
  string public constant symbol = "KHC";                //Coin's symbol
  uint8 public constant decimals = 6;
  uint public totalSupply;                              //Total supply of coins

  event Transfer(address indexed from, address indexed to, uint value); //Event indicating a transaction
  //////////////////////////////////////////////////////////////////////////

  function KolkhaToken(uint initSupply) {
    balanceOf[msg.sender] = initSupply;
    totalSupply = initSupply;
  }


  //Transfer transaction function
  function transfer(address _to, uint _value) returns (bool)
  {
    assert(msg.data.length == 2*32 + 4);
    require(balanceOf[msg.sender] >= _value); //Not enough balanceOf
    require(balanceOf[_to] + _value >= balanceOf[_to]); //Balance overflow, integer too large (or negative)

    //In case of no exceptions
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;

    Transfer(msg.sender, _to, _value); //Call the event
    return true;
  }
}