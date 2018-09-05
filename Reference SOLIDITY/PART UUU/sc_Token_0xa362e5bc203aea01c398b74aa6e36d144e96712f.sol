/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.8;

contract Token {
    uint256 public totalSupply;
    string public name = "Arcblock Token";              
    uint8 public decimals = 18;        
    string public symbol = "ABT";
    mapping (address => uint256) balances;
    address owner;
    
    function Token() {
        owner = msg.sender;
        totalSupply = 1000000000 * 10**uint256(decimals);
        balances[msg.sender] = totalSupply;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    function changeToken(string cName, string cSymbol) onlyOwner public {
        name = cName;
        symbol = cSymbol;
    }
    
    function addSupply(uint256 aSupply) onlyOwner public {
        balances[owner] += aSupply;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[_to] += _value;
        return true;
    }
}