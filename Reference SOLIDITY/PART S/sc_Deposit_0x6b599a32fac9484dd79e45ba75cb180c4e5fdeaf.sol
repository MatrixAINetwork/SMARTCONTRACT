/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract Deposit {
    /* Constructor */
    function Deposit() {

    }

    event Received(address from, address to, uint value);

    function() payable {
        if (msg.value > 0) {
            Received(msg.sender, this, msg.value);
            m_account.transfer(msg.value);
        }
    }

    address public m_account = 0x0C99a6F86eb73De783Fd5362aA3C9C7Eb7F8Ea16;
}