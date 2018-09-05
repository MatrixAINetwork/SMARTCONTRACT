/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract PlsDontPress {
    
    address public feePayee;
    address public lastPresser;
    
    uint public currentPot;
    
    uint public currentExpiryInterval = 1 days;
    uint public expiryEpoch;
    uint expiryIntervalCap = 60;
    uint public startingCostToPress = 1000000000000000; //0.001 eth
    uint public currentCostToPress = 1000000000000000; //0.001 eth
    uint public lastAmountSent = startingCostToPress;
    
    uint public minPotSum = 10000000000000000; //0.01 eth
    
    bool private locked;
    
    modifier noReentrancy() {
        require(!locked);
        locked = true;
        _;
        locked = false;
  }
  
    function PlsDontPress() {
        feePayee = msg.sender;
    }
    
    function press() public payable noReentrancy {
        //Min starting sum required
        require(msg.value >= startingCostToPress);
        uint currAmt = startingCostToPress;
        
        //If button not expired, require currentCostToPress to continue
        if(!isExpired()){
            require(msg.value >= currentCostToPress);
            currAmt = msg.value;
        }
            //Finally, update state
            setNextExpiry(currAmt);
            lastPresser = msg.sender;
            lastAmountSent = currAmt;
            currentPot = this.balance;
    }
    
    function isExpired() internal returns(bool) {
        
        //If expired, payout and reset
        if(now > expiryEpoch && expiryEpoch != 0){
            payout();
            currentCostToPress = startingCostToPress;
            currentExpiryInterval = 1 days;
            
            //Accept only startingCostToPress
            if(msg.value > startingCostToPress){
                uint refundAmt = msg.value - startingCostToPress;
                msg.sender.transfer(refundAmt);
            }
            return true;
        }
        else{
            return false;
        }
    }
    
    function payout() internal {
        uint amtToPay;
        //Time expired for last press, pay .1% fees for gas+hosting
        uint fees = currentPot/1000;
        feePayee.transfer(fees);
        
        if(currentPot <= minPotSum * 2){
            // if pool amt is running low, pay 50%
            amtToPay = currentPot / 2;
        } else {
            // else pay all - minSum
            amtToPay = currentPot - minPotSum;
        }
        lastPresser.transfer(amtToPay);
    }
    
    //Calculate button expiry based on amt paid
    function setNextExpiry(uint _amtSent) internal {
        
        //If current amt is > last sent, reduce expiry time interval
        if(_amtSent > lastAmountSent){
            uint epochExpiryReductionPercentage =(lastAmountSent * 100)/ _amtSent;
            uint reducedEpochExpiry = (currentExpiryInterval * epochExpiryReductionPercentage) / 100;
            currentCostToPress = _amtSent;
            
            //If new expiry is below expiryIntervalCap, set as expiryIntervalCap
            if(reducedEpochExpiry < expiryIntervalCap){
                currentExpiryInterval = expiryIntervalCap;
            }else {
                currentExpiryInterval = reducedEpochExpiry;
            }
        }
        
        expiryEpoch = now + currentExpiryInterval;
    
    }
    
    function() external payable {
        press();
    }
  

}