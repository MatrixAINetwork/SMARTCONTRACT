/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.8;

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


contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract Ownable {
  address public owner;


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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract PauseInfrastructure is Ownable {
    event triggerUnpauseEvent();
    event triggerPauseEvent();

    bool public paused;

    /**
     * constructor assigns initial paused state
     * @param _paused selects the initial pause state.
     */
    function PauseInfrastructure(bool _paused){
        paused = _paused;
    }

    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused() {
        if (paused) revert();
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract IS NOT paused
     */
    modifier whenPaused {
        require (paused);
        _;
    }
}


contract Startable is PauseInfrastructure {
  function Startable () PauseInfrastructure(true){
  }

  // called by the owner to start
  function start() onlyOwner whenPaused returns (bool) {
    paused = false;
    triggerUnpauseEvent();
    return true;
  }
}

contract StartableMintableToken is Startable, MintableToken {

    function transfer(address _to, uint _value) whenNotPaused returns (bool){
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}

contract SeratioCoin is StartableMintableToken {
    // Name of the token
    string constant public name = "SeratioCoin";
    // Token abbreviation
    string constant public symbol = "SER";
    // Decimal places
    uint8 constant public decimals = 7;
    // Zeros after the point
    uint32 constant public DECIMAL_ZEROS = 10000000;
}

/**
 *
 * @title Seratio Stake
 *
 * TODO Whitepaper https://github.com/seratio/whitepaper/blob/master/Seratio%20Enterprise%20Platform%20(29%20March%202017)%20%5Bv.%204.03%5D.pdf
 *
 */
contract SeratioICO is Ownable{
    using SafeMath for uint;

    // logged events:
    // Funds has arrived into the wallet (record how much).
    event DepositAcceptedEvent(address _from, uint value);

    // Minimum investment ICO phase one
    uint16 constant public MIN_INVESTMENT_ICO_PHASE_ONE_POUNDS = 5000;
    // Minimum investment ICO phase two
    uint16 constant public MIN_INVESTMENT_ICO_PHASE_TWO_POUNDS = 1000;
    // Investment cap ICO phase one
    uint32 constant public INVESTMENT_CAP_ICO_PHASE_ONE_POUNDS = 1000000;
    // Investment cap ICO phase two
    uint32 public investmentCapIcoPhaseTwoPounds = 4000000000;
    // Base toke price in pound pences
    uint8 constant BASE_TOKEN_PRICE_IN_POUND_PENCES = 20;

    bool investmentCapPreIcoReached = false;

    // Total value in wei
    uint totalValue;

    uint public timeStampOfCrowdSaleStart;
    uint public timeStampOfCrowdSaleEnd;

    // Address of multisig wallet holding ether from sale
    address wallet;

    struct IcoPhaseOneConfig{
    uint startingTime;
    uint8 tokenPriceInPoundPences;
    }

    IcoPhaseOneConfig[] IcoPhaseOneArray;

    uint32 public etherPriceInPoundPences = 30000;

    SeratioCoin public seratioCoin;

    /**
     * Constructor of the contract.
     *
     * Passes address of the account holding the value.
     * SeratioCoin contract itself does not hold any value
     *
     * @param multisig address of MultiSig wallet which will hold the value
     */
    function SeratioICO(address multisig, uint _timeStampOfCrowdSaleStart, SeratioCoin serationCoinAddress){
        seratioCoin = SeratioCoin(serationCoinAddress);

        timeStampOfCrowdSaleStart = _timeStampOfCrowdSaleStart;
        timeStampOfCrowdSaleEnd = timeStampOfCrowdSaleStart + 47 days;

        wallet = multisig;

        IcoPhaseOneArray.push(IcoPhaseOneConfig({startingTime: timeStampOfCrowdSaleStart +  0 days,  tokenPriceInPoundPences:  10})); // from  1st day to  3rd day -> 50% discount
        IcoPhaseOneArray.push(IcoPhaseOneConfig({startingTime: timeStampOfCrowdSaleStart +  3 days,  tokenPriceInPoundPences:  12})); // from  4th day to  6th day -> 40% discount
        IcoPhaseOneArray.push(IcoPhaseOneConfig({startingTime: timeStampOfCrowdSaleStart +  6 days,  tokenPriceInPoundPences:  14})); // from  7th day to  9th day -> 30% discount
        IcoPhaseOneArray.push(IcoPhaseOneConfig({startingTime: timeStampOfCrowdSaleStart +  9 days,  tokenPriceInPoundPences:  16})); // from 10th day to 12th day -> 20% discount
        IcoPhaseOneArray.push(IcoPhaseOneConfig({startingTime: timeStampOfCrowdSaleStart + 12 days,  tokenPriceInPoundPences:  18})); // from 13th day to 16th day -> 10% discount
    }

    function getIcoPhaseOneThreeDayIndex(uint time) constant returns (uint){
        for (uint i = 1; i <= IcoPhaseOneArray.length; i++) {
            uint indexToEvaluate = IcoPhaseOneArray.length-i;
            if (time >= IcoPhaseOneArray[indexToEvaluate].startingTime)
                return indexToEvaluate;
        }
    }

    function getIcoPhaseOneTokenPriceInPoundPences(uint time) constant returns (uint8){
        IcoPhaseOneConfig storage todaysConfig = IcoPhaseOneArray[getIcoPhaseOneThreeDayIndex(time)];
        return todaysConfig.tokenPriceInPoundPences;
    }

    function hasIcoPhaseOneEnded (uint time) constant returns (bool){
        return time >= (IcoPhaseOneArray[IcoPhaseOneArray.length-1].startingTime + 4 days);
    }

    /**
     * Fallback function: called on ether sent.
     *
     * It calls to createSER function with msg.sender
     * as a value for holder argument
     */
    function () payable hasCrowdSaleStarted hasCrowdSaleNotYetEnded {
        // check if investment is more than 0
        if (msg.value > 0){
            mintSerTokens(msg.sender, msg.value, now);
            require (wallet.send(msg.value));
            DepositAcceptedEvent(msg.sender, msg.value);
        }
    }

    modifier hasCrowdSaleStarted() {
        require (now >= timeStampOfCrowdSaleStart);
        _;
    }

    modifier hasCrowdSaleEnded() {
        require (now >= timeStampOfCrowdSaleEnd);
        _;
    }

    modifier hasCrowdSaleNotYetEnded() {
        require (now < timeStampOfCrowdSaleEnd);
        _;
    }

    function calculateEthers(uint poundPences) constant returns (uint){
        return poundPences.mul(1 ether).div(etherPriceInPoundPences)+1;
    }

    function calculatePoundsTimesEther(uint ethersAmount) constant returns (uint){
        return ethersAmount.mul(etherPriceInPoundPences).div(100);
    }

    function setEtherPriceInPoundPences(uint32 _etherPriceInPoundPences) onlyOwner{
        etherPriceInPoundPences = _etherPriceInPoundPences;
    }

    function setInvestmentCapIcoPhaseTwoPounds(uint32 _investmentCapIcoPhaseTwoPounds) onlyOwner{
        investmentCapIcoPhaseTwoPounds = _investmentCapIcoPhaseTwoPounds;
    }

    function createSeratioStake() hasCrowdSaleEnded onlyOwner{
        uint SeratioTokens = seratioCoin.totalSupply().mul(3);
        seratioCoin.mint(wallet, SeratioTokens);
        seratioCoin.finishMinting();
    }

    function SwitchTokenTransactionsOn() hasCrowdSaleEnded onlyOwner{
        seratioCoin.start();
    }

    /**
     * Creates SER tokens.
     *
     * Runs sanity checks including safety cap
     * Then calculates current price by getPrice() function, creates SER tokens
     * Finally sends a value of transaction to the wallet
     *
     * Note: due to lack of floating point types in Solidity,
     * contract assumes that last 3 digits in tokens amount are stood after the point.
     * It means that if stored SER balance is 100000, then its real value is 100 SER
     *
     * @param sender ether sender
     * @param value amount of ethers sent
     */
    function mintSerTokens(address sender, uint value, uint timeStampOfInvestment) private {
        uint investmentCapInPounds;
        uint minimumInvestmentInPounds;
        uint8 tokenPriceInPoundPences;

        uint investmentInPoundsTimesEther = calculatePoundsTimesEther(value);
        if (hasIcoPhaseOneEnded(timeStampOfInvestment) || investmentCapPreIcoReached){
            // ICO Phase Two
            investmentCapInPounds = investmentCapIcoPhaseTwoPounds;
            minimumInvestmentInPounds = MIN_INVESTMENT_ICO_PHASE_TWO_POUNDS;
            tokenPriceInPoundPences = BASE_TOKEN_PRICE_IN_POUND_PENCES;
            require(investmentInPoundsTimesEther >= minimumInvestmentInPounds.mul(1 ether));
        }else{
            // ICO Phase One
            investmentCapInPounds = INVESTMENT_CAP_ICO_PHASE_ONE_POUNDS;
            minimumInvestmentInPounds = MIN_INVESTMENT_ICO_PHASE_ONE_POUNDS;
            tokenPriceInPoundPences = getIcoPhaseOneTokenPriceInPoundPences(timeStampOfInvestment);
            require(investmentInPoundsTimesEther >= minimumInvestmentInPounds.mul(1 ether));

            uint totalInvestmentInPoundsTimesEther = calculatePoundsTimesEther(getTotalValue().add(value));
            uint investmentCapInPoundsTimesEther = investmentCapInPounds.mul(1 ether);
            if(totalInvestmentInPoundsTimesEther > investmentCapInPoundsTimesEther){
                // With this investment, the investment cap is reached
                investmentCapPreIcoReached = true;
                // retarget investment over phase one cap to phase two.
                uint retargetedInvestmentInPoundsTimesEther = totalInvestmentInPoundsTimesEther.sub(investmentCapInPoundsTimesEther);
                uint investmentInPoundsTimesEtherToFulfilCap = investmentInPoundsTimesEther.sub(retargetedInvestmentInPoundsTimesEther);
                // mint difference until cap is reached.
                mintHelper(sender, investmentInPoundsTimesEtherToFulfilCap, tokenPriceInPoundPences);
                // update parameters for minting retargeted investment.
                investmentInPoundsTimesEther = retargetedInvestmentInPoundsTimesEther;
                tokenPriceInPoundPences = BASE_TOKEN_PRICE_IN_POUND_PENCES;
            }
        }

        mintHelper(sender, investmentInPoundsTimesEther, tokenPriceInPoundPences);
        totalValue = totalValue.add(value);
    }

    function mintHelper(address sender, uint investmentInPoundsTimesEther, uint8 tokenPriceInPoundPences) private {
        uint tokens = investmentInPoundsTimesEther
        .mul(100).div(tokenPriceInPoundPences)
        .mul(uint(seratioCoin.DECIMAL_ZEROS()))
        .div(1 ether);

        seratioCoin.mint(sender, tokens);
    }
    function manuallyMintTokens(address beneficiary, uint value, uint timeStampOfInvestment) onlyOwner{
        mintSerTokens(beneficiary, value, timeStampOfInvestment);
    }
    function rawManuallyMintTokens(address beneficiary, uint tokens) onlyOwner{
        seratioCoin.mint(beneficiary, tokens);
    }

    /**
     * Denotes complete price structure during the sale.
     *
     * @return SER amount per 1 ETH for the current moment in time
     */
    function getPrice(uint time) constant returns (uint) {
        uint8 tokenPriceInPoundPences;
        if (hasIcoPhaseOneEnded(time)){
            tokenPriceInPoundPences = BASE_TOKEN_PRICE_IN_POUND_PENCES;
        }else{
            tokenPriceInPoundPences = getIcoPhaseOneTokenPriceInPoundPences(time);
        }
        return tokenPriceInPoundPences;
    }

    /**
     * Returns total stored SER amount.
     *
     * Contract assumes that last 5 digits of this value are behind the decimal place. i.e. 1000001 is 10.00001
     * Thus, result of this function should be divided by 100000 to get SER value
     *
     * @return result stored SER amount
     */
    function getTotalSupply() constant returns (uint) {
        return seratioCoin.totalSupply();
    }

    /**
     * Returns total value passed through the contract
     *
     * @return result total value in wei
     */
    function getTotalValue() constant returns (uint) {
        return totalValue;
    }
}