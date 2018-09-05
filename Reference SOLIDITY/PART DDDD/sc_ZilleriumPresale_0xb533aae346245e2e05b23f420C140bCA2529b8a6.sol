/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.4;

contract SafeMath 
{
     function safeMul(uint a, uint b) internal returns (uint) 
     {
          uint c = a * b;
          assert(a == 0 || c / a == b);
          return c;
     }

     function safeSub(uint a, uint b) internal returns (uint) 
     {
          assert(b <= a);
          return a - b;
     }

     function safeAdd(uint a, uint b) internal returns (uint) 
     {
          uint c = a + b;
          assert(c>=a && c>=b);
          return c;
     }

     function assert(bool assertion) internal 
     {
          if (!assertion) throw;
     }
}

// Standard token interface (ERC 20)
// https://github.com/ethereum/EIPs/issues/20
contract Token 
{
// Functions:
    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

// Events:
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StdToken is Token 
{
// Fields:
     mapping(address => uint256) balances;
     mapping (address => mapping (address => uint256)) allowed;

     uint256 public allSupply = 0;

// Functions:
     function transfer(address _to, uint256 _value) returns (bool success) 
     {
          if((balances[msg.sender] >= _value) && (balances[_to] + _value > balances[_to])) 
          {
               balances[msg.sender] -= _value;
               balances[_to] += _value;

               Transfer(msg.sender, _to, _value);
               return true;
          } 
          else 
          { 
               return false; 
          }
     }

     function transferFrom(address _from, address _to, uint256 _value) returns (bool success) 
     {
          if((balances[_from] >= _value) && (allowed[_from][msg.sender] >= _value) && (balances[_to] + _value > balances[_to])) 
          {
               balances[_to] += _value;
               balances[_from] -= _value;
               allowed[_from][msg.sender] -= _value;

               Transfer(_from, _to, _value);
               return true;
          } 
          else 
          { 
               return false; 
          }
     }

     function balanceOf(address _owner) constant returns (uint256 balance) 
     {
          return balances[_owner];
     }

     function approve(address _spender, uint256 _value) returns (bool success) 
     {
          allowed[msg.sender][_spender] = _value;
          Approval(msg.sender, _spender, _value);

          return true;
     }

     function allowance(address _owner, address _spender) constant returns (uint256 remaining) 
     {
          return allowed[_owner][_spender];
     }

     function totalSupply() constant returns (uint256 supplyOut) 
     {
          supplyOut = allSupply;
          return;
     }
}

contract ZilleriumToken is StdToken
{
     string public name = "Zillerium Token";
     uint public decimals = 18;
     string public symbol = "ZTK";

     address public creator = 0x0;
     address public tokenClient = 0x0; // who can issue more tokens

     bool locked = false;

     function ZilleriumToken()
     {
          creator = msg.sender;
          tokenClient = msg.sender;
     }

     function changeClient(address newAddress)
     {
          if(msg.sender!=creator)throw;

          tokenClient = newAddress;
     }

     function lock(bool value)
     {
          if(msg.sender!=creator) throw;

          locked = value;
     }

     function transfer(address to, uint256 value) returns (bool success)
     {
          if(locked)throw;

          success = super.transfer(to, value);
          return;
     }

     function transferFrom(address from, address to, uint256 value) returns (bool success)
     {
          if(locked)throw;

          success = super.transferFrom(from, to, value);
          return;
     }

     function issueTokens(address forAddress, uint tokenCount) returns (bool success)
     {
          if(msg.sender!=tokenClient)throw;
          
          if(tokenCount==0) {
               success = false;
               return ;
          }

          balances[forAddress]+=tokenCount;
          allSupply+=tokenCount;

          success = true;
          return;
     }
}

contract Presale
{
     // Will allow changing the block number if set to true
     bool public isStop = false;

     uint public presaleTokenSupply = 0; //this will keep track of the token supply created during the crowdsale
     uint public presaleEtherRaised = 0; //this will keep track of the Ether raised during the crowdsale

// Parameters:
     uint public maxPresaleWei = 0;
     uint public presaleTotalWei = 0;

     // Please see our whitepaper for details
     // sell 2.5M tokens for the pre-ICO with a 20% bonus 
     // 1 ETH = 500 tokens 
     function getCurrentTokenPriceWei() constant returns (uint out)
     {
          out = 2000000000000000;  // 2000000000000000 Wei = 1 token
          return;
     }
}

contract ZilleriumPresale is Presale, SafeMath
{
     address public creator = 0x0;
     address public fund = 0x0;

     ZilleriumToken public zilleriumToken;

// Events:
     event Buy(address indexed sender, uint eth, uint fbt);

// Functions:
     function ZilleriumPresale(
          address zilleriumToken_,
          uint maxIcoEth_,
          address fundAddress_)  
     {
          creator = msg.sender;
          zilleriumToken = ZilleriumToken(zilleriumToken_);

          maxPresaleWei = maxIcoEth_ * 10**18;

          fund = fundAddress_;
     }

     function transfer(address _to, uint256 _value) returns (bool success) 
     {
          if(!presaleEnded() && (msg.sender!=creator)) {
               throw;
          }

          return zilleriumToken.transfer(_to, _value);
     }
     
     function transferFrom(address _from, address _to, uint256 _value) returns (bool success) 
     {
          if(!presaleEnded() && (msg.sender!=creator)) {
               throw;
          }

          return zilleriumToken.transferFrom(_from, _to, _value);
     }

     function stop(bool _stop)
     {
          if(msg.sender!=creator) throw;
          isStop = _stop;
     }

     function buyTokens()
     {
          address to = msg.sender;
          buyTokensFor(to);
     }

     function buyTokensFor(address to)
     {
          if(msg.value==0) throw;
          if(isStop) throw;
          if(presaleEnded()) throw;

          uint pricePerToken = getCurrentTokenPriceWei();
          if(msg.value<pricePerToken)
          {
               // Not enough Wei to buy at least 1 token
               throw; 
          }

          // the div rest is not returned!
          uint tokens = (msg.value / pricePerToken);

          if(!fund.send(msg.value)) 
          {
               // Can not send money
               throw;
          }

          zilleriumToken.issueTokens(to,tokens);
          presaleTotalWei = safeAdd(presaleTotalWei, msg.value);

          Buy(to, msg.value, tokens);
     }

     function presaleEnded() returns(bool){
          return (presaleTotalWei>=maxPresaleWei);
     }

     /// This function is called when someone sends money to this contract directly.
     function() 
     {
          throw;
     }
}