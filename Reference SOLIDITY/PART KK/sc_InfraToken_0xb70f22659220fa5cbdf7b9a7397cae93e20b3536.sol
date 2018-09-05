/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract Token {
    
    

    function totalSupply() constant returns (uint256 supply) {
        
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
       
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
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
    uint256 public totalSupply;
}

contract InfraToken is StandardToken { // 

    
    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    address public fundsWallet;    

    function InfraToken() {
        balances[msg.sender] = 25000000000000000;                
        totalSupply = 25000000000000000;                            
        name = "InfraToken";                                        
        decimals = 8;                                              
        symbol = "IDT";                                             
        fundsWallet = 0x0000;                                  
    }

    function () {
        throw;     // Prevents accidental sending of ether
    }
    
}