/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.20;

/*

Options Exchange
========================

An Exchange for American Options, which are also reversible until the deadline (Maturation).
An American Option is a contract between its Buyer and its Seller, giving the Buyer the ability
to buy (or sell) an Asset at a specified Strike Price any time before a specified time (Maturation).

Authors: /u/Cintix and /u/Hdizzle83

*/

library SafeMath {

  function mul(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a * b;
    assert((a == 0) || (c / a == b));
    return c;
  }

  function div(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

}

// ERC20 Interface: https://github.com/ethereum/EIPs/issues/20
contract Token {
  function transferFrom(address from, address to, uint256 value) public returns (bool success) {}
  function transfer(address to, uint256 value) public returns (bool success) {}
}

contract OptionsExchange {

  using SafeMath for uint256;

  // Admin takes a 1% cut of each purchased Option's Premium, stored as a ratio with 1 ether as the denominator.
  uint256 public fee_ratio = 10 ** 16;
  
  // Admin is initialized to the contract creator.
  address public admin = msg.sender;
  
  // User balances are stored as userBalance[user][token], where ETH is stored as token address 0.
  mapping (address => mapping(address => uint256)) public userBalance;
  
  // An Option is a bet between two users on the relative price of two tokens on a given date.
  // The Seller locks some amount of token A (Asset) in the Option in exchange for payment (the Premium) from the Buyer.
  // The Buyer is then free to trade between token A and token B (Base) at the given exchange rate (the Strike Price).
  // At the closing date (Maturation), the Option's funds are sent back to the Seller.
  // To reduce onchain storage, Options are indexed by a hash of their parameters, optionHash.
  
  // Address of the Option's Taker, the user who filled the order for the Option.
  // Doubles as an indicator for whether a given Option is active.
  mapping (bytes32 => address) public optionTaker;
  
  // Boolean indicating whether an offchain Option order has been cancelled.
  mapping (bytes32 => bool) public optionOrderCancelled;
  
  // Option balances are stored as optionBalance[optionHash][token], where ETH is stored as token address 0.
  mapping (bytes32 => mapping(address => uint256)) public optionBalance;
  
  // Possible states an Option (or its offchain order) can be in.
  enum optionStates {
    Invalid,    // Option parameters are invalid.
    Available,  // Option hasn't been created or filled yet.
    Cancelled,  // Option's offchain order has been cancelled by the Maker.
    Expired,    // Option's offchain order has passed its Expiration time.
    Tradeable,  // Option can be traded by its Buyer until its Maturation time.
    Matured,    // Option has passed its Maturation time and is ready to be closed.
    Closed      // Option has been closed by its Seller, withdrawing all its funds.
  }
  
  // Events emitted by the contract for use in tracking exchange activity.
  // For Deposits and Withdrawals, ETH balances are stored as a token with address 0.
  event Deposit(address indexed user, address indexed token, uint256 amount);
  event Withdrawal(address indexed user, address indexed token, uint256 amount);
  event OrderFilled(bytes32 indexed optionHash);
  event OrderCancelled(bytes32 indexed optionHash);
  event OptionTraded(bytes32 indexed optionHash, uint256 amountToOption, bool tradingTokenAToOption);
  event OptionClosed(bytes32 indexed optionHash);
  
  // Allow the admin to transfer ownership.
  function changeAdmin(address _admin) external {
    require(msg.sender == admin);
    admin = _admin;
  }
  
  // Users must first deposit ETH into the Exchange in order to purchase Options.
  // ETH balances are stored as a token with address 0.
  function depositETH() external payable {
    userBalance[msg.sender][0] = userBalance[msg.sender][0].add(msg.value);
    Deposit(msg.sender, 0, msg.value);
  }
  
  // Users can withdraw any amount of ETH up to their current balance.
  function withdrawETH(uint256 amount) external {
    require(userBalance[msg.sender][0] >= amount);
    userBalance[msg.sender][0] = userBalance[msg.sender][0].sub(amount);
    msg.sender.transfer(amount);
    Withdrawal(msg.sender, 0, amount);
  }
  
  // To deposit tokens, users must first "approve" the transfer in the token contract.
  // Users must first deposit tokens into the Exchange in order to create or trade with Options.
  function depositToken(address token, uint256 amount) external {
    require(Token(token).transferFrom(msg.sender, this, amount));  
    userBalance[msg.sender][token] = userBalance[msg.sender][token].add(amount);
    Deposit(msg.sender, token, amount);
  }
  
  // Users can withdraw any amount of a given token up to their current balance.
  function withdrawToken(address token, uint256 amount) external {
    require(userBalance[msg.sender][token] >= amount);
    userBalance[msg.sender][token] = userBalance[msg.sender][token].sub(amount);
    require(Token(token).transfer(msg.sender, amount));
    Withdrawal(msg.sender, token, amount);
  }
  
  // Transfer funds from one user's balance to another's.  Not externally callable.
  function transferUserToUser(address from, address to, address token, uint256 amount) private {
    require(userBalance[from][token] >= amount);
    userBalance[from][token] = userBalance[from][token].sub(amount);
    userBalance[to][token] = userBalance[to][token].add(amount);
  }

  // Transfer funds from a user's balance into an Option.  Not externally callable.
  function transferUserToOption(address from, bytes32 optionHash, address token, uint256 amount) private {
    require(userBalance[from][token] >= amount);
    userBalance[from][token] = userBalance[from][token].sub(amount);
    optionBalance[optionHash][token] = optionBalance[optionHash][token].add(amount);
  }

  // Transfer funds from an Option to a user's balance.  Not externally callable.
  function transferOptionToUser(bytes32 optionHash, address to, address token, uint256 amount) private {
    require(optionBalance[optionHash][token] >= amount);
    optionBalance[optionHash][token] = optionBalance[optionHash][token].sub(amount);
    userBalance[to][token] = userBalance[to][token].add(amount);
  }

  // Hashes an Option's parameters for use in looking up information about the Option.  Callable internally and externally.
  // Variables are grouped into arrays as a workaround for the "too many local variables" problem.
  // Instead of directly encoding the token exchange rate (Strike Price), it is instead implicitly
  // stored as limits on the number of each kind of token the Option can store.
  // Note that due to integer division during trading, Options may collect dust amounts over their limits.
  // The offchain order expiration time doubles as a nonce, allowing Makers to create otherwise identical Options.
  function getOptionHash(address[3] tokenA_tokenB_maker,
                         uint256[3] limitTokenA_limitTokenB_premium,
                         uint256[2] maturation_expiration,
                         bool makerIsSeller,
                         bool premiumIsTokenA) pure public returns(bytes32) {
    bytes32 optionHash = keccak256(
                           tokenA_tokenB_maker[0],
                           tokenA_tokenB_maker[1],
                           tokenA_tokenB_maker[2],
                           limitTokenA_limitTokenB_premium[0],
                           limitTokenA_limitTokenB_premium[1],
                           limitTokenA_limitTokenB_premium[2],
                           maturation_expiration[0],
                           maturation_expiration[1],
                           makerIsSeller,
                           premiumIsTokenA
                         );
    return optionHash;
  }
  
  // Computes the current state of an Option given its parameters.  Callable internally and externally.
  function getOptionState(address[3] tokenA_tokenB_maker,
                          uint256[3] limitTokenA_limitTokenB_premium,
                          uint256[2] maturation_expiration,
                          bool makerIsSeller,
                          bool premiumIsTokenA) view public returns(optionStates) {
    // Tokens must be different for Option to be Valid.
    if(tokenA_tokenB_maker[0] == tokenA_tokenB_maker[1]) return optionStates.Invalid;
    // Options must have non-zero limits on their contained Tokens to be Valid.
    if((limitTokenA_limitTokenB_premium[0] == 0) || (limitTokenA_limitTokenB_premium[1] == 0)) return optionStates.Invalid;
    // Options must reach Maturity after the offchain order expires to be Valid.
    if(maturation_expiration[0] <= maturation_expiration[1]) return optionStates.Invalid;
    bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA);
    // Check if the Option's offchain order was cancelled.
    if(optionOrderCancelled[optionHash]) return optionStates.Cancelled;
    // Check if the Option's offchain order hasn't been filled yet.
    if(optionTaker[optionHash] == 0) {
      // Check if the Option's offchain order has expired.
      if(now >= maturation_expiration[1]) return optionStates.Expired;
      // Otherwise, the Option's offchain order is still Available to be created or filled.
      return optionStates.Available;
    }
    // Check if the Option has been emptied of its funds, which means it was closed by its Seller.
    if((optionBalance[optionHash][tokenA_tokenB_maker[0]] == 0) &&
       (optionBalance[optionHash][tokenA_tokenB_maker[1]] == 0)) return optionStates.Closed;
    // Check if the Option has passed its Maturation time.
    if(now >= maturation_expiration[0]) return optionStates.Matured;
    // Otherwise, the Option must still be active and tradeable by its Buyer.
    return optionStates.Tradeable;
  }
  
  // Determines whether the Seller is the Maker or the Taker for a given Option.  Not externally callable.
  function getSeller(address maker, address taker, bool makerIsSeller) pure private returns(address) {
    // Ternary operator to assign the Seller's address: (<conditional> ? <if-true> : <if-false>)
    address seller = makerIsSeller ? maker : taker;
    return seller;
  }
  
  // Determines whether the Buyer is the Maker or the Taker for a given Option.  Not externally callable.
  function getBuyer(address maker, address taker, bool makerIsSeller) pure private returns(address) {
    // Ternary operator to assign the Buyer's address: (<conditional> ? <if-true> : <if-false>)
    address buyer = makerIsSeller ? taker : maker;
    return buyer;
  }
  
  // Transfer payment from an Option's Buyer to the Seller less the 1% fee sent to the admin.  Not externally callable.
  function payForOption(address buyer, address seller, uint256 premium, address TokenA, address TokenB, bool premiumIsTokenA) private {
    uint256 fee = (premium.mul(fee_ratio)).div(1 ether);
    // Ternary operator to assign the Token used for the Premium: (<conditional> ? <if-true> : <if-false>)
    address premiumToken = premiumIsTokenA ? TokenA : TokenB;
    transferUserToUser(buyer, seller, premiumToken, premium.sub(fee));
    transferUserToUser(buyer, admin, premiumToken, fee);
  }
  
  // Allows a Taker to fill an offchain order for an Option created by a Maker.
  function fillOptionOrder(address[3] tokenA_tokenB_maker,
                           uint256[3] limitTokenA_limitTokenB_premium,
                           uint256[2] maturation_expiration,
                           bool makerIsSeller,
                           bool premiumIsTokenA,
                           uint8 v,
                           bytes32[2] r_s) external {
    // Option must be Available, which means it is valid, unexpired, unfilled, and uncancelled.
    require(getOptionState(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA) == optionStates.Available);
    bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA);
    // Verify the Maker's offchain order is valid by checking whether it was signed by the Maker.
    require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", optionHash), v, r_s[0], r_s[1]) == tokenA_tokenB_maker[2]);
    address seller = getSeller(tokenA_tokenB_maker[2], msg.sender, makerIsSeller);
    address buyer = getBuyer(tokenA_tokenB_maker[2], msg.sender, makerIsSeller);
    // Pay the premium for the Option in units of either TokenA or TokenB, depending on the boolean premiumIsTokenA.
    payForOption(buyer, seller, limitTokenA_limitTokenB_premium[2], tokenA_tokenB_maker[0], tokenA_tokenB_maker[1], premiumIsTokenA);
    // Transfer the amount of Token A specified in the order from the Seller to the Option.
    transferUserToOption(seller, optionHash, tokenA_tokenB_maker[0], limitTokenA_limitTokenB_premium[0]);
    // Set the order filler as the Option's Taker, marking the Option as active.
    optionTaker[optionHash] = msg.sender;
    OrderFilled(optionHash);
  }
  
  // Allows a Maker to cancel their offchain Option order early (i.e. before its expiration).
  function cancelOptionOrder(address[3] tokenA_tokenB_maker,
                             uint256[3] limitTokenA_limitTokenB_premium,
                             uint256[2] maturation_expiration,
                             bool makerIsSeller,
                             bool premiumIsTokenA) external {
    // Option must be Available, which means it is valid, unexpired, unfilled, and uncancelled.
    require(getOptionState(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA) == optionStates.Available);
    // Only allow the Maker to cancel their own offchain Option order.
    require(msg.sender == tokenA_tokenB_maker[2]);
    bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA);
    // Mark the offchain Option order as cancelled onchain.
    optionOrderCancelled[optionHash] = true;
    OrderCancelled(optionHash);
  }
  
  // Handler for trading tokens into and out of the Option at the given Strike Price.  Not externally callable.
  function tradeOptionHelper(address buyer,
                             bytes32 optionHash,
                             address tokenToOption,
                             address tokenFromOption,
                             uint256 limitToOption,
                             uint256 limitFromOption,
                             uint256 amountToOption) private {
    transferUserToOption(buyer, optionHash, tokenToOption, amountToOption);
    // Strike Price is calculated as the ratio of the maximum amounts of each Token the Option can hold.
    uint256 amountFromOption = (amountToOption.mul(limitFromOption)).div(limitToOption);
    transferOptionToUser(optionHash, buyer, tokenFromOption, amountFromOption);
  }

  // Allow an Option's Buyer to trade tokens into and out of the Option at the Strike Price until the Option's Maturation.
  // The boolean tradingTokenAToOption is True when Token A is being traded to the Option, and False when Token B is.
  // Trade limits aren't explicitly checked, but are enforced by Option balances not being drainable below zero.
  // Note that due to integer division during trading, Options may collect dust amounts over their limits.
  function tradeOption(address[3] tokenA_tokenB_maker,
                       uint256[3] limitTokenA_limitTokenB_premium,
                       uint256[2] maturation_expiration,
                       bool makerIsSeller,
                       bool premiumIsTokenA,
                       uint256 amountToOption,
                       bool tradingTokenAToOption) external {
    // Option must be Tradeable, which means it's been filled and hasn't passed its trading deadline (Maturation).
    require(getOptionState(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA) == optionStates.Tradeable);
    bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA);
    address buyer = getBuyer(tokenA_tokenB_maker[2], optionTaker[optionHash], makerIsSeller);
    // Only allow the Buyer to trade with the Option.
    require(msg.sender == buyer);
    if(tradingTokenAToOption) {
      tradeOptionHelper(buyer, optionHash, tokenA_tokenB_maker[0], tokenA_tokenB_maker[1], limitTokenA_limitTokenB_premium[0], limitTokenA_limitTokenB_premium[1], amountToOption);
    } else {
      tradeOptionHelper(buyer, optionHash, tokenA_tokenB_maker[1], tokenA_tokenB_maker[0], limitTokenA_limitTokenB_premium[1], limitTokenA_limitTokenB_premium[0], amountToOption);
    }
    OptionTraded(optionHash, amountToOption, tradingTokenAToOption);
  }
  
  // Allows an Option's Seller to withdraw their funds after the Option's Maturation.
  function closeOption(address[3] tokenA_tokenB_maker,
                       uint256[3] limitTokenA_limitTokenB_premium,
                       uint256[2] maturation_expiration,
                       bool makerIsSeller,
                       bool premiumIsTokenA) external {
    // Option must have Matured, which means it's filled, has passed its Maturation time, and is unclosed.
    require(getOptionState(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA) == optionStates.Matured);
    bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA);
    address seller = getSeller(tokenA_tokenB_maker[2], optionTaker[optionHash], makerIsSeller);
    // Only allow the Seller to close their own Option.
    require(msg.sender == seller);
    // Transfer the Option's entire balance of each token back to the Seller, closing the Option.
    transferOptionToUser(optionHash, seller, tokenA_tokenB_maker[0], optionBalance[optionHash][tokenA_tokenB_maker[0]]);
    transferOptionToUser(optionHash, seller, tokenA_tokenB_maker[1], optionBalance[optionHash][tokenA_tokenB_maker[1]]);
    OptionClosed(optionHash);
  }
  
  function() payable external {
    revert();
  }
  
}