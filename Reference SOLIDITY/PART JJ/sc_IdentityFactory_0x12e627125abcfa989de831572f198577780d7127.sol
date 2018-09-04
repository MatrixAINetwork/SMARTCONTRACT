/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.4;

library ArrayLib{
  function findAddress(address a, address[] storage arry) returns (int){
    for (uint i = 0 ; i < arry.length ; i++){
      if(arry[i] == a){return int(i);}
    }
    return -1;
  }
  function removeAddress(uint i, address[] storage arry){
    uint lengthMinusOne = arry.length - 1;
    arry[i] = arry[lengthMinusOne];
    delete arry[lengthMinusOne];
    arry.length = lengthMinusOne;
  }
}

contract Owned {
  address public owner;
  modifier onlyOwner(){ if (isOwner(msg.sender)) _; }
  modifier ifOwner(address sender) { if(isOwner(sender)) _; }

  function Owned(){ owner = msg.sender; }

  function isOwner(address addr) public returns(bool) { return addr == owner; }

  function transfer(address _owner) onlyOwner { owner = _owner; }
}

contract Proxy is Owned {
  event Forwarded (address indexed destination, uint value, bytes data );
  event Received (address indexed sender, uint value);

  function () payable { Received(msg.sender, msg.value); }

  function forward(address destination, uint value, bytes data) onlyOwner {
    if (!destination.call.value(value)(data)) { throw; }
    Forwarded(destination, value, data);
  }
}

contract RecoverableController {
  uint    public version;
  Proxy   public proxy;

  address public userKey;
  address public proposedUserKey;
  uint    public proposedUserKeyPendingUntil;

  address public recoveryKey;
  address public proposedRecoveryKey;
  uint    public proposedRecoveryKeyPendingUntil;

  address public proposedController;
  uint    public proposedControllerPendingUntil;

  uint    public shortTimeLock;// use 900 for 15 minutes
  uint    public longTimeLock; // use 259200 for 3 days

  event RecoveryEvent(string action, address initiatedBy);

  modifier onlyUserKey() { if (msg.sender == userKey) _; }
  modifier onlyRecoveryKey() { if (msg.sender == recoveryKey) _; }

  function RecoverableController(address proxyAddress, address _userKey, uint _longTimeLock, uint _shortTimeLock) {
    version = 1;
    proxy = Proxy(proxyAddress);
    userKey = _userKey;
    shortTimeLock = _shortTimeLock;
    longTimeLock = _longTimeLock;
    recoveryKey = msg.sender;
  }

  function forward(address destination, uint value, bytes data) onlyUserKey {
    proxy.forward(destination, value, data);
  }
  //pass 0x0 to cancel 
  function signRecoveryChange(address _proposedRecoveryKey) onlyUserKey{
    proposedRecoveryKeyPendingUntil = now + longTimeLock;
    proposedRecoveryKey = _proposedRecoveryKey;
    RecoveryEvent("signRecoveryChange", msg.sender);
  }
  function changeRecovery() {
    if(proposedRecoveryKeyPendingUntil < now && proposedRecoveryKey != 0x0){
      recoveryKey = proposedRecoveryKey;
      delete proposedRecoveryKey;
    }
  }
  //pass 0x0 to cancel 
  function signControllerChange(address _proposedController) onlyUserKey{
    proposedControllerPendingUntil = now + longTimeLock;
    proposedController = _proposedController;
    RecoveryEvent("signControllerChange", msg.sender);
  }
  function changeController() {
    if(proposedControllerPendingUntil < now && proposedController != 0x0){
      proxy.transfer(proposedController);
      suicide(proposedController);
    }
  }
  //pass 0x0 to cancel 
  function signUserKeyChange(address _proposedUserKey) onlyUserKey{
    proposedUserKeyPendingUntil = now + shortTimeLock;
    proposedUserKey = _proposedUserKey;
    RecoveryEvent("signUserKeyChange", msg.sender);
  }
  function changeUserKey(){
    if(proposedUserKeyPendingUntil < now && proposedUserKey != 0x0){
      userKey = proposedUserKey;
      delete proposedUserKey;
      RecoveryEvent("changeUserKey", msg.sender);
    }
  }
  
  function changeRecoveryFromRecovery(address _recoveryKey) onlyRecoveryKey{ recoveryKey = _recoveryKey; }
  function changeUserKeyFromRecovery(address _userKey) onlyRecoveryKey{
    delete proposedUserKey;
    userKey = _userKey;
  }
}

