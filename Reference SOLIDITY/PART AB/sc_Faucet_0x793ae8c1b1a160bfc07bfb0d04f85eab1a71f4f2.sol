/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Faucet {
    uint256 sendAmount;
    mapping (address => uint) lastSent;
    uint blockLimit;
    function Faucet(){
        
	sendAmount = 10000000000000000;
        blockLimit = 5760;
    }
	
	function getWei() returns (bool){
	    if(lastSent[msg.sender]<(block.number-blockLimit)&&address(this).balance>sendAmount){
	        msg.sender.send(sendAmount);
	        lastSent[msg.sender] = block.number;
	        return true;
	    } else {
	        return false;
	    }
	}
	
}