/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

/**
 * @title InteractiveCrowdsaleLib
 * @author Modular, Inc
 *
 * version 1.0.0
 * Copyright (c) 2017 Modular, Inc
 * The MIT License (MIT)
 *
 * The InteractiveCrowdsale Library provides functionality to create a crowdsale
 * based on the white paper initially proposed by Jason Teutsch and Vitalik
 * Buterin. See https://people.cs.uchicago.edu/~teutsch/papers/ico.pdf for
 * further information.
 *
 * This library was developed in a collaborative effort among many organizations
 * including TrueBit, Modular, and Consensys.
 * For further information: truebit.io, modular.network,
 * consensys.net
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

library InteractiveCrowdsaleLib {
  using BasicMathLib for uint256;
  using TokenLib for TokenLib.TokenStorage;
  using LinkedListLib for LinkedListLib.LinkedList;
  using CrowdsaleLib for CrowdsaleLib.CrowdsaleStorage;

  // Node constants for use in the linked list
  uint256 constant NULL = 0;
  uint256 constant HEAD = 0;
  bool constant PREV = false;
  bool constant NEXT = true;

  struct InteractiveCrowdsaleStorage {

    CrowdsaleLib.CrowdsaleStorage base; // base storage from CrowdsaleLib

    // List of personal valuations, sorted from smallest to largest (from LinkedListLib)
    LinkedListLib.LinkedList valuationsList;

    // Info holder for token creation
    TokenLib.TokenStorage tokenInfo;

    uint256 endWithdrawalTime;   // time when manual withdrawals are no longer allowed

    // current total valuation of the sale
    // actual amount of ETH committed, taking into account partial purchases
    uint256 totalValuation;

    // amount of value committed at this valuation, cannot rely on owner balance
    // due to fluctations in commitment calculations needed after owner withdraws
    // in other words, the total amount of ETH committed, including total bids
    // that will eventually get partial purchases
    uint256 valueCommitted;

    // the bucket that sits either at or just below current total valuation.
    // determines where the cutoff point is for bids in the sale
    uint256 currentBucket;

    // the fraction of each minimal valuation bidder's ether refund, 'q' is from the paper
    // and is calculated when finalizing the sale
    uint256 q;

    // minimim amount that the sale needs to make to be successfull
    uint256 minimumRaise;

    // percentage of total tokens being sold in this sale
    uint8 percentBeingSold;

    // the bonus amount for early bidders.  This is a percentage of the base token
    // price that gets added on the the base token price used in getCurrentBonus()
    uint256 priceBonusPercent;

    // Indicates that the owner has finalized the sale and withdrawn Ether
    bool isFinalized;

    // Set to true if the sale is canceled
    bool isCanceled;

    // shows the price that the address purchased tokens at
    mapping (address => uint256) pricePurchasedAt;

    // the sums of bids at each valuation.  Used to calculate the current bucket for the valuation pointer
    mapping (uint256 => uint256) valuationSums;

    // the number of active bids at a certain valuation cap
    mapping (uint256 => uint256) numBidsAtValuation;

    // the valuation cap that each address has submitted
    mapping (address => uint256) personalCaps;

    // shows if an address has done a manual withdrawal. manual withdrawals are only allowed once
    mapping (address => bool) hasManuallyWithdrawn;
  }

  // Indicates when a bidder submits a bid to the crowdsale
  event LogBidAccepted(address indexed bidder, uint256 amount, uint256 personalValuation);

  // Indicates when a bidder manually withdraws their bid from the crowdsale
  event LogBidWithdrawn(address indexed bidder, uint256 amount, uint256 personalValuation);

  // Indicates when a bid is removed by the automated bid removal process
  event LogBidRemoved(address indexed bidder, uint256 personalValuation);

  // Generic Error Msg Event
  event LogErrorMsg(uint256 amount, string Msg);

  // Indicates when the price of the token changes
  event LogTokenPriceChange(uint256 amount, string Msg);

  // Logs the current bucket that the valuation points to, the total valuation of
  // the sale, and the amount of ETH committed, including total bids that will eventually get partial purchases
  event BucketAndValuationAndCommitted(uint256 bucket, uint256 valuation, uint256 committed);

  /// @dev Called by a crowdsale contract upon creation.
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _owner Address of crowdsale owner
  /// @param _saleData Array of 3 item arrays such that, in each 3 element
  /// array index-0 is a timestamp, index-1 is price in tokens/ETH
  /// index-2 is address purchase cap at that time, 0 if no address cap
  /// @param _priceBonusPercent the bonus amount for early bidders
  /// @param _minimumRaise minimim amount that the sale needs to make to be successfull
  /// @param _endWithdrawalTime timestamp that indicates that manual withdrawals are no longer allowed
  /// @param _endTime Timestamp of sale end time
  /// @param _percentBeingSold percentage of total tokens being sold in the sale
  /// @param _tokenName name of the token being sold. ex: "Jason Network Token"
  /// @param _tokenSymbol symbol of the token. ex: "JNT"
  /// @param _tokenDecimals number of decimals in the token
  /// @param _allowMinting whether or not to allow minting of the token after the sale
  function init(InteractiveCrowdsaleStorage storage self,
                address _owner,
                uint256[] _saleData,
                uint256 _priceBonusPercent,
                uint256 _minimumRaise,
                uint256 _endWithdrawalTime,
                uint256 _endTime,
                uint8 _percentBeingSold,
                string _tokenName,
                string _tokenSymbol,
                uint8 _tokenDecimals,
                bool _allowMinting) public
  {
    self.base.init(_owner,
                _saleData,
                _endTime,
                0, // no token burning for iico
                CrowdsaleToken(0)); // no tokens created prior to iico

    require(_endWithdrawalTime < _endTime);
    require(_endWithdrawalTime > _saleData[0]);
    require(_minimumRaise > 0);
    require(_percentBeingSold > 0);
    require(_percentBeingSold <= 100);
    require(_priceBonusPercent > 0);

    self.minimumRaise = _minimumRaise;
    self.endWithdrawalTime = _endWithdrawalTime;
    self.percentBeingSold = _percentBeingSold;
    self.priceBonusPercent = _priceBonusPercent;

    self.tokenInfo.name = _tokenName;
    self.tokenInfo.symbol = _tokenSymbol;
    self.tokenInfo.decimals = _tokenDecimals;
    self.tokenInfo.stillMinting = _allowMinting;
  }

  /// @dev calculates the number of digits in a given number
  /// @param _number the number for which we're caluclating digits
  /// @return _digits the number of digits in _number
  function numDigits(uint256 _number) public pure returns (uint256) {
    uint256 _digits = 0;
    while (_number != 0) {
      _number /= 10;
      _digits++;
    }
    return _digits;
  }

  /// @dev calculates the number of tokens purchased based on the amount of wei
  ///      spent and the price of tokens
  /// @param _amount amound of wei that the buyer sent
  /// @param _price price of tokens in the sale, in tokens/ETH
  /// @return uint256 numTokens the number of tokens purchased
  /// @return remainder  any remaining wei leftover from integer division
  function calculateTokenPurchase(uint256 _amount,
                                  uint256 _price)
                                  internal
                                  pure
                                  returns (uint256,uint256)
  {
    uint256 remainder = 0; //temp calc holder for division remainder for leftover wei

    bool err;
    uint256 numTokens;
    uint256 weiTokens; //temp calc holder

    // Find the number of tokens as a function in wei
    (err,weiTokens) = _amount.times(_price);
    require(!err);

    numTokens = weiTokens / 1000000000000000000;
    remainder = weiTokens % 1000000000000000000;
    remainder = remainder / _price;

    return (numTokens,remainder);
  }

  /// @dev Called when an address wants to submit a bid to the sale
  /// @param self Stored crowdsale from crowdsale contract
  /// @return currentBonus percentage of the bonus that is applied for the purchase
  function getCurrentBonus(InteractiveCrowdsaleStorage storage self) internal view returns (uint256){
    // can't underflow becuase endWithdrawalTime > startTime
    uint256 bonusTime = self.endWithdrawalTime - self.base.startTime;
    // can't underflow because now > startTime
    uint256 elapsed = now - self.base.startTime;
    uint256 percentElapsed = (elapsed * 100)/bonusTime;

    bool err;
    uint256 currentBonus;
    (err,currentBonus) = self.priceBonusPercent.minus(((percentElapsed * self.priceBonusPercent)/100));
    require(!err);

    return currentBonus;
  }

  /// @dev Called when an address wants to submit bid to the sale
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _amount amound of wei that the buyer is sending
  /// @param _personalCap the total crowdsale valuation (wei) that the bidder is comfortable with
  /// @param _valuePredict prediction of where the valuation will go in the linked list. saves on searching time
  /// @return true on succesful bid
  function submitBid(InteractiveCrowdsaleStorage storage self,
                      uint256 _amount,
                      uint256 _personalCap,
                      uint256 _valuePredict) public returns (bool)
  {
    require(msg.sender != self.base.owner);
    require(self.base.validPurchase());
    // bidder can't have already bid
    require((self.personalCaps[msg.sender] == 0) && (self.base.hasContributed[msg.sender] == 0));

    uint256 _bonusPercent;
    // token purchase bonus only applies before the withdrawal lock
    if (now < self.endWithdrawalTime) {
      require(_personalCap > _amount);
      _bonusPercent = getCurrentBonus(self);
    } else {
      // The personal valuation submitted must be greater than the current
      // valuation plus the bid if after the withdrawal lock.
      require(_personalCap >= self.totalValuation + _amount);
    }

    // personal valuation and minimum should be set to the proper granularity,
    // only three most significant values can be non-zero. reduces the number of possible
    // valuation buckets in the linked list
    uint256 digits = numDigits(_personalCap);
    if(digits > 3) {
      require((_personalCap % (10**(digits - 3))) == 0);
    }

    // add the bid to the sorted valuations list
    // duplicate personal valuation caps share a spot in the linked list
    uint256 _listSpot;
    if(!self.valuationsList.nodeExists(_personalCap)){
        _listSpot = self.valuationsList.getSortedSpot(_valuePredict,_personalCap,NEXT);
        self.valuationsList.insert(_listSpot,_personalCap,PREV);
    }

    // add the bid to the address => cap mapping
    self.personalCaps[msg.sender] = _personalCap;

    // add the bid to the sum of bids at this valuation. Needed for calculating correct valuation pointer
    self.valuationSums[_personalCap] += _amount;
    self.numBidsAtValuation[_personalCap] += 1;

    // add the bid to bidder's contribution amount
    self.base.hasContributed[msg.sender] += _amount;

    // temp variables for calculation
    uint256 _proposedCommit;
    uint256 _currentBucket;
    bool loop;
    bool exists;

    // we only affect the pointer if we are coming in above it
    if(_personalCap > self.currentBucket){

      // if our valuation is sitting at the current bucket then we are using
      // commitments right at their cap
      if (self.totalValuation == self.currentBucket) {
        // we are going to drop those commitments to see if we are going to be
        // greater than the current bucket without them
        _proposedCommit = (self.valueCommitted - self.valuationSums[self.currentBucket]) + _amount;
        if(_proposedCommit > self.currentBucket){ loop = true; }
      } else {
        // else we're sitting in between buckets and have already dropped the
        // previous commitments
        _proposedCommit = self.totalValuation + _amount;
        loop = true;
      }

      if(loop){
        // if we're going to loop we move to the next bucket
        (exists,_currentBucket) = self.valuationsList.getAdjacent(self.currentBucket, NEXT);

        while(_proposedCommit >= _currentBucket){
          // while we are proposed higher than the next bucket we drop commitments
          // and iterate to the next
          _proposedCommit = _proposedCommit - self.valuationSums[_currentBucket];
          (exists,_currentBucket) = self.valuationsList.getAdjacent(_currentBucket, NEXT);
        }
        // once we've reached a bucket too high we move back to the last bucket and set it
        (exists, _currentBucket) = self.valuationsList.getAdjacent(_currentBucket, PREV);
        self.currentBucket = _currentBucket;
      } else {
        // else we're staying at the current bucket
        _currentBucket = self.currentBucket;
      }
      // if our proposed commitment is less than or equal to the bucket
      if(_proposedCommit <= _currentBucket){
        // we add the commitments in that bucket
        _proposedCommit += self.valuationSums[_currentBucket];
        // and our value is capped at that bucket
        self.totalValuation = _currentBucket;
      } else {
        // else our total value is in between buckets and it equals the total commitements
        self.totalValuation = _proposedCommit;
      }

      self.valueCommitted = _proposedCommit;
    } else if(_personalCap == self.totalValuation){
      self.valueCommitted += _amount;
    }

    self.pricePurchasedAt[msg.sender] = (self.base.tokensPerEth * (100 + _bonusPercent))/100;
    LogBidAccepted(msg.sender, _amount, _personalCap);
    BucketAndValuationAndCommitted(self.currentBucket, self.totalValuation, self.valueCommitted);
    return true;
  }


  /// @dev Called when an address wants to manually withdraw their bid from the
  ///      sale. puts their wei in the LeftoverWei mapping
  /// @param self Stored crowdsale from crowdsale contract
  /// @return true on succesful
  function withdrawBid(InteractiveCrowdsaleStorage storage self) public returns (bool) {
    // The sender has to have already bid on the sale
    require(self.personalCaps[msg.sender] > 0);

    uint256 refundWei;
    // cannot withdraw after compulsory withdraw period is over unless the bid's
    // valuation is below the cutoff
    if (now >= self.endWithdrawalTime) {
      require(self.personalCaps[msg.sender] < self.totalValuation);

      // full refund because their bid no longer affects the total sale valuation
      refundWei = self.base.hasContributed[msg.sender];

    } else {
      require(!self.hasManuallyWithdrawn[msg.sender]);  // manual withdrawals are only allowed once
      /***********************************************************************
      The following lines were commented out due to stack depth, but they represent
      the variables and calculations from the paper. The actual code is the same
      thing spelled out using current variables.  See section 4 of the white paper for formula used
      ************************************************************************/
      //uint256 t = self.endWithdrawalTime - self.base.startTime;
      //uint256 s = now - self.base.startTime;
      //uint256 pa = self.pricePurchasedAt[msg.sender];
      //uint256 pu = self.base.tokensPerEth;
      //uint256 multiplierPercent =  (100*(t - s))/t;
      //self.pricePurchasedAt = pa-((pa-pu)/3)

      uint256 multiplierPercent = (100 * (self.endWithdrawalTime - now)) /
                                  (self.endWithdrawalTime - self.base.startTime);
      refundWei = (multiplierPercent * self.base.hasContributed[msg.sender]) / 100;

      self.valuationSums[self.personalCaps[msg.sender]] -= refundWei;
      self.numBidsAtValuation[self.personalCaps[msg.sender]] -= 1;

      self.pricePurchasedAt[msg.sender] = self.pricePurchasedAt[msg.sender] -
                                          ((self.pricePurchasedAt[msg.sender] - self.base.tokensPerEth) / 3);

      self.hasManuallyWithdrawn[msg.sender] = true;

    }

    // Put the sender's contributed wei into the leftoverWei mapping for later withdrawal
    self.base.leftoverWei[msg.sender] += refundWei;

    // subtract the bidder's refund from its total contribution
    self.base.hasContributed[msg.sender] -= refundWei;


    uint256 _proposedCommit;
    uint256 _proposedValue;
    uint256 _currentBucket;
    bool loop;
    bool exists;

    // bidder's withdrawal only affects the pointer if the personal cap is at or
    // above the current valuation
    if(self.personalCaps[msg.sender] >= self.totalValuation){

      // first we remove the refundWei from the committed value
      _proposedCommit = self.valueCommitted - refundWei;

      // if we've dropped below the current bucket
      if(_proposedCommit <= self.currentBucket){
        // and current valuation is above the bucket
        if(self.totalValuation > self.currentBucket){
          _proposedCommit += self.valuationSums[self.currentBucket];
        }

        if(_proposedCommit >= self.currentBucket){
          _proposedValue = self.currentBucket;
        } else {
          // if we are still below the current bucket then we need to iterate
          loop = true;
        }
      } else {
        if(self.totalValuation == self.currentBucket){
          _proposedValue = self.totalValuation;
        } else {
          _proposedValue = _proposedCommit;
        }
      }

      if(loop){
        // if we're going to loop we move to the previous bucket
        (exists,_currentBucket) = self.valuationsList.getAdjacent(self.currentBucket, PREV);
        while(_proposedCommit <= _currentBucket){
          // while we are proposed lower than the previous bucket we add commitments
          _proposedCommit += self.valuationSums[_currentBucket];
          // and iterate to the previous
          if(_proposedCommit >= _currentBucket){
            _proposedValue = _currentBucket;
          } else {
            (exists,_currentBucket) = self.valuationsList.getAdjacent(_currentBucket, PREV);
          }
        }

        if(_proposedValue == 0) { _proposedValue = _proposedCommit; }

        self.currentBucket = _currentBucket;
      }

      self.totalValuation = _proposedValue;
      self.valueCommitted = _proposedCommit;
    }

    LogBidWithdrawn(msg.sender, refundWei, self.personalCaps[msg.sender]);
    BucketAndValuationAndCommitted(self.currentBucket, self.totalValuation, self.valueCommitted);
    return true;
  }

  /// @dev This should be called once the sale is over to commit all bids into
  ///      the owner's bucket.
  /// @param self stored crowdsale from crowdsale contract
  function finalizeSale(InteractiveCrowdsaleStorage storage self) public returns (bool) {
    require(now >= self.base.endTime);
    require(!self.isFinalized); // can only be called once
    require(setCanceled(self));

    self.isFinalized = true;
    require(launchToken(self));
    // may need to be computed due to EVM rounding errors
    uint256 computedValue;

    if(!self.isCanceled){
      if(self.totalValuation == self.currentBucket){
        // calculate the fraction of each minimal valuation bidders ether and tokens to refund
        self.q = (100*(self.valueCommitted - self.totalValuation)/(self.valuationSums[self.totalValuation])) + 1;
        computedValue = self.valueCommitted - self.valuationSums[self.totalValuation];
        computedValue += (self.q * self.valuationSums[self.totalValuation])/100;
      } else {
        // no computation necessary
        computedValue = self.totalValuation;
      }
      self.base.ownerBalance = computedValue;  // sets ETH raised in the sale to be ready for withdrawal
    }
  }

  /// @dev Mints the token being sold by taking the percentage of the token supply
  ///      being sold in this sale along with the valuation, derives all necessary
  ///      values and then transfers owner tokens to the owner.
  /// @param self Stored crowdsale from crowdsale contract
  function launchToken(InteractiveCrowdsaleStorage storage self) internal returns (bool) {
    // total valuation of all the tokens not including the bonus
    uint256 _fullValue = (self.totalValuation*100)/uint256(self.percentBeingSold);
    // total valuation of bonus tokens
    uint256 _bonusValue = ((self.totalValuation * (100 + self.priceBonusPercent))/100) - self.totalValuation;
    // total supply of all tokens not including the bonus
    uint256 _supply = (_fullValue * self.base.tokensPerEth)/1000000000000000000;
    // total number of bonus tokens
    uint256 _bonusTokens = (_bonusValue * self.base.tokensPerEth)/1000000000000000000;
    // tokens allocated to the owner of the sale
    uint256 _ownerTokens = _supply - ((_supply * uint256(self.percentBeingSold))/100);
    // total supply of tokens not including the bonus tokens
    uint256 _totalSupply = _supply + _bonusTokens;

    // deploy new token contract with total number of tokens
    self.base.token = new CrowdsaleToken(address(this),
                                         self.tokenInfo.name,
                                         self.tokenInfo.symbol,
                                         self.tokenInfo.decimals,
                                         _totalSupply,
                                         self.tokenInfo.stillMinting);

    // if the sale got canceled, then all the tokens go to the owner and bonus tokens are burned
    if(!self.isCanceled){
      self.base.token.transfer(self.base.owner, _ownerTokens);
    } else {
      self.base.token.transfer(self.base.owner, _supply);
      self.base.token.burnToken(_bonusTokens);
    }
    // the owner of the crowdsale becomes the new owner of the token contract
    self.base.token.changeOwner(self.base.owner);
    self.base.startingTokenBalance = _supply - _ownerTokens;

    return true;
  }

  /// @dev returns a boolean indicating if the sale is canceled.
  ///      This can either be if the minimum raise hasn't been met
  ///      or if it is 30 days after the sale and the owner hasn't finalized the sale.
  /// @return bool canceled indicating if the sale is canceled or not
  function setCanceled(InteractiveCrowdsaleStorage storage self) internal returns(bool){
    bool canceled = (self.totalValuation < self.minimumRaise) ||
                    ((now > (self.base.endTime + 30 days)) && !self.isFinalized);

    if(canceled) {self.isCanceled = true;}

    return true;
  }

  /// @dev If the address' personal cap is below the pointer, refund them all their ETH.
  ///      if it is above the pointer, calculate tokens purchased and refund leftoever ETH
  /// @param self Stored crowdsale from crowdsale contract
  /// @return bool success if the contract runs successfully
  function retreiveFinalResult(InteractiveCrowdsaleStorage storage self) public returns (bool) {
    require(now > self.base.endTime);
    require(self.personalCaps[msg.sender] > 0);

    uint256 numTokens;
    uint256 remainder;

    if(!self.isFinalized){
      require(setCanceled(self));
      require(self.isCanceled);
    }

    if (self.isCanceled) {
      // if the sale was canceled, everyone gets a full refund
      self.base.leftoverWei[msg.sender] += self.base.hasContributed[msg.sender];
      self.base.hasContributed[msg.sender] = 0;
      LogErrorMsg(self.totalValuation, "Sale is canceled, all bids have been refunded!");
      return true;
    }

    if (self.personalCaps[msg.sender] < self.totalValuation) {

      // full refund if personal cap is less than total valuation
      self.base.leftoverWei[msg.sender] += self.base.hasContributed[msg.sender];

      // set hasContributed to 0 to prevent participant from calling this over and over
      self.base.hasContributed[msg.sender] = 0;

      return self.base.withdrawLeftoverWei();

    } else if (self.personalCaps[msg.sender] == self.totalValuation) {

      // calculate the portion that this address has to take out of their bid
      uint256 refundAmount = (self.q*self.base.hasContributed[msg.sender])/100;

      // refund that amount of wei to the address
      self.base.leftoverWei[msg.sender] += refundAmount;

      // subtract that amount the address' contribution
      self.base.hasContributed[msg.sender] -= refundAmount;
    }

    LogErrorMsg(self.base.hasContributed[msg.sender],"contribution");
    LogErrorMsg(self.pricePurchasedAt[msg.sender],"price");
    LogErrorMsg(self.q,"percentage");
    // calculate the number of tokens that the bidder purchased
    (numTokens, remainder) = calculateTokenPurchase(self.base.hasContributed[msg.sender],
                                                    self.pricePurchasedAt[msg.sender]);

    // add tokens to the bidders purchase.  can't overflow because it will be under the cap
    self.base.withdrawTokensMap[msg.sender] += numTokens;
    self.valueCommitted = self.valueCommitted - remainder;
    self.base.leftoverWei[msg.sender] += remainder;

    // burn any extra bonus tokens
    uint256 _fullBonus;
    uint256 _fullBonusPrice = (self.base.tokensPerEth*(100 + self.priceBonusPercent))/100;
    (_fullBonus, remainder) = calculateTokenPurchase(self.base.hasContributed[msg.sender], _fullBonusPrice);
    uint256 _leftoverBonus = _fullBonus - numTokens;
    self.base.token.burnToken(_leftoverBonus);

    self.base.hasContributed[msg.sender] = 0;

    // send tokens and leftoverWei to the address calling the function
    self.base.withdrawTokens();

    self.base.withdrawLeftoverWei();

  }



   /*Functions "inherited" from CrowdsaleLib library*/

  function withdrawLeftoverWei(InteractiveCrowdsaleStorage storage self) internal returns (bool) {

    return self.base.withdrawLeftoverWei();
  }

  function withdrawOwnerEth(InteractiveCrowdsaleStorage storage self) internal returns (bool) {

    return self.base.withdrawOwnerEth();
  }

  function crowdsaleActive(InteractiveCrowdsaleStorage storage self) internal view returns (bool) {
    return self.base.crowdsaleActive();
  }

  function crowdsaleEnded(InteractiveCrowdsaleStorage storage self) internal view returns (bool) {
    return self.base.crowdsaleEnded();
  }

  function getPersonalCap(InteractiveCrowdsaleStorage storage self, address _bidder) internal view returns (uint256) {
    return self.personalCaps[_bidder];
  }

  function getTokensSold(InteractiveCrowdsaleStorage storage self) internal view returns (uint256) {
    return self.base.getTokensSold();
  }

}