contract RecoveryQuorum {
  RecoverableController public controller;

  address[] public delegateAddresses; // needed for iteration of mapping
  mapping (address => Delegate) public delegates;
  struct Delegate{
    uint deletedAfter; // delegate exists if not 0
    uint pendingUntil;
    address proposedUserKey;
  }

  event RecoveryEvent(string action, address initiatedBy);

  modifier onlyUserKey(){ if (msg.sender == controller.userKey()) _; }

  function RecoveryQuorum(address _controller, address[] _delegates){
    controller = RecoverableController(_controller);
    for(uint i = 0; i < _delegates.length; i++){
      delegateAddresses.push(_delegates[i]);
      delegates[_delegates[i]] = Delegate({proposedUserKey: 0x0, pendingUntil: 0, deletedAfter: 31536000000000});
    }
  }
  function signUserChange(address proposedUserKey) {
    if(delegateRecordExists(delegates[msg.sender])) {
      delegates[msg.sender].proposedUserKey = proposedUserKey;
      changeUserKey(proposedUserKey);
      RecoveryEvent("signUserChange", msg.sender);
    }
  }
  function changeUserKey(address newUserKey) {
    if(collectedSignatures(newUserKey) >= neededSignatures()){
      controller.changeUserKeyFromRecovery(newUserKey);
      for(uint i = 0 ; i < delegateAddresses.length ; i++){
        //remove any pending delegates after a recovery
        if(delegates[delegateAddresses[i]].pendingUntil > now){ 
            delegates[delegateAddresses[i]].deletedAfter = now;
        }
        delete delegates[delegateAddresses[i]].proposedUserKey;
      }
    }
  }

  function replaceDelegates(address[] delegatesToRemove, address[] delegatesToAdd) onlyUserKey{
    for(uint i = 0 ; i < delegatesToRemove.length ; i++){
      removeDelegate(delegatesToRemove[i]);
    }
    garbageCollect();
    for(uint j = 0 ; j < delegatesToAdd.length ; j++){
      addDelegate(delegatesToAdd[j]);
    }
    RecoveryEvent("replaceDelegates", msg.sender);
  }
  function collectedSignatures(address _proposedUserKey) returns (uint signatures){
    for(uint i = 0 ; i < delegateAddresses.length ; i++){
      if (delegateHasValidSignature(delegates[delegateAddresses[i]]) && delegates[delegateAddresses[i]].proposedUserKey == _proposedUserKey){
        signatures++;
      }
    }
  }

  function getAddresses() constant returns (address[]){ return delegateAddresses; }

  function neededSignatures() returns (uint){
    uint currentDelegateCount; //always 0 at this point
    for(uint i = 0 ; i < delegateAddresses.length ; i++){
      if(delegateIsCurrent(delegates[delegateAddresses[i]])){ currentDelegateCount++; }
    }
    return currentDelegateCount/2 + 1;
  }
  function addDelegate(address delegate) private {
    if(!delegateRecordExists(delegates[delegate]) && delegateAddresses.length < 15) {
      delegates[delegate] = Delegate({proposedUserKey: 0x0, pendingUntil: now + controller.longTimeLock(), deletedAfter: 31536000000000});
      delegateAddresses.push(delegate);
    }
  }
  function removeDelegate(address delegate) private {
    if(delegates[delegate].deletedAfter > controller.longTimeLock() + now){ 
      //remove right away if they are still pending
      if(delegates[delegate].pendingUntil > now){ 
        delegates[delegate].deletedAfter = now;
      } else{
        delegates[delegate].deletedAfter = controller.longTimeLock() + now;
      }
    }
  }
  function garbageCollect() private{
    uint i = 0;
    while(i < delegateAddresses.length){
      if(delegateIsDeleted(delegates[delegateAddresses[i]])){
        delegates[delegateAddresses[i]].deletedAfter = 0;
        delegates[delegateAddresses[i]].pendingUntil = 0;
        delegates[delegateAddresses[i]].proposedUserKey = 0;
        ArrayLib.removeAddress(i, delegateAddresses);
      }else{i++;}
    }
  }
  function delegateRecordExists(Delegate d) private returns (bool){
      return d.deletedAfter != 0;
  }
  function delegateIsDeleted(Delegate d) private returns (bool){
      return d.deletedAfter <= now; //doesnt check record existence
  }
  function delegateIsCurrent(Delegate d) private returns (bool){
      return delegateRecordExists(d) && !delegateIsDeleted(d) && now > d.pendingUntil;
  }
  function delegateHasValidSignature(Delegate d) private returns (bool){
      return delegateIsCurrent(d) && d.proposedUserKey != 0x0;
  }
}

contract IdentityFactory {
    event IdentityCreated(
        address indexed userKey,
        address proxy,
        address controller,
        address recoveryQuorum);

    mapping(address => address) public senderToProxy;

    //cost ~2.4M gas
    function CreateProxyWithControllerAndRecovery(address userKey, address[] delegates, uint longTimeLock, uint shortTimeLock) {
        Proxy proxy = new Proxy();
        RecoverableController controller = new RecoverableController(proxy, userKey, longTimeLock, shortTimeLock);
        proxy.transfer(controller);
        RecoveryQuorum recoveryQuorum = new RecoveryQuorum(controller, delegates);
        controller.changeRecoveryFromRecovery(recoveryQuorum);

        IdentityCreated(userKey, proxy, controller, recoveryQuorum);
        senderToProxy[msg.sender] = proxy;
    }
}