/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.24;

contract ERC20 {
	function balanceOf(address who) public view returns (uint256);

	function transfer(address to, uint256 value) public returns (bool);

	function transferFrom(address _from, address _to, uint _value) external returns (bool);
}

contract Ownable {
	address public owner = 0x345aCaFA4314Bc2479a3aA7cCf8eb47f223C1d0e;

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
	event Pause();

	event Unpause();

	bool public paused = false;


	/**
        * @dev modifier to allow actions only when the contract IS paused
        */
	modifier whenNotPaused() {
		require(!paused);
		_;
	}

	/**
        * @dev modifier to allow actions only when the contract IS NOT paused
        */
	modifier whenPaused() {
		require(paused);
		_;
	}

	/**
        * @dev called by the owner to pause, triggers stopped state
        */
	function pause() public onlyOwner whenNotPaused {
		paused = true;
		emit Pause();
	}

	/**
        * @dev called by the owner to unpause, returns to normal state
        */
	function unpause() public onlyOwner whenPaused {
		paused = false;
		emit Unpause();
	}
}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <