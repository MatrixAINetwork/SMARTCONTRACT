/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.8;

contract SmartRouletteToken 
{
   uint8 public decimals;
   function balanceOf( address who ) external constant returns (uint256);
   function gameListOf( address who ) external constant returns (bool);
   function getItemHolders(uint256 index) external constant returns(address);
   function getCountHolders() external constant returns (uint256);
   function getCountTempHolders() external constant returns(uint256);
   function getItemTempHolders(uint256 index) external constant returns(address);
   function tempTokensBalanceOf( address who ) external constant returns (uint256);
   function transfer( address to, uint256 value) returns (bool ok);
   function transferFrom( address from, address to, uint256 value) returns (bool ok);
}

contract SmartRouletteTokenDividend {

	address developer;
	address manager;

	SmartRouletteToken smartToken;
	uint256 decimal;

	enum Status {Initialized, EthSentWaitingForTokens, TokensReceived, PaymentsSent}

	struct DividendInfo
	{
	   uint256 amountDividend;
	   uint256 amountDividendInTokens;
	   uint256 blockDividend;
	   Status status;
	}

	DividendInfo[] dividendHistory;

	address public gameAddress;

	uint256 public tokensNeededToGetPayment = 1000;


	function SmartRouletteTokenDividend() {
		developer = msg.sender;
		manager = msg.sender;

		// 0xC631333d0451e95E4F20940B04a68fa5602d5eAC
		smartToken = SmartRouletteToken(0xcced5b8288086be8c38e23567e684c3740be4d48); //test 0xc46ed6ba652bd552671a46045b495748cd10fa04 main 0x2a650356bd894370cc1d6aba71b36c0ad6b3dc18
		decimal = 10**uint256(smartToken.decimals());	
		// 0x69000c5653F211164aE2b3Cc47a243db647F7EAb	
	}
	

	modifier isDeveloper(){
		if (msg.sender!=developer) throw;
		_;
	}

	modifier isManager(){
		if (msg.sender!=manager && msg.sender!=developer) throw;
		_;
	}

	function changeTokensLimit(uint256 newTokensLimit) isDeveloper
	{
		tokensNeededToGetPayment = newTokensLimit;
	}
	function dividendCount() constant returns(uint256)
	{
		return dividendHistory.length;
	}


	function changeDeveloper(address new_developer)
	isDeveloper
	{
		if(new_developer == address(0x0)) throw;
		developer = new_developer;
	}

	function changeManager(address new_manager)
	isDeveloper
	{
		if(new_manager == address(0x0)) throw;
		manager = new_manager;
	}

	function kill() isDeveloper {
		suicide(developer);
	}

	function getDividendInfo(uint256 index) constant returns(uint256 amountDividend, uint256 amountDividendInTokens, uint256 blockDividend, Status status)
	{
		amountDividend  = dividendHistory[index].amountDividend;
		amountDividendInTokens = dividendHistory[index].amountDividendInTokens;
		blockDividend   = dividendHistory[index].blockDividend;
		status = dividendHistory[index].status;
	}


	//  get total count tokens (to calculate profit for one token)
	function get_CountProfitsToken() constant returns(uint256)
	{
		uint256 countProfitsTokens = 0;

        mapping(address => bool) uniqueHolders;

		uint256 countHolders = smartToken.getCountHolders();
		for(uint256 i=0; i<countHolders; i++)
		{
			address holder = smartToken.getItemHolders(i);
			if(holder!=address(0x0) && !uniqueHolders[holder])
			{
				uint256 holdersTokens = smartToken.balanceOf(holder);
				if(holdersTokens>0)
				{
					uint256 tempTokens = smartToken.tempTokensBalanceOf(holder);
					if((holdersTokens+tempTokens)/decimal >= tokensNeededToGetPayment)
					{
						uniqueHolders[holder]=true;
						countProfitsTokens += (holdersTokens+tempTokens);
					}
				}
			}
		}

		uint256 countTempHolders = smartToken.getCountTempHolders();
		for(uint256 j=0; j<countTempHolders; j++)
		{
			address temp_holder = smartToken.getItemTempHolders(j);
			if(temp_holder!=address(0x0) && !uniqueHolders[temp_holder])
			{
				uint256 token_balance = smartToken.balanceOf(temp_holder);
				if(token_balance==0)
				{
					uint256 count_tempTokens = smartToken.tempTokensBalanceOf(temp_holder);
					if(count_tempTokens>0 && count_tempTokens/decimal >= tokensNeededToGetPayment)
					{
						uniqueHolders[temp_holder]=true;
						countProfitsTokens += count_tempTokens;
					}
				}
			}
		}
		
		return countProfitsTokens;
	}

	function get_CountAllHolderForProfit() constant returns(uint256){
		uint256 countAllHolders = 0;

		mapping(address => bool) uniqueHolders;

		uint256 countHolders = smartToken.getCountHolders();
		for(uint256 i=0; i<countHolders; i++)
		{
			address holder = smartToken.getItemHolders(i);
			if(holder!=address(0x0) && !uniqueHolders[holder])
			{
				uint256 holdersTokens = smartToken.balanceOf(holder);
				if(holdersTokens>0)
				{
					uint256 tempTokens = smartToken.tempTokensBalanceOf(holder);
					if((holdersTokens+tempTokens)/decimal >= tokensNeededToGetPayment)
					{
						uniqueHolders[holder] = true;
						countAllHolders += 1;
					}
				}
			}
		}

		uint256 countTempHolders = smartToken.getCountTempHolders();
		for(uint256 j=0; j<countTempHolders; j++)
		{
			address temp_holder = smartToken.getItemTempHolders(j);
			if(temp_holder!=address(0x0) && !uniqueHolders[temp_holder])
			{
				uint256 token_balance = smartToken.balanceOf(temp_holder);
				if(token_balance==0)
				{
					uint256 coun_tempTokens = smartToken.tempTokensBalanceOf(temp_holder);
					if(coun_tempTokens>0 && coun_tempTokens/decimal >= tokensNeededToGetPayment)
					{
						uniqueHolders[temp_holder] = true;
						countAllHolders += 1;
					}
				}
			}
		}
		
		return countAllHolders;
	}

	// get holders addresses to make payment each of them
	function get_Holders(uint256 position) constant returns(address[64] listHolders, uint256 nextPosition) 
	{
		uint8 n = 0;		
		uint256 countHolders = smartToken.getCountHolders();
		for(; position < countHolders; position++){			
			address holder = smartToken.getItemHolders(position);
			if(holder!=address(0x0)){
				uint256 holdersTokens = smartToken.balanceOf(holder);
				if(holdersTokens>0){
					uint256 tempTokens = smartToken.tempTokensBalanceOf(holder);
					if((holdersTokens+tempTokens)/decimal >= tokensNeededToGetPayment){
						//
						listHolders[n++] = holder;
						if (n == 64) 
						{
							nextPosition = position + 1;
							return;
						}
					}
				}
			}
		}

		
		if (position >= countHolders)
		{			
			uint256 countTempHolders = smartToken.getCountTempHolders();			
			for(uint256 j=position-countHolders; j<countTempHolders; j++) 
			{							
				address temp_holder = smartToken.getItemTempHolders(j);
				if(temp_holder!=address(0x0)){
					uint256 token_balance = smartToken.balanceOf(temp_holder);
					if(token_balance==0){
						uint256 count_tempTokens = smartToken.tempTokensBalanceOf(temp_holder);
						if(count_tempTokens>0 && count_tempTokens/decimal >= tokensNeededToGetPayment){
							listHolders[n++] = temp_holder;
							if (n == 64) 
							{
								nextPosition = position + 1;
								return;
							}
						}
					}
				}

				position = position + 1;
			}
		}

		nextPosition = 0;
	}

	function get_HoldersProfit(address holder, uint256 amountDividendInTokens) constant returns(uint256){
		uint256 profit = 0;
		if(holder != address(0x0) && amountDividendInTokens > 0)
		{
			uint256 count_tokens = smartToken.balanceOf(holder) + smartToken.tempTokensBalanceOf(holder);
			if(count_tokens/decimal >= tokensNeededToGetPayment){
				profit = (count_tokens * amountDividendInTokens) / get_CountProfitsToken();
			}
		}
		return profit;
	}

	function takeEthForExchange(uint256 dividendPaymentNum) isManager 
	{
		if (dividendHistory[dividendPaymentNum].status == Status.Initialized)
		{
			if (manager.send(dividendHistory[dividendPaymentNum].amountDividend) == false) throw;
			dividendHistory[dividendPaymentNum].status = Status.EthSentWaitingForTokens;
		}		
	}

	function receiveTokens(uint256 dividendPaymentNum,uint256 tokens) isManager
	{
		if (tokens == 0) throw;

		if (dividendHistory[dividendPaymentNum].status == Status.EthSentWaitingForTokens)
		{
			if (!smartToken.transferFrom(msg.sender, this, tokens)) throw;

			dividendHistory[dividendPaymentNum].amountDividendInTokens = tokens;

			dividendHistory[dividendPaymentNum].status = Status.TokensReceived;
		}
	}


	function send_DividendToAddress(address holder, uint256 amount) isManager 
	{
		if (!smartToken.transfer(holder, amount)) throw;
	}

	function paymentsFinished(uint256 dividendPaymentNum) isManager
	{
		if (dividendHistory[dividendPaymentNum].status == Status.TokensReceived) 
		{
			dividendHistory[dividendPaymentNum].status = Status.PaymentsSent;
		}
	}

	function () payable
	{
		if(smartToken.gameListOf(msg.sender))
		{
			// only the one game can be attached to this contract
			if (gameAddress == 0) 
				gameAddress = msg.sender;
			else if (gameAddress != msg.sender)
				throw;

			dividendHistory.push(DividendInfo(msg.value, 0, block.number, Status.Initialized));			
		}
		else 
		{
			throw;
		}
	}
}