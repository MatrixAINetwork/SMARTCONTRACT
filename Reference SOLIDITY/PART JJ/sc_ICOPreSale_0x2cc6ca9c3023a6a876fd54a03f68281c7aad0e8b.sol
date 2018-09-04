/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract ComplianceService {
	function validate(address _from, address _to, uint256 _amount) public returns (bool allowed) {
		return true;
	}
}

contract ERC20 {
	function balanceOf(address _owner) public constant returns (uint256 balance);
	function transfer(address _to, uint256 _amount) public returns (bool success);
	function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);
	function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
	function totalSupply() public constant returns (uint);
}

contract HardcodedWallets {
	// **** DATA

	address public walletFounder1; // founder #1 wallet, CEO, compulsory
	address public walletFounder2; // founder #2 wallet
	address public walletFounder3; // founder #3 wallet
	address public walletCommunityReserve;	// Distribution wallet
	address public walletCompanyReserve;	// Distribution wallet
	address public walletTeamAdvisors;		// Distribution wallet
	address public walletBountyProgram;		// Distribution wallet


	// **** FUNCTIONS

	/**
	 * @notice Constructor, set up the compliance officer oracle wallet
	 */
	constructor() public {
		// set up the founders' oracle wallets
		walletFounder1             = 0x5E69332F57Ac45F5fCA43B6b007E8A7b138c2938; // founder #1 (CEO) wallet
		walletFounder2             = 0x852f9a94a29d68CB95Bf39065BED6121ABf87607; // founder #2 wallet
		walletFounder3             = 0x0a339965e52dF2c6253989F5E9173f1F11842D83; // founder #3 wallet

		// set up the wallets for distribution of the total supply of tokens
		walletCommunityReserve = 0xB79116a062939534042d932fe5DF035E68576547;
		walletCompanyReserve = 0xA6845689FE819f2f73a6b9C6B0D30aD6b4a006d8;
		walletTeamAdvisors = 0x0227038b2560dF1abf3F8C906016Af0040bc894a;
		walletBountyProgram = 0xdd401Df9a049F6788cA78b944c64D21760757D73;

	}
}

library SafeMath {

	/**
    * @dev Multiplies two numbers, throws on overflow.
    */
	function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
		if (a == 0) {
			return 0;
		}
		c = a * b;
		assert(c / a == b);
		return c;
	}

	/**
    * @dev Integer division of two numbers, truncating the quotient.
    */
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		// uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return a / b;
	}

	/**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	/**
    * @dev Adds two numbers, throws on overflow.
    */
	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
		c = a + b;
		assert(c >= a);
		return c;
	}
}

contract System {
	using SafeMath for uint256;
	
	address owner;
	
	// **** MODIFIERS

	// @notice To limit functions usage to contract owner
	modifier onlyOwner() {
		if (msg.sender != owner) {
			error('System: onlyOwner function called by user that is not owner');
		} else {
			_;
		}
	}

	// **** FUNCTIONS
	
	// @notice Calls whenever an error occurs, logs it or reverts transaction
	function error(string _error) internal {
		revert(_error);
		// in case revert with error msg is not yet fully supported
		//	emit Error(_error);
		// throw;
	}

	// @notice For debugging purposes when using solidity online browser, remix and sandboxes
	function whoAmI() public constant returns (address) {
		return msg.sender;
	}
	
	// @notice Get the current timestamp from last mined block
	function timestamp() public constant returns (uint256) {
		return block.timestamp;
	}
	
	// @notice Get the balance in weis of this contract
	function contractBalance() public constant returns (uint256) {
		return address(this).balance;
	}
	
	// @notice System constructor, defines owner
	constructor() public {
		// This is the constructor, so owner should be equal to msg.sender, and this method should be called just once
		owner = msg.sender;
		
		// make sure owner address is configured
		if(owner == 0x0) error('System constructor: Owner address is 0x0'); // Never should happen, but just in case...
	}
	
	// **** EVENTS

	// @notice A generic error log
	event Error(string _error);

	// @notice For debug purposes
	event DebugUint256(uint256 _data);

}

