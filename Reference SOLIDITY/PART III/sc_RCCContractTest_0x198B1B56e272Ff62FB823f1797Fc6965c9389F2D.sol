/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract RCCContractTest {

        struct TXS {
                address addr;
                uint amount;
        }

        address private myAddress;
        uint amount;
        uint numberOfTXS;
        TXS[] txsVector;

        function RCCContractTest() {
                amount = 0;
                myAddress = this;
        }

        function initDeposit(uint totalAmount) {
                amount = totalAmount;
        }

        function registerTXS(uint txsAmount, address fromAddress) {
                txsVector.push(TXS(fromAddress, txsAmount));
                numberOfTXS = txsVector.length;
        }
        function getTXSAddress(uint index) returns (address) {
                return txsVector[index].addr;
        }
        function getTXSValue(uint index) returns (uint) {
                return txsVector[index].amount;
        }


}