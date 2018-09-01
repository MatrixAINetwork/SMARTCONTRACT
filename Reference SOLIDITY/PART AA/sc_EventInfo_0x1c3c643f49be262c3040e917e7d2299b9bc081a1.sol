/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.6;

/**
 * 
 * EventInfo - imutable class that denotes
 * the time of the virtual accelerator hack
 * event
 * 
 */
contract EventInfo{
    
    
    uint constant HACKATHON_5_WEEKS = 60 * 60 * 24 * 7 * 5;
    uint constant T_1_WEEK = 60 * 60 * 24 * 7;

    uint eventStart = 1479391200; // Thu, 17 Nov 2016 14:00:00 GMT
    uint eventEnd = eventStart + HACKATHON_5_WEEKS;
    
    
    /**
     * getEventStart - return the start of the event time
     */ 
    function getEventStart() constant returns (uint result){        
       return eventStart;
    } 
    
    /**
     * getEventEnd - return the end of the event time
     */ 
    function getEventEnd() constant returns (uint result){        
       return eventEnd;
    } 
    
    
    /**
     * getVotingStart - the voting starts 1 week after the 
     *                  event starts
     */ 
    function getVotingStart() constant returns (uint result){
        return eventStart+ T_1_WEEK;
    }

    /**
     * getTradingStart - the DST tokens trading starts 1 week 
     *                   after the event starts
     */ 
    function getTradingStart() constant returns (uint result){
        return eventStart+ T_1_WEEK;
    }

    /**
     * getNow - helper class to check what time the contract see
     */
    function getNow() constant returns (uint result){        
       return now;
    } 
    
}