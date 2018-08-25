/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.9;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract DiceRoll is owned {
	uint public minBet = 10 finney;
	uint public maxBet = 2 ether;
	
    enum GameState {
		InProgress,
		PlayerWon,
		PlayerLose
	}
	
	event logStr(
        string str
    );
	event log8(
        uint8 value
    );
	event log256(
        uint value
    );
	event logClassic(
        string str,
        uint8 value
    );
	event logState(
        string str,
        GameState state
    );
	
	struct Game {
		address player;
		uint bet;
		uint8 chance;
		GameState state;
		uint8 seed;
	}

	mapping (address => Game) public games;
	
	modifier gameIsNotInProgress() {
		if (gameInProgress(games[msg.sender])) {
			throw;
		}
		_;
	}
	
	modifier betValueIsOk() {
		if (msg.value < minBet || msg.value > maxBet) {
			throw; // incorrect bet
		}
		_;
	}
	
	function gameInProgress(Game game)
		constant
		private
		returns (bool)
	{
		if (game.player == 0) {
			return false;
		}
		if (game.state == GameState.InProgress) {
			return true;
		} else {
			return false;
		}
	}
	
	// starts a new game
	function roll(uint8 chance) 
	    public 
	    payable 
	    gameIsNotInProgress
	    betValueIsOk 
	{
		if (gameInProgress(games[msg.sender])) {
			throw;
		}
        
		Game memory game = Game({
			player: msg.sender,
			bet: msg.value,
			chance: chance,
			state: GameState.InProgress,
			seed: 3,
		});
        
		games[msg.sender] = game;
		
		uint rnd = randomGen(msg.sender, games[msg.sender].seed);
		uint valueMax = chance*100;
		uint bet = msg.value;
		uint payout = bet*100/games[msg.sender].chance;
        uint profit = payout - bet;
        log256(now);
        log256(payout);
        log256(profit);
        log256(bet);
        log8(chance);
		
		if(rnd > valueMax){
		    log8(0);
		    games[msg.sender].state = GameState.PlayerLose;
        } else {
            log8(1);
		     games[msg.sender].state = GameState.PlayerWon;
		     if(!msg.sender.send(payout)) {
	            logStr("Money is not send.");
	        }
        }
        
        //logState("state:", games[msg.sender].state);
	}
	
	function randomGen(address player, uint8) internal returns (uint8) {
		uint b = block.number;
		uint timestamp = block.timestamp;
		return uint8(uint256(keccak256(block.blockhash(b), player, timestamp)) % 10000);
	}
	
	function getGameState() public constant returns (GameState) {
		Game memory game = games[msg.sender];
        
		if (game.player == 0) {
			// game doesn't exist
			throw;
		}

		return game.state;
	}
	
	function getGameChance() public constant returns (uint8) {
		Game memory game = games[msg.sender];
        
		if (game.player == 0) {
			// game doesn't exist
			throw;
		}

		return game.chance;
	}
}