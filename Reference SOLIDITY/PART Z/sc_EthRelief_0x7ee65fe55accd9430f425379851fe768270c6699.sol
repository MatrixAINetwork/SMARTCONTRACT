/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/*
 *      ##########################################
 *      ##########################################
 *      ###                                    ###
 *      ###          𝐏𝐥𝐚𝐲 & 𝐖𝐢𝐧 𝐄𝐭𝐡𝐞𝐫          ###
 *      ###                 at                 ###
 *      ###          𝐄𝐓𝐇𝐄𝐑𝐀𝐅𝐅𝐋𝐄.𝐂𝐎𝐌          ###
 *      ###                                    ###
 *      ##########################################
 *      ##########################################
 *
 *      Welcome to the temporary 𝐄𝐭𝐡𝐑𝐞𝐥𝐢𝐞𝐟 contract. It's just
 *      a place-holder for now, with little functionality other 
 *      than being forward compatible with the first version of 
 *      the 𝐄𝐭𝐡𝐑𝐞𝐥𝐢𝐞𝐟 contract in current development. 
 *
 *      This contract acts as a temporary store for the ether 
 *      raised each week from the ticket sales of 𝐄𝐭𝐡𝐞𝐫𝐚𝐟𝐟𝐥𝐞, 
 *      for the future funding of the charitable arm of the 
 *      enterprise. It is the nascent beginnings of a blockchain 
 *      portal for donations to good causes worldwide, driven by a 
 *      decentralized cadre of 𝐋𝐎𝐓 token holders, forming part
 *      of a 𝐃𝐀𝐎 who both own and run 𝐄𝐭𝐡𝐞𝐫𝐚𝐟𝐟𝐥𝐞 & 𝐄𝐭𝐡𝐑𝐞𝐥𝐢𝐞𝐟.
 * 
 *
 *                  𝐄𝐱𝐜𝐢𝐭𝐢𝐧𝐠 𝐭𝐢𝐦𝐞𝐬 - 𝐬𝐭𝐚𝐲 𝐭𝐮𝐧𝐞𝐝!
 *
 *
 *      Learn more and take part at 𝐡𝐭𝐭𝐩𝐬://𝐞𝐭𝐡𝐞𝐫𝐚𝐟𝐟𝐥𝐞.𝐜𝐨𝐦/𝐢𝐜𝐨
 *      If you want to chat to us you have loads of options:
 *      On 𝐓𝐞𝐥𝐞𝐠𝐫𝐚𝐦 @ 𝐡𝐭𝐭𝐩𝐬://𝐭.𝐦𝐞/𝐞𝐭𝐡𝐞𝐫𝐚𝐟𝐟𝐥𝐞
 *      Or on 𝐓𝐰𝐢𝐭𝐭𝐞𝐫 @ 𝐡𝐭𝐭𝐩𝐬://𝐭𝐰𝐢𝐭𝐭𝐞𝐫.𝐜𝐨𝐦/𝐞𝐭𝐡𝐞𝐫𝐚𝐟𝐟𝐥𝐞
 *      Or on 𝐑𝐞𝐝𝐝𝐢𝐭 @ 𝐡𝐭𝐭𝐩𝐬://𝐞𝐭𝐡𝐞𝐫𝐚𝐟𝐟𝐥𝐞.𝐫𝐞𝐝𝐝𝐢𝐭.𝐜𝐨𝐦
 *
 *
 *
 *                                  𝐄𝐭𝐡𝐑𝐞𝐥𝐢𝐞𝐟  
 *      Building the largest source of decentralized altruism in the world!
 *
 *
 */
pragma solidity^0.4.21;

contract ReceiverInterface {
    function receiveEther() external payable {}
}

contract EthRelief {

    bool    upgraded;
    address etheraffle;
    /**
     * @dev  Modifier to prepend to functions rendering them
     *       only callable by the Etheraffle multisig address.
     */
    modifier onlyEtheraffle() {
        require(msg.sender == etheraffle);
        _;
    }
    event LogEtherReceived(address fromWhere, uint howMuch, uint atTime);
    event LogUpgrade(address toWhere, uint amountTransferred, uint atTime);
    /**
     * @dev   Constructor - sets the etheraffle var to the Etheraffle
     *        managerial multisig account.
     *
     * @param _etheraffle   The Etheraffle multisig account.
     */
    function EthRelief(address _etheraffle) {
        etheraffle = _etheraffle;
    }
    /**
     * @dev   Upgrade function transferring all this contract's ether
     *        via the standard receive ether function in the proposed
     *        new disbursal contract.
     *
     * @param _addr    The new disbursal contract address.
     */
    function upgrade(address _addr) onlyEtheraffle external {
        upgraded = true;
        emit LogUpgrade(_addr, this.balance, now);
        ReceiverInterface(_addr).receiveEther.value(this.balance)();
    }
    /**
     * @dev   Standard receive ether function, forward-compatible
     *        with proposed future disbursal contract.
     */
    function receiveEther() payable external {
        emit LogEtherReceived(msg.sender, msg.value, now);
    }
    /**
     * @dev   Set the Etheraffle multisig contract address, in case of future
     *        upgrades. Only callable by the current Etheraffle address.
     *
     * @param _newAddr   New address of Etheraffle multisig contract.
     */
    function setEtheraffle(address _newAddr) onlyEtheraffle external {
        etheraffle = _newAddr;
    }
    /**
     * @dev   selfDestruct - used here to delete this placeholder contract
     *        and forward any funds sent to it on to the final EthRelief
     *        contract once it is fully developed. Only callable by the
     *        Etheraffle multisig.
     *
     * @param _addr   The destination address for any ether herein.
     */
    function selfDestruct(address _addr) onlyEtheraffle {
        require(upgraded);
        selfdestruct(_addr);
    }
    /**
     * @dev   Fallback function that accepts ether and announces it's
     *        arrival via an event.
     */
    function () payable external {
    }
}