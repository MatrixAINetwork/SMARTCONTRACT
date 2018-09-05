/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
//params (fee set to 0 so it's free):
//  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], "MJ comeback", 1603152000, "21/10/2020", "MGM grand", "MJC", 1000
// "0x000000000000000000000000000000000000000000000000016a6075a7170002", 27, "0xE26D930533CF5E36051C576E1988D096727F28A4AB638DBE7729BCC067BD06C8", "0x76EBAA64A541D1DE054F4B63B586E7FEB485C1B3E85EA463F873CA69307EEEAA"

pragma solidity ^0.4.17;
contract TicketPro
{
    uint totalTickets;
    mapping(address => uint16[]) inventory;
    mapping(address => uint) spent;
    uint16 ticketIndex = 0; //to track mapping in tickets
    uint expiryTimeStamp;
    address organiser;
    uint transferFee;
    uint numOfTransfers = 0;
    string public name;
    string public symbol;
    string public date;
    string public venue;
    uint startPrice;
    uint ticketLimit;
    uint8 public constant decimals = 0; //no decimals as tickets cannot be split

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event TransferFrom(address indexed _from, address indexed _to, uint _value);

    modifier eventNotExpired()
    {
        //not perfect but probably good enough
        if(block.timestamp > expiryTimeStamp)
        {
            revert();
        }
        else _;
    }

    modifier organiserOnly()
    {
        if(msg.sender != organiser) revert();
        else _;
    }

    function() public { revert(); } //should not send any ether directly

    function TicketPro(
        uint16[] numberOfTickets,
        string evName,
        uint expiry,
        string evDate,
        string evVenue,
        string eventSymbol,
        uint startTicketLimit) public
    {
        totalTickets = numberOfTickets.length;
        //assign some tickets to event organiser
        inventory[msg.sender] = numberOfTickets;
        expiryTimeStamp = expiry;
        organiser = msg.sender;
        symbol = eventSymbol;
        name = evName;
        date = evDate;
        venue = evVenue;
        ticketLimit = startTicketLimit;
    }

    function getDecimals() public pure returns(uint)
    {
        return decimals;
    }

    function getNumberOfAvailableStartTickets() public view returns (uint)
    {
        return ticketLimit;
    }

    function uintArrayToString (uint[] data) public pure returns (string)
    {
        bytes memory bytesString = new bytes(data.length * 32);
        uint urlLength;
        for (uint i=0; i<data.length; i++) {
            for (uint j=0; j<32; j++) {
                byte char = byte((data[i] * 2 ** (8 * j)));
                if (char != 0) {
                    bytesString[urlLength] = char;
                    urlLength += 1;
                }
            }
        }
        bytes memory bytesStringTrimmed = new bytes(urlLength);
        for (i=0; i<urlLength; i++) {
            bytesStringTrimmed[i] = bytesString[i];
        }
        return string(bytesStringTrimmed);
    }

    function trade(uint[] ticketIndices,
                   uint priceOfAllTickets,
                   uint8 v,
                   bytes32 r,
                   bytes32 s,
                   bytes memory prefix) public payable
    {
        string memory message = uintArrayToString(ticketIndices);
        bytes32 digest = keccak256(prefix, message);
        address seller = ecrecover(digest, v, r, s);
        require(msg.value == priceOfAllTickets);
        for(uint i = 0; i < ticketIndices.length; i++)
            require(inventory[seller][i] != 0); //should revert if arrayOutOfBounds
        for(uint j = 0; j < ticketIndices.length; j++)
        {
            inventory[msg.sender].push(inventory[seller][j]);
            inventory[seller][j] = 0;
            spent[seller] += 1;
        }
    }

    function totalSupply() public constant returns(uint)
    {
        return totalTickets;
    }

    function name() public view returns(string)
    {
        return name;
    }

    function symbol() public view returns(string)
    {
        return symbol;
    }

    function eventVenue() public constant returns(string)
    {
        return venue;
    }

    function eventDate() public constant returns(string)
    {
        return date;
    }

    function getAmountTransferred() public view returns (uint)
    {
        return numOfTransfers;
    }

    function isContractExpired() public view returns (bool)
    {
        if(block.timestamp > expiryTimeStamp)
        {
            return true;
        }
        else return false;
    }

    function balanceOf(address _owner) public view returns (uint16[])
    {
        return inventory[_owner];
    }

    function transfer(address _to, uint16[] ticketIndices) public
    {
        //one array element equals one ticket
        require(inventory[msg.sender].length -
            spent[msg.sender] < ticketIndices.length);
        for(uint i = 0; i < ticketIndices.length; i++)
        {
            require(inventory[msg.sender][i] != 0);
            //pushes each element with ordering
            inventory[_to].push(inventory[msg.sender][ticketIndices[i]]);
            inventory[msg.sender][ticketIndices[i]] = 0;
            numOfTransfers++;
        }
        spent[msg.sender] += ticketIndices.length;
    }

    function transferFrom(address _from, address _to, uint16[] ticketIndices)
        organiserOnly public
    {
        bool isOrganiser = msg.sender == organiser;
        //one array element equals one ticket
        require(inventory[_from].length -
            spent[_from] < ticketIndices.length || isOrganiser);
        for(uint i = 0; i < ticketIndices.length; i++)
        {
            require(inventory[msg.sender][i] != 0 || isOrganiser);
            //pushes each element with ordering
            inventory[_to].push(inventory[msg.sender][ticketIndices[i]]);
            inventory[msg.sender][ticketIndices[i]] = 0;
            numOfTransfers++;
        }
        spent[_from] += ticketIndices.length;
    }

}