contract Escrow is System, HardcodedWallets {
	using SafeMath for uint256;

	// **** DATA
	mapping (address => uint256) public deposited;
	uint256 nextStage;

	// Circular reference to ICO contract
	address public addressSCICO;

	// Circular reference to Tokens contract
	address public addressSCTokens;
	Tokens public SCTokens;


	// **** FUNCTIONS

	/**
	 * @notice Constructor, set up the state
	 */
	constructor() public {
		// copy totalSupply from Tokens to save gas
		uint256 totalSupply = 1350000000 ether;


		deposited[this] = totalSupply.mul(50).div(100);
		deposited[walletCommunityReserve] = totalSupply.mul(20).div(100);
		deposited[walletCompanyReserve] = totalSupply.mul(14).div(100);
		deposited[walletTeamAdvisors] = totalSupply.mul(15).div(100);
		deposited[walletBountyProgram] = totalSupply.mul(1).div(100);
	}

	function deposit(uint256 _amount) public returns (bool) {
		// only ICO could deposit
		if (msg.sender != addressSCICO) {
			error('Escrow: not allowed to deposit');
			return false;
		}
		deposited[this] = deposited[this].add(_amount);
		return true;
	}

	/**
	 * @notice Withdraw funds from the tokens contract
	 */
	function withdraw(address _address, uint256 _amount) public onlyOwner returns (bool) {
		if (deposited[_address]<_amount) {
			error('Escrow: not enough balance');
			return false;
		}
		deposited[_address] = deposited[_address].sub(_amount);
		return SCTokens.transfer(_address, _amount);
	}

	/**
	 * @notice Withdraw funds from the tokens contract
	 */
	function fundICO(uint256 _amount, uint8 _stage) public returns (bool) {
		if(nextStage !=_stage) {
			error('Escrow: ICO stage already funded');
			return false;
		}

		if (msg.sender != addressSCICO || tx.origin != owner) {
			error('Escrow: not allowed to fund the ICO');
			return false;
		}
		if (deposited[this]<_amount) {
			error('Escrow: not enough balance');
			return false;
		}
		bool success = SCTokens.transfer(addressSCICO, _amount);
		if(success) {
			deposited[this] = deposited[this].sub(_amount);
			nextStage++;
			emit FundICO(addressSCICO, _amount);
		}
		return success;
	}

	/**
 	* @notice The owner can specify which ICO contract is allowed to transfer tokens while timelock is on
 	*/
	function setMyICOContract(address _SCICO) public onlyOwner {
		addressSCICO = _SCICO;
	}

	/**
 	* @notice Set the tokens contract
 	*/
	function setTokensContract(address _addressSCTokens) public onlyOwner {
		addressSCTokens = _addressSCTokens;
		SCTokens = Tokens(_addressSCTokens);
	}

	/**
	 * @notice Returns balance of given address
	 */
	function balanceOf(address _address) public constant returns (uint256 balance) {
		return deposited[_address];
	}


	// **** EVENTS

	// Triggered when an investor buys some tokens directly with Ethers
	event FundICO(address indexed _addressICO, uint256 _amount);


}

