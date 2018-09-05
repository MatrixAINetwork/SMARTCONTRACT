/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract AbstractStarbaseToken {
    function isFundraiser(address fundraiserAddress) public returns (bool);
    function company() public returns (address);
    function allocateToCrowdsalePurchaser(address to, uint256 value) public returns (bool);
    function allocateToMarketingSupporter(address to, uint256 value) public returns (bool);
}

contract AbstractStarbaseCrowdsale {
    function startDate() constant returns (uint256) {}
    function endedAt() constant returns (uint256) {}
    function isEnded() constant returns (bool);
    function totalRaisedAmountInCny() constant returns (uint256);
    function numOfPurchasedTokensOnCsBy(address purchaser) constant returns (uint256);
    function numOfPurchasedTokensOnEpBy(address purchaser) constant returns (uint256);
}

contract StarbaseEarlyPurchase {
    /*
     *  Constants
     */
    string public constant PURCHASE_AMOUNT_UNIT = 'CNY';    // Chinese Yuan
    string public constant PURCHASE_AMOUNT_RATE_REFERENCE = 'http://www.xe.com/currencytables/';
    uint public constant PURCHASE_AMOUNT_CAP = 9000000;

    /*
     *  Types
     */
    struct EarlyPurchase {
        address purchaser;
        uint amount;        // CNY based amount
        uint purchasedAt;   // timestamp
    }

    /*
     *  External contracts
     */
    AbstractStarbaseCrowdsale public starbaseCrowdsale;

    /*
     *  Storage
     */
    address public owner;
    EarlyPurchase[] public earlyPurchases;
    uint public earlyPurchaseClosedAt;

    /*
     *  Modifiers
     */
    modifier noEther() {
        if (msg.value > 0) {
            throw;
        }
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

    modifier onlyBeforeCrowdsale() {
        if (address(starbaseCrowdsale) != 0 &&
            starbaseCrowdsale.startDate() > 0)
        {
            throw;
        }
        _;
    }

    modifier onlyEarlyPurchaseTerm() {
        if (earlyPurchaseClosedAt > 0) {
            throw;
        }
        _;
    }

    /*
     *  Contract functions
     */
    /// @dev Returns early purchased amount by purchaser's address
    /// @param purchaser Purchaser address
    function purchasedAmountBy(address purchaser)
        external
        constant
        noEther
        returns (uint amount)
    {
        for (uint i; i < earlyPurchases.length; i++) {
            if (earlyPurchases[i].purchaser == purchaser) {
                amount += earlyPurchases[i].amount;
            }
        }
    }

    /// @dev Returns total amount of raised funds by Early Purchasers
    function totalAmountOfEarlyPurchases()
        constant
        noEther
        returns (uint totalAmount)
    {
        for (uint i; i < earlyPurchases.length; i++) {
            totalAmount += earlyPurchases[i].amount;
        }
    }

    /// @dev Returns number of early purchases
    function numberOfEarlyPurchases()
        external
        constant
        noEther
        returns (uint)
    {
        return earlyPurchases.length;
    }

    /// @dev Append an early purchase log
    /// @param purchaser Purchaser address
    /// @param amount Purchase amount
    /// @param purchasedAt Timestamp of purchased date
    function appendEarlyPurchase(address purchaser, uint amount, uint purchasedAt)
        external
        noEther
        onlyOwner
        onlyBeforeCrowdsale
        onlyEarlyPurchaseTerm
        returns (bool)
    {
        if (amount == 0 ||
            totalAmountOfEarlyPurchases() + amount > PURCHASE_AMOUNT_CAP)
        {
            return false;
        }

        if (purchasedAt == 0 || purchasedAt > now) {
            throw;
        }

        earlyPurchases.push(EarlyPurchase(purchaser, amount, purchasedAt));
        return true;
    }

    /// @dev Close early purchase term
    function closeEarlyPurchase()
        external
        noEther
        onlyOwner
        returns (bool)
    {
        earlyPurchaseClosedAt = now;
    }

    /// @dev Setup function sets external contract's address
    /// @param starbaseCrowdsaleAddress Token address
    function setup(address starbaseCrowdsaleAddress)
        external
        noEther
        onlyOwner
        returns (bool)
    {
        if (address(starbaseCrowdsale) == 0) {
            starbaseCrowdsale = AbstractStarbaseCrowdsale(starbaseCrowdsaleAddress);
            return true;
        }
        return false;
    }

    /// @dev Contract constructor function
    function StarbaseEarlyPurchase() noEther {
        owner = msg.sender;
    }

    /// @dev Fallback function always fails
    function () {
        throw;
    }
}


contract StarbaseEarlyPurchaseAmendment {
    /*
     *  Events
     */
    event EarlyPurchaseInvalidated(uint epIdx);
    event EarlyPurchaseAmended(uint epIdx);

    /*
     *  External contracts
     */
    AbstractStarbaseCrowdsale public starbaseCrowdsale;
    StarbaseEarlyPurchase public starbaseEarlyPurchase;

    /*
     *  Storage
     */
    address public owner;
    uint[] public invalidEarlyPurchaseIndexes;
    uint[] public amendedEarlyPurchaseIndexes;
    mapping (uint => StarbaseEarlyPurchase.EarlyPurchase) public amendedEarlyPurchases;

    /*
     *  Modifiers
     */
    modifier noEther() {
        if (msg.value > 0) {
            throw;
        }
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

    modifier onlyBeforeCrowdsale() {
        if (address(starbaseCrowdsale) != 0 &&
            starbaseCrowdsale.startDate() > 0)
        {
            throw;
        }
        _;
    }

    modifier onlyEarlyPurchasesLoaded() {
        if (address(starbaseEarlyPurchase) == 0) {
            throw;
        }
        _;
    }

    /*
     *  Contract functions are compatible with original ones
     */
    /// @dev Returns an early purchase record
    /// @param earlyPurchaseIndex Index number of an early purchase
    function earlyPurchases(uint earlyPurchaseIndex)
        external
        constant
        onlyEarlyPurchasesLoaded
        returns (address purchaser, uint amount, uint purchasedAt)
    {
        return starbaseEarlyPurchase.earlyPurchases(earlyPurchaseIndex);
    }

    /// @dev Returns early purchased amount by purchaser's address
    /// @param purchaser Purchaser address
    function purchasedAmountBy(address purchaser)
        external
        constant
        noEther
        returns (uint amount)
    {
        StarbaseEarlyPurchase.EarlyPurchase[] memory normalizedEP =
            normalizedEarlyPurchases();
        for (uint i; i < normalizedEP.length; i++) {
            if (normalizedEP[i].purchaser == purchaser) {
                amount += normalizedEP[i].amount;
            }
        }
    }

    /// @dev Returns total amount of raised funds by Early Purchasers
    function totalAmountOfEarlyPurchases()
        constant
        noEther
        returns (uint totalAmount)
    {
        StarbaseEarlyPurchase.EarlyPurchase[] memory normalizedEP =
            normalizedEarlyPurchases();
        for (uint i; i < normalizedEP.length; i++) {
            totalAmount += normalizedEP[i].amount;
        }
    }

    /// @dev Returns number of early purchases
    function numberOfEarlyPurchases()
        external
        constant
        noEther
        returns (uint)
    {
        return normalizedEarlyPurchases().length;
    }

    /// @dev Setup function sets external contract's address
    /// @param starbaseCrowdsaleAddress Token address
    function setup(address starbaseCrowdsaleAddress)
        external
        noEther
        onlyOwner
        returns (bool)
    {
        if (address(starbaseCrowdsale) == 0) {
            starbaseCrowdsale = AbstractStarbaseCrowdsale(starbaseCrowdsaleAddress);
            return true;
        }
        return false;
    }

    /*
     *  Contract functions
     */
    function invalidateEarlyPurchase(uint earlyPurchaseIndex)
        external
        noEther
        onlyOwner
        onlyEarlyPurchasesLoaded
        onlyBeforeCrowdsale
        returns (bool)
    {
        if (numberOfRawEarlyPurchases() <= earlyPurchaseIndex) {
            throw;  // Array Index Out of Bounds Exception
        }

        for (uint i; i < invalidEarlyPurchaseIndexes.length; i++) {
            if (invalidEarlyPurchaseIndexes[i] == earlyPurchaseIndex) {
                throw;  // disallow duplicated invalidation
            }
        }

        invalidEarlyPurchaseIndexes.push(earlyPurchaseIndex);
        EarlyPurchaseInvalidated(earlyPurchaseIndex);
        return true;
    }

    function isInvalidEarlyPurchase(uint earlyPurchaseIndex)
        constant
        noEther
        returns (bool)
    {
        if (numberOfRawEarlyPurchases() <= earlyPurchaseIndex) {
            throw;  // Array Index Out of Bounds Exception
        }

        for (uint i; i < invalidEarlyPurchaseIndexes.length; i++) {
            if (invalidEarlyPurchaseIndexes[i] == earlyPurchaseIndex) {
                return true;
            }
        }
        return false;
    }

    function amendEarlyPurchase(uint earlyPurchaseIndex, address purchaser, uint amount, uint purchasedAt)
        external
        noEther
        onlyOwner
        onlyEarlyPurchasesLoaded
        onlyBeforeCrowdsale
        returns (bool)
    {
        if (purchasedAt == 0 || purchasedAt > now) {
            throw;
        }

        if (numberOfRawEarlyPurchases() <= earlyPurchaseIndex) {
            throw;  // Array Index Out of Bounds Exception
        }

        if (isInvalidEarlyPurchase(earlyPurchaseIndex)) {
            throw;  // Invalid early purchase cannot be amended
        }

        if (!isAmendedEarlyPurchase(earlyPurchaseIndex)) {
            amendedEarlyPurchaseIndexes.push(earlyPurchaseIndex);
        }

        amendedEarlyPurchases[earlyPurchaseIndex] =
            StarbaseEarlyPurchase.EarlyPurchase(purchaser, amount, purchasedAt);
        EarlyPurchaseAmended(earlyPurchaseIndex);
        return true;
    }

    function isAmendedEarlyPurchase(uint earlyPurchaseIndex)
        constant
        noEther
        returns (bool)
    {
        if (numberOfRawEarlyPurchases() <= earlyPurchaseIndex) {
            throw;  // Array Index Out of Bounds Exception
        }

        for (uint i; i < amendedEarlyPurchaseIndexes.length; i++) {
            if (amendedEarlyPurchaseIndexes[i] == earlyPurchaseIndex) {
                return true;
            }
        }
        return false;
    }

    function loadStarbaseEarlyPurchases(address starbaseEarlyPurchaseAddress)
        external
        noEther
        onlyOwner
        onlyBeforeCrowdsale
        returns (bool)
    {
        if (starbaseEarlyPurchaseAddress == 0 ||
            address(starbaseEarlyPurchase) != 0)
        {
            throw;
        }

        starbaseEarlyPurchase = StarbaseEarlyPurchase(starbaseEarlyPurchaseAddress);
        if (starbaseEarlyPurchase.earlyPurchaseClosedAt() == 0) {
            throw;   // the early purchase must be closed
        }
        return true;
    }

    /// @dev Contract constructor function
    function StarbaseEarlyPurchaseAmendment() noEther {
        owner = msg.sender;
    }

    /// @dev Fallback function always fails
    function () {
        throw;
    }

    /**
     * Internal functions
     */
    function normalizedEarlyPurchases()
        constant
        internal
        returns (StarbaseEarlyPurchase.EarlyPurchase[] normalizedEP)
    {
        uint rawEPCount = numberOfRawEarlyPurchases();
        normalizedEP = new StarbaseEarlyPurchase.EarlyPurchase[](
            rawEPCount - invalidEarlyPurchaseIndexes.length);

        uint normalizedIdx;
        for (uint i; i < rawEPCount; i++) {
            if (isInvalidEarlyPurchase(i)) {
                continue;   // invalid early purchase should be ignored
            }

            StarbaseEarlyPurchase.EarlyPurchase memory ep;
            if (isAmendedEarlyPurchase(i)) {
                ep = amendedEarlyPurchases[i];  // amended early purchase should take a priority
            } else {
                ep = getEarlyPurchase(i);
            }

            normalizedEP[normalizedIdx] = ep;
            normalizedIdx++;
        }
    }

    function getEarlyPurchase(uint earlyPurchaseIndex)
        internal
        constant
        onlyEarlyPurchasesLoaded
        returns (StarbaseEarlyPurchase.EarlyPurchase)
    {
        var (purchaser, amount, purchasedAt) =
            starbaseEarlyPurchase.earlyPurchases(earlyPurchaseIndex);
        return StarbaseEarlyPurchase.EarlyPurchase(purchaser, amount, purchasedAt);
    }

    function numberOfRawEarlyPurchases()
        internal
        constant
        onlyEarlyPurchasesLoaded
        returns (uint)
    {
        return starbaseEarlyPurchase.numberOfEarlyPurchases();
    }
}

contract Certifier {
	event Confirmed(address indexed who);
	event Revoked(address indexed who);
	function certified(address) public constant returns (bool);
	function get(address, string) public constant returns (bytes32);
	function getAddress(address, string) public constant returns (address);
	function getUint(address, string) public constant returns (uint);
}

/**
 * @title Crowdsale contract - Starbase crowdsale to create STAR.
 * @author Starbase PTE. LTD. - <