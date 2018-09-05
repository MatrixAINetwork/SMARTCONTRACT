/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract ZipperWithdrawalRight
{
    address realzipper;

    function ZipperWithdrawalRight(address _realzipper) public
    {
        realzipper = _realzipper;
    }
    
    function withdraw(MultiSigWallet _wallet, uint _value) public
    {
        require (_wallet.isOwner(msg.sender));
        require (_wallet.isOwner(this));
        
        _wallet.submitTransaction(msg.sender, _value, "");
    }

    function changeRealZipper(address _newRealZipper) public
    {
        require(msg.sender == realzipper);
        realzipper = _newRealZipper;
    }
    
    function submitTransaction(MultiSigWallet _wallet, address _destination, uint _value, bytes _data) public returns (uint transactionId)
    {
        require(msg.sender == realzipper);
        return _wallet.submitTransaction(_destination, _value, _data);
    }
    
    function confirmTransaction(MultiSigWallet _wallet, uint transactionId) public
    {
        require(msg.sender == realzipper);
        _wallet.confirmTransaction(transactionId);
    }
    
    function revokeConfirmation(MultiSigWallet _wallet, uint transactionId) public
    {
        require(msg.sender == realzipper);
        _wallet.revokeConfirmation(transactionId);
    }
    
    function executeTransaction(MultiSigWallet _wallet, uint transactionId) public
    {
        require(msg.sender == realzipper);
        _wallet.confirmTransaction(transactionId);
    }
}

contract ZipperMultisigFactory
{
    address zipper;
    
    function ZipperMultisigFactory(address _zipper) public
    {
        zipper = _zipper;
    }

    function createMultisig() public returns (address _multisig)
    {
        address[] memory addys = new address[](2);
        addys[0] = zipper;
        addys[1] = msg.sender;
        
        MultiSigWallet a = new MultiSigWallet(addys, 2);
        
        MultisigCreated(address(a), msg.sender, zipper);
        
        return address(a);
    }
    
    function changeZipper(address _newZipper) public
    {
        require(msg.sender == zipper);
        zipper = _newZipper;
    }

    event MultisigCreated(address _multisig, address indexed _sender, address indexed _zipper);
}


    // b7f01af8bd882501f6801eb1eea8b22aa2a4979e from https://github.com/gnosis/MultiSigWallet/blob/master/contracts/MultiSigWallet.sol
    
    /// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
    /// @author Stefan George - <