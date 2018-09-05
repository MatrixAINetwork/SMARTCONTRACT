/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract thewhalegame {

  struct Person {
      address etherAddress;
      uint amount;
  }

  Person[] public persons;

  uint public payoutIdx = 0;
  uint public collectedFees;
  uint public balance = 0;

  address public owner;


  modifier onlyowner { if (msg.sender == owner) _ }


  function thewhalegame() {
    owner = msg.sender;
  }

  function() {
    enter();
  }
  
  function enter() {
    if (msg.value < 5 ether) {
        msg.sender.send(msg.value);
        return;
    }
	
		uint amount;
		if (msg.value > 500 ether) {
			msg.sender.send(msg.value - 500 ether);	
			amount = 500 ether;
    }
		else {
			amount = msg.value;
		}


    uint idx = persons.length;
    persons.length += 1;
    persons[idx].etherAddress = msg.sender;
    persons[idx].amount = amount;
 
    
    if (idx != 0) {
      collectedFees += amount / 100 * 3;
	  owner.send(collectedFees);
	  collectedFees = 0;
      balance += amount - amount / 100 * 3;
    } 
    else {
      balance += amount;
    }


    while (balance > persons[payoutIdx].amount / 100 * 125) {
      uint transactionAmount = persons[payoutIdx].amount / 100 * 125;
      persons[payoutIdx].etherAddress.send(transactionAmount);

      balance -= transactionAmount;
      payoutIdx += 1;
    }
  }


  function setOwner(address _owner) onlyowner {
      owner = _owner;
  }
}