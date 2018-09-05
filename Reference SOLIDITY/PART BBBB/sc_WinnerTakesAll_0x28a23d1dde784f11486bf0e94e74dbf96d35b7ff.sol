/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.4;
// 6 Player, winner takes all
// 6P-WTA-0.005 Version 1.2
// - updated version tracking system
// - changed bet to 0.005
// - changed default function title

contract WinnerTakesAll { 
    uint8 public currentPlayers;
    uint8 constant public requiredPlayers = 6;
    uint256 constant public requiredBet = 0.005*1e18; // Only acceptable bet is 0.005 ether
    address[requiredPlayers] public players;
    event roundEvent(
        address[requiredPlayers] roundPlayers,
        bytes32[requiredPlayers] roundScores
    );
    
    function WinnerTakesAll() public {
        currentPlayers = 0;
    }
    
    function () public payable correctBet {
        currentPlayers += 1;
        players[currentPlayers-1] = msg.sender;
        if (currentPlayers == requiredPlayers) {
            bytes32 best = 0;
            bytes32[requiredPlayers] memory scores;
            address winner = 0;
            for (uint x = 0 ; x < requiredPlayers ; x++) {
                scores[x] = keccak256(now,players[x]);
                if (scores[x] > best ){
                    best = scores[x];
                    winner = players[x];
                }
            }
            winner.transfer(this.balance);
            currentPlayers = 0;
            roundEvent(players,scores);
        }
    }
    
    modifier correctBet {
        require(msg.value == requiredBet);
        _;
    }
}