library CrowdsaleLib {
  using BasicMathLib for uint256;

  struct CrowdsaleStorage {
  	address owner;     //owner of the crowdsale

  	uint256 tokensPerEth;  //number of tokens received per ether
  	uint256 startTime; //ICO start time, timestamp
  	uint256 endTime; //ICO end time, timestamp automatically calculated
    uint256 ownerBalance; //owner wei Balance
    uint256 startingTokenBalance; //initial amount of tokens for sale
    uint256[] milestoneTimes; //Array of timestamps when token price and address cap changes
    uint8 currentMilestone; //Pointer to the current milestone
    uint8 percentBurn; //percentage of extra tokens to burn
    bool tokensSet; //true if tokens have been prepared for crowdsale

    //Maps timestamp to token price and address purchase cap starting at that time
    mapping (uint256 => uint256[2]) saleData;

    //shows how much wei an address has contributed
  	mapping (address => uint256) hasContributed;

    //For token withdraw function, maps a user address to the amount of tokens they can withdraw
  	mapping (address => uint256) withdrawTokensMap;

    // any leftover wei that buyers contributed that didn't add up to a whole token amount
    mapping (address => uint256) leftoverWei;

  	CrowdsaleToken token; //token being sold
  }

  // Indicates when an address has withdrawn their supply of tokens
  event LogTokensWithdrawn(address indexed _bidder, uint256 Amount);

  // Indicates when an address has withdrawn their supply of extra wei
  event LogWeiWithdrawn(address indexed _bidder, uint256 Amount);

  // Logs when owner has pulled eth
  event LogOwnerEthWithdrawn(address indexed owner, uint256 amount, string Msg);

  // Generic Notice message that includes and address and number
  event LogNoticeMsg(address _buyer, uint256 value, string Msg);

  // Indicates when an error has occurred in the execution of a function
  event LogErrorMsg(uint256 amount, string Msg);

  /// @dev Called by a crowdsale contract upon creation.
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _owner Address of crowdsale owner
  /// @param _saleData Array of 3 item sets such that, in each 3 element
  /// set, 1 is timestamp, 2 is price in tokens/eth at that time,
  /// 3 is address token purchase cap at that time, 0 if no address cap
  /// @param _endTime Timestamp of sale end time
  /// @param _percentBurn Percentage of extra tokens to burn
  /// @param _token Token being sold
  function init(CrowdsaleStorage storage self,
                address _owner,
                uint256[] _saleData,
                uint256 _endTime,
                uint8 _percentBurn,
                CrowdsaleToken _token)
                public
  {
  	require(self.owner == 0);
    require(_saleData.length > 0);
    require((_saleData.length%3) == 0); // ensure saleData is 3-item sets
    require(_saleData[0] > (now + 2 hours));
    require(_endTime > _saleData[0]);
    require(_owner > 0);
    require(_percentBurn <= 100);
    self.owner = _owner;
    self.startTime = _saleData[0];
    self.endTime = _endTime;
    self.token = _token;
    self.percentBurn = _percentBurn;

    uint256 _tempTime;
    for(uint256 i = 0; i < _saleData.length; i += 3){
      require(_saleData[i] > _tempTime);
      require(_saleData[i + 1] > 0);
      require((_saleData[i + 2] == 0) || (_saleData[i + 2] >= 100));
      self.milestoneTimes.push(_saleData[i]);
      self.saleData[_saleData[i]][0] = _saleData[i + 1];
      self.saleData[_saleData[i]][1] = _saleData[i + 2];
      _tempTime = _saleData[i];
    }
    changeTokenPrice(self, _saleData[1]);
  }

  /// @dev function to check if the crowdsale is currently active
  /// @param self Stored crowdsale from crowdsale contract
  /// @return success
  function crowdsaleActive(CrowdsaleStorage storage self) public view returns (bool) {
  	return (now >= self.startTime && now <= self.endTime);
  }

  /// @dev function to check if the crowdsale has ended
  /// @param self Stored crowdsale from crowdsale contract
  /// @return success
  function crowdsaleEnded(CrowdsaleStorage storage self) public view returns (bool) {
  	return now > self.endTime;
  }

  /// @dev function to check if a purchase is valid
  /// @param self Stored crowdsale from crowdsale contract
  /// @return true if the transaction can buy tokens
  function validPurchase(CrowdsaleStorage storage self) internal returns (bool) {
    bool nonZeroPurchase = msg.value != 0;
    if (crowdsaleActive(self) && nonZeroPurchase) {
      return true;
    } else {
      LogErrorMsg(msg.value, "Invalid Purchase! Check start time and amount of ether.");
      return false;
    }
  }

  /// @dev Function called by purchasers to pull tokens
  /// @param self Stored crowdsale from crowdsale contract
  /// @return true if tokens were withdrawn
  function withdrawTokens(CrowdsaleStorage storage self) public returns (bool) {
    bool ok;

    if (self.withdrawTokensMap[msg.sender] == 0) {
      LogErrorMsg(0, "Sender has no tokens to withdraw!");
      return false;
    }

    if (msg.sender == self.owner) {
      if(!crowdsaleEnded(self)){
        LogErrorMsg(0, "Owner cannot withdraw extra tokens until after the sale!");
        return false;
      } else {
        if(self.percentBurn > 0){
          uint256 _burnAmount = (self.withdrawTokensMap[msg.sender] * self.percentBurn)/100;
          self.withdrawTokensMap[msg.sender] = self.withdrawTokensMap[msg.sender] - _burnAmount;
          ok = self.token.burnToken(_burnAmount);
          require(ok);
        }
      }
    }

    var total = self.withdrawTokensMap[msg.sender];
    self.withdrawTokensMap[msg.sender] = 0;
    ok = self.token.transfer(msg.sender, total);
    require(ok);
    LogTokensWithdrawn(msg.sender, total);
    return true;
  }

  /// @dev Function called by purchasers to pull leftover wei from their purchases
  /// @param self Stored crowdsale from crowdsale contract
  /// @return true if wei was withdrawn
  function withdrawLeftoverWei(CrowdsaleStorage storage self) public returns (bool) {
    if (self.leftoverWei[msg.sender] == 0) {
      LogErrorMsg(0, "Sender has no extra wei to withdraw!");
      return false;
    }

    var total = self.leftoverWei[msg.sender];
    self.leftoverWei[msg.sender] = 0;
    msg.sender.transfer(total);
    LogWeiWithdrawn(msg.sender, total);
    return true;
  }

  /// @dev send ether from the completed crowdsale to the owners wallet address
  /// @param self Stored crowdsale from crowdsale contract
  /// @return true if owner withdrew eth
  function withdrawOwnerEth(CrowdsaleStorage storage self) public returns (bool) {
    if ((!crowdsaleEnded(self)) && (self.token.balanceOf(this)>0)) {
      LogErrorMsg(0, "Cannot withdraw owner ether until after the sale!");
      return false;
    }

    require(msg.sender == self.owner);
    require(self.ownerBalance > 0);

    uint256 amount = self.ownerBalance;
    self.ownerBalance = 0;
    self.owner.transfer(amount);
    LogOwnerEthWithdrawn(msg.sender,amount,"Crowdsale owner has withdrawn all funds!");

    return true;
  }

  /// @dev Function to change the price of the token
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _tokensPerEth new token price (amount of tokens per ether)
  /// @return true if the token price changed successfully
  function changeTokenPrice(CrowdsaleStorage storage self,
                            uint256 _tokensPerEth)
                            internal
                            returns (bool)
  {
  	require(_tokensPerEth > 0);

    self.tokensPerEth = _tokensPerEth;

    return true;
  }

  /// @dev function to set tokens for the sale
  /// @param self Stored Crowdsale from crowdsale contract
  /// @return true if tokens set successfully
  function setTokens(CrowdsaleStorage storage self) public returns (bool) {
    require(msg.sender == self.owner);
    require(!self.tokensSet);
    require(now < self.endTime);

    uint256 _tokenBalance;

    _tokenBalance = self.token.balanceOf(this);
    self.withdrawTokensMap[msg.sender] = _tokenBalance;
    self.startingTokenBalance = _tokenBalance;
    self.tokensSet = true;

    return true;
  }

  /// @dev Gets the price and buy cap for individual addresses at the given milestone index
  /// @param self Stored Crowdsale from crowdsale contract
  /// @param timestamp Time during sale for which data is requested
  /// @return A 3-element array with 0 the timestamp, 1 the price in cents, 2 the address cap
  function getSaleData(CrowdsaleStorage storage self, uint256 timestamp)
                       public
                       view
                       returns (uint256[3])
  {
    uint256[3] memory _thisData;
    uint256 index;

    while((index < self.milestoneTimes.length) && (self.milestoneTimes[index] < timestamp)) {
      index++;
    }
    if(index == 0)
      index++;

    _thisData[0] = self.milestoneTimes[index - 1];
    _thisData[1] = self.saleData[_thisData[0]][0];
    _thisData[2] = self.saleData[_thisData[0]][1];
    return _thisData;
  }

  /// @dev Gets the number of tokens sold thus far
  /// @param self Stored Crowdsale from crowdsale contract
  /// @return Number of tokens sold
  function getTokensSold(CrowdsaleStorage storage self) public view returns (uint256) {
    return self.startingTokenBalance - self.withdrawTokensMap[self.owner];
  }
}

