/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

// Original code of smart contract on github: 

// Standart libary from "Open Zeppelin"
library SafeMath {

    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}

// Standart contract from "Open Zeppelin"
contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) constant public returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

// Standart contract from "Open Zeppelin"
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant public returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Describing contract with owner.
contract Owned {

    address public owner;

    address public newOwner;

    function Owned() public payable {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    function changeOwner(address _owner) onlyOwner public {
        require(_owner != 0);
        newOwner = _owner;
    }

    function confirmOwner() public {
        require(newOwner == msg.sender);
        owner = newOwner;
        delete newOwner;
    }
}

// Describing Bloccking modifier which founds on time block.
contract Blocked {

	// Time till modifier block
    uint public blockedUntil;

    modifier unblocked {
        require(now > blockedUntil);
        _;
    }
}

// contract which discribes contract of token which founds on ERC20 and implement balanceOf function.
contract BalancingToken is ERC20 {
    mapping (address => uint256) public balances;      //!< array of all balances

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
}

// Contract for dividend tokens. This contract describes implementation for tokens which can be used for dividends
contract DividendToken is BalancingToken, Blocked, Owned {

    using SafeMath for uint256;

	// Event for dividends when somebody takes dividends it will raised.
    event DividendReceived(address indexed dividendReceiver, uint256 dividendValue);

	// mapping for alloweds and amounts.
    mapping (address => mapping (address => uint256)) public allowed;

	// full reward amount for one round.
	// this value is defined by ether amount on DividendToken contract on moment when dividend payments starts.
    uint public totalReward;
	// time when last time dividends started pay.
    uint public lastDivideRewardTime;

    // Fix for the ERC20 short address attack
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }

	// This modifier checkes if reward payment is over.
    modifier rewardTimePast() {
        require(now > lastDivideRewardTime + rewardDays * 1 days);
        _;
    }

	// Structure is for Token holder which contains information about all token holders with balances and times.
    struct TokenHolder {
        uint256 balance;
        uint    balanceUpdateTime;
        uint    rewardWithdrawTime;
    }

	// mapping for token holders.
    mapping(address => TokenHolder) holders;

	// the number of days for rewards.
    uint public rewardDays = 0;

	// standard method for transfer from ERC20.
    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) unblocked public returns (bool) {
        return transferSimple(_to, _value);
    }

	// internal implementation for transfer with recounting rewards.
    function transferSimple(address _to, uint256 _value) internal returns (bool) {
        beforeBalanceChanges(msg.sender);
        beforeBalanceChanges(_to);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

	// standard method for transferFrom from ERC20. 
    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) unblocked public returns (bool) {
        beforeBalanceChanges(_from);
        beforeBalanceChanges(_to);
        uint256 _allowance = allowed[_from][msg.sender];
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

	// standard method for transferFrom from ERC20. 
    function approve(address _spender, uint256 _value) onlyPayloadSize(2 * 32) unblocked public returns (bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

	// standard method for transferFrom from ERC20. 
    function allowance(address _owner, address _spender) onlyPayloadSize(2 * 32) unblocked constant public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

	// THis method returns the amount of caller's reward.
	// Caller gets ether which should be given to him.
    function reward() constant public returns (uint256) {
        if (holders[msg.sender].rewardWithdrawTime >= lastDivideRewardTime) {
            return 0;
        }
        uint256 balance;
        if (holders[msg.sender].balanceUpdateTime <= lastDivideRewardTime) {
            balance = balances[msg.sender];
        } else {
            balance = holders[msg.sender].balance;
        }
        return totalReward.mul(balance).div(totalSupply);
    }

	// This method shoud be called when caller wants take dividends reward.
	// Caller gets ether which should be given to him.
    function withdrawReward() public returns (uint256) {
        uint256 rewardValue = reward();
        if (rewardValue == 0) {
            return 0;
        }
        if (balances[msg.sender] == 0) {
            // garbage collector
            delete holders[msg.sender];
        } else {
            holders[msg.sender].rewardWithdrawTime = now;
        }
        require(msg.sender.call.gas(3000000).value(rewardValue)());
        DividendReceived(msg.sender, rewardValue);
        return rewardValue;
    }

    // Divide up reward and make it accesible for withdraw
	// Need to provide the number of days for reward. It can be less then 15 days and more then 45 days.
    function divideUpReward(uint inDays) rewardTimePast onlyOwner external payable {
        require(inDays >= 15 && inDays <= 45);
        lastDivideRewardTime = now;
        rewardDays = inDays;
        totalReward = this.balance;
    }
	
	// Take left reward after reward period.
    function withdrawLeft() rewardTimePast onlyOwner external {
        require(msg.sender.call.gas(3000000).value(this.balance)());
    }

	// recount reward of somebody.
    function beforeBalanceChanges(address _who) public {
        if (holders[_who].balanceUpdateTime <= lastDivideRewardTime) {
            holders[_who].balanceUpdateTime = now;
            holders[_who].balance = balances[_who];
        }
    }
}

// Final contract for RENT coin.
contract RENTCoin is DividendToken {

    string public constant name = "RentAway Coin";

    string public constant symbol = "RTW";

    uint32 public constant decimals = 18;

    function RENTCoin(uint256 initialSupply, uint unblockTime) public {
        totalSupply = initialSupply;
        balances[owner] = totalSupply;
        blockedUntil = unblockTime;
		Transfer(this, owner, totalSupply);
    }

	// Uses for overwork manual Blocked contract for ICO time.
	// After ICO it is not needed.
    function manualTransfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) onlyOwner public returns (bool) {
        return transferSimple(_to, _value);
    }
}