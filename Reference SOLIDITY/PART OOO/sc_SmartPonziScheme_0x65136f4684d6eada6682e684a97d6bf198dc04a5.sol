/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.2;


contract SmartPonziScheme{ 
    uint private sender_per_round = 50;
    uint private sender = 0;
    uint public round = 1;
    mapping (uint => uint) public round_earnings;
    mapping (address => uint) private balances;
    mapping (address => uint) public roundin;
    address private owner;

    function SmartPonziScheme() public {
        owner = msg.sender;
    }

    function () public payable {
        if(balances[msg.sender] == 0 && msg.value >= 10000000000000000){
            round_earnings[round] += msg.value;
	    sender += 1;
	    balances[msg.sender] = msg.value;
            roundin[msg.sender] = round;
            if (sender >= sender_per_round){
	        sender_per_round = (sender_per_round * 3) / 2;							
                owner.transfer(round_earnings[round]/100);
                sender = 0;
                round += 1;
            }
         }
         else{
             revert();
         }
        
    }

   function withdraw () public {
       if (roundin[msg.sender]+1 < round){
            uint withdrawAmount = balances[msg.sender];
            uint counter = roundin[msg.sender]+2;
            uint total_value = 0;
            balances[msg.sender] = 0;
            while (counter <= round){
                total_value += round_earnings[counter];
                counter += 1;
            }
            uint payout = (total_value / (2*roundin[msg.sender]*withdrawAmount)) / round_earnings[roundin[msg.sender]] ;
            payout += withdrawAmount;
            msg.sender.transfer(payout);
            
        }
    }
}