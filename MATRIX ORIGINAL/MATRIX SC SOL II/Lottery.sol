pragma solidity ^0.4.21;

contract Lottery {
    //setting manager
    address public manager;
    //players array
    address[] players;
    address winnerPlayers;
    uint battingEther = .01 ether;
    
    function Lottery() public {
        manager = msg.sender;
    }
    
    //enter
    function enter() public payable{
        //ether deposit
        require(msg.value > battingEther);
        players.push(msg.sender);
    }
    
    //random
    function random() private view returns (uint){
        return uint(keccak256(block.difficulty, now, players));
    }
    
    //pickWinner
    //check execute from only manager
    function pickWinner() public restricted {
        //pick the random pickWinner
        uint index = random() % players.length;
        //send the all money
        address contractAddress = this;
        winnerPlayers = players[index];
        winnerPlayers.transfer( contractAddress.balance );
        // init players
        players = new address[](0);
    }
    
    //get the players
    function getPlayers() public view returns (address[]) {
        //check manager
        return players;
    }
    
    function getWinnerPlayer() public view returns (address) {
        return winnerPlayers;
    }

    //restricted
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
}