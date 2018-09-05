/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.8;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }
    
    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner == 0x0) throw;
        owner = newOwner;
    }
}

contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  
  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  
  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
  
  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}

contract Token {
    uint256 public totalSupply;
    
    function balanceOf(address _owner) constant returns (uint256 balance);
    
    function transfer(address _to, uint256 _value) returns (bool success);
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    
    function approve(address _spender, uint256 _value) returns (bool success);
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_from] -= _value;
            balances[_to] += _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract pr0coin is owned, SafeMath, StandardToken {
    string public name = "pr0coin";
    string public symbol = ">_";
    address public pr0coinAddress = this;
    uint8 public decimals = 4;
    uint256 public totalSupply = 1000000000000;
    uint256 public buyPriceEth = 2 szabo;
    uint256 public sellPriceEth = 1 szabo;
    uint256 public gasForDCN = 5 szabo;
    uint256 public DCNForGas = 10;
    uint256 public gasReserve = 1 ether;
    uint256 public minBalanceForAccounts = 10 szabo;
    bool public directTradeAllowed = true;
    
    function pr0coin() {
        balances[msg.sender] = totalSupply/10; 
        balances[this] = totalSupply - balances[msg.sender];
    }
    
    function setEtherPrices(uint256 newBuyPriceEth, uint256 newSellPriceEth) onlyOwner {
        buyPriceEth = newBuyPriceEth;
        sellPriceEth = newSellPriceEth;
    }
    
    function setGasForDCN(uint newGasAmountInWei) onlyOwner {
        gasForDCN = newGasAmountInWei;
    }
    
    function setDCNForGas(uint newDCNAmount) onlyOwner {
        DCNForGas = newDCNAmount;
    }
    
    function setGasReserve(uint newGasReserveInWei) onlyOwner {
        gasReserve = newGasReserveInWei;
    }
    
    function setMinBalance(uint minimumBalanceInWei) onlyOwner {
        minBalanceForAccounts = minimumBalanceInWei;
    }
    
    function haltDirectTrade() onlyOwner {
        directTradeAllowed = false;
    }
    
    function unhaltDirectTrade() onlyOwner {
        directTradeAllowed = true;
    }
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (_value < DCNForGas) throw;                                   
        if (msg.sender != owner && _to == pr0coinAddress && directTradeAllowed) {
            sellpr0coinsAgainstEther(_value);                         
            return true;
        }

        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {            
            balances[msg.sender] = safeSub(balances[msg.sender], _value);

            if (msg.sender.balance >= minBalanceForAccounts && _to.balance >= minBalanceForAccounts) { 
                balances[_to] = safeAdd(balances[_to], _value);
                Transfer(msg.sender, _to, _value);
                return true;
            } else {
                balances[this] = safeAdd(balances[this], DCNForGas);
                balances[_to] = safeAdd(balances[_to], safeSub(_value, DCNForGas));
                Transfer(msg.sender, _to, safeSub(_value, DCNForGas));

                if(msg.sender.balance < minBalanceForAccounts) {
                    if(!msg.sender.send(gasForDCN)) throw;
                  }
                if(_to.balance < minBalanceForAccounts) {
                    if(!_to.send(gasForDCN)) throw;
                }
            }
        } else { throw; }
    }
    
    function buypr0coinsAgainstEther() payable returns (uint amount) {
        if (buyPriceEth == 0 || msg.value < buyPriceEth) throw;             
        amount = msg.value / buyPriceEth;                                   
        if (balances[this] < amount) throw;                                 
        balances[msg.sender] = safeAdd(balances[msg.sender], amount);       
        balances[this] = safeSub(balances[this], amount);                   
        Transfer(this, msg.sender, amount);                                 
        return amount;
    }
    
    function sellpr0coinsAgainstEther(uint256 amount) returns (uint revenue) {
        if (sellPriceEth == 0 || amount < DCNForGas) throw;                 
        if (balances[msg.sender] < amount) throw;                           
        revenue = safeMul(amount, sellPriceEth);                            
        if (safeSub(this.balance, revenue) < gasReserve) throw;             
        if (!msg.sender.send(revenue)) {                                    
            throw;                                                          
        } else {
            balances[this] = safeAdd(balances[this], amount);               
            balances[msg.sender] = safeSub(balances[msg.sender], amount);   
            Transfer(this, msg.sender, revenue);                            
            return revenue;                                                 
        }
    }
    
    function refundToOwner (uint256 amountOfEth, uint256 dcn) onlyOwner {
        uint256 eth = safeMul(amountOfEth, 1 ether);
        if (!msg.sender.send(eth)) {                                       
            throw;                                                         
        } else {
            Transfer(this, msg.sender, eth);                               
        }
        if (balances[this] < dcn) throw;                                   
        balances[msg.sender] = safeAdd(balances[msg.sender], dcn);         
        balances[this] = safeSub(balances[this], dcn);                     
        Transfer(this, msg.sender, dcn);                                   
    }
    
    function() payable {
        if (msg.sender != owner) {
            if (!directTradeAllowed) throw;
            buypr0coinsAgainstEther();
        }
    }
}