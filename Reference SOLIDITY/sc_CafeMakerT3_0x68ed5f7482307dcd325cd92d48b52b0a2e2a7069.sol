/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract CafeMakerT3 {

	//CafeMaker Counters..
	uint public payed;
	uint public delivered;

	uint public PricePerCafe = 50000000000000000; //0.05 eth
	address public Owner = msg.sender;

//	function CafeMaker(){
//		PricePerCafe = 50000000000000000;
//		Owner = msg.sender; //"0x43e7948F4A71da12f6b79a82bf1C478E9eDB062a";
//	}

	function GetFreeCnt() returns (uint cnt) {
		return payed - delivered;
	}

	function CafeDelivered(){
		delivered += 1;
	}


	function CollectMoney(uint amount){
       if (!Owner.send(amount))
            throw;
		
	}


	//ProcessIncomingPayment
    function () {

		uint addedcafe = msg.value / PricePerCafe;
		payed += addedcafe;

    }
}