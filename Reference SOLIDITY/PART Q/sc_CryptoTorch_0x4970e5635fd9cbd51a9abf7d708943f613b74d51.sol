/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
// CryptoTorch Source code
// copyright 2018 CryptoTorch <https://cryptotorch.io>

pragma solidity 0.4.19;


/**
 * @title SafeMath
 * Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
* @title Ownable
 *
 * Owner rights:
 *   - change the name of the contract
 *   - change the name of the token
 *   - change the Proof of Stake difficulty
 *   - pause/unpause the contract
 *   - transfer ownership
 *
 * Owner CANNOT:
 *   - withdrawal funds
 *   - disable withdrawals
 *   - kill the contract
 *   - change the price of tokens
*/
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


/**
 * @title Pausable
 *
 * Pausing the contract will only disable deposits,
 * it will not prevent player dividend withdraws or token sales
 */
contract Pausable is Ownable {
    event OnPause();
    event OnUnpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
        OnPause();
    }

    function unpause() public onlyOwner whenPaused {
        paused = false;
        OnUnpause();
    }
}


/**
* @title ReentrancyGuard
* Helps contracts guard against reentrancy attacks.
* @author Remco Bloemen <