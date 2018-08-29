/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/**
 * The Edgeless token contract complies with the ERC20 standard. 
 * Additionally tokens can be locked for a defined time interval by token holders.
 * author: Julia Altenried
 * */

pragma solidity ^0.4.6;
contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract EdgelessToken {
    /* Public variables of the token */
    string public standard = 'ERC20';
    string public name = 'Edgeless';
    string public symbol = 'EDG';
    uint8 public decimals = 0; 
    uint256 public totalSupply;
    uint256 public currentInterval = 1;
    uint256 public intervalLength = 30 days;
    uint256 public startTime = 1485878400;//from this time on tokens may be transfered (after ICO)
    address public owner;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    
    /* Defines how many tokens of which addresses are locked in which interval*/
    mapping(address => mapping(uint256=>uint256)) public locked;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Lock(address indexed owner, uint256 interval, uint256 value);
    
    /* Initializes contract with initial supply tokens to the creator of the contract */
    function EdgelessToken() {
        owner = 0x003230BBE64eccD66f62913679C8966Cf9F41166;
        balanceOf[owner] = 500000000;              // Give the owner all initial tokens
        totalSupply = 500000000;                        // Update total supply           
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) returns (bool success){
        if (now < startTime) throw; //check if the crowdsale is already over
        if (balanceOf[msg.sender]-locked[msg.sender][getInterval()] < _value) throw;   // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
        return true;
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /* Approve and then comunicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }        

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (now < startTime) throw; //check if the crowdsale is already over
        if (balanceOf[_from]-locked[_from][getInterval()] < _value) throw;     // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (_value > allowance[_from][msg.sender]) throw;   // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }
    
    /* Lock a number of tokens */
    function lock(address holder, uint256 _value) returns (bool success) {
        if(holder==msg.sender||holder==tx.origin){
            locked[holder][getInterval()]+=_value;
            Lock(holder, currentInterval, _value);
            return true;
        }
    }
    
    /* Increase the interval, if sufficient time has passed */
    function getInterval() returns (uint256 interval){
        if (now > currentInterval * intervalLength + startTime) {
            currentInterval = (now - startTime) / intervalLength + 1;
        }
        return currentInterval;
    }

}