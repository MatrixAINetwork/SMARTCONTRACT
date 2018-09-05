/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

/// ETH sent to the contract address will be split by half and sent to 2 addresses.
contract SplitIt {
    struct SplitAgreement {
        address from;
        address to1;
        address to2;
    }

    address private owner;

    // Sender -> Agreement Owner
    mapping (address => address) private senderToOwner;
    // Agreement Owner -> SplitAgreement
    mapping (address => SplitAgreement) private splitAgreements;

    // Split sent
    event Sent(address from, address to, uint amount);
    // Sent failed, sender refunded
    event Refunded(address from, address to, uint amount);
    // Refund failed, 'agreement owner' refunded
    event OwnerRefunded(address agreementOwner, address from, address to, uint amount);
    // All refunds failed, the balance will be kept by the Contract Owner.
    event Penalty(address agreementOwner, uint amount);

    modifier onlyExecuteBy(address _account)
    {
        require(msg.sender == _account);
        _;
    }

    function SplitIt() public {
        owner = msg.sender;
    }

    function() payable public {
        require(msg.value > 0);
        // if odd number, the contract keep the difference as fee.
        uint splitValue = msg.value / 2;
        processSplit(msg.sender, splitValue);
    }

    function createSplitAgreement(address from, address to1, address to2) public {
        // Require the sender address to not be in use.
        require(senderToOwner[from] == address(0));
        splitAgreements[msg.sender].from = from;
        splitAgreements[msg.sender].to1 = to1;
        splitAgreements[msg.sender].to2 = to2;
        senderToOwner[from] = msg.sender;
    }

    function endSplitAgreement() public {
        address from = splitAgreements[msg.sender].from;
        senderToOwner[from] = address(0);
        splitAgreements[msg.sender].from = address(0);
        splitAgreements[msg.sender].to1 = address(0);
        splitAgreements[msg.sender].to2 = address(0);
    }

    function collectFees() public onlyExecuteBy(owner) {
        msg.sender.transfer(this.balance);
    }

    function processSplit(address from, uint amount) private {
        address agreementOwner = senderToOwner[from];
        require(agreementOwner != address(0));
        processSend(from, splitAgreements[agreementOwner].to1, amount);
        processSend(from, splitAgreements[agreementOwner].to2, amount);
    }

    function processSend(address from, address to, uint amount) private {
        if (to.send(amount)) { // Try to send
            Sent(from, to, amount);
        } else if(from.send(amount)) { // Try to refund the sender
            Refunded(from, to, amount);
        } else if(senderToOwner[from].send(amount)) { // Try to refund the agreement owner
            OwnerRefunded(senderToOwner[from], from, to, amount);
        } else { // The contract owner keeps the funds.
            Penalty(senderToOwner[from], amount);
        }
    }
}