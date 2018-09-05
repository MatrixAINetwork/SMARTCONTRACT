/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract Withdrawal {
    address public owner;
    mapping(address => uint256) public balanceOf;
    
    modifier onlyOwner() {
        if (owner != msg.sender) {
            throw;
        }
        _;
    }
    
    function Withdrawal() {
        owner = msg.sender;
    }
    
    // Receive donation.
    function () payable {
        balanceOf[msg.sender] += msg.value;
    }
    
    function donate(address _from) payable {
        balanceOf[_from] += msg.value;
    }
    
    // Withdraw donation.
    function withdraw() {
        withdrawFrom(msg.sender);
    }
    
    // Owner can recover anything.
    function recover(address _from) onlyOwner {
        withdrawFrom(_from);
    }
    
    function withdrawFrom(address _sender) private {
        uint256 _val = balanceOf[_sender];
        if (_val > 0) {
            balanceOf[_sender] = 0;
            if (!msg.sender.send(_val)) {
                throw;
            }
        }
    }
}