library LinkedListLib {

    uint256 constant NULL = 0;
    uint256 constant HEAD = 0;
    bool constant PREV = false;
    bool constant NEXT = true;
    
    struct LinkedList{
        mapping (uint256 => mapping (bool => uint256)) list;
    }

    /// @dev returns true if the list exists
    /// @param self stored linked list from contract
    function listExists(LinkedList storage self)
        internal
        view returns (bool)
    {
        // if the head nodes previous or next pointers both point to itself, then there are no items in the list
        if (self.list[HEAD][PREV] != HEAD || self.list[HEAD][NEXT] != HEAD) {
            return true;
        } else {
            return false;
        }
    }

    /// @dev returns true if the node exists
    /// @param self stored linked list from contract
    /// @param _node a node to search for
    function nodeExists(LinkedList storage self, uint256 _node) 
        internal
        view returns (bool)
    {
        if (self.list[_node][PREV] == HEAD && self.list[_node][NEXT] == HEAD) {
            if (self.list[HEAD][NEXT] == _node) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }
    
    /// @dev Returns the number of elements in the list
    /// @param self stored linked list from contract
    function sizeOf(LinkedList storage self) internal view returns (uint256 numElements) {
        bool exists;
        uint256 i;
        (exists,i) = getAdjacent(self, HEAD, NEXT);
        while (i != HEAD) {
            (exists,i) = getAdjacent(self, i, NEXT);
            numElements++;
        }
        return;
    }

    /// @dev Returns the links of a node as a tuple
    /// @param self stored linked list from contract
    /// @param _node id of the node to get
    function getNode(LinkedList storage self, uint256 _node)
        internal view returns (bool,uint256,uint256)
    {
        if (!nodeExists(self,_node)) {
            return (false,0,0);
        } else {
            return (true,self.list[_node][PREV], self.list[_node][NEXT]);
        }
    }

    /// @dev Returns the link of a node `_node` in direction `_direction`.
    /// @param self stored linked list from contract
    /// @param _node id of the node to step from
    /// @param _direction direction to step in
    function getAdjacent(LinkedList storage self, uint256 _node, bool _direction)
        internal view returns (bool,uint256)
    {
        if (!nodeExists(self,_node)) {
            return (false,0);
        } else {
            return (true,self.list[_node][_direction]);
        }
    }

    /// @dev Can be used before `insert` to build an ordered list
    /// @param self stored linked list from contract
    /// @param _node an existing node to search from, e.g. HEAD.
    /// @param _value value to seek
    /// @param _direction direction to seek in
    //  @return next first node beyond '_node' in direction `_direction`
    function getSortedSpot(LinkedList storage self, uint256 _node, uint256 _value, bool _direction)
        internal view returns (uint256)
    {
        if (sizeOf(self) == 0) { return 0; }
        require((_node == 0) || nodeExists(self,_node));
        bool exists;
        uint256 next;
        (exists,next) = getAdjacent(self, _node, _direction);
        while  ((next != 0) && (_value != next) && ((_value < next) != _direction)) next = self.list[next][_direction];
        return next;
    }

    /// @dev Creates a bidirectional link between two nodes on direction `_direction`
    /// @param self stored linked list from contract
    /// @param _node first node for linking
    /// @param _link  node to link to in the _direction
    function createLink(LinkedList storage self, uint256 _node, uint256 _link, bool _direction) internal  {
        self.list[_link][!_direction] = _node;
        self.list[_node][_direction] = _link;
    }

    /// @dev Insert node `_new` beside existing node `_node` in direction `_direction`.
    /// @param self stored linked list from contract
    /// @param _node existing node
    /// @param _new  new node to insert
    /// @param _direction direction to insert node in
    function insert(LinkedList storage self, uint256 _node, uint256 _new, bool _direction) internal returns (bool) {
        if(!nodeExists(self,_new) && nodeExists(self,_node)) {
            uint256 c = self.list[_node][_direction];
            createLink(self, _node, _new, _direction);
            createLink(self, _new, c, _direction);
            return true;
        } else {
            return false;
        }
    }
    
    /// @dev removes an entry from the linked list
    /// @param self stored linked list from contract
    /// @param _node node to remove from the list
    function remove(LinkedList storage self, uint256 _node) internal returns (uint256) {
        if ((_node == NULL) || (!nodeExists(self,_node))) { return 0; }
        createLink(self, self.list[_node][PREV], self.list[_node][NEXT], NEXT);
        delete self.list[_node][PREV];
        delete self.list[_node][NEXT];
        return _node;
    }

    /// @dev pushes an enrty to the head of the linked list
    /// @param self stored linked list from contract
    /// @param _node new entry to push to the head
    /// @param _direction push to the head (NEXT) or tail (PREV)
    function push(LinkedList storage self, uint256 _node, bool _direction) internal  {
        insert(self, HEAD, _node, _direction);
    }
    
    /// @dev pops the first entry from the linked list
    /// @param self stored linked list from contract
    /// @param _direction pop from the head (NEXT) or the tail (PREV)
    function pop(LinkedList storage self, bool _direction) internal returns (uint256) {
        bool exists;
        uint256 adj;

        (exists,adj) = getAdjacent(self, HEAD, _direction);

        return remove(self, adj);
    }
}

library TokenLib {
  using BasicMathLib for uint256;

  struct TokenStorage {
    bool initialized;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    string name;
    string symbol;
    uint256 totalSupply;
    uint256 initialSupply;
    address owner;
    uint8 decimals;
    bool stillMinting;
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event OwnerChange(address from, address to);
  event Burn(address indexed burner, uint256 value);
  event MintingClosed(bool mintingClosed);

  /// @dev Called by the Standard Token upon creation.
  /// @param self Stored token from token contract
  /// @param _name Name of the new token
  /// @param _symbol Symbol of the new token
  /// @param _decimals Decimal places for the token represented
  /// @param _initial_supply The initial token supply
  /// @param _allowMinting True if additional tokens can be created, false otherwise
  function init(TokenStorage storage self,
                address _owner,
                string _name,
                string _symbol,
                uint8 _decimals,
                uint256 _initial_supply,
                bool _allowMinting)
                public
  {
    require(!self.initialized);
    self.initialized = true;
    self.name = _name;
    self.symbol = _symbol;
    self.totalSupply = _initial_supply;
    self.initialSupply = _initial_supply;
    self.decimals = _decimals;
    self.owner = _owner;
    self.stillMinting = _allowMinting;
    self.balances[_owner] = _initial_supply;
  }

  /// @dev Transfer tokens from caller's account to another account.
  /// @param self Stored token from token contract
  /// @param _to Address to send tokens
  /// @param _value Number of tokens to send
  /// @return True if completed
  function transfer(TokenStorage storage self, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    bool err;
    uint256 balance;

    (err,balance) = self.balances[msg.sender].minus(_value);
    require(!err);
    self.balances[msg.sender] = balance;
    //It's not possible to overflow token supply
    self.balances[_to] = self.balances[_to] + _value;
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /// @dev Authorized caller transfers tokens from one account to another
  /// @param self Stored token from token contract
  /// @param _from Address to send tokens from
  /// @param _to Address to send tokens to
  /// @param _value Number of tokens to send
  /// @return True if completed
  function transferFrom(TokenStorage storage self,
                        address _from,
                        address _to,
                        uint256 _value)
                        public
                        returns (bool)
  {
    var _allowance = self.allowed[_from][msg.sender];
    bool err;
    uint256 balanceOwner;
    uint256 balanceSpender;

    (err,balanceOwner) = self.balances[_from].minus(_value);
    require(!err);

    (err,balanceSpender) = _allowance.minus(_value);
    require(!err);

    self.balances[_from] = balanceOwner;
    self.allowed[_from][msg.sender] = balanceSpender;
    self.balances[_to] = self.balances[_to] + _value;

    Transfer(_from, _to, _value);
    return true;
  }

  /// @dev Retrieve token balance for an account
  /// @param self Stored token from token contract
  /// @param _owner Address to retrieve balance of
  /// @return balance The number of tokens in the subject account
  function balanceOf(TokenStorage storage self, address _owner) public view returns (uint256 balance) {
    return self.balances[_owner];
  }

  /// @dev Authorize an account to send tokens on caller's behalf
  /// @param self Stored token from token contract
  /// @param _spender Address to authorize
  /// @param _value Number of tokens authorized account may send
  /// @return True if completed
  function approve(TokenStorage storage self, address _spender, uint256 _value) public returns (bool) {
    // must set to zero before changing approval amount in accordance with spec
    require((_value == 0) || (self.allowed[msg.sender][_spender] == 0));

    self.allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /// @dev Remaining tokens third party spender has to send
  /// @param self Stored token from token contract
  /// @param _owner Address of token holder
  /// @param _spender Address of authorized spender
  /// @return remaining Number of tokens spender has left in owner's account
  function allowance(TokenStorage storage self, address _owner, address _spender)
                     public
                     view
                     returns (uint256 remaining) {
    return self.allowed[_owner][_spender];
  }

  /// @dev Authorize third party transfer by increasing/decreasing allowed rather than setting it
  /// @param self Stored token from token contract
  /// @param _spender Address to authorize
  /// @param _valueChange Increase or decrease in number of tokens authorized account may send
  /// @param _increase True if increasing allowance, false if decreasing allowance
  /// @return True if completed
  function approveChange (TokenStorage storage self, address _spender, uint256 _valueChange, bool _increase)
                          public returns (bool)
  {
    uint256 _newAllowed;
    bool err;

    if(_increase) {
      (err, _newAllowed) = self.allowed[msg.sender][_spender].plus(_valueChange);
      require(!err);

      self.allowed[msg.sender][_spender] = _newAllowed;
    } else {
      if (_valueChange > self.allowed[msg.sender][_spender]) {
        self.allowed[msg.sender][_spender] = 0;
      } else {
        _newAllowed = self.allowed[msg.sender][_spender] - _valueChange;
        self.allowed[msg.sender][_spender] = _newAllowed;
      }
    }

    Approval(msg.sender, _spender, _newAllowed);
    return true;
  }

  /// @dev Change owning address of the token contract, specifically for minting
  /// @param self Stored token from token contract
  /// @param _newOwner Address for the new owner
  /// @return True if completed
  function changeOwner(TokenStorage storage self, address _newOwner) public returns (bool) {
    require((self.owner == msg.sender) && (_newOwner > 0));

    self.owner = _newOwner;
    OwnerChange(msg.sender, _newOwner);
    return true;
  }

  /// @dev Mints additional tokens, new tokens go to owner
  /// @param self Stored token from token contract
  /// @param _amount Number of tokens to mint
  /// @return True if completed
  function mintToken(TokenStorage storage self, uint256 _amount) public returns (bool) {
    require((self.owner == msg.sender) && self.stillMinting);
    uint256 _newAmount;
    bool err;

    (err, _newAmount) = self.totalSupply.plus(_amount);
    require(!err);

    self.totalSupply =  _newAmount;
    self.balances[self.owner] = self.balances[self.owner] + _amount;
    Transfer(0x0, self.owner, _amount);
    return true;
  }

  /// @dev Permanent stops minting
  /// @param self Stored token from token contract
  /// @return True if completed
  function closeMint(TokenStorage storage self) public returns (bool) {
    require(self.owner == msg.sender);

    self.stillMinting = false;
    MintingClosed(true);
    return true;
  }

  /// @dev Permanently burn tokens
  /// @param self Stored token from token contract
  /// @param _amount Amount of tokens to burn
  /// @return True if completed
  function burnToken(TokenStorage storage self, uint256 _amount) public returns (bool) {
      uint256 _newBalance;
      bool err;

      (err, _newBalance) = self.balances[msg.sender].minus(_amount);
      require(!err);

      self.balances[msg.sender] = _newBalance;
      self.totalSupply = self.totalSupply - _amount;
      Burn(msg.sender, _amount);
      Transfer(msg.sender, 0x0, _amount);
      return true;
  }
}

contract CrowdsaleToken {
  using TokenLib for TokenLib.TokenStorage;

  TokenLib.TokenStorage public token;

  function CrowdsaleToken(address owner,
                          string name,
                          string symbol,
                          uint8 decimals,
                          uint256 initialSupply,
                          bool allowMinting) public
  {
    token.init(owner, name, symbol, decimals, initialSupply, allowMinting);
  }

  function name() public view returns (string) {
    return token.name;
  }

  function symbol() public view returns (string) {
    return token.symbol;
  }

  function decimals() public view returns (uint8) {
    return token.decimals;
  }

  function totalSupply() public view returns (uint256) {
    return token.totalSupply;
  }

  function initialSupply() public view returns (uint256) {
    return token.initialSupply;
  }

  function balanceOf(address who) public view returns (uint256) {
    return token.balanceOf(who);
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return token.allowance(owner, spender);
  }

  function transfer(address to, uint value) public returns (bool ok) {
    return token.transfer(to, value);
  }

  function transferFrom(address from, address to, uint value) public returns (bool ok) {
    return token.transferFrom(from, to, value);
  }

  function approve(address spender, uint value) public returns (bool ok) {
    return token.approve(spender, value);
  }

  function approveChange(address spender, uint256 valueChange, bool increase)
                         public returns (bool ok)
  {
    return token.approveChange(spender, valueChange, increase);
  }

  function changeOwner(address newOwner) public returns (bool ok) {
    return token.changeOwner(newOwner);
  }

  function mintToken(uint256 amount) public returns (bool ok) {
    return token.mintToken(amount);
  }

  function closeMint() public returns (bool ok) {
    return token.closeMint();
  }

  function burnToken(uint256 amount) public returns (bool ok) {
    return token.burnToken(amount);
  }
}

library BasicMathLib {
  /// @dev Multiplies two numbers and checks for overflow before returning.
  /// Does not throw.
  /// @param a First number
  /// @param b Second number
  /// @return err False normally, or true if there is overflow
  /// @return res The product of a and b, or 0 if there is overflow
  function times(uint256 a, uint256 b) public pure returns (bool err,uint256 res) {
    assembly{
      res := mul(a,b)
      switch or(iszero(b), eq(div(res,b), a))
      case 0 {
        err := 1
        res := 0
      }
    }
  }

  /// @dev Divides two numbers but checks for 0 in the divisor first.
  /// Does not throw.
  /// @param a First number
  /// @param b Second number
  /// @return err False normally, or true if `b` is 0
  /// @return res The quotient of a and b, or 0 if `b` is 0
  function dividedBy(uint256 a, uint256 b) public pure returns (bool err,uint256 i) {
    uint256 res;
    assembly{
      switch iszero(b)
      case 0 {
        res := div(a,b)
        let loc := mload(0x40)
        mstore(add(loc,0x20),res)
        i := mload(add(loc,0x20))
      }
      default {
        err := 1
        i := 0
      }
    }
  }

  /// @dev Adds two numbers and checks for overflow before returning.
  /// Does not throw.
  /// @param a First number
  /// @param b Second number
  /// @return err False normally, or true if there is overflow
  /// @return res The sum of a and b, or 0 if there is overflow
  function plus(uint256 a, uint256 b) public pure returns (bool err, uint256 res) {
    assembly{
      res := add(a,b)
      switch and(eq(sub(res,b), a), or(gt(res,b),eq(res,b)))
      case 0 {
        err := 1
        res := 0
      }
    }
  }

  /// @dev Subtracts two numbers and checks for underflow before returning.
  /// Does not throw but rather logs an Err event if there is underflow.
  /// @param a First number
  /// @param b Second number
  /// @return err False normally, or true if there is underflow
  /// @return res The difference between a and b, or 0 if there is underflow
  function minus(uint256 a, uint256 b) public pure returns (bool err,uint256 res) {
    assembly{
      res := sub(a,b)
      switch eq(and(eq(add(res,b), a), or(lt(res,a), eq(res,a))), 1)
      case 0 {
        err := 1
        res := 0
      }
    }
  }
}