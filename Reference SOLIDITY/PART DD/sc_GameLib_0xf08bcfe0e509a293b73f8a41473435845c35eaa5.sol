/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
library ArrayLib {
  // Inserts to keep array sorted (assumes input array is sorted)
	function insertInPlace(uint8[] storage self, uint8 n) {
		uint8 insertingIndex = 0;

		while (self.length > 0 && insertingIndex < self.length && self[insertingIndex] < n) {
			insertingIndex += 1;
		}

		self.length += 1;
		for (uint8 i = uint8(self.length) - 1; i > insertingIndex; i--) {
			self[i] = self[i - 1];
		}

		self[insertingIndex] = n;
	}
}


library DeckLib {
	using ArrayLib for uint8[];

	enum Suit { Spades, Hearts, Clubs, Diamonds }
	uint8 constant cardsPerSuit = 13;
	uint8 constant suits = 4;
	uint8 constant totalCards = cardsPerSuit * suits;

	struct Deck {
		uint8[] usedCards; // always has to be sorted
		address player;
		uint256 gameID;
	}

	function init(Deck storage self, uint256 gameID)  {
		self.usedCards = new uint8[](0);
		self.player = msg.sender;
		self.gameID = gameID;
	}

	function getCard(Deck storage self, uint256 blockNumber)  returns (uint8)  {
		uint cardIndex = self.usedCards.length;
		if (cardIndex >= totalCards) throw;
		uint8 r = uint8(getRandomNumber(blockNumber, self.player, self.gameID, cardIndex, totalCards - cardIndex));

		for (uint8 i = 0; i < cardIndex; i++) {
			if (self.usedCards[i] <= r) r += 1;
		}

		self.usedCards.insertInPlace(r);

		return r;
	}

	function cardDescription(uint8 self) constant returns (Suit, uint8) {
		return (Suit(self / cardsPerSuit), cardFacevalue(self));
	}

	function cardEmojified(uint8 self) constant returns (uint8, string) {
		string memory emojiSuit;

		var (suit, number) = cardDescription(self);
		if (suit == Suit.Clubs) emojiSuit = "♣️";
		else if (suit == Suit.Diamonds) emojiSuit = "♦️";
		else if (suit == Suit.Hearts) emojiSuit = "♥️";
		else if (suit == Suit.Spades) emojiSuit = "♠️";

		return (number, emojiSuit);
	}

	function cardFacevalue(uint8 self) constant returns (uint8) {
		return 1 + self % cardsPerSuit;
	}

	function blackjackValue(uint8 self) constant returns (uint8) {
		uint8 cardValue = cardFacevalue(self);
		return cardValue < 10 ? cardValue : 10;
	}

	function getRandomNumber(uint b, address player, uint256 gameID, uint n, uint m) constant returns (uint) {
		// Uses blockhash as randomness source.
		// Credits: https://github.com/Bunjin/Rouleth/blob/master/Provably_Fair_No_Cheating.md
		bytes32 blockHash = block.blockhash(b);
		if (blockHash == 0x0) throw;
		return uint(uint256(keccak256(blockHash, player, gameID, n)) % m);

	}
}

