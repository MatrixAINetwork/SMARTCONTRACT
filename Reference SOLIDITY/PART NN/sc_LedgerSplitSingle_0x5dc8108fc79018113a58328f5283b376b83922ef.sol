/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract AmIOnTheFork {
    function forked() constant returns(bool);
}

contract LedgerSplitSingle {
    // Fork oracle to use
    AmIOnTheFork amIOnTheFork = AmIOnTheFork(0x2bd2326c993dfaef84f696526064ff22eba5b362);

    // Splits the funds on a single chain
    function split(bool forked, address target) returns(bool) {
        if (amIOnTheFork.forked() && forked && target.send(msg.value)) {
            return true;
        } 
        else
        if (!amIOnTheFork.forked() && !forked && target.send(msg.value)) {
            return true;
        } 
        throw; // don't accept value transfer, otherwise it would be trapped.
    }

    // Reject value transfers.
    function() {
        throw;
    }
}