/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract Ownable {

    address owner;
    
    function Ownable() public{
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner{
    require(newOwner != address(0));      
    owner = newOwner;
  }
}

contract IamKokinToken is Ownable {
    
    string public  name  = "GitHubs cherry";
    
    string public  symbol = "GHC";
    
    uint32 public  decimals = 8 ;
    
    uint public totalSupply = 2100000000000000;
    
    uint public etap = 1000000000000000;
    
    uint public forCommand = 100000000000000;
    
    uint public sendCount = 500000000000;
    
    uint public etapAddressesLimit = etap/sendCount;
    
    address public commandAddress = 0x60BF15Bc406242706385846779732C740fb077f9;
    
    uint startEtap1 = 1511424600;
    uint endEtap1 = 1511425500;
    
    uint startEtap2 = 1511426100;
    uint endEtap2 = 1511427000;
    
    address[] tempArray;

    mapping (address => uint) balances;
    
    mapping (address => mapping(address => uint)) allowed;
    
    function IamKokinToken() public {
        balances[commandAddress] = forCommand;
        balances[owner] = totalSupply-forCommand;
    }
    
    function balanceOf(address who) public constant returns (uint balance) {
        return balances[who];
    }

    function transfer(address _to, uint _value) public returns (bool success) {
            if(balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
                balances[msg.sender] -= _value; 
                balances[_to] += _value;
                Transfer(msg.sender, _to, _value);
                return true;
            }
        return false;
    }
    
    function multisend(address[] temp) public onlyOwner returns (bool success){
         if((now > startEtap1 && now < endEtap1)||(now > startEtap2 && now < endEtap2)){
                if(temp.length > 0) {
                    for(uint i = 0; i < temp.length; i++)
                    {
                        balances[owner] -= sendCount;
                        balances[temp[i]] += sendCount;
                        Transfer(owner, temp[i],sendCount);
                    }
                    return true;
                } 
            }
        return false;
    }
    
    
    function burn() onlyOwner public {
        require (now>=endEtap1 && now <=startEtap2 || now >= endEtap2);
        uint _value;
        if (now>=endEtap1 && now <=startEtap2) {
            _value = balances[owner] - etap;
            require(_value > 0);
        }
        else _value = balances[owner];
        balances[owner] -= _value;
        totalSupply -= _value;
        Burn(owner, _value);
    }
    
    event Burn(address indexed burner, uint indexed value);
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        if( allowed[_from][msg.sender] >= _value && balances[_from] >= _value && balances[_to] + _value >= balances[_to]) {
            allowed[_from][msg.sender] -= _value;
            balances[_from] -= _value; 
            balances[_to] += _value;
            Transfer(_from, _to, _value);
            return true;
        } 
        return false;
    }
     
    function approve(address _spender, uint _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint _value);   
}