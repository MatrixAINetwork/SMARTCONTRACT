/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/**
 * The Edgeless token contract complies with the ERC20 standard (see https://github.com/ethereum/EIPs/issues/20).
 * Additionally tokens can be locked for a defined time interval by token holders.
 * The owner's share of tokens is locked for the first 360 days and all tokens not
 * being sold during the crowdsale but 60.000.000 (owner's share + bounty program) are burned.
 * Author: Julia Altenried
 * */

pragma solidity ^0.4.6;
contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract SafeMath {
  //internals

  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}

contract EdgelessToken is SafeMath {
    /* Public variables of the token */
    string public standard = 'ERC20';
    string public name = 'Edgeless';
    string public symbol = 'EDG';
    uint8 public decimals = 0;
    uint256 public totalSupply;
    uint256 public currentInterval = 1;
    uint256 public intervalLength = 30 days;
    address public owner;
    /* from this time on tokens may be transfered (after ICO)*/
    uint256 public startTime = 1490112000;
    /* tells if tokens have been burned already */
    bool burned;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* Defines how many tokens of which addresses are locked in which interval*/
    mapping(address => mapping(uint256=>uint256)) public locked;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Lock(address indexed owner, uint256 interval, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract,
    *  locks the owner's final share of tokens for the first 12 intervals. */
    function EdgelessToken() {
        owner = 0x003230BBE64eccD66f62913679C8966Cf9F41166;
        balanceOf[owner] = 500000000;              // Give the owner all initial tokens
        totalSupply = 500000000;                   // Update total supply
        for(uint8 i = 1; i < 13; i++)		   // lock owner's final share of tokens for the first 12 months
        	locked[owner][i] = 50000000;
    }

    /* Send some of your tokens to a given address */
    function transfer(address _to, uint256 _value) returns (bool success){
        if (now < startTime) throw; //check if the crowdsale is already over
        if (locked[msg.sender][getInterval()] >= balanceOf[msg.sender] || balanceOf[msg.sender]-locked[msg.sender][getInterval()] < _value) throw;   // Check if the sender has enough
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender],_value);                     // Subtract from the sender
        balanceOf[_to] = safeAdd(balanceOf[_to],_value);                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
        return true;
    }

    /* Allow another contract or person to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }


    /* A contract or  person attempts to get the tokens of somebody else.
    *  This is only allowed if the token holder approved. */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (now < startTime && _from!=owner) throw; //check if the crowdsale is already over
        if (locked[_from][getInterval()] >= balanceOf[_from] || balanceOf[_from]-locked[_from][getInterval()] < _value) throw;     // Check if the sender has enough
        var _allowance = allowance[_from][msg.sender];
        balanceOf[_from] = safeSub(balanceOf[_from],_value); // Subtract from the sender
        balanceOf[_to] = safeAdd(balanceOf[_to],_value);     // Add the same to the recipient
        allowance[_from][msg.sender] = safeSub(_allowance,_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /* Lock a number of tokens. This means, you will not be able to transfer these tokens until
    *  the start of the next interval. */
    function lock(address holder, uint256 _value) returns (bool success) {
        if(holder==msg.sender||holder==tx.origin){
			uint ci = getInterval();
			uint holderLock = locked[holder][ci];
            locked[holder][ci] = safeAdd(holderLock,_value);
            Lock(holder, ci, _value);
            return true;
        }
    }

    /* Increase the interval, if sufficient time has passed.
    *  When a new interval starts, all tokens are unlocked. */
    function getInterval() returns (uint256 interval){
        if (now > safeAdd(safeMul(currentInterval, intervalLength), startTime)) {
            currentInterval = (now - startTime) / intervalLength + 1;
        }
        return currentInterval;
    }

    /* to be called when ICO is closed, burns the remaining tokens but the owners share (50 000 000) and the ones reserved
    *  for the bounty program (10 000 000).
    *  anybody may burn the tokens after ICO ended, but only once (in case the owner holds more tokens in the future).
    *  this ensures that the owner will not posses a majority of the tokens. */
    function burn(){
    	//if tokens have not been burned already and the ICO ended
    	if(!burned && now>startTime){
    		uint difference = safeSub(balanceOf[owner], 60000000);//checked for overflow above
    		balanceOf[owner] = 60000000;
    		totalSupply = safeSub(totalSupply, difference);
    		burned = true;
    	}
    }

}