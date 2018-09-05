/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
// This is the base contract that your contract test2 extends from.
contract BaseRegistry {

    // The owner of this registry.
    address owner;

    // This struct keeps all data for a Record.
    struct Record {
        // Keeps the address of this record creator.
        address owner;
        // Keeps the time when this record was created.
        uint time;
        // Keeps the index of the keys array for fast lookup
        uint keysIndex;
    }

    // This mapping keeps the records of this Registry.
    mapping(address => Record) records;

    // Keeps the total numbers of records in this Registry.
    uint public numRecords;

    // Keeps a list of all keys to interate the records.
    address[] private keys;



    // Constructor
    function BaseRegistry() {
        owner = msg.sender;
    }

    // This is the function that actually insert a record. 
    function register(address key) {
        if (records[key].time == 0) {
            records[key].time = now;
            records[key].owner = msg.sender;
            records[key].keysIndex = keys.length;
            keys.length++;
            keys[keys.length - 1] = key;
            numRecords++;
        } else {
            returnValue();
        }
    }

    // Updates the values of the given record.
    function update(address key) {
        // Only the owner can update his record.
        if (records[key].owner == msg.sender) {}
    }

    // Unregister a given record
    function unregister(address key) {
        if (records[key].owner == msg.sender) {
            uint keysIndex = records[key].keysIndex;
            delete records[key];
            numRecords--;
            keys[keysIndex] = keys[keys.length - 1];
            records[keys[keysIndex]].keysIndex = keysIndex;
            keys.length--;
        }
    }

    // Transfer ownership of a given record.
    function transfer(address key, address newOwner) {
        if (records[key].owner == msg.sender) {
            records[key].owner = newOwner;
        } else {
            returnValue();
        }
    }

    // Tells whether a given key is registered.
    function isRegistered(address key) returns(bool) {
        return records[key].time != 0;
    }

    function getRecordAtIndex(uint rindex) returns(address key, address owner, uint time) {
        Record record = records[keys[rindex]];
        key = keys[rindex];
        owner = record.owner;
        time = record.time;

    }

    function getRecord(address key) returns(address owner, uint time) {
        Record record = records[key];
        owner = record.owner;
        time = record.time;

    }

    // Returns the owner of the given record. The owner could also be get
    // by using the function getRecord but in that case all record attributes 
    // are returned.
    function getOwner(address key) returns(address) {
        return records[key].owner;
    }

    // Returns the registration time of the given record. The time could also
    // be get by using the function getRecord but in that case all record attributes
    // are returned.
    function getTime(address key) returns(uint) {
        return records[key].time;
    }

    // Returns the total number of records in this registry.
    function getTotalRecords() returns(uint) {
        return numRecords;
    }

    // This function is used by subcontracts when an error is detected and
    // the value needs to be returned to the transaction originator.
    function returnValue() internal {
        if (msg.value > 0) {
            msg.sender.send(msg.value);
        }
    }

    // Registry owner can use this function to withdraw any value owned by
    // the registry.
    function withdraw(address to, uint value) {
        if (msg.sender == owner) {
            to.send(value);
        }
    }

    function kill() {
        if (msg.sender == owner) {
            suicide(owner);
        }
    }
}

contract test2 is BaseRegistry {}