contract RefundVault is HardcodedWallets, System {
	using SafeMath for uint256;

	enum State { Active, Refunding, Closed }


	// **** DATA

	mapping (address => uint256) public deposited;
	mapping (address => uint256) public tokensAcquired;
	State public state;

	// Circular reference to ICO contract
	address public addressSCICO;
	
	

	// **** MODIFIERS

	// @notice To limit functions usage to contract owner
	modifier onlyICOContract() {
		if (msg.sender != addressSCICO) {
			error('RefundVault: onlyICOContract function called by user that is not ICOContract');
		} else {
			_;
		}
	}


	// **** FUNCTIONS

	/**
	 * @notice Constructor, set up the state
	 */
	constructor() public {
		state = State.Active;
	}

	function weisDeposited(address _investor) public constant returns (uint256) {
		return deposited[_investor];
	}

	function getTokensAcquired(address _investor) public constant returns (uint256) {
		return tokensAcquired[_investor];
	}

	/**
	 * @notice Registers how many tokens have each investor and how many ethers they spent (When ICOing through PayIn this function is not called)
	 */
	function deposit(address _investor, uint256 _tokenAmount) onlyICOContract public payable returns (bool) {
		if (state != State.Active) {
			error('deposit: state != State.Active');
			return false;
		}
		deposited[_investor] = deposited[_investor].add(msg.value);
		tokensAcquired[_investor] = tokensAcquired[_investor].add(_tokenAmount);

		return true;
	}

	/**
	 * @notice When ICO finalizes funds are transferred to founders' wallets
	 */
	function close() onlyICOContract public returns (bool) {
		if (state != State.Active) {
			error('close: state != State.Active');
			return false;
		}
		state = State.Closed;

		walletFounder1.transfer(address(this).balance.mul(33).div(100)); // Forwards 33% to 1st founder wallet
		walletFounder2.transfer(address(this).balance.mul(50).div(100)); // Forwards 33% to 2nd founder wallet
		walletFounder3.transfer(address(this).balance);                  // Forwards 34% to 3rd founder wallet

		emit Closed(); // Event log

		return true;
	}

	/**
	 * @notice When ICO finalizes owner toggles refunding
	 */
	function enableRefunds() onlyICOContract public returns (bool) {
		if (state != State.Active) {
			error('enableRefunds: state != State.Active');
			return false;
		}
		state = State.Refunding;

		emit RefundsEnabled(); // Event log

		return true;
	}

	/**
	 * @notice ICO Smart Contract can call this function for the investor to refund
	 */
	function refund(address _investor) onlyICOContract public returns (bool) {
		if (state != State.Refunding) {
			error('refund: state != State.Refunding');
			return false;
		}
		if (deposited[_investor] == 0) {
			error('refund: no deposit to refund');
			return false;
		}
		uint256 depositedValue = deposited[_investor];
		deposited[_investor] = 0;
		tokensAcquired[_investor] = 0; // tokens should have been returned previously to the ICO
		_investor.transfer(depositedValue);

		emit Refunded(_investor, depositedValue); // Event log

		return true;
	}

	/**
	 * @notice To allow ICO contracts to check whether RefundVault is ready to refund investors
	 */
	function isRefunding() public constant returns (bool) {
		return (state == State.Refunding);
	}

	/**
	 * @notice The owner must specify which ICO contract is allowed call for refunds
	 */
	function setMyICOContract(address _SCICO) public onlyOwner {
		require(address(this).balance == 0);
		addressSCICO = _SCICO;
	}



	// **** EVENTS

	// Triggered when ICO contract closes the vault and forwards funds to the founders' wallets
	event Closed();

	// Triggered when ICO contract initiates refunding
	event RefundsEnabled();

	// Triggered when an investor claims (through ICO contract) and gets its funds
	event Refunded(address indexed beneficiary, uint256 weiAmount);
}

contract Haltable is System {
	bool public halted;
	
	// **** MODIFIERS

	modifier stopInEmergency {
		if (halted) {
			error('Haltable: stopInEmergency function called and contract is halted');
		} else {
			_;
		}
	}

	modifier onlyInEmergency {
		if (!halted) {
			error('Haltable: onlyInEmergency function called and contract is not halted');
		} {
			_;
		}
	}

	// **** FUNCTIONS
	
	// called by the owner on emergency, triggers stopped state
	function halt() external onlyOwner {
		halted = true;
		emit Halt(true, msg.sender, timestamp()); // Event log
	}

	// called by the owner on end of emergency, returns to normal state
	function unhalt() external onlyOwner onlyInEmergency {
		halted = false;
		emit Halt(false, msg.sender, timestamp()); // Event log
	}
	
	// **** EVENTS
	// @notice Triggered when owner halts contract
	event Halt(bool _switch, address _halter, uint256 _timestamp);
}

