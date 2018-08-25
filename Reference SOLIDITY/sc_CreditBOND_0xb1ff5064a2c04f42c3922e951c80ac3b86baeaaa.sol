/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.8;

contract CreditBOND {
    
    uint public yearlyBlockCount = 2102400;
    
    function getBondMultiplier(uint _creditAmount, uint _locktime) constant returns (uint bondMultiplier){

        if (_locktime >= block.number + yearlyBlockCount * 2) { return 0; }
        
        uint answer = 0;
        if (_locktime > block.number){
            if (_locktime < 175200 + block.number){ // 1 month
                answer = 1;
            }else if(_locktime < 525600 + block.number){ // 3 months
                answer = 3;
            }else if(_locktime < 1051200 + block.number){ // 6 months
                answer = 6;
            }else if (_locktime < 2102400 + block.number){ // 12 months
                answer = 8;
            }else{
                answer = 12;
            }
        }
        return answer;
    }
    
    function getNewCoinsIssued(uint _lockedBalance, uint _blockDifference, uint _percentReward) constant returns(uint newCoinsIssued){
        return (_percentReward*_lockedBalance*_blockDifference)/(100*yearlyBlockCount);
    }
}