/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.18;


// D.H.A.R.M.A. Initiative Swan Protocol
// The protocol must be executed at least once every 108 minutes
// Failure to do so releases the reward to the last executor
contract Protocol108 {
	// smart contract version
	uint public version = 1;

	// countdown timer reset value
	uint length = 6480;

	// last time protocol was executed
	uint offset;

	// last executor of the protocol
	address public executor;

	// number of times protocol was executed
	// zero value means protocol is in initialization state
	uint public cycle;

	// total value volume passed through
	uint public volume;

	// creates the protocol
	function Protocol108() public {
	}

	// initializes the protocol
	function initialize() public payable {
		// validate protocol state
		assert(cycle == 0);

		// update the protocol
		update();
	}

	// executes the protocol
	function execute() public payable {
		// validate protocol state
		assert(cycle > 0);
		assert(offset + length > now);

		// update the protocol
		update();
	}

	// withdraws the reward to the last executor
	function withdraw() public {
		// validate protocol state
		assert(cycle > 0);
		assert(offset + length <= now);

		// validate input(s)
		require(msg.sender == executor);

		// reset cycle count
		cycle = 0;

		// transfer the reward
		executor.transfer(this.balance);
	}

	// updates the protocol state by
	// updating offset, last executor and cycle count
	function update() private {
		// validate input(s)
		validate(msg.value);

		// update offset (last execution time)
		offset = now;

		// update last executor
		executor = msg.sender;

		// update cycle
		cycle++;

		// update total volume
		volume += msg.value;
	}

	// validates the input sequence of numbers
	// simplest impl (current): positive value
	// proper impl (consideration for future versions): 00..0481516234200..0-like values
	// where any number of leading/trailing zeroes allowed
	// calling this function as part of transaction returns true or throws an exception
	// calling this function as constant returns true or false
	function validate(uint sequence) public constant returns (bool) {
		// validate the sequence
		require(sequence > 0);

		// we won't get here if validation fails
		return true;
	}

	// number of seconds left until protocol terminates
	function countdown() public constant returns (uint) {
		// check if protocol is initialized
		if(cycle == 0) {
			// for uninitialized protocol its equal to length
			return length;
		}

		// for active/terminated protocol calculate the value
		uint n = now;

		// check for negative overflow
		if(offset + length > n) {
			// positive countdown
			return offset + length - n;
		}

		// zero or negative countdown
		return 0;
	}

	// the default payable function, performs one of
	// initialize(), execute() or withdraw() depending on protocol state
	function() public payable {
		if(cycle == 0) {
			// protocol not yet initialized, try to initialize
			initialize();
		}
		else if(offset + length > now) {
			// protocol is eligible for execution, execute
			execute();
		}
		else if(this.balance > 0) {
			// protocol has terminated, withdraw the reward
			withdraw();
		}
		else {
			// invalid protocol state
			revert();
		}
	}

}

// D.H.A.R.M.A. Initiative Swan Protocol version 2
// makes use of the sequence, 4 8 15 16 23 42
contract Protocol108v2 is Protocol108 {
	// smart contract version
	uint public version = 2;

	// creates the protocol, nothing to improve here
	function Protocol108v2() Protocol108() public {
	}

	// validates the input sequence of numbers
	// improvement over version 1 protocol, makes use of the sequence
	function validate(uint sequence) public constant returns (bool) {
		// save the countdown value for reuse inside the function
		uint c = countdown();

		// validate the sequence:
		// require ~0.0048 ETH to initialize the protocol,
		// or to execute it if countdown is four minutes or more
		// require ~4.8 szabo to execute the protocol if
		// countdown is one minute or more
		// require ~4.8 Gwei to execute the protocol if
		// countdown is less then one minute
		require(
			c < 60 && ( // ~4.8+ Shannon
				sequence == 4815162342
				|| sequence == 48151623420
				|| sequence == 481516234200
			) || //
			c < 240 && ( // ~4.8 Szabo
				sequence == 4815162342000
				|| sequence == 48151623420000
				|| sequence == 481516234200000
			) || (
				sequence == 4815162342000000 // ~0.0048 ETH
				|| sequence == 48151623420000000 // ~0.048 ETH
				|| sequence == 481516234200000000 // ~0.48 ETH
				|| sequence == 4815162342000000000 // ~4.8 ETH
				|| sequence == 48151623420000000000 // ~48 ETH
				|| sequence == 481516234200000000000 // ~0.48 Einstein
				// to reduce gas costs we use seqSearch only for big numbers
				|| seqSearch(sequence, 12, 56) != -1 // ~4.8 Einstein - ~4.8*10^55 Einstein
			)
		);

		// we won't get here if validation fails
		return true;
	}

	// checks if sequence can be represented in form of
	// 48151623420..00 where number of trailing zeroes
	// is between offset and offset + length;
	// returns number of trailing zeroes or -1
	// if the sequence cannot be represented in this form
	function seqSearch(uint sequence, uint offset, uint length) private constant returns (int) {
		for(uint i = offset; i < offset + length; i++) {
			if(sequence == 4815162342 * 10 ** i) {
				// found at index i
				return int(i);
			}
		}

		// not found
		return -1;
	}
}