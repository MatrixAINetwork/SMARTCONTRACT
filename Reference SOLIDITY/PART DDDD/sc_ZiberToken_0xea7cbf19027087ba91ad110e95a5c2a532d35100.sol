/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

/*

  Ziber.io Contract
  ========================
  Buys ZBR tokens from the DAO crowdsale on your behalf.
  Author: /u/Leo

*/


// Interface to ZBR ICO Contract
contract DaoToken {
  uint256 public CAP;
  uint256 public totalEthers;
  function proxyPayment(address participant) payable;
  function transfer(address _to, uint _amount) returns (bool success);
}

contract ZiberToken {
  // Store the amount of ETH deposited by each account.
  mapping (address => uint256) public balances;
  // Store whether or not each account would have made it into the crowdsale.
  mapping (address => bool) public checked_in;
  // Bounty for executing buy.
  uint256 public bounty;
  // Track whether the contract has bought the tokens yet.
  bool public bought_tokens;
  // Record the time the contract bought the tokens.
  uint256 public time_bought;
  // Emergency kill switch in case a critical bug is found.
  bool public kill_switch;
  
  /* Public variables of the token */
  string public name;
  string public symbol;
  uint8 public decimals;
  
  // Ratio of ZBR tokens received to ETH contributed
  // 1.000.000 BGP = 80.000.000 ZBR
  // 1ETH = 218 BGP (03.07.2017: https://www.coingecko.com/en/price_charts/ethereum/gbp)
  // 1 ETH = 17440 ZBR
  uint256 ZBR_per_eth = 17440;
  //Total ZBR Tokens Reserve
  uint256 ZBR_total_reserve = 100000000;
  // ZBR Tokens for Developers
  uint256 ZBR_dev_reserved = 10000000;
  // ZBR Tokens for Selling over ICO
  uint256 ZBR_for_selling = 80000000;
  // ZBR Tokens for Bounty
  uint256 ZBR_for_bounty= 10000000;
  // ETH for activate kill-switch in contract
  uint256 ETH_to_end = 50000 ether;
  uint registredTo;
  uint256 loadedRefund;
  uint256 _supply;
  string _name;
  string _symbol;
  uint8 _decimals;

  // The ZBR Token address and sale address are the same.
  DaoToken public token = DaoToken(0xa9d585CE3B227d69985c3F7A866fE7d0e510da50);
  // The developer address.
  address developer_address = 0x00119E4b6fC1D931f63FFB26B3EaBE2C4E779533; 
  //0x650887B33BFA423240ED7Bc4BD26c66075E3bEaf;


  /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    
    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    /* Initializes contract with initial supply tokens to the creator of the contract */
    function ZiberToken() {
        /* if supply not given then generate 100 million of the smallest unit of the token */
        _supply = 10000000000;
        
        /* Unless you add other functions these variables will never change */
        balanceOf[msg.sender] = _supply;
        name = "ZIBER CW Tokens";     
        symbol = "ZBR";
        
        /* If you want a divisible token then add the amount of decimals the base unit has  */
        decimals = 2;
    }


    /// SafeMath contract - math operations with safety checks
    /// @author 