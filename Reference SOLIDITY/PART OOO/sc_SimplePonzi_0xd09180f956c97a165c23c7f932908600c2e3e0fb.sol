/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract SimplePonzi {
    address public currentInvestor;
    uint public currentInvestment = 0;
    
    function () payable public {
        // new investments must be 10% greater than current
        uint minimumInvestment = currentInvestment * 11 / 10;
        require(msg.value > minimumInvestment);

        // document new investor
        address previousInvestor = currentInvestor;
        currentInvestor = msg.sender;
        currentInvestment = msg.value;

        
        // payout previous investor
        previousInvestor.send(msg.value);
    }
}