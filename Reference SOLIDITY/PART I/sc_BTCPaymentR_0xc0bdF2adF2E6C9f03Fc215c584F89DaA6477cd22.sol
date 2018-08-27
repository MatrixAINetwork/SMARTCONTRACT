/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
        return 0;
    }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Owned {
    address public Owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed NewOwner);

    function Owned() public {
        Owner = msg.sender;
    }

    modifier OnlyOwner() {
        require(msg.sender == Owner);
        _;
    }

    function transferOwnership(address NewOwner) public OnlyOwner {
        require(NewOwner != address(0));
        OwnershipTransferred(Owner, NewOwner);
        Owner = NewOwner;
    }
}

contract RYC is Owned {
    mapping (address => mapping (bool => bool)) public registeredAddress;

    mapping (address => bool) public admin;

    event Registered(address indexed _addr);
    event Unregistered(address indexed _addr);
    event SetAdmin(address indexed _addr);

    modifier onlyRegistered(address _addr, bool _isPresale) {
        require(registeredAddress[_addr][_isPresale]);
        _;
    }

    modifier onlyAdmin() {
        require(admin[msg.sender]);
        _;
    }

    function RYC() public {
        admin[msg.sender] = true;
    }

    function setAdmin(address _addr, bool _value)
        public
        OnlyOwner
        returns (bool) {
        require(_addr != address(0));
        require(admin[_addr] == !_value);

        admin[_addr] = _value;

        SetAdmin(_addr);

        return true;
    }

    function isRegistered(address _addr, bool _isPresale)
        public
        view
        returns (bool) {
        return registeredAddress[_addr][_isPresale];
    }

    function register(address _addr, bool _isPresale)
        public
        onlyAdmin {
        require(_addr != address(0) && registeredAddress[_addr][_isPresale] == false);

        registeredAddress[_addr][_isPresale] = true;

        Registered(_addr);
    }

    function registerByList(address[] _addrs, bool _isPresale)
        public
        onlyAdmin {
        for(uint256 i = 0; i < _addrs.length; i++) {
        register(_addrs[i], _isPresale);
        }
    }

    function unregister(address _addr, bool _isPresale)
        public
        onlyAdmin
        onlyRegistered(_addr, _isPresale) {
        registeredAddress[_addr][_isPresale] = false;
        Unregistered(_addr);
    }

    function unregisterByList(address[] _addrs, bool _isPresale)
        public
        onlyAdmin {
        for(uint256 i = 0; i < _addrs.length; i++) {
            unregister(_addrs[i], _isPresale);
        }
    }
}

contract PaymentFallbackReceiver {
    BTCPaymentI public payment;

    enum SaleType { pre, main }

    function PaymentFallbackReceiver(address _payment) public {
        require(_payment != address(0));
        payment = BTCPaymentI(_payment);
    }

    modifier onlyPayment() {
        require(msg.sender == address(payment));
        _;
    }

    event MintByBTC(SaleType _saleType, address indexed _beneficiary, uint256 _tokens);

    function paymentFallBack(address _beneficiary, uint256 _tokens) external onlyPayment();
}

contract PresaleFallbackReceiver {
    bool public presaleFallBackCalled;

    function presaleFallBack(uint256 _presaleWeiRaised) public returns (bool);
}

contract BTCPaymentI is Owned, PresaleFallbackReceiver {
    PaymentFallbackReceiver public presale;
    PaymentFallbackReceiver public mainsale;

    function addPayment(address _beneficiary, uint256 _tokens) public;
    function setPresale(address _presale) external;
    function setMainsale(address _mainsale) external;
    function presaleFallBack(uint256) public returns (bool);
}

contract BTCPaymentR is Owned, PresaleFallbackReceiver {
    using SafeMath for uint256;

    PaymentFallbackReceiver public presale;
    PaymentFallbackReceiver public mainsale;

    event NewPayment(address _beneficiary, uint256 _tokens);

    function addPayment(address _beneficiary, uint256 _tokens)
        public
        OnlyOwner {
        if (!presaleFallBackCalled) {
            presale.paymentFallBack(_beneficiary, _tokens);
        } else {
            mainsale.paymentFallBack(_beneficiary, _tokens);
        }
        NewPayment(_beneficiary, _tokens);
    }

    function setPresale(address _presale) external OnlyOwner {
        require(presale == address(0));
        presale = PaymentFallbackReceiver(_presale);
    }

    function setMainsale(address _mainsale) external OnlyOwner {
        require(mainsale == address(0));
        mainsale = PaymentFallbackReceiver(_mainsale);
    }

    function presaleFallBack(uint256) public returns (bool) {
        require(msg.sender == address(presale));
        if (presaleFallBackCalled) return false;
        presaleFallBackCalled = true;
        return true;
    }
}