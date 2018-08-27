/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract token {
    function transfer(address receiver, uint256 amount);
    function balanceOf(address _owner) constant returns (uint256 balance);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
}

contract bkfkCrowdsale {
    using SafeMath for uint256;
    
    address public beneficiary;
    uint256 public fundingGoal;
    uint256 public amountRaised;
    uint256 public preSaleStartdate;
    uint256 public preSaleDeadline;
    uint256 public mainSaleStartdate;
    uint256 public mainSaleDeadline;
    uint256 public preSaleprice;
    uint256 public mainSaleprice;
    uint256 public fundTransferred;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;

    //event GoalReached(address recipient, uint256 totalAmountRaised);
    //event FundTransfer(address backer, uint256 amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function bkfkCrowdsale() {
        beneficiary = 0x007FB3e94dCd7C441CAA5b87621F275d199Dff81;
        fundingGoal = 5720 ether;
        preSaleStartdate = 1522972800;
        preSaleDeadline = 1524268800;
        mainSaleStartdate = 1524787200;
        mainSaleDeadline = 1528502400;
        preSaleprice = 0.00001 ether;
        mainSaleprice = 0.00003 ether;
        tokenReward = token(0xE6AcB21DE14c12086663b442120F8504093635D9);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable {
        require(!crowdsaleClosed);
        uint256 bonus;
        uint256 amount = msg.value;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        amountRaised = amountRaised.add(amount);
        
        //add bounus for funders
        if(now >= preSaleStartdate && now <= preSaleDeadline ){
            amount =  amount.div(preSaleprice);
        }
        else if(now >= mainSaleStartdate && now <= mainSaleStartdate + 24 hours ){
            amount =  amount.div(mainSaleprice);
            bonus = amount.mul(40).div(100);
            amount = amount.add(bonus);
        }
        else if(now > mainSaleStartdate + 24 hours && now <= mainSaleStartdate + 24 hours + 1 weeks ){
            amount =  amount.div(mainSaleprice);
            bonus = amount.mul(30).div(100);
            amount = amount.add(bonus);
        }
        else if(now > mainSaleStartdate + 24 hours + 1 weeks && now <= mainSaleStartdate + 24 hours + 2 weeks ){
            amount =  amount.div(mainSaleprice);
            bonus = amount.mul(25).div(100);
            amount = amount.add(bonus);
        } 
        else if(now > mainSaleStartdate + 24 hours + 2 weeks && now <= mainSaleStartdate + 24 hours + 3 weeks ){
            amount =  amount.div(mainSaleprice);
            bonus = amount.mul(20).div(100);
            amount = amount.add(bonus);
        } 
        else if(now > mainSaleStartdate + 24 hours + 3 weeks && now <= mainSaleStartdate + 24 hours + 4 weeks ){
            amount =  amount.div(mainSaleprice);
            bonus = amount.mul(15).div(100);
            amount = amount.add(bonus);
        }
        else if(now > mainSaleStartdate + 24 hours + 4 weeks && now <= mainSaleStartdate + 24 hours + 5 weeks ){
            amount =  amount.div(mainSaleprice);
            bonus = amount.mul(10).div(100);
            amount = amount.add(bonus);
        } else {
            amount =  amount.div(mainSaleprice);
            bonus = amount.mul(5).div(100);
            amount = amount.add(bonus);
        }
        
        amount = amount.mul(100000000);
        tokenReward.transfer(msg.sender, amount);
        //FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() { if (now >= mainSaleDeadline) _; }

    /**
     *ends the campaign after deadline
     */
     
    function endCrowdsale() afterDeadline {
        crowdsaleClosed = true;
    }
    
    function getTokensBack() {
        uint256 remaining = tokenReward.balanceOf(this);
        if(msg.sender == beneficiary){
           tokenReward.transfer(beneficiary, remaining); 
        }
    }

    /**
     * Withdraw the funds
     */
    function safeWithdrawal() {
        if (beneficiary == msg.sender) {
            if(fundTransferred != amountRaised){
               uint256 transferfund;
               transferfund = amountRaised.sub(fundTransferred);
               fundTransferred = fundTransferred.add(transferfund);
               beneficiary.send(transferfund);
            } 
        }
    }
}