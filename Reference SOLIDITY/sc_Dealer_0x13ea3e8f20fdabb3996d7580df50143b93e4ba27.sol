/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

contract Dealer {

    address public pitboss;
    uint public constant ceiling = 0.25 ether;

    event Deposit(address indexed _from, uint _value);

    function Dealer() public {
      pitboss = msg.sender;
    }

    function () public payable {
      Deposit(msg.sender, msg.value);
    }

    modifier pitbossOnly {
      require(msg.sender == pitboss);
      _;
    }

    function cashout(address winner, uint amount) public pitbossOnly {
      winner.transfer(amount);
    }

    function overflow() public pitbossOnly {
      require (this.balance > ceiling);
      pitboss.transfer(this.balance - ceiling);
    }

    function kill() public pitbossOnly {
      selfdestruct(pitboss);
    }

}