contract ICO is HardcodedWallets, Haltable {
	// **** DATA

	// Linked Contracts
	Tokens public SCTokens;	// The token being sold
	RefundVault public SCRefundVault;	// The vault for softCap refund
	Whitelist public SCWhitelist;	// The whitelist of allowed wallets to buy tokens on ICO
	Escrow public SCEscrow; // Escrow service

	// start and end timestamps where investments are allowed (both inclusive)
	uint256 public startTime;
	uint256 public endTime;
	bool public isFinalized = false;

	uint256 public weisPerBigToken; // how many weis a buyer pays to get a big token (10^18 tokens)
	uint256 public weisPerEther;
	uint256 public tokensPerEther; // amount of tokens with multiplier received on ICO when paying with 1 Ether, discounts included
	uint256 public bigTokensPerEther; // amount of tokens w/omultiplier received on ICO when paying with 1 Ether, discounts included

	uint256 public weisRaised; // amount of Weis raised
	uint256 public etherHardCap; // Max amount of Ethers to raise
	uint256 public tokensHardCap; // Max amount of Tokens for sale
	uint256 public weisHardCap; // Max amount of Weis raised
	uint256 public weisMinInvestment; // Min amount of Weis to perform a token sale
	uint256 public etherSoftCap; // Min amount of Ethers for sale to ICO become successful
	uint256 public tokensSoftCap; // Min amount of Tokens for sale to ICO become successful
	uint256 public weisSoftCap; // Min amount of Weis raised to ICO become successful

	uint256 public discount; // Applies to token price when investor buys tokens. It is a number between 0-100
	uint256 discountedPricePercentage;
	uint8 ICOStage;



	// **** MODIFIERS

	
	// **** FUNCTIONS

	// fallback function can be used to buy tokens
	function () payable public {
		buyTokens();
	}
	

	/**
	 * @notice Token purchase function direclty through ICO Smart Contract. Beneficiary = msg.sender
	 */
	function buyTokens() public stopInEmergency payable returns (bool) {
		if (msg.value == 0) {
			error('buyTokens: ZeroPurchase');
			return false;
		}

		uint256 tokenAmount = buyTokensLowLevel(msg.sender, msg.value);

		// Send the investor's ethers to the vault
		if (!SCRefundVault.deposit.value(msg.value)(msg.sender, tokenAmount)) {
			revert('buyTokens: unable to transfer collected funds from ICO contract to Refund Vault'); // Revert needed to refund investor on error
			// error('buyTokens: unable to transfer collected funds from ICO contract to Refund Vault');
			// return false;
		}

		emit BuyTokens(msg.sender, msg.value, tokenAmount); // Event log

		return true;
	}

	/**
	 * @notice Token purchase function through Oracle PayIn by MarketPay.io API
	 */
	/* // Deactivated to save ICO contract deployment gas cost
	function buyTokensOraclePayIn(address _beneficiary, uint256 _weisAmount) public onlyCustodyFiat stopInEmergency returns (bool) {
		uint256 tokenAmount = buyTokensLowLevel(_beneficiary, _weisAmount);

		emit BuyTokensOraclePayIn(msg.sender, _beneficiary, _weisAmount, tokenAmount); // Event log

		return true;
	}*/

	/**
	 * @notice Low level token purchase function, w/o ether transfer from investor
	 */
	function buyTokensLowLevel(address _beneficiary, uint256 _weisAmount) private stopInEmergency returns (uint256 tokenAmount) {
		if (_beneficiary == 0x0) {
			revert('buyTokensLowLevel: _beneficiary == 0x0'); // Revert needed to refund investor on error
			// error('buyTokensLowLevel: _beneficiary == 0x0');
			// return 0;
		}
		if (timestamp() < startTime || timestamp() > endTime) {
			revert('buyTokensLowLevel: Not withinPeriod'); // Revert needed to refund investor on error
			// error('buyTokensLowLevel: Not withinPeriod');
			// return 0;
		}
		if (!SCWhitelist.isInvestor(_beneficiary)) {
			revert('buyTokensLowLevel: Investor is not registered on the whitelist'); // Revert needed to refund investor on error
			// error('buyTokensLowLevel: Investor is not registered on the whitelist');
			// return 0;
		}
		if (isFinalized) {
			revert('buyTokensLowLevel: ICO is already finalized'); // Revert needed to refund investor on error
			// error('buyTokensLowLevel: ICO is already finalized');
			// return 0;
		}

		// Verify whether enough ether has been sent to buy the min amount of investment
		if (_weisAmount < weisMinInvestment) {
			revert('buyTokensLowLevel: Minimal investment not reached. Not enough ethers to perform the minimal purchase'); // Revert needed to refund investor on error
			// error('buyTokensLowLevel: Minimal investment not reached. Not enough ethers to perform the minimal purchase');
			// return 0;
		}

		// Verify whether there are enough tokens to sell
		if (weisRaised.add(_weisAmount) > weisHardCap) {
			revert('buyTokensLowLevel: HardCap reached. Not enough tokens on ICO contract to perform this purchase'); // Revert needed to refund investor on error
			// error('buyTokensLowLevel: HardCap reached. Not enough tokens on ICO contract to perform this purchase');
			// return 0;
		}

		// Calculate token amount to be sold
		tokenAmount = _weisAmount.mul(weisPerEther).div(weisPerBigToken);

		// Applying discount
		tokenAmount = tokenAmount.mul(100).div(discountedPricePercentage);

		// Update state
		weisRaised = weisRaised.add(_weisAmount);

		// Send the tokens to the investor
		if (!SCTokens.transfer(_beneficiary, tokenAmount)) {
			revert('buyTokensLowLevel: unable to transfer tokens from ICO contract to beneficiary'); // Revert needed to refund investor on error
			// error('buyTokensLowLevel: unable to transfer tokens from ICO contract to beneficiary');
			// return 0;
		}
		emit BuyTokensLowLevel(msg.sender, _beneficiary, _weisAmount, tokenAmount); // Event log

		return tokenAmount;
	}

	/**
	 * @return true if ICO event has ended
	 */
	/* // Deactivated to save ICO contract deployment gas cost
	function hasEnded() public constant returns (bool) {
		return timestamp() > endTime;
	}*/

	/**
	 * @notice Called by owner to alter the ICO deadline
	 */
	function updateEndTime(uint256 _endTime) onlyOwner public returns (bool) {
		endTime = _endTime;

		emit UpdateEndTime(_endTime); // Event log
	}


	/**
	 * @notice Must be called by owner before or after ICO ends, to check whether soft cap is reached and transfer collected funds
	 */
	function finalize(bool _forceRefund) onlyOwner public returns (bool) {
		if (isFinalized) {
			error('finalize: ICO is already finalized.');
			return false;
		}

		if (weisRaised >= weisSoftCap && !_forceRefund) {
			if (!SCRefundVault.close()) {
				error('finalize: SCRefundVault.close() failed');
				return false;
			}
		} else {
			if (!SCRefundVault.enableRefunds()) {
				error('finalize: SCRefundVault.enableRefunds() failed');
				return false;
			}
			if(_forceRefund) {
				emit ForceRefund(); // Event log
			}
		}

		// Move remaining ICO tokens back to the Escrow
		uint256 balanceAmount = SCTokens.balanceOf(this);
		if (!SCTokens.transfer(address(SCEscrow), balanceAmount)) {
			error('finalize: unable to return remaining ICO tokens');
			return false;
		}
		// Adjust Escrow balance correctly
		if(!SCEscrow.deposit(balanceAmount)) {
			error('finalize: unable to return remaining ICO tokens');
			return false;
		}

		isFinalized = true;

		emit Finalized(); // Event log

		return true;
	}

	/**
	 * @notice If ICO is unsuccessful, investors can claim refunds here
	 */
	function claimRefund() public stopInEmergency returns (bool) {
		if (!isFinalized) {
			error('claimRefund: ICO is not yet finalized.');
			return false;
		}

		if (!SCRefundVault.isRefunding()) {
			error('claimRefund: RefundVault state != State.Refunding');
			return false;
		}

		// Before transfering the ETHs to the investor, get back the tokens bought on ICO
		uint256 tokenAmount = SCRefundVault.getTokensAcquired(msg.sender);
		emit GetBackTokensOnRefund(msg.sender, this, tokenAmount); // Event Log
		if (!SCTokens.refundTokens(msg.sender, tokenAmount)) {
			error('claimRefund: unable to transfer investor tokens to ICO contract before refunding');
			return false;
		}

		if (!SCRefundVault.refund(msg.sender)) {
			error('claimRefund: SCRefundVault.refund() failed');
			return false;
		}

		return true;
	}

	function fundICO() public onlyOwner {
		if (!SCEscrow.fundICO(tokensHardCap, ICOStage)) {
			revert('ICO funding failed');
		}
	}




// **** EVENTS

	// Triggered when an investor buys some tokens directly with Ethers
	event BuyTokens(address indexed _purchaser, uint256 _value, uint256 _amount);

	// Triggered when Owner says some investor has requested tokens on PayIn MarketPay.io API
	event BuyTokensOraclePayIn(address indexed _purchaser, address indexed _beneficiary, uint256 _weisAmount, uint256 _tokenAmount);

	// Triggered when an investor buys some tokens directly with Ethers or through payin Oracle
	event BuyTokensLowLevel(address indexed _purchaser, address indexed _beneficiary, uint256 _value, uint256 _amount);

	// Triggered when an SC owner request to end the ICO, transferring funds to founders wallet or ofeering them as a refund
	event Finalized();

	// Triggered when an SC owner request to end the ICO and allow transfer of funds to founders wallets as a refund
	event ForceRefund();

	// Triggered when RefundVault is created
	//event AddressSCRefundVault(address _scAddress);

	// Triggered when investor refund and their tokens got back to ICO contract
	event GetBackTokensOnRefund(address _from, address _to, uint256 _amount);

	// Triggered when Owner updates ICO deadlines
	event UpdateEndTime(uint256 _endTime);
}

