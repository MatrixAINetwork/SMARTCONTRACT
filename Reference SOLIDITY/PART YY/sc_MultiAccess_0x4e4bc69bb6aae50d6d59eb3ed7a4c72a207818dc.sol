/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
// © 2016 Ambisafe Inc. No reuse without written permission is allowed.

contract Delegate {
    mapping(address => mapping(address => bool)) public senderDelegates;

    modifier onlyDelegate(address _sender) {
        if (_sender == msg.sender || address(this) == msg.sender || senderDelegates[_sender][msg.sender]) {
            _
        }
    }

    function setDelegate(address _delegate, bool _trust) returns(bool) {
        senderDelegates[msg.sender][_delegate] = _trust;
        return true;
    }
}

contract MultiAccess is Delegate {
    address public multiAccessRecipient;

    struct PendingOperation {
        bool[] ownersDone;
        uint yetNeeded;
        bytes32 op;
    }

    struct PendingState {
        PendingOperation[] pending;
        mapping(bytes32 => uint) pendingIndex;
    }

    mapping(uint => PendingState) pendingState;
    uint currentPendingState;

    uint public multiAccessRequired;

    mapping(address => uint) ownerIndex;
    address[] public multiAccessOwners;


    event Confirmation(address indexed owner, bytes32 indexed operation, bool completed);
    event Revoke(address owner, bytes32 operation);
    event OwnerChanged(address oldOwner, address newOwner);
    event OwnerAdded(address newOwner);
    event OwnerRemoved(address oldOwner);
    event RequirementChanged(uint newRequirement);

    function MultiAccess() {
        multiAccessOwners.length = 2;
        multiAccessOwners[1] = msg.sender;
        ownerIndex[msg.sender] = 1;
        multiAccessRequired = 1;
        pendingState[0].pending.length = 1;
    }

    function _state() internal constant returns(PendingState storage) {
        return pendingState[currentPendingState];
    }

    function multiAccessHasConfirmed(bytes32 _operation, address _owner) constant returns(bool) {
        uint pos = _state().pendingIndex[_operation];
        if (pos == 0) {
            return false;
        }
        uint index = ownerIndex[_owner];
        var pendingOp = _state().pending[pos];
        if (index >= pendingOp.ownersDone.length) {
            return false;
        }
        return pendingOp.ownersDone[index];
    }

    function multiAccessGetOwners() constant returns(address[]) {
        address[] memory owners = new address[](multiAccessOwners.length - 1);
        for (uint i = 1; i < multiAccessOwners.length; i++) {
            owners[i-1] = multiAccessOwners[i];
        }
        return owners;
    }

    modifier onlyowner(address _owner) {
        if (multiAccessIsOwner(_owner)) {
            _
        }
    }

    modifier onlymanyowners(address _owner, bytes32 _operation) {
        if (_confirmAndCheck(_owner, _operation)) {
            _
        }
    }

    function _confirmAndCheck(address _owner, bytes32 _operation) onlyowner(_owner) internal returns(bool) {
        uint index = ownerIndex[_owner];
        if (multiAccessHasConfirmed(_operation, _owner)) {
            return false;
        }

        uint pos = _state().pendingIndex[_operation];
        if (pos == 0) {
            pos = _state().pending.length++;
            _state().pending[pos].yetNeeded = multiAccessRequired;
            _state().pending[pos].op = _operation;
            _state().pendingIndex[_operation] = pos;
        }

        var pendingOp = _state().pending[pos];
        if (pendingOp.yetNeeded <= 1) {
            Confirmation(_owner, _operation, true);
            _removeOperation(_operation);
            return true;
        } else {
            Confirmation(_owner, _operation, false);
            pendingOp.yetNeeded--;
            if (index >= pendingOp.ownersDone.length) {
                pendingOp.ownersDone.length = index+1;
            }
            pendingOp.ownersDone[index] = true;
        }

        return false;
    }

    function _incrementState() internal {
        currentPendingState++;
        pendingState[currentPendingState].pending.length++;
    }

    function _removeOperation(bytes32 _operation) internal {
        uint pos = _state().pendingIndex[_operation];
        if (pos < _state().pending.length-1) {
            PendingOperation last = _state().pending[_state().pending.length-1];
            _state().pending[pos] = last;
            _state().pendingIndex[last.op] = pos;
        }
        _state().pending.length--;
        delete _state().pendingIndex[_operation];
    }

    function multiAccessIsOwner(address _addr) constant returns(bool) {
        return ownerIndex[_addr] > 0;
    }

    function multiAccessRevoke(bytes32 _operation) returns(bool) {
        return multiAccessRevokeD(_operation, msg.sender);
    }

    function multiAccessRevokeD(bytes32 _operation, address _sender) onlyDelegate(_sender) onlyowner(_sender) returns(bool) {
        uint index = ownerIndex[_sender];
        if (!multiAccessHasConfirmed(_operation, _sender)) {
            return false;
        }
        var pendingOp = _state().pending[_state().pendingIndex[_operation]];
        pendingOp.ownersDone[index] = false;
        pendingOp.yetNeeded++;
        if (pendingOp.yetNeeded == multiAccessRequired) {
            _removeOperation(_operation);
        }
        Revoke(_sender, _operation);
        return true;
    }

    function multiAccessChangeOwner(address _from, address _to) returns(bool) {
        return this.multiAccessChangeOwnerD(_from, _to, msg.sender);
    }

    function multiAccessChangeOwnerD(address _from, address _to, address _sender) external onlyDelegate(_sender) onlymanyowners(_sender, sha3(msg.sig, _from, _to)) returns(bool) {
        if (multiAccessIsOwner(_to)) {
            return false;
        }
        uint index = ownerIndex[_from];
        if (index == 0) {
            return false;
        }

        multiAccessOwners[index] = _to;
        delete ownerIndex[_from];
        ownerIndex[_to] = index;
        _incrementState();
        OwnerChanged(_from, _to);
        return true;
    }

    function multiAccessAddOwner(address _owner) returns(bool) {
        return this.multiAccessAddOwnerD(_owner, msg.sender);
    }

    function multiAccessAddOwnerD(address _owner, address _sender) external onlyDelegate(_sender) onlymanyowners(_sender, sha3(msg.sig, _owner)) returns(bool) {
        if (multiAccessIsOwner(_owner)) {
            return false;
        }
        uint pos = multiAccessOwners.length++;
        multiAccessOwners[pos] = _owner;
        ownerIndex[_owner] = pos;
        OwnerAdded(_owner);
        return true;
    }

    function multiAccessRemoveOwner(address _owner) returns(bool) {
        return this.multiAccessRemoveOwnerD(_owner, msg.sender);
    }

    function multiAccessRemoveOwnerD(address _owner, address _sender) external onlyDelegate(_sender) onlymanyowners(_sender, sha3(msg.sig, _owner)) returns(bool) {
        uint index = ownerIndex[_owner];
        if (index == 0) {
            return false;
        }
        if (multiAccessRequired >= multiAccessOwners.length-1) {
            return false;
        }
        if (index < multiAccessOwners.length-1) {
            address last = multiAccessOwners[multiAccessOwners.length-1];
            multiAccessOwners[index] = last;
            ownerIndex[last] = index;
        }
        multiAccessOwners.length--;
        delete ownerIndex[_owner];
        _incrementState();
        OwnerRemoved(_owner);
        return true;
    }

    function multiAccessChangeRequirement(uint _newRequired) returns(bool) {
        return this.multiAccessChangeRequirementD(_newRequired, msg.sender);
    }

    function multiAccessChangeRequirementD(uint _newRequired, address _sender) external onlyDelegate(_sender) onlymanyowners(_sender, sha3(msg.sig, _newRequired)) returns(bool) {
        if (_newRequired == 0 || _newRequired > multiAccessOwners.length-1) {
            return false;
        }
        multiAccessRequired = _newRequired;
        _incrementState();
        RequirementChanged(_newRequired);
        return true;
    }

    function multiAccessSetRecipient(address _address) returns(bool) {
        return this.multiAccessSetRecipientD(_address, msg.sender);
    }

    function multiAccessSetRecipientD(address _address, address _sender) external onlyDelegate(_sender) onlymanyowners(_sender, sha3(msg.sig, _address)) returns(bool) {
        multiAccessRecipient = _address;
        return true;
    }

    function multiAccessCall(address _to, uint _value, bytes _data) returns(bool) {
        return this.multiAccessCallD(_to, _value, _data, msg.sender);
    }

    function multiAccessCallD(address _to, uint _value, bytes _data, address _sender) external onlyDelegate(_sender) onlymanyowners(_sender, sha3(msg.sig, _to, _value, _data)) returns(bool) {
        return _to.call.value(_value)(_data);
    }

    function() returns(bool) {
        return multiAccessCall(multiAccessRecipient, msg.value, msg.data);
    }
}