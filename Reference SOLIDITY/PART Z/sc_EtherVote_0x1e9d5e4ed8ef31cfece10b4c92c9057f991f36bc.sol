/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/* 
Based on a contract built by Vlad and Vitalik for Ether signal
If you need a license, refer to WTFPL.
*/

contract EtherVote {
    event LogVote(bytes32 indexed proposalHash, bool pro, address addr);
    function vote(bytes32 proposalHash, bool pro) {
        // don't accept ether
        if (msg.value > 0) throw;
        // Log the vote
        LogVote(proposalHash, pro, msg.sender);
    }

    // again, no ether
    function () { throw; }
}