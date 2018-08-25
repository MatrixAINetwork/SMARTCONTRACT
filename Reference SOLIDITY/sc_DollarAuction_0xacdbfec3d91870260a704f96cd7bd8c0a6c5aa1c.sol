/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.17;

contract DollarAuction {

  struct Bid {
    address sender;
    uint amount;
    uint time;
  }

  Bid[] bids;
  uint bidsPtr = 0;
  uint interval = 60;
  uint step = 1;
  uint minBid = 10000000000000000;
  uint total = 0;

  event LogBidMade(address accountAddress, uint amount, uint time);
  event LogBidFailed(address accountAddress, uint amount, uint time);
  event LogBidFinal(address accountAddress, uint amount, uint time, uint profit);
  event LogBidReturned(address accountAddress, uint amount, uint time);
  event LogPayoutFailed(address accountAddress, uint amount, uint time);
  event BidSaved(Bid bid);

  function DollarAuction() {
    bids.length = 100000;
  }

  function bid() public payable returns (bool success) {
      //if (bidsPtr == bids.length -1) bids.length = bids.length + 100;
      uint amount = msg.value;
      uint lastBidAmount = getLastBidAmount();
      address sender = msg.sender;
      uint time = now;
      require(amount > minBid);
      require(amount > (lastBidAmount + step));
      bids[bidsPtr] = Bid({time: now, sender: sender, amount: amount});
      bidsPtr = bidsPtr + 1;
      total = total + amount;
      LogBidMade(sender, amount, time);
      if (isBidFinal()) {
        uint payout = total;
        total = 0;
        if (!sender.send(payout)) {
          total = payout;
          LogPayoutFailed(sender, amount, time);
          return false;
        }
        bidsPtr = 0;
        LogBidFinal(sender, amount, time, total);
      }
      return true;
  }

  function getLastBidAmount() constant public returns (uint lastBidAmount) {
    if (bidsPtr == 0) return 0;
    else return bids[bidsPtr-1].amount;
  }

  function getTotalBidded() constant public returns (uint totalBidded) {
    return total;
  }

  function isBidFinal() constant public returns (bool isFinal) {
    if (bidsPtr <= 1) return false;
    return ((bids[bidsPtr-1].time - bids[bidsPtr-2].time) > interval);
  }

  function getTimeOfLastBid() constant public returns (uint time) {
    if (bidsPtr == 0) return now;
    return bids[bidsPtr-1].time;
  }

  function getMinBid() constant public returns (uint minimumBid) {
    return minBid;
  }

  function () public payable {
    revert();
  }

}