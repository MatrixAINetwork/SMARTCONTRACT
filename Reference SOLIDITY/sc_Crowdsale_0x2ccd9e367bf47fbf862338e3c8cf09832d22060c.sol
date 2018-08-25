/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
 
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

 function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant public returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) tokenBalances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(tokenBalances[msg.sender]>=_value);
    tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(_value);
    tokenBalances[_to] = tokenBalances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return tokenBalances[_owner];
  }

}
//TODO: Change the name of the token
contract QuantumBreakToken is BasicToken,Ownable {

   using SafeMath for uint256;
   
   //TODO: Change the name and the symbol
   string public constant name = "Quantum Break";
   string public constant symbol = "QBT";
   uint256 public constant decimals = 18;
    address public ownerWallet;
   uint256 public constant INITIAL_SUPPLY = 5000000000;
   event Debug(string message, address addr, uint256 number);
  /**
   * @dev Contructor that gives msg.sender all of existing tokens.
   */
   //TODO: Change the name of the constructor
    function QuantumBreakToken(address wallet) public {
        owner = msg.sender;
        ownerWallet = wallet;
        totalSupply = INITIAL_SUPPLY;
        tokenBalances[ownerWallet] = INITIAL_SUPPLY * 10 ** 18;   //Since we divided the token into 10^18 parts
    }

    function mint(address buyer, uint256 tokenAmount) public onlyOwner {
      require(tokenBalances[ownerWallet] >= tokenAmount);               // checks if it has enough to sell
      tokenBalances[buyer] = tokenBalances[buyer].add(tokenAmount);                  // adds the amount to buyer's balance
      tokenBalances[ownerWallet] = tokenBalances[ownerWallet].sub(tokenAmount);                        // subtracts amount from seller's balance
      Transfer(ownerWallet, buyer, tokenAmount); 
    }
  function showMyTokenBalance(address addr) public view returns (uint tokenBalance) {
        tokenBalance = tokenBalances[addr];
    }
    
    function makeAnotherContractOwnerOfToken(address newContractAddress) public
    {
        require(msg.sender == ownerWallet);
        owner = newContractAddress;
    }
}
contract Crowdsale {
  using SafeMath for uint256;
 
  // The token being sold
  QuantumBreakToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  // address where tokens are deposited and from where we send tokens to buyers
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public ratePerWei = 1 * 10 ** 5;   //1 token's price is 0.00001 eth, so in 1 wei we get 10^5 token parts

  // amount of raised money in wei
  uint256 public weiRaised;
  
  //number of tokens sold
  uint256 tokensSold;

  //upper cap of tokens
  uint256 upperCap = 4500000000 * 10 ** 18;
  //uint256 upperCap = 450000 * 10 ** 18;
 
  //duration of ICO
  uint256 duration = 90 days;
  
  bool ownerAmountPaid = false; 

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, address _wallet) public {
    
    startTime = _startTime;   
       
    endTime = startTime + duration;  //ICO goes on for 90 days
    
    require(endTime >= startTime);
    require(_wallet != 0x0);

    wallet = _wallet;
    token = createTokenContract(wallet);
    
  }

  // creates the token to be sold.
  // TODO: Change the name of the token from QBT token to something else
  function createTokenContract(address wall) internal returns (QuantumBreakToken) {
    return new QuantumBreakToken(wall);
  }


  // fallback function can be used to buy tokens
   function () public payable {
    buyTokens(msg.sender);
   }

    // low level token purchase function
    // Minimum purchase can be of 1 ETH
  
   function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be given
    uint256 tokens = weiAmount.mul(ratePerWei);
    uint discountTokens;
    uint discountPercentage;
    (discountTokens,discountPercentage) = determineDiscount(weiAmount, tokens);
    
    uint tokensAboutToBeSold = tokens.add(discountTokens);
    
    uint tokensYouCanGive = upperCap - tokensSold;
    require (tokensYouCanGive>0);
    uint ethsToReturn;
    if (tokensYouCanGive < tokensAboutToBeSold)
    {
        discountPercentage = discountPercentage.add(100);
        uint tokensToCharge = tokensYouCanGive.mul(100);
        tokensToCharge = tokensToCharge.div(discountPercentage);
        
        uint ethsToCharge = tokensToCharge.div(ratePerWei);
        ethsToReturn = weiAmount - ethsToCharge;
        tokensAboutToBeSold = tokensYouCanGive;
    }
    // update state
    uint actualFundsRaised = weiAmount-ethsToReturn;
    weiRaised = weiRaised.add(actualFundsRaised);
    token.mint(beneficiary, tokensAboutToBeSold); 
    TokenPurchase(msg.sender, beneficiary, actualFundsRaised, tokensAboutToBeSold);
    tokensSold = tokensSold.add(tokensAboutToBeSold);
    beneficiary.transfer(ethsToReturn);
    forwardFunds(actualFundsRaised);
  }

    //determine the rate of the token w.r.t. time elapsed
  function determineDiscount(uint256 weiAmount, uint256 tokens) internal view returns (uint discountTokens, uint discountPercentage) {
      
    if (weiAmount > 0 && weiAmount < 1 * 10 ** 18)
    {
        //10% discount    
        discountTokens = tokens.mul(10);
        discountTokens = discountTokens.div(100);
        discountPercentage = 10;
    }
    else if (weiAmount >= 1 * 10 ** 18 && weiAmount < 5 * 10 ** 18)
    {
        //20% discount
        discountTokens = tokens.mul(20);
        discountTokens = discountTokens.div(100);
        discountPercentage = 20;
    }
    else if (weiAmount >= 5 * 10 ** 18 && weiAmount <10 * 10 ** 18)
    {
        //30% discount
        discountTokens = tokens.mul(30);
        discountTokens = discountTokens.div(100);
        discountPercentage = 30;
    }
    else if (weiAmount >= 10 * 10 * 10 ** 18 && weiAmount <20 * 10 ** 18)
    {
        //40% discount
        discountTokens = tokens.mul(40);
        discountTokens = discountTokens.div(100);
        discountPercentage = 40;
    }
    else if (weiAmount >= 20 * 10 * 10 ** 18)
    {
        //50% discount
        discountTokens = tokens.mul(50);
        discountTokens = discountTokens.div(100);
        discountPercentage = 50;
    }
  }
  
  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds(uint funds) internal {
    wallet.transfer(funds);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }
  
   function showMyTokenBalance(address sender) public view returns (uint256 tokenBalance) {
        tokenBalance = token.showMyTokenBalance(sender);
    }
    
    function changeStartTime(uint256 newStartTime) public
    {
        require (msg.sender == wallet);
        startTime = newStartTime;
    }
    
    function changeEndTime(uint256 newEndTime) public
    {
        require (msg.sender == wallet);
        endTime = newEndTime;
    }
}