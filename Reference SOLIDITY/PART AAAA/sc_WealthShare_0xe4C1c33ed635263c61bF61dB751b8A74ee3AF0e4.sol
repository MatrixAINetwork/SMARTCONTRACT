/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
//***********************************Wealth Share
//
// Deposit Ether, and Earn Wealth from new depositors. All new deposits will be divided equally between all depositors.
//
//
// Minimum Deposit: 0.2 Ether (200 Finney)
//
//
// Become Wealthy Now!
//
//***********************************START
contract WealthShare {

  struct InvestorArray 
	{
      	address etherAddress;
      	uint amount;
  	}

  InvestorArray[] public depositors;

//********************************************PUBLIC VARIABLES

  uint public Total_Savers=0;
  uint public Fees=0;
  uint public Balance = 0;
  uint public Total_Deposited=0;
  uint public Total_Paid_Out=0;
string public Message="Welcome to Wealth Share deposit Eth, and generate more with it!";
	
  address public owner;

  // simple single-sig function modifier
  modifier onlyowner { if (msg.sender == owner) _ }

//********************************************INIT

  function WealthShare() {
    owner = 0xEe462A6717f17C57C826F1ad9b4d3813495296C9;  //this contract is an attachment to EthVentures
  }

//********************************************TRIGGER

  function() {
    enter();
  }
  
//********************************************ENTER

  function enter() {
    if (msg.value > 200 finney) {

    uint amount=msg.value;


    // add a new participant to the system and calculate total players
    Total_Savers=depositors.length+1;
    depositors.length += 1;
    depositors[depositors.length-1].etherAddress = msg.sender;
    depositors[depositors.length-1].amount = amount;



    // collect Fees and update contract Balance and deposited amount
      	Balance += amount;               // Balance update
      	Total_Deposited+=amount;       		//update deposited amount

      	Fees  = Balance * 1 / 100;    // fee to the owner
	Balance-=Fees;




//********************************EthVenturesFinal Fee Plugin
    // payout Fees to the owner
     if (Fees != 0) 
     {
	uint minimal= 1990 finney;
	if(Fees<minimal)
	{
      	owner.send(Fees);		//send fee to owner
	Total_Paid_Out+=Fees;        //update paid out amount
	}
	else
	{
	uint Times= Fees/minimal;

	for(uint i=0; i<Times;i++)   // send the Fees out in packets compatible to EthVentures dividend function
	if(Fees>0)
	{
	owner.send(minimal);		//send fee to owner
	Total_Paid_Out+=Fees;        //update paid out amount
	Fees-=minimal;
	}
	}
     }
//********************************End Plugin 
 //loop variables
    uint payout;
    uint nr=0;

if(Total_Deposited * 50/100 < Balance )  //if balance is at 50% or higher, then pay depositors
{
  

	
    while (Balance > 0  && nr<depositors.length)  //exit condition to avoid infinite loop
    { 
      payout = Balance / (nr+1);                           	//calculate pay out
      depositors[nr].etherAddress.send(payout);                      	//send pay out to participant
      Balance -= Balance /(nr+1);                         	//Balance update
      Total_Paid_Out += Balance /(nr+1);                 	//update paid out amount
      nr += 1;                                                                         //go to next participant
    }
    
	Message="The Wealth has been paid to Depositors!";
} 
else Message="The Balance has to be at least 50% full to be able to pay out!";

  }

//********************************************SET INTEREST RATE
}


}