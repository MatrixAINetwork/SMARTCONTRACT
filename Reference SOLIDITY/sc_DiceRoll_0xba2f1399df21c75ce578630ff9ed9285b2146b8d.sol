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
	uint private countRolls = 0;
	uint private totalEthSended = 0;
    mapping (address => uint) public totalRollsByUser;
    enum GameState {
		InProgress,
		PlayerWon,
		PlayerLose,
		NoBank
	}
	
	event logAdr(
        address str
    );
	event logStr(
        string str
    );
	event log8(
        uint8 value
    );
	event log32(
        uint32 value
    );
	event log256(
        uint value
    );
	event logClassic(
        string str,
        address value
    );
	event logState(
        string str,
        GameState state
    );
	event logCheck(
        uint value1,
        string sign,
        uint value2
    );
	
	struct Game {
		address player;
		uint bet;
		uint chance;
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
	
	function () payable {

	}
	
	// starts a new game
	function roll(uint value) 
	    public 
	    payable 
	    gameIsNotInProgress
	    betValueIsOk 
	{
		if (gameInProgress(games[msg.sender])) {
			throw;
		}
		
		uint bet = msg.value;
		uint payout = bet*(10000-100)/value;
		uint chance = value;
		bool isBank = true;
		
		Game memory game = Game({
			player: msg.sender,
			bet: msg.value,
			chance: chance,
			state: GameState.InProgress,
			seed: 3,
		});
		
    	games[msg.sender] = game;
		
        totalRollsByUser[msg.sender]++;
        
		if(payout > this.balance){
		    isBank = false;
		    games[msg.sender].state = GameState.NoBank;
		    if(msg.sender.send(bet)) {
		    }
		}
		
		if(isBank){
    		countRolls ++;
    		
    		uint rnd = randomGen(msg.sender);
            uint profit = payout - bet;
            logAdr(msg.sender);
            log256(payout);
            log256(profit);
            log256(bet);
            log256(chance);
    
    		
    		if(rnd > value){
    		    log8(0);
    		    games[msg.sender].state = GameState.PlayerLose;
            } else {
                log8(1);
                
    		    games[msg.sender].state = GameState.PlayerWon;
    		    if(msg.sender.send(payout)) {
    	            totalEthSended += payout;
    	        } else {
    	            logStr("Money is not send.");
    	        }
            }
		}
		logState("state:", games[msg.sender].state);
	}
	
	function randomGen(address player) private returns (uint) {
		uint b = block.number;
		uint timestamp = block.timestamp;
		return uint(uint256(keccak256(block.blockhash(b), player, timestamp)) % 10000);
	}
	
	function getCount() public constant returns (uint) {
		return totalRollsByUser[msg.sender];
	}
	
	function getState() public constant returns (GameState) {
		Game memory game = games[msg.sender];
		
		if (game.player == 0) {
			// game doesn't exist
			throw;
		}

		return game.state;
	}
	
	function getGameChance() public constant returns (uint) {
		Game memory game = games[msg.sender];
        
		if (game.player == 0) {
			// game doesn't exist
			throw;
		}

		return game.chance;
	}
	
	function getTotalRollMade() public constant returns (uint) {
		return countRolls;
	}
	
	function getTotalEthSended() public constant returns (uint) {
		return totalEthSended;
	}
}