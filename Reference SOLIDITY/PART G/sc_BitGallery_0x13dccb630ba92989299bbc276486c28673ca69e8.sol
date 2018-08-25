/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
        return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint a, uint b) internal pure returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

/**
 * @title Heritable
 * @dev The Heritable contract provides ownership transfer capabilities, in the
 * case that the current owner stops "heartbeating". Only the heir can pronounce the
 * owner's death.
 */
contract Heritable is Ownable {
    address public heir;

    // Time window the owner has to notify they are alive.
    uint public heartbeatTimeout;

    // Timestamp of the owner's death, as pronounced by the heir.
    uint public timeOfDeath;

    event HeirChanged(address indexed owner, address indexed newHeir);
    event OwnerHeartbeated(address indexed owner);
    event OwnerProclaimedDead(address indexed owner, address indexed heir, uint timeOfDeath);
    event HeirOwnershipClaimed(address indexed previousOwner, address indexed newOwner);


    /**
    * @dev Throw an exception if called by any account other than the heir's.
    */
    modifier onlyHeir() {
        require(msg.sender == heir);
        _;
    }


    /**
    * @notice Create a new Heritable Contract with heir address 0x0.
    * @param _heartbeatTimeout time available for the owner to notify they are alive,
    * before the heir can take ownership.
    */
    function Heritable(uint _heartbeatTimeout) public {
        setHeartbeatTimeout(_heartbeatTimeout);
    }

    function setHeir(address newHeir) public onlyOwner {
        require(newHeir != owner);
        heartbeat();
        HeirChanged(owner, newHeir);
        heir = newHeir;
    }

    /**
    * @dev set heir = 0x0
    */
    function removeHeir() public onlyOwner {
        heartbeat();
        heir = 0;
    }

    /**
    * @dev Heir can pronounce the owners death. To claim the ownership, they will
    * have to wait for `heartbeatTimeout` seconds.
    */
    function proclaimDeath() public onlyHeir {
        require(owner != heir); // added
        require(ownerLives());
        OwnerProclaimedDead(owner, heir, timeOfDeath);
        timeOfDeath = now;
    }

    /**
    * @dev Owner can send a heartbeat if they were mistakenly pronounced dead.
    */
    function heartbeat() public onlyOwner {
        OwnerHeartbeated(owner);
        timeOfDeath = 0;
    }

    /**
    * @dev Allows heir to transfer ownership only if heartbeat has timed out.
    */
    function claimHeirOwnership() public onlyHeir {
        require(!ownerLives());
        require(now >= timeOfDeath + heartbeatTimeout);
        OwnershipTransferred(owner, heir);
        HeirOwnershipClaimed(owner, heir);
        owner = heir;
        timeOfDeath = 0;
    }

    function setHeartbeatTimeout(uint newHeartbeatTimeout) internal onlyOwner {
        require(ownerLives());
        heartbeatTimeout = newHeartbeatTimeout;
    }

    function ownerLives() internal view returns (bool) {
        return timeOfDeath == 0;
    }
}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <