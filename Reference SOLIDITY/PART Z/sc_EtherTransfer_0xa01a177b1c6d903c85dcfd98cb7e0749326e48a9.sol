/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.20;


contract EtherTransfer {

    address public owner;
    address public to;
    bool public isAutoFowarding;

    event FundTransfer(address backer, uint amount, bool isContribution);

    modifier onlyBy(address _account)
    {
        require (msg.sender != _account);
        _;
    }

    function changeOwner(address _newOwner)
        onlyBy(owner)
    {
        owner = _newOwner;
    }

    function turnOn(address _owner)
        onlyBy(owner)
    {
        isAutoFowarding = true;
    }

    function turnOff(address _owner)
        onlyBy(owner)
    {
        isAutoFowarding = false;
    }

    /**
     * Constructor function
     *
     *
     */
    function EtherTransfer() {
        owner = msg.sender;
        to = 0x75461D0b6623E9F4FC08CB34d5d57B44dac13Db4;
        isAutoFowarding = true;
    }

    /**
     * Fallback function
     *
     *
     */
    function () payable {

        uint amount = msg.value;
        require(isAutoFowarding);
        require(amount>0);
        to.transfer(amount);
        FundTransfer(msg.sender, amount, true);
    }


}