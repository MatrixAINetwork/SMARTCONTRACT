/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
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
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {

    function Destructible() public payable { }

    /**
     * @dev Transfers the current balance to the owner and terminates the contract.
     */
    function destroy() onlyOwner public {
        selfdestruct(owner);
    }

    function destroyAndSend(address _recipient) onlyOwner public {
        selfdestruct(_recipient);
    }
}

/**
 * @title PullPayment
 * @dev Base contract supporting async send for pull payments. Inherit from this
 * contract and use asyncSend instead of send.
 */
contract PullPayment {
    using SafeMath for uint256;

    mapping(address => uint256) public payments;
    uint256 public totalPayments;

    /**
     * @dev Called by the payer to store the sent amount as credit to be pulled.
     * @param dest The destination address of the funds.
     * @param amount The amount to transfer.
     */
    function asyncSend(address dest, uint256 amount) internal {
        payments[dest] = payments[dest].add(amount);
        totalPayments = totalPayments.add(amount);
    }

    /**
     * @dev withdraw accumulated balance, called by payee.
     */
    function withdrawPayments() public {
        address payee = msg.sender;
        uint256 payment = payments[payee];

        require(payment != 0);
        require(this.balance >= payment);

        totalPayments = totalPayments.sub(payment);
        payments[payee] = 0;

        assert(payee.send(payment));
    }
}

/**
 * @title Bounty
 * @dev This bounty will pay out to a researcher if they break invariant logic of the contract.
 */
contract Bounty is PullPayment, Destructible {
    bool public claimed;
    mapping(address => address) public researchers;

    event TargetCreated(address createdAddress);

    /**
     * @dev Fallback function allowing the contract to receive funds, if they haven't already been claimed.
     */
    function() external payable {
        require(!claimed);
    }

    /**
     * @dev Create and deploy the target contract (extension of Target contract), and sets the
     * msg.sender as a researcher
     * @return A target contract
     */
    function createTarget() public returns(Target) {
        Target target = Target(deployContract());
        researchers[target] = msg.sender;
        TargetCreated(target);
        return target;
    }

    /**
     * @dev Internal function to deploy the target contract.
     * @return A target contract address
     */
    function deployContract() internal returns(address);

    /**
     * @dev Sends the contract funds to the researcher that proved the contract is broken.
     * @param target contract
     */
    function claim(Target target) public {
        address researcher = researchers[target];
        require(researcher != 0);
        // Check Target contract invariants
        require(!target.checkInvariant());
        asyncSend(researcher, this.balance);
        claimed = true;
    }
}


/**
 * @title Target
 * @dev Your main contract should inherit from this class and implement the checkInvariant method.
 */
contract Target {
    /**
     * @dev Checks all values a contract assumes to be true all the time. If this function returns
     * false, the contract is broken in some way and is in an inconsistent state.
     * In order to win the bounty, security researchers will try to cause this broken state.
     * @return True if all invariant values are correct, false otherwise.
     */
    function checkInvariant() public returns(bool);
}

/*
*  @title PricingStrategy
*  An abstract class for all Pricing Strategy contracts.
*/
contract PricingStrategy is Ownable {
    /*
    * @dev Number sold tokens for current strategy
    */
    uint256 public totalSoldTokens = 0;
    uint256 public weiRaised = 0;
    /*
    * @dev Count number of tokens with bonuses
    * @param _value uint256 Value in ether from investor
    * @return uint256 Return number of tokens for investor
    */
    function countTokens(uint256 _value) internal returns (uint256 tokensAndBonus);

    /*
    * @dev Summing sold of tokens
    * @param _tokensAndBonus uint256 Number tokens for current sale in a tranche
    */
    function soldInTranche(uint256 _tokensAndBonus) internal;

    /*
    * @dev Check required of tokens in the tranche
    * @param _requiredTokens uint256 Number required of tokens
    * @return boolean Return true if count of tokens is available
    */
    function getFreeTokensInTranche(uint256 _requiredTokens) internal constant returns (bool);

    function isNoEmptyTranches() public constant returns(bool);
}

