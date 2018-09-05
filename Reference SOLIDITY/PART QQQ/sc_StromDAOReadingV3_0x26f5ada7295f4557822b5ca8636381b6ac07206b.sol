/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract StromDAOReadingV3  {
    
   mapping(address=>uint256) public readings;
   event pinged(address link,uint256 time,uint256 total,uint256 delta);
   
   function pingDelta(uint256 _delta) {
       readings[msg.sender]+=_delta;
       pinged(msg.sender,now,readings[msg.sender],_delta);
   }
   
   function pingReading(uint256 _reading) {
       pinged(msg.sender,now,_reading,_reading-readings[msg.sender]);
       readings[msg.sender]=_reading;
   }
}