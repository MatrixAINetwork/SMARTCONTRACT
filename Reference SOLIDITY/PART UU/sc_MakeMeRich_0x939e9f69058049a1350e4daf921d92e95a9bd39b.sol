/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract MakeMeRich {
    
    mapping(address => address) public usersRef; // userAddress => referal
    mapping(address => bool) public users;
    mapping(address => uint) public countRef; 
    address[] public usersAddress;
    address public owner = 0x71224f308fEaA6FbC0Ab9d3D820C1e454AdcD6d9;
    
    function MakeMeRich()   public {
        usersRef[msg.sender] = owner;
        users[msg.sender] = true;
        usersAddress.push(msg.sender);
    }
    
    function register(address _ref) payable public  {
        
        require(msg.value == 0.1 ether); // 0.1 ether
        require(users[msg.sender] == false); // not registered yet
        require(users[_ref] == true); // valid _ref
        users[msg.sender] = true;
        usersAddress.push(msg.sender);
        usersRef[msg.sender] = _ref;
        countRef[_ref] += 1;
         //1 level - send 80% from 0.1 ether
        if(_ref.send(0.08 ether) == false) {
            owner.transfer(0.08 ether);
        }
        // 2 level - send 15% from 0.1 ether
        if(usersRef[_ref].send(0.015 ether) == false) {
            owner.transfer(0.015 ether);
        }
        // Service comission - 5%
        owner.transfer(0.005 ether);
        
    }
}