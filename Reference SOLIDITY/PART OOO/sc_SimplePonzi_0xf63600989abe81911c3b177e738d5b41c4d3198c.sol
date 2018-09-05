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
        require(msg.value > currentInvestment);
        
        // payout previous investor
        currentInvestor.send(msg.value);

        // document new investment
        currentInvestor = msg.sender;
        currentInvestment = msg.value;

    }
}