contract ICOPreSale is ICO {
	/**
	 * @notice ICO constructor. Definition of ICO parameters and subcontracts autodeployment
	 */
	constructor(address _SCEscrow, address _SCTokens, address _SCWhitelist, address _SCRefundVault) public {
		if (_SCTokens == 0x0) {
			revert('Tokens Constructor: _SCTokens == 0x0');
		}
		if (_SCWhitelist == 0x0) {
			revert('Tokens Constructor: _SCWhitelist == 0x0');
		}
		if (_SCRefundVault == 0x0) {
			revert('Tokens Constructor: _SCRefundVault == 0x0');
		}
		
		SCTokens = Tokens(_SCTokens);
		SCWhitelist = Whitelist(_SCWhitelist);
		SCRefundVault = RefundVault(_SCRefundVault);
		
		weisPerEther = 1 ether; // 10e^18 multiplier

		// Deadline
		startTime = timestamp();
		endTime = timestamp().add(24 days); // from 8th June to 2th July 2018

		// Token Price
		bigTokensPerEther = 7500; // tokens (w/o multiplier) got for 1 ether
		tokensPerEther = bigTokensPerEther.mul(weisPerEther); // tokens (with multiplier) got for 1 ether

		discount = 45; // pre-sale 45%
		discountedPricePercentage = 100;
		discountedPricePercentage = discountedPricePercentage.sub(discount);

		weisMinInvestment = weisPerEther.mul(1);

		// 2018-05-10: 