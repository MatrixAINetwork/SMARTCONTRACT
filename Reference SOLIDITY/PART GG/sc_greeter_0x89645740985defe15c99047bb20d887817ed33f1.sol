/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract mortal {
  /* Define owner */
  address owner;

  /* executed at init and sets the owner */
  function mortal() { owner = msg.sender; }

  /* Recover funds */
  function kill() {
    if (msg.sender == owner) selfdestruct(owner);
  }
}

contract greeter is mortal {
  /* Define greeting */
  string greeting;

  /* Runs when contract is executed */
  function greeter(string _greeting) public {
    greeting = _greeting;
  }

  /* Main function */
  function greet() constant returns (string) {
    return greeting;
  }
}