/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract ItsCalledBeingOnTheCuttingEdge {
    
    address Alex;
    address Ben;
    address Chow;
    
    // variables that get written each pay period
    uint256 minsToPay;
    
    bool benAccepts;
    uint256 bensEtherPriceInCents;
    
    bool alexAccepts;
    uint256 alexsEtherPriceInCents;
    
    // hourly wage
    uint16 hourlyWageInCents = 4000;
    
    event PleasePayMe(uint256 minsToPay, uint256 timestamp);
    event Accept(address acceptor, uint256 mins, uint256 etherPrice);
    event Reject(address rejector);
    event Paid(address Chow, uint256 mins, uint256 amt, uint256 timestamp);
    
    function ItsCalledBeingOnTheCuttingEdge(address alex, address ben, address chow) public {
        Alex = alex;
        Ben = ben;
        Chow = chow;
    }
    
    function () public payable {
    }
    
    function payMeFor(uint16 mins) public {
        require(msg.sender == Chow && mins < 20000);
        
        minsToPay = mins;
        // log an event
        PleasePayMe(mins, block.timestamp);
    }
    
    function acceptMins(uint256 etherPriceInCents) public {
        require (minsToPay > 0 && (msg.sender == Ben || msg.sender == Alex));
        
        Accept(msg.sender, minsToPay, etherPriceInCents);
        
        if (msg.sender == Alex){
            if (benAccepts && etherPricesAreClose(bensEtherPriceInCents, etherPriceInCents)){
                // pay Chow
                payChow(bensEtherPriceInCents, etherPriceInCents);
                // toggle off acceptance
                toggleOffAcceptance();
            }
            else {
                alexAccepts = true;
                alexsEtherPriceInCents = etherPriceInCents;
            }
        }
        else if (msg.sender == Ben){
            if (alexAccepts && etherPricesAreClose(bensEtherPriceInCents, etherPriceInCents)){
                // pay Chow
                payChow(alexsEtherPriceInCents, etherPriceInCents);
                // toggleOffAcceptance
                toggleOffAcceptance();
            }
            else {
                benAccepts = true;
                bensEtherPriceInCents = etherPriceInCents;
            }
        }
    }
    
    function rejectHours() public {
        require(msg.sender == Alex || msg.sender == Ben);
        // log an event
        Reject(msg.sender);
        
        toggleOffAcceptance();
    }
    
    function etherPricesAreClose(uint256 price1InCents, uint256 price2InCents) public pure returns (bool) {
        if (price1InCents + 1001 > price2InCents && price2InCents + 1001 > price1InCents){
            return true;
        }
        return false;
    }
    
    function toggleOffAcceptance() internal {
        minsToPay = 0;
        alexAccepts = false;
        alexsEtherPriceInCents = 0;
        benAccepts = false;
        bensEtherPriceInCents = 0;
    }
    
    function payChow(uint256 price1InCents, uint256 price2InCents) internal {
        uint256 actualPriceInCents = (price1InCents + price2InCents) / 2;
        uint256 weiPerMin = (1e18 / actualPriceInCents) * hourlyWageInCents / 60;
        uint256 payment = weiPerMin * minsToPay;
        
        Chow.transfer(payment);
        
        Paid(Chow, minsToPay, payment, block.timestamp);
        
        toggleOffAcceptance();
    }

    function newAlex(address alex) public {
        require(msg.sender == Alex);
        
        Alex = alex;
    }
    
    function newBen(address ben) public {
        require(msg.sender == Ben);
        
        Ben = ben;
    }
    
    function newChow(address chow) public {
        require(msg.sender == Chow);
        
        Chow = chow;
    }
    
    function newWage(uint16 wageInCents) public {
        require(msg.sender == Alex || msg.sender == Ben);
        
        hourlyWageInCents = wageInCents;
    }
    
    function selfDestruct() public {
        require(msg.sender == Alex || msg.sender == Ben);
        
        selfdestruct(msg.sender);
    }

}