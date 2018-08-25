/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract ctf {
    address public owner;
    // uint public secret;
    uint private flag; //no public, it's a secret;

    /* CONSTRUCTOR */
    function ctf(uint _flag) public { 
      owner = msg.sender;
      flag = _flag;
    }

    /* let me change the secret just in case I want to */
    function change_flag(uint newflag) public {
      require(msg.sender == owner); //make sure it's me
      flag = newflag;
    }

    function() payable public {
      return;
    }
    // don't need it anymore
    function kill(address _to) public {
      require(msg.sender == owner);
      selfdestruct(_to);
    }
}