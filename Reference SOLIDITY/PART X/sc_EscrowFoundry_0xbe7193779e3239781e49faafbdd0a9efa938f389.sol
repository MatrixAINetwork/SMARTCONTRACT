/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract EscrowContract {

    // TYPES
    enum state {Funding, Paid, Accepted, Dispute, Closed}
    
    // PRIVATE VARIABLES
    address private developer;
    bool private mutex;
    uint256 private dispute_limit;
    
    // PUBLIC VARIABLES
    address public buyer;
    address public seller;
    address public escrow;
    uint256 public amount;
    uint256 public fee;
    uint256 public tip;
    uint256 public dispute_end;
    state public status;
    
    // EVENTS
    event CurrentStatus(uint8 s);
    
    // CONSTRUCTOR
    function EscrowContract(address _developer, address _buyer, address _seller, address _escrow, uint256 _amount, uint256 _fee, uint256 _tip ,uint256 _dispute_limit)
        private
    {
        developer = _developer;
        mutex = false;
        dispute_limit = _dispute_limit;     
        buyer = _buyer;
        seller = _seller;
        escrow = _escrow;
        amount = _amount;
        fee = _fee;
        tip = _tip;
        dispute_end = 0;
        status = state.Funding;
        CurrentStatus(uint8(status));
    }

    // MODIFIERS
    modifier only_when(state s) {
        if (status != s)  throw;
        _
    }
    modifier only_before(state s) {
        if (status >= s)  throw;
        _
    }
    modifier only_buyer() {
        if (msg.sender != buyer) throw;
        _
    }
    modifier only_seller() {
        if (msg.sender != seller) throw;
        _
    }
    modifier only_buyer_seller() {
        if (msg.sender != buyer && msg.sender != seller) throw;
        _
    }
    modifier only_escrow() {
        if (msg.sender != escrow) throw;
        _
    }
    modifier only_no_value() {
        if (msg.value != 0)  throw;
        _
    }
    modifier check_mutex() {
        if (mutex) throw;
        mutex = true;
        _
        mutex = false;
    }
    
    // VALIDATE PERCENT
    function validate_percent(uint8 val)
        private
        constant
    {
        if (val > 100) throw;
    }   

    // BUYER CANCEL
    function buyer_cancel()
        public
        only_before(state.Accepted)
        only_buyer()
        only_no_value()
        check_mutex()
    {
        if (this.balance > 0)
            if (!buyer.send(this.balance)) throw;
        status = state.Closed;
        CurrentStatus(uint8(status));
    }
    
    // SELLER ACCEPT
    function seller_accept()
        public
        only_when(state.Paid)
        only_seller()
        only_no_value()
        check_mutex()
    {
        status = state.Accepted;
        CurrentStatus(uint8(status));
    }

    // BUYER PAY
    function buyer_pay()
        public
        only_when(state.Accepted)
        only_buyer()
        only_no_value()
        check_mutex()
    {
        if (amount > 0)
            if (!seller.send(amount)) throw;
        if (fee > 0)
            if (!buyer.send(fee)) throw;
        if (tip > 0)
            if (!developer.send(tip)) throw;
        status = state.Closed;
        CurrentStatus(uint8(status));
    }

    // DISPUTE
    function dispute()
        public
        only_when(state.Accepted)
        only_buyer_seller()
        only_no_value()
        check_mutex()
    {
        status = state.Dispute;
        dispute_end = block.timestamp + dispute_limit;
        CurrentStatus(uint8(status));
    }

    // RESOLVE
    function resolve(uint8 percent_buyer, uint8 percent_tip)
        public
        only_when(state.Dispute)
        only_escrow()
        only_no_value()
        check_mutex()
    {
        validate_percent(percent_buyer);
        validate_percent(percent_tip);
        uint256 buyer_amount = uint256(amount * percent_buyer)/100;
        uint256 seller_amount = amount - buyer_amount;
        uint256 tip_amount = uint256(fee * percent_tip)/100;
        uint256 escrow_amount = fee - tip_amount;
        tip_amount = tip_amount + tip;
        if (buyer_amount > 0)
            if (!buyer.send(buyer_amount)) throw;
        if (seller_amount > 0)
            if (!seller.send(seller_amount)) throw;
        if (escrow_amount > 0)
            if (!escrow.send(escrow_amount)) throw;
        if (tip_amount > 0)
            if (!developer.send(tip_amount)) throw;
        status = state.Closed;
        CurrentStatus(uint8(status));
    }

    // FIFTY FIFTY
    function fifty_fifty()
        public
        only_when(state.Dispute)
        only_buyer_seller()
        only_no_value()
        check_mutex()
    {
        if (block.timestamp < dispute_end) throw;
        uint256 buyer_amount = uint256(amount * 50)/100;
        uint256 seller_amount = amount - buyer_amount;
        buyer_amount = buyer_amount + fee;
        if (buyer_amount > 0)
            if (!buyer.send(buyer_amount)) throw;
        if (seller_amount > 0)
            if (!seller.send(seller_amount)) throw;
        if (tip > 0)
            if (!developer.send(tip)) throw;
        status = state.Closed;
        CurrentStatus(uint8(status));
    }
    
    // DEFAULT FUNCTION
    function()
        public
        only_before(state.Closed)
        check_mutex()
    {
        if (status == state.Funding) {
            if (this.balance >= (amount + fee + tip)) {
                status = state.Paid;
                CurrentStatus(uint8(status));
            }
        }
        if (status >= state.Paid) tip = this.balance - (amount + fee);
    }
    
}


contract EscrowFoundry {
    
    // PRIVATE VARIABLES
    address private developer;
    
    // EVENTS
    event NewContract(address a);
    
    // CONSTRUCTOR
    function EscrowFoundry() 
        private
    {
        developer = msg.sender;
    }
    
    // MODIFIERS
    modifier only_no_value() {
        if (msg.value != 0)  throw;
        _
    }

    // VALIDATE PERCENT
    function validate_percent(uint8 val)
        private
        constant
    {
        if (val > 100) throw;
    }
    
    // CREATE
    function create(address _buyer, address _seller, address _escrow, uint256 _amount, uint8 _percent_fee, uint8 _percent_tip, uint256 _dispute_limit)
        public
        constant
        only_no_value()
        returns (address)
    {
        validate_percent(_percent_fee);
        validate_percent(_percent_tip);
        uint256 fee = uint256(_amount * _percent_fee)/100;
        uint256 tip = uint256(_amount * _percent_tip)/100;
        EscrowContract c = new EscrowContract(developer, _buyer, _seller, _escrow, _amount, fee, tip, _dispute_limit);
        NewContract(c);
        return c;
    }
    
    // DEFAULT FUNCTION
    function()
        public
    {
        throw;
    }

}