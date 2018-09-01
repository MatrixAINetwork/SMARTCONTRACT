/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract DigitalPadlock {
    string public message;

    function DigitalPadlock(string _m) public {
        message = _m;
    }
}

contract EthernalLoveParent {
  address owner;
  address[] public padlocks;
  event LogCreatedValentine(address padlock); // maybe listen for events

  function EthernalLoveParent() public {
    owner = msg.sender;
  }

  function createPadlock(string _m) public {
    DigitalPadlock d = new DigitalPadlock(_m);
    LogCreatedValentine(d); // emit an event
    padlocks.push(d); 
  }
}