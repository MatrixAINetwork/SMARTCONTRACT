/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;

contract AffiliateNetwork {
    uint public idx = 0;
    mapping (uint => address) public affiliateAddresses;
    mapping (address => uint) public affiliateCodes;

    function () payable {
        if (msg.value > 0) {
            msg.sender.transfer(msg.value);
        }

        addAffiliate();
    }

    function addAffiliate() {
        if (affiliateCodes[msg.sender] != 0) { return; }

        idx += 1;   // first assigned code will be 1
        affiliateAddresses[idx] = msg.sender;
        affiliateCodes[msg.sender] = idx;
    }
}