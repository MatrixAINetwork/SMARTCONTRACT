/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract token {
    function transfer(address _to, uint256 _value);
    function balanceOf(address _owner) constant returns (uint256 balance);	
}

contract TEST_Crowdsale {
    
    token public sharesTokenAddress; 
    address public owner;
    address public safeContract;

	uint public TIMEstartICO = 1513728000; 
	uint public stopICO = 1521504000;
	uint febr20 = 1519084800;
	uint jan20 = 1516406400;
	uint public price = 0.0035 * 1 ether; 
	uint coeff = 100000; 
	
	uint256 public tokenSold = 0;
	uint256 public tokenFree = 0; 
	bool public crowdsaleClosed = false;
    bool public tokenWithdraw = false;
	
	event TokenFree(uint256 value);
	event CrowdsaleClosed(bool value);
    
	function TEST_Crowdsale(address _tokenAddress, address _owner, address _stopScamHolder) {
		owner = _owner;
		sharesTokenAddress = token(_tokenAddress);
		safeContract = _stopScamHolder;
	}

	function() payable {
	    
	    if(now > febr20) price = 0.0105 * 1 ether; 
	    else if(now > jan20) price = 0.0070 * 1 ether; 
	    
		tokenFree = sharesTokenAddress.balanceOf(this);
		
		if (now < TIMEstartICO) {
		    msg.sender.transfer(msg.value);
		}
		else if (now > stopICO) {
			msg.sender.transfer(msg.value);
			if(!tokenWithdraw){ 
			    sharesTokenAddress.transfer(safeContract, sharesTokenAddress.balanceOf(this));
			    tokenFree = sharesTokenAddress.balanceOf(this);
			    tokenWithdraw = true;
			    crowdsaleClosed = true;
			}
		} 
		else if (crowdsaleClosed) {
			msg.sender.transfer(msg.value); 
		} 
		else {
			uint256 tokenToBuy = msg.value / price * coeff; 
			if(tokenToBuy <= 0) msg.sender.transfer(msg.value); 
			require(tokenToBuy > 0);
			uint256 actualETHTransfer = tokenToBuy * price / coeff;
			if (tokenFree >= tokenToBuy) { 
				owner.transfer(actualETHTransfer);
				if (msg.value > actualETHTransfer){ 
					msg.sender.transfer(msg.value - actualETHTransfer);
				}
				sharesTokenAddress.transfer(msg.sender, tokenToBuy);
				tokenSold += tokenToBuy;
				tokenFree -= tokenToBuy;
				if(tokenFree==0) crowdsaleClosed = true;
			} else { 
				uint256 sendETH = tokenFree * price / coeff;
				owner.transfer(sendETH); 
				sharesTokenAddress.transfer(msg.sender, tokenFree); 
				msg.sender.transfer(msg.value - sendETH); 
				tokenSold += tokenFree;
				tokenFree = sharesTokenAddress.balanceOf(this);
				crowdsaleClosed = true;
			}
		}
		TokenFree(tokenFree);
		CrowdsaleClosed(crowdsaleClosed);
	}
}