library GameLib {
  using DeckLib for *;

  uint8 constant houseLimit = 17;
  uint8 constant target = 21;

  enum ComparaisonResult { First, Second, Tie }
  enum GameState { InitialCards, Waiting, Hit, Stand, Finished }
  enum GameResult { Ongoing, House, Tie, Player, PlayerNatural }

  struct Game {
    address player;
    uint256 bet;
    uint256 payout;
    uint256 gameID;

    DeckLib.Deck deck;
    uint8[] houseCards;
    uint8[] playerCards;

    uint256 actionBlock; // Block on which commitment to perform an action happens.

    GameState state;
    GameResult result;

    bool closed;
  }

  function init(Game storage self, uint256 gameID) {
    self.player = msg.sender;
    self.bet = msg.value;
    self.payout = 0;
    self.houseCards = new uint8[](0);
    self.playerCards = new uint8[](0);
    self.actionBlock = block.number;
    self.state = GameState.InitialCards;
    self.result = GameResult.Ongoing;
    self.closed = false;
    self.gameID = gameID;

    self.deck.init(gameID);
  }

  function tick(Game storage self)  returns (bool) {
    if (block.number <= self.actionBlock) return false; // Can't tick yet
    if (self.actionBlock + 255 < block.number) {
      endGame(self, GameResult.House);
      return true;
    }
    if (!needsTick(self)) return true; // not needed, everything is fine

    if (self.state == GameState.InitialCards) dealInitialCards(self);
    if (self.state == GameState.Hit) dealHitCard(self);

    if (self.state == GameState.Stand) {
      dealHouseCards(self);
      checkGameResult(self);
    } else {
      checkGameContinues(self);
    }

    return true;
  }

  function needsTick(Game storage self) constant returns (bool) {
    if (self.state == GameState.Waiting) return false;
    if (self.state == GameState.Finished) return false;

    return true;
  }

  function checkGameResult(Game storage self)  {
    uint8 houseHand = countHand(self.houseCards);

    if (houseHand == target && self.houseCards.length == 2) return endGame(self, GameResult.House); // House natural

    ComparaisonResult result = compareHands(houseHand, countHand(self.playerCards));
    if (result == ComparaisonResult.First) return endGame(self, GameResult.House);
    if (result == ComparaisonResult.Second) return endGame(self, GameResult.Player);

    endGame(self, GameResult.Tie);
  }

  function checkGameContinues(Game storage self)  {
    uint8 playerHand = countHand(self.playerCards);
    if (playerHand == target && self.playerCards.length == 2) return endGame(self, GameResult.PlayerNatural); // player natural
    if (playerHand > target) return endGame(self, GameResult.House); // Player busted
    if (playerHand == target) {
      // Player is forced to stand with 21
      uint256 currentActionBlock = self.actionBlock;
      playerDecision(self, GameState.Stand);
      self.actionBlock = currentActionBlock;
      if (!tick(self)) throw; // Forces tick, commitment to play actually happened past block
    }
  }

  function playerDecision(Game storage self, GameState decision)  {
    if (self.state != GameState.Waiting) throw;
    if (decision != GameState.Hit && decision != GameState.Stand) throw;

    self.state = decision;
    self.actionBlock = block.number;
  }

  function dealInitialCards(Game storage self) private {
    self.playerCards.push(self.deck.getCard(self.actionBlock));
    self.houseCards.push(self.deck.getCard(self.actionBlock));
    self.playerCards.push(self.deck.getCard(self.actionBlock));

    self.state = GameState.Waiting;
  }

  function dealHitCard(Game storage self) private {
    self.playerCards.push(self.deck.getCard(self.actionBlock));

    self.state = GameState.Waiting;
  }

  function dealHouseCards(Game storage self) private {
    self.houseCards.push(self.deck.getCard(self.actionBlock));

    if (countHand(self.houseCards) < houseLimit) dealHouseCards(self);
  }

  function endGame(Game storage self, GameResult result) {
    self.result = result;
    self.state = GameState.Finished;
    self.payout = payoutForResult(self.result, self.bet);

    closeGame(self);
  }

  function closeGame(Game storage self) private {
    if (self.closed) throw; // cannot re-close
    if (self.state != GameState.Finished) throw; // not closable

    self.closed = true;

    if (self.payout > 0) {
      if (!self.player.send(self.payout)) throw;
    }
  }

  function payoutForResult(GameResult result, uint256 bet) private returns (uint256) {
    if (result == GameResult.PlayerNatural) return bet * 5 / 2; // bet + 1.5x bet
    if (result == GameResult.Player) return bet * 2; // doubles bet
    if (result == GameResult.Tie) return bet; // returns bet

    return 0;
  }

  function countHand(uint8[] memory hand)  returns (uint8) {
    uint8[] memory possibleSums = new uint8[](1);

    for (uint i = 0; i < hand.length; i++) {
      uint8 value = hand[i].blackjackValue();
      uint l = possibleSums.length;
      for (uint j = 0; j < l; j++) {
        possibleSums[j] += value;
        if (value == 1) { // is Ace
          possibleSums = appendArray(possibleSums, possibleSums[j] + 10); // Fork possible sum with 11 as ace value.
        }
      }
    }

    return bestSum(possibleSums);
  }

  function bestSum(uint8[] possibleSums)  returns (uint8 bestSum) {
    bestSum = 50; // very bad hand
    for (uint i = 0; i < possibleSums.length; i++) {
      if (compareHands(bestSum, possibleSums[i]) == ComparaisonResult.Second) {
        bestSum = possibleSums[i];
      }
    }
    return;
  }

  function appendArray(uint8[] memory array, uint8 n)  returns (uint8[] memory) {
    uint8[] memory newArray = new uint8[](array.length + 1);
    for (uint8 i = 0; i < array.length; i++) {
      newArray[i] = array[i];
    }
    newArray[array.length] = n;
    return newArray;
  }

  function compareHands(uint8 a, uint8 b)  returns (ComparaisonResult) {
    if (a <= target && b <= target) {
      if (a > b) return ComparaisonResult.First;
      if (a < b) return ComparaisonResult.Second;
    }

    if (a > target && b > target) {
      if (a < b) return ComparaisonResult.First;
      if (a > b) return ComparaisonResult.Second;
    }

    if (a > target) return ComparaisonResult.Second;
    if (b > target) return ComparaisonResult.First;

    return ComparaisonResult.Tie;
  }
}