contract  TranchePricingStrategy is PricingStrategy, Target {
    using SafeMath for uint256;

    uint256 public tokensCap;
    uint256 public capInWei;

    /*
    * Define bonus schedule of tranches.
    */
    struct BonusSchedule {
        uint256 bonus; // Bonus rate for current tranche
        uint valueForTranche; // Amount of tokens available for the current period
        uint rate; // How much tokens for one ether
    }

    //event for testing
    event TokenForInvestor(uint256 _token, uint256 _tokenAndBonus, uint256 indexOfperiod);

    uint tranchesCount = 0;
    uint MAX_TRANCHES = 50;

    //Store BonusStrategy in a fixed array, so that it can be seen in a blockchain explorer
    BonusSchedule[] public tranches;

    /*
    * @dev Constructor
    * @param _bonuses uint256[] Bonuses in tranches
    * @param _valueForTranches uint[] Value of tokens in tranches
    * @params _rates uint[] Rates for tranches
    */
    function TranchePricingStrategy(uint256[] _bonuses, uint[] _valueForTranches, uint[] _rates,
        uint256 _capInWei, uint256 _tokensCap) public {

        tokensCap = _tokensCap;
        capInWei = _capInWei;
        require(_bonuses.length == _valueForTranches.length && _valueForTranches.length == _rates.length);
        require(_bonuses.length <= MAX_TRANCHES);

        tranchesCount = _bonuses.length;

        for (uint i = 0; i < _bonuses.length; i++) {
                tranches.push(BonusSchedule({
                bonus: _bonuses[i],
                valueForTranche: _valueForTranches[i],
                rate: _rates[i]
            }));
        }
    }

    /*
    * @dev Count number of tokens with bonuses
    * @param _value uint256 Value in ether
    * @return uint256 Return number of tokens for an investor
    */
    function countTokens(uint256 _value) internal returns (uint256 tokensAndBonus) {
        uint256 indexOfTranche = defineTranchePeriod();

        require(indexOfTranche != MAX_TRANCHES + 1);

        BonusSchedule currentTranche = tranches[indexOfTranche];
        uint256 etherInWei = 1e18;

        uint256 bonusRate = currentTranche.bonus;
        uint val = msg.value * etherInWei;
        uint256 oneTokenInWei = etherInWei/currentTranche.rate;
        uint tokens = val / oneTokenInWei;
        uint256 bonusToken = tokens.mul(bonusRate).div(100);
        tokensAndBonus = tokens.add(bonusToken);

        soldInTranche(tokensAndBonus);
        weiRaised += _value;
        TokenForInvestor(tokens, tokensAndBonus, indexOfTranche);
        return tokensAndBonus;
    }

    /*
    * @dev Check required of tokens in the tranche
    * @param _requiredTokens uint256 Number of tokens
    * @return boolean Return true if count of tokens is available
    */
    function getFreeTokensInTranche(uint256 _requiredTokens) internal constant returns (bool) {
        bool hasTokens = false;
        uint256 indexOfTranche = defineTranchePeriod();
        hasTokens = tranches[indexOfTranche].valueForTranche > _requiredTokens;

        return hasTokens;
    }

    /*
    * @dev Summing sold of tokens
    * @param _tokensAndBonus uint256 Number tokens for current sale
    */
    function soldInTranche(uint256 _tokensAndBonus) internal {
        uint256 indexOfTranche = defineTranchePeriod();
        require(tranches[indexOfTranche].valueForTranche >= _tokensAndBonus);
        tranches[indexOfTranche].valueForTranche = tranches[indexOfTranche].valueForTranche.sub(_tokensAndBonus);
        totalSoldTokens = totalSoldTokens.add(_tokensAndBonus);
    }

    /*
    * @dev Check sum of the tokens for sale in the tranches in the crowdsale time
    */
    function isNoEmptyTranches() public constant returns(bool) {
        uint256 sumFreeTokens = 0;
        for (uint i = 0; i < tranches.length; i++) {
            sumFreeTokens = sumFreeTokens.add(tranches[i].valueForTranche);
        }
        bool isValid = sumFreeTokens > 0;
        return isValid;
    }

    /*
    * @dev get index of tranche
    * @return uint256 number of current tranche in array tranches
    */
    function defineTranchePeriod() internal constant returns (uint256) {
        for (uint256 i = 0; i < tranches.length; i++) {
            if (tranches[i].valueForTranche > 0) {
                return i;
            }
        }
        return MAX_TRANCHES + 1;
    }

    /* Now we have the Bounty code, as the contract is Bounty.
    * @dev Function to check if the contract has been compromised.
    */
    function checkInvariant() public returns(bool) {

        uint256 tranchePeriod = defineTranchePeriod();
        bool isTranchesDone = tranchePeriod == MAX_TRANCHES + 1;
        bool isTokensCapReached = tokensCap == totalSoldTokens;
        bool isWeiCapReached = weiRaised == capInWei;

        bool isNoCapReached = isTranchesDone &&
            (!isTokensCapReached || !isWeiCapReached);

        bool isExceededCap = !isTranchesDone &&
            (isTokensCapReached || isWeiCapReached);

        // Check the compromised flag.
        if (isNoCapReached || isExceededCap) {
            return false;
        }
        return true;
    }

    function payContract() payable {
        countTokens(msg.value);
    }
}

contract MowjowBounty is Bounty {

    uint256[] public rates;
    uint256[] public bonuses;
    uint256[] public valueForTranches;
    uint256 capInWei;
    uint256 capInTokens;

    function MowjowBounty (uint256[] _bonuses, uint256[] _valueForTranches,
        uint256[] _rates, uint256 _capInWei, uint256 _capInTokens) public {

        bonuses = _bonuses;
        valueForTranches = _valueForTranches;
        rates = _rates;
        capInWei = _capInWei;
        capInTokens = _capInTokens;
    }

    function deployContract() internal returns(address) {
        return new TranchePricingStrategy(bonuses, valueForTranches, rates, capInWei, capInTokens);
    }

}