/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Vote {
    address creator;

    function Vote() {
        creator = msg.sender;
    }

    function() {
        if (msg.value > 0) {
            tx.origin.send(msg.value);
        }
    }

    function kill() {
        if (msg.sender == creator) {
            suicide(creator);
        }
    }
}