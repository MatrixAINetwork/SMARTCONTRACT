/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.18;




contract MiniMeToken {
function generateTokens(address to, uint256 amount) public returns (bool);
function changeController(address controller) public;
}




contract StoppableAirdrop {
MiniMeToken public airdropToken;
address public owner;




bool public stopped;




mapping (address => bool) dropped;




function StoppableAirdrop(MiniMeToken _airdropToken, address _owner) {
airdropToken = _airdropToken;
owner = _owner;
stopped = true;
}




function () external {
drop();
}




function drop() public {
require(!dropped[msg.sender]);
require(!stopped);
dropped[msg.sender] = true;




require(airdropToken.generateTokens(msg.sender, 10 ** 18));
}




function setStopped(bool _stop) public {
require(msg.sender == owner);
stopped = _stop;
}




function claimController() public {
require(msg.sender == owner);
airdropToken.changeController(owner);
}
}