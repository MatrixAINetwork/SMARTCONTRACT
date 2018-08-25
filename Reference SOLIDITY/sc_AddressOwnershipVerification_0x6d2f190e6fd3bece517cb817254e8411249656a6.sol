/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.2;

contract AddressOwnershipVerification {
    mapping(address => mapping (uint32 => address)) _requests;        // Pending requests (transactee address => (deposit => transactor address)
    mapping(address => mapping (address => uint32)) _requestsReverse; // Used for reverse lookups  (transactee address => (transactor address => deposit)
    mapping(address => mapping (address => uint32)) _verifications;   // Verified requests (transactor address => (transactee address => deposit)

    event RequestEvent(address indexed transactor, address indexed transactee, uint32 indexed deposit);      // Event is triggered when a new request is added
    event RemoveRequestEvent(address indexed transactor, address indexed transactee);                        // Event is triggered when an unverified request is removed
    event VerificationEvent(address indexed transactor, address indexed transactee, uint32 indexed deposit); // Event is triggered when someone proves ownership of an address
    event RevokeEvent(address indexed transactor, address indexed transactee, uint32 indexed deposit);       // Event is triggered when either party removes a trust

    function AddressOwnershipVerification() {}

    // Used to verify pending requests by transactee sending deposit to this contract
    function () payable {
        uint32 value = uint32(msg.value);

        if (!_requestExists(msg.sender, value)) {
            throw;
        }

        // Get matching transactor for request
        address transactor = _requests[msg.sender][value];

        // Save new Verification
        _saveVerification(transactor, msg.sender, value);

        // And then delete the verified request
        _deleteRequest(transactor, msg.sender);

        VerificationEvent(transactor, msg.sender, value);
    }

    // Request a new verification as transactor
    function request(address transactee, uint32 deposit) {
        // Throw if sender wastes blockchain space
        if (transactee == msg.sender) {
            throw;
        }

        // Deposit can't be 0 because all uint's get initialized to 0 in _requests
        if (deposit == 0) {
            throw;
        }

        // Throw if transactee already provided verification to transactor
        if(verify(msg.sender, transactee)) {
            throw;
        }

        // Throw if transactee already has a pending request for this exact deposit
        if (_requestExists(transactee, deposit)) {
            throw;
        }

        if (_requestExistsReverse(msg.sender, transactee)) {
            throw;
        }

        _saveRequest(msg.sender, transactee, deposit);

        RequestEvent(msg.sender, transactee, deposit);
    }

    // Returns amount of wei transactee has to send to fullfill transactor's request
    function getRequest(address transactor, address transactee) returns (uint32 deposit) {
        return _requestsReverse[transactee][transactor];
    }

    // Removes a pending request as transactor or transactee
    function removeRequest(address transactor, address transactee) returns (uint32) {
        // Only transactor and transactee can trigger removal of their request
        if (msg.sender != transactor && msg.sender != transactee) {
            throw;
        }

        _deleteRequest(transactor, transactee);

        RemoveRequestEvent(transactor, transactee);
    }

    //  Returns true if transactee has already proven their address ownership to transactor in the past
    function verify(address transactor, address transactee) returns (bool) {
        return _verifications[transactor][transactee] != 0;
    }

    // Removes an existing verification and returns the deposited amount to transactee
    // Can be called by either transactor or transactee
    function revoke(address transactor, address transactee) {
        // Only transactor and transactee can trigger removal of their verification
        if (msg.sender != transactor && msg.sender != transactee) {
            throw;
        }

        // Throw if verification does not exist
        if(!verify(transactor, transactee)) {
            throw;
        }

        uint32 deposit = _verifications[transactor][transactee];

        // Delete verification
        delete _verifications[transactor][transactee];

        // Send deposit to transactee
        if (!transactee.call.value(deposit).gas(23000)()) {
            throw;
        }

        RevokeEvent(transactor, transactee, deposit);
    }

    // Internal: Save a new request
    function _saveRequest(address transactor, address transactee, uint32 deposit) internal {
        _requests[transactee][deposit] = transactor;
        _requestsReverse[transactee][transactor] = deposit;
    }

    // Internal: Remove a fullfilled request
    function _deleteRequest(address transactor, address transactee) internal {
        uint32 deposit = _requestsReverse[transactee][transactor];

        delete _requests[transactee][deposit];
        delete _requestsReverse[transactee][transactor];
    }

    // Internal: Test if a request exists when you know transactee and deposit
    function _requestExists(address transactee, uint32 deposit) internal returns(bool) {
        return _requests[transactee][deposit] != 0x0000000000000000000000000000000000000000;
    }

    // Internal: Test if a request exists when you know transactee and transactor
    function _requestExistsReverse(address transactor, address transactee) internal returns(bool) {
        return _requestsReverse[transactee][transactor] != 0;
    }

    // Internal: Save a new verification
    function _saveVerification(address transactor, address transactee, uint32 deposit) internal {
        _verifications[transactor][transactee] = deposit;
    }
}