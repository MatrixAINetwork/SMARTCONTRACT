/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

/*
  Allows buyers to securely/confidently buy recent ICO tokens that are
  still non-transferrable, on an IOU basis. Like HitBTC, but with protection,
  control, and guarantee of either the purchased tokens or ETH refunded.

  The Buyer's ETH will be locked into the contract until the purchased
  IOU/tokens arrive here and are ready for the buyer to invoke withdraw(),
  OR until cut-off time defined below is exceeded and as a result ETH
  refunds/withdrawals become enabled.

  In other words, the seller must fulfill the IOU token purchases any time
  before the cut-off time defined below, otherwise the buyer gains the
  ability to withdraw their ETH.

  The buyer's ETH will ONLY be released to the seller AFTER the adequate
  amount of tokens have been deposited for ALL purchases.

  Withdrawal/distribution ETA: 2-3 weeks from ICO close
  Cut-off Time: ~ August 15, 2017

  Greetz: Dr. Crypto, blast, meritt, stealth, agent 2o99

  Greetz++: Cintix, for inspiration, withdrawal method, and positive
            contributions to the crypto community.

  