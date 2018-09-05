/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract PChannel {
    
    string public name = 'Payment channel';

    string public symbol = 'ETH';
    
    /**
     * Contract owner
     */
    address public owner = msg.sender;

    /**
     * Fee for refund, send and forward
     */
    uint256 public fee = 1 szabo;

    /**
     */
    uint256 public trFee = 0;

    /**
     * User balances
     */
    mapping(address => uint256) private balances;

    /**
     * Decimals for balances
     */
    uint8 public constant decimals = 18;
    
    uint256 public totalSupply = 0;
    
    /**
     * event for token purchase logging
     * @param purchaser who paid for the weis
     * @param beneficiary who got the weis
     * @param value weis paid for purchase
     * @param amount amount of wei purchased
     */
    event TokenPurchase (
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );
    
    function balanceOf(address addr) public constant returns (uint256) {
        return balances[addr];
    }
    
    /**
     * Store wei in contract
     */
    function () public payable {
        require(msg.value > 0);

        totalSupply += msg.value;
        balances[msg.sender] += msg.value;
        
        TokenPurchase(msg.sender, msg.sender, msg.value, msg.value);
    }
    
    /**
     * Send wei for user allocated in contract
     * @param to who got weis
     */
    function send(address to) public payable {
        require(to!=address(0));
        require(msg.value > fee);

        uint256 amount = msg.value - fee;
        totalSupply += msg.value;
        balances[to] += amount;
        balances[owner] += fee;

        TokenPurchase(msg.sender, to, msg.value, amount);
    }
    
    /**
     * Forward payment to 'to' from sender
     */
    function forward(address to) public payable {
        require(to!=address(0));
        require(msg.value > fee);
        
        uint256 amount = msg.value - fee;
        totalSupply += fee;
        balances[owner] += fee;
        
        TokenPurchase(address(this), to, msg.value, amount);

        to.transfer(amount);
    }

    /**
     * Transfer wei from sender to 'to'
     */
    function transfer(address to, uint256 value) public {
        require(to!=address(0));
        require(balances[msg.sender]>=value+trFee);
        
        uint256 amount = value - trFee;
        balances[msg.sender] -= amount;
        balances[to] += amount;
        balances[owner] += trFee;

        TokenPurchase(msg.sender, to, value, value);
    }
    
    /**
     * Refund 'value' wei to sender
     */
    function refund(uint256 value) public {
        require(balances[msg.sender]>value+fee);

        uint256 amount = value - fee;
        balances[msg.sender] -= value;
        balances[owner] += fee;
        totalSupply -= amount;

        TokenPurchase(address(this), msg.sender, value, amount);
        
        msg.sender.transfer(amount);
    }

    /**
     * Allocate fee for transfer
     */
    function setTrFee(uint256 _fee) public {
        require(msg.sender == owner);
        trFee = _fee;
    }

    /**
     * Allocate new fee
     */
    function setFee(uint256 _fee) public {
        require(msg.sender == owner);
        fee = _fee;
    }

    /**
     * Allocate new owner
     */
    function transferOwnership(address newOwner) public {
        require(msg.sender==owner && newOwner != address(0));      
        
        balances[newOwner] = balances[owner];
        balances[owner] = 0;
        
        owner = newOwner;
    }

}