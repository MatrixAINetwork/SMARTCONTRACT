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
contract SafeMath {
    /**
    * @dev constructor
    */
    function SafeMath() public {
    }

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
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
    address public newOwner;

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
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    /**
    * @dev confirm ownership by a new owner
    */
    function confirmOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
}

contract TheAbyssCrowdsale is Ownable, SafeMath {
    mapping (address => uint256) public balances;

    uint256 public constant TOKEN_PRICE_NUM = 2500;
    uint256 public constant TOKEN_PRICE_DENOM = 1;

    uint256 public constant PRESALE_ETHER_MIN_CONTRIB = 5 ether;
    uint256 public constant SALE_ETHER_MIN_CONTRIB = 0.1 ether;

    uint256 public totalEtherContributed = 0;
    uint256 public totalTokensToSupply = 0;
    address public wallet = 0x0;

    uint256 public preSaleStartTime = 0;
    uint256 public preSaleEndTime = 0;

    uint256 public saleStartTime = 0;
    uint256 public saleEndTime = 0;

    uint256 public bonusWindow1EndTime = 0;
    uint256 public bonusWindow2EndTime = 0;
    uint256 public bonusWindow3EndTime = 0;  

    event LogContribution(address indexed contributor, uint256 amountWei, uint256 tokenAmount, uint256 tokenBonus, uint256 timestamp);

    modifier checkContribution() {
        require((now >= preSaleStartTime && now < preSaleEndTime && msg.value >= PRESALE_ETHER_MIN_CONTRIB) || (now >= saleStartTime && now < saleEndTime && msg.value >= SALE_ETHER_MIN_CONTRIB));
        _;
    }

    function TheAbyssCrowdsale(address _wallet, uint256 _preSaleStartTime, uint256 _preSaleEndTime, uint256 _saleStartTime, uint256 _saleEndTime) public {
        require(_preSaleStartTime >= now);
        require(_preSaleEndTime > _preSaleStartTime);
        require(_saleStartTime > _preSaleEndTime);
        require(_saleEndTime > _saleStartTime);
        require(_wallet != address(0));

        wallet = _wallet;

        preSaleStartTime = _preSaleStartTime;
        preSaleEndTime = _preSaleEndTime;

        saleStartTime = _saleStartTime;
        saleEndTime = _saleEndTime;

        bonusWindow1EndTime = saleStartTime + 1 days;
        bonusWindow2EndTime = saleStartTime + 4 days;
        bonusWindow3EndTime = saleStartTime + 20 days;
    }

    function getBonus() internal constant returns (uint256, uint256) {
        uint256 numerator = 0;
        uint256 denominator = 100;

        if(now >= preSaleStartTime && now < preSaleEndTime) {
            numerator = 25;
        } else if(now >= saleStartTime && now < saleEndTime) {
            if(now < bonusWindow1EndTime) {
                numerator = 15;
            } else if(now < bonusWindow2EndTime) {
                numerator = 10;
            } else if(now < bonusWindow3EndTime) {
                numerator = 5;
            } else {
                numerator = 0;
            }
        }
        return (numerator, denominator);
    }

    function () payable public {
        processContribution();
    }

    function processContribution() private checkContribution {
        uint256 bonusNum = 0;
        uint256 bonusDenom = 100;
        (bonusNum, bonusDenom) = getBonus();
        uint256 tokenBonusAmount = 0;
        uint256 tokenAmount = safeDiv(safeMul(msg.value, TOKEN_PRICE_NUM), TOKEN_PRICE_DENOM);

        if(bonusNum > 0) {
            tokenBonusAmount = safeDiv(safeMul(tokenAmount, bonusNum), bonusDenom);
        }

        uint256 tokenTotalAmount = safeAdd(tokenAmount, tokenBonusAmount);
        balances[msg.sender] = safeAdd(balances[msg.sender], tokenTotalAmount);

        totalEtherContributed = safeAdd(totalEtherContributed, msg.value);
        totalTokensToSupply = safeAdd(totalTokensToSupply, tokenTotalAmount);
        LogContribution(msg.sender, msg.value, tokenAmount, tokenBonusAmount, now);
    }

    function transferFunds() public onlyOwner {
        wallet.transfer(this.balance);
    }
}