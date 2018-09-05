/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.20;

contract Lottery {
    address public manager;
    address[] public players;
    address public lastWinner;
    address[] public lastConsolationPrize;
    uint[] consolationPrizeIndexes;
    bool public lockGate = false;
    
    function Lottery() public {
        manager = msg.sender;
    }
    modifier restricted(){
        require(msg.sender == manager);
        _;
    }
    function compareByte(string _a, string _b) returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }
    /// @dev Compares two strings and returns true iff they are equal.
    function equal(string _a, string _b) returns (bool) {
        return compareByte(_a, _b) == 0;
    }
    function enter(string message) public payable {
        require(lockGate == false);
        require(msg.value == .05 ether && equal(message, "lotto") == true);
        players.push(msg.sender);
    }
    function random() private restricted view returns (uint) {
        return uint(keccak256(block.difficulty, now, players));
    }
    function pickWinner() public restricted {
        lockGate = true;
        uint indexWinner = random() % players.length;
        uint authorPrize = this.balance / 100 * 15; // 12% for marketing 3% for developers
        uint winnerPrize = this.balance / 2;

        lastWinner = players[indexWinner];
        players[indexWinner] = players[players.length - 1];
        delete players[players.length - 1];

        manager.transfer(authorPrize);
        lastWinner.transfer(winnerPrize);
    }
    function getPlayers() public view returns (address[]) {
        return players;
    }
    // Due to cost a lot of gas, Consolation Prize random numbers will be done on server side
    function pickConsolationPrize(uint[] value) public restricted {
        require(lockGate == true);
        consolationPrizeIndexes = value;
        lastConsolationPrize = new address[](0);
        uint consolationLength = consolationPrizeIndexes.length;
        uint consolationPrize = this.balance;
        uint eachConsolationPrize = consolationPrize / consolationLength;
        uint consolationPrizeIndex;
        for (uint index = 0; index < consolationLength; index++) {
            consolationPrizeIndex = consolationPrizeIndexes[index];
            players[consolationPrizeIndex].transfer(eachConsolationPrize);
            lastConsolationPrize.push(players[consolationPrizeIndex]);
        }
        lockGate = false;
        consolationPrizeIndexes = new uint[](0);
        players = new address[](0);
    }
    function getLastConsolationPrize() public view returns (address[]) {
        return lastConsolationPrize;
    }
}