/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

//Token Contract
contract LoveLockChain {

	address private constant _ceo = 0x41321d1639BA6587185C10b8e589418F46c698C6;
	modifier ownerFunc {
		require(_ceo == msg.sender);
		_;
	}


    function LoveLockChain() public ownerFunc {
        for(uint8 i = 1; i<=3; i++){
            grantToken(_ceo);
            newAuction(lastAuctionId+1,currentStartPrice, currentMinPrice, currentSpawnDuration, LastTokenId,_ceo);
            AuctionIds[lastAuctionId+1].isSpawn = true;
            lastAuctionId = lastAuctionId +1;
        }
    }


    // Token Info
	string public constant name = "Love Locks";
	string public constant symbol = "LOCKS";
	uint8 public constant decimals = 0;
	uint64 public totalSupply = 0;
	uint64 public LastTokenId = 0;
	uint64 public constant maxSupply = 520;
	
	
	// Spawn vars
    uint256 private constant currentStartPrice = 0.1 ether;
    uint256 private constant currentMinPrice = 0.01 ether;
    uint256 private constant currentSpawnDuration = 60 minutes ;//60 minutes;

    // Desgign attributes
	mapping(uint64 => uint16) private tokenBackground;
	mapping(uint64 => uint16) private tokenLock;
	mapping(uint64 => uint16) private tokenNote;
	uint16 private maxIdBackground = 19;
	uint16 private maxIdLock = 18;
	uint16 private maxIdNote = 22;

	// User Wallet
	mapping (address => uint64[]) private TokenBalanceOf;
	mapping (uint64 => uint64) private TokenBalanceIndex; // TokenID => TokenBalanceIndex
	mapping (address => uint64) public balanceOf;
	mapping (uint64 => Message) internal LoveLocks;
	mapping (uint64 => address) private Tokens;
	mapping (address => uint64[]) private _userLoveLocks;

	// Auction Storage 
	mapping (uint64 => uint64) private tokenAuctions;
    mapping (uint64 => Auction) private AuctionIds;
    mapping (address => uint64[]) private userAuctionIds;
    uint64 private lastAuctionId = 0;

	// Events
	event Spend(uint64 indexed _TokenId, address _from, string _Message);
	event PriceChanged(uint indexed _time, uint64 newPrice);
	event AuctionStarted(uint64 indexed _AuctionId, uint64 _TokenId, address _from);
	event AuctionWon(uint64 indexed _AuctionId, uint64 _TokenId, address _winner, uint256 price);
	event Transfer(address indexed from, address indexed to, uint64 _TokenId);

    // Balance function
	function TokenBalance(address _addr) public view returns (uint64[]){
		return TokenBalanceOf[_addr];
	}
    
    // User Love Locks
	function userLoveLocks(address _addr) public view returns (uint64[]){
		return _userLoveLocks[_addr];
	}


	// Grants token
	function grantToken(address _to) private {
		uint64 _TokenId = LastTokenId + 1;
		LastTokenId += 1;
		AddTokenId(_to, _TokenId);
		totalSupply += 1;

	}

	// Transfer Token
	function transfer(address _to, uint64 _TokenId) public {
		_transfer(msg.sender, _to, _TokenId);
	}

	function _transfer(address _from, address _to, uint64 _TokenId) internal {
		require(_to != 0x0);// Prevent transfer to 0x0 address. Use burn() instead
		require(RemoveTokenId(_from,_TokenId));
		require(!HasLiveAuction(_TokenId));
		AddTokenId(_to,_TokenId);

		Transfer(_from, _to, _TokenId); // Event
	}
	// Token Spending:
	// TODO: Return bool
	function sendLoveToken( uint64 _TokenId, string _Message,string _To, string _From) public {
		require(RemoveTokenId(msg.sender,_TokenId));
		require(!HasLiveAuction(_TokenId));

		LoveLocks[_TokenId]._To = _To;
		LoveLocks[_TokenId]._From = _From;
		LoveLocks[_TokenId]._Message = _Message;

		_userLoveLocks[msg.sender].push(_TokenId);
		Spend(_TokenId, msg.sender, _Message);
	}

    // Get LoveLock
	function getLoveLock(uint64 _TokenId)
	public view
	returns (string _To, string _From, string _Message, uint16 _background, uint16 _lock, uint16 _note){
	    _To = LoveLocks[_TokenId]._To;
	    _From = LoveLocks[_TokenId]._From;
	    _Message = LoveLocks[_TokenId]._Message;
	    _background = tokenBackground[_TokenId];
	    _lock =  tokenLock[_TokenId];
	    _note =  tokenNote[_TokenId];
	}

    // Last Auction Id neeeded for external loops
    function getLastAuctionId() public view returns (uint64){
        return lastAuctionId;
    }

    // User's Auctions used for wallet
	function getUserAuctionIds(address _addr) public view returns (uint64[]){
	    return userAuctionIds[_addr];
	}


    // Get Auction Info
	function getAuctionByAuctionId(uint64 _AuctionId)
	public view 
	returns
	(uint64 _TokenId, uint256 _startTime, uint256 _endTime,
	bool _sold, uint256 _finalPrice, uint256 _startPrice,	uint256 _minPrice, uint256 _currentPrice,
	bool _cancelled, bool _expired, uint16[3] preview ){
	      //object auction: {TokenId, starttime, endtime, sold, finalPrice}
	      Auction storage auc = AuctionIds[_AuctionId];
	      _TokenId = auc.TokenId;
	      
	      
	      _sold = auc.sold;
	      _finalPrice = auc.finalPrice;
	      _startPrice = auc.startPrice;
	      _minPrice = auc.minPrice;
	      _cancelled = auc.cancelled;
	     
	      _currentPrice = auctionCurrentPrice(_AuctionId);

            if(auc.isSpawn){
                _startTime = auc.startTime + auc.duration * SpawnCycles(_AuctionId); 
                _expired=false;
                var a = uint64(_TokenId + SpawnCycles(_AuctionId));
                preview[0] = rand(1, maxIdBackground, a);
        		preview[1] = rand(1, maxIdLock, a);
        		preview[2] = rand(1, maxIdNote, a);
            } else{
                _startTime = auc.startTime;
                _expired = isExpired(_AuctionId);
            	preview[0] = tokenBackground[_TokenId];
                preview[1] = tokenLock[_TokenId];
                preview[2] = tokenNote[_TokenId];
            }
            
            _endTime = auc.duration + _startTime;

	}


    // Start an auction
	function startNewAuction(uint64 _startPrice, uint64 _minPrice, uint64 _duration, uint64 _TokenId) public {
		address _from = msg.sender;
		require(HasTokenId(_from, _TokenId)); // user has token
		require(!HasLiveAuction(_TokenId)); // no concurrent auctions


		newAuction(lastAuctionId+1,_startPrice, _minPrice, _duration, _TokenId,_from);
		lastAuctionId = lastAuctionId +1;


		AuctionStarted(lastAuctionId, _TokenId, _from );
	}

    // Buy from auction
	function placeBid(uint64 _AuctionId) public payable {
		require(_placeBid(_AuctionId,msg.value));

		// Make trade
        uint256 finalPrice = AuctionIds[_AuctionId].finalPrice;
        address _owner = AuctionIds[_AuctionId].owner;
        uint64 _TokenId = AuctionIds[_AuctionId].TokenId;

		msg.sender.transfer(msg.value - finalPrice);
		_owner.transfer(finalPrice);
		_transfer(_owner, msg.sender, _TokenId);

		AuctionWon(_AuctionId, _TokenId, msg.sender, finalPrice);
	}

    // Run bid on auction
	function _placeBid(uint64 _AuctionId, uint256 _bid) private returns (bool) {
		if(setBid(_AuctionId, _bid)){
		    var SoldAuc = AuctionIds[_AuctionId];
		    if(SoldAuc.isSpawn){
		      var SoldTokenId = SoldAuc.TokenId;
                tokenBackground[SoldTokenId]    = rand(1, maxIdBackground, uint64(SoldTokenId + SpawnCycles(_AuctionId)));
        		tokenLock[SoldTokenId]          = rand(1, maxIdLock, uint64(SoldTokenId + SpawnCycles(_AuctionId)));
        		tokenNote[SoldTokenId]          = rand(1, maxIdNote, uint64(SoldTokenId + SpawnCycles(_AuctionId)));
		        
		        //Spawn new
		        if(LastTokenId <maxSupply){
    		        grantToken(_ceo);
    		        newAuction(lastAuctionId+1,currentStartPrice, currentMinPrice, currentSpawnDuration, LastTokenId,_ceo);
                    AuctionIds[lastAuctionId+1].isSpawn = true;
                    lastAuctionId = lastAuctionId +1;
		        }
		    }
		    
			return true;
		}
		return false;
	}

	// Misc help functions -----------------------------
	function AddTokenId(address _addr, uint64 _TokenId) internal returns (bool){
		Tokens[_TokenId] = _addr; // Set token belonging to new user
		uint64[] storage curUserTokenBalance=TokenBalanceOf[_addr];
		uint64 UserBalance = uint64(curUserTokenBalance.length);
		balanceOf[_addr] = balanceOf[_addr]+1;
		curUserTokenBalance.push(_TokenId);
		TokenBalanceIndex[_TokenId] = UserBalance;
		return true;
	}

	function HasTokenId(address _addr , uint64 _TokenId) internal view returns (bool){
		if(Tokens[_TokenId] == _addr)	return true;
		return false;
	}

	function RemoveTokenId(address _addr , uint64 _TokenId) internal returns (bool){
		if(Tokens[_TokenId] != _addr)	return false;
		Tokens[_TokenId] = address(0);
		balanceOf[_addr] = balanceOf[_addr]-1;

		uint64 curIndex = TokenBalanceIndex[_TokenId];
		TokenBalanceOf[_addr][curIndex] = 0;
		return true;
	}

	function HasLiveAuction(uint64 _TokenId) internal view returns(bool) {
	    uint64 _AuctionId = tokenAuctions[_TokenId];
	    if(!AuctionIds[_AuctionId].created) return false;
		if(isExpired(_AuctionId)) return false;
		return true;
	}


	struct Auction {
	    uint64 AuctionId;
    	uint256 startTime;
    	uint256 duration;

    	uint64 TokenId;
    	uint256 startPrice;
    	uint256 minPrice;
    	bool created;
    	bool cancelled;
    	bool sold;
    	uint256 finalPrice;
    	address owner;
    	bool isSpawn;
	}



	function newAuction(uint64 _AuctionId,uint256 _startPrice, uint256 _minPrice, uint256 _duration, uint64 _TokenId, address _owner) internal returns (Auction _out){
		require(_duration >= 600 && _duration <= 24 hours ); //10min to 1 day
		require(_TokenId > 0);
		require(_minPrice > 0);
		require(_startPrice > _minPrice);

        _out.AuctionId = _AuctionId;
		_out.startTime = block.timestamp;
		_out.duration = _duration;
		_out.minPrice = _minPrice;
		_out.startPrice = _startPrice;
		_out.TokenId = _TokenId;
		_out.owner = _owner;
		_out.created = true;
		_out.cancelled = false;
			

		AuctionIds[_AuctionId] = _out;
		tokenAuctions[_TokenId] = _AuctionId;
		userAuctionIds[_owner].push(_AuctionId);

	}

	function setBid(uint64 _AuctionId, uint256 bid) internal returns (bool) {
		require(bid>0);
		require(AuctionIds[_AuctionId].created);
		require(!AuctionIds[_AuctionId].sold);
		require(!AuctionIds[_AuctionId].cancelled);
		uint256 curPrice = auctionCurrentPrice(_AuctionId);
		if(bid > curPrice){
			AuctionIds[_AuctionId].sold = true;
			AuctionIds[_AuctionId].finalPrice = curPrice;
			return true;
		}
		return false;
	}

	function auctionCurrentPrice(uint64 _AuctionId) internal view returns (uint256){
	    require(AuctionIds[_AuctionId].created);

		uint256 DeltaP = (AuctionIds[_AuctionId].startPrice - AuctionIds[_AuctionId].minPrice);
		uint256 DeltaT = (now - AuctionIds[_AuctionId].startTime) % AuctionIds[_AuctionId].duration ;
		
		
		return AuctionIds[_AuctionId].startPrice - (DeltaT* DeltaP)/AuctionIds[_AuctionId].duration;
	}


	function isExpired(uint64 _AuctionId) internal view returns (bool) {
		if(AuctionIds[_AuctionId].sold) return true;
		if(AuctionIds[_AuctionId].cancelled) return true;
		if(AuctionIds[_AuctionId].isSpawn) return false;
		if(block.timestamp >= AuctionIds[_AuctionId].duration + AuctionIds[_AuctionId].startTime) return true;
		return false;
	}

	function cancelAuction(uint64 _AuctionId) public {
	    require(AuctionIds[_AuctionId].created);
	    require(!AuctionIds[_AuctionId].sold);
	    require(!AuctionIds[_AuctionId].cancelled);
	    require(AuctionIds[_AuctionId].owner == msg.sender);
	    AuctionIds[_AuctionId].cancelled = true;
	}

	struct Message {
	    string _Message;
	    string _To;
	    string _From;
	}

	function setTokenTypes(uint16 _maxIdBackground, uint16 _maxIdLock,uint16 _maxIdNote) public ownerFunc {
	    require(_maxIdBackground >= maxIdBackground);
	    require(_maxIdLock >= maxIdLock);
	    require(_maxIdNote >= maxIdNote);
	    maxIdBackground = _maxIdBackground;
	    maxIdLock = _maxIdLock;
        maxIdNote = _maxIdNote;
	}


    function rand(uint16 min, uint16 max,uint64 _seed) private pure returns (uint16){
        return (uint16(keccak256(_seed+max)) % (max-min+1))+min;
    }
    
    function SpawnCycles(uint64 _AuctionId) private view returns (uint256){
        var a = AuctionIds[_AuctionId];
        return ((now-a.startTime)/a.duration);
    }





}