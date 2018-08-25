/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^ 0.4.16;

library SafeMath {
	function mul(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a / b;
		return c;
	}

	function sub(uint256 a, uint256 b) internal constant returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
}

contract Bitflax is owned {
    using SafeMath for uint256;

    string public constant name = "Bitflax";
    string public constant symbol = "BFX";
    uint8 public constant decimals = 8;
    uint256 public constant initialSupply = 31900000 * (10 ** uint256(decimals));
    uint256 public totalSupply;

    address public reserveAccount;
    address public bountyAccount;
    address public devAccount;

    mapping (address => bool) public frozenAccount;
    mapping (address => uint256) public balanceOf;

    event Burn(address indexed _from,uint256 _value);
    event FrozenFunds(address _account, bool _frozen);
    event Transfer(address indexed _from,address indexed _to,uint256 _value);

    function Bitflax() {
        reserveAccount = 0x001Ce24d27D59C081aa38065E4BaB0Ddc53798f1;
        bountyAccount = 0x008bfb8bFd89EfDA0607723E4ec293E1cF9A4fe6;
        devAccount = 0x002E1b8A59F8Ff9b16e25Bc5F27B96008c636f6B;

        totalSupply = initialSupply;

        uint256 icoToken = ( totalSupply * 27 ) / 100;
        uint256 devToken = ( totalSupply * 20 ) / 100;
        uint256 bountyToken = ( totalSupply * 2 ) / 100;
        uint256 reserveToken = totalSupply - icoToken - devToken - bountyToken;

        balanceOf[msg.sender] = icoToken;
        balanceOf[devAccount] = devToken;
        balanceOf[bountyAccount] = bountyToken;
        balanceOf[reserveAccount] = reserveToken;

        Transfer(msg.sender,reserveAccount,reserveToken);
        Transfer(msg.sender,bountyAccount,bountyToken);
        Transfer(msg.sender,devAccount,devToken);
    }

    function _transfer(address _from,address _to,uint256 _value) internal {
        require(balanceOf[_from] >= _value);
        require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(_from, _to, _value);
    }

    function transfer(address _to,uint256 _value) {
        _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) {
        _transfer(_from, _to, _value);
    }

    function freezeAccount(address _account, bool _frozen) onlyOwner {
        frozenAccount[_account] = _frozen;
        FrozenFunds(_account, _frozen);
    }

    function burnTokens(uint256 _value) onlyOwner returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender,_value);

        return true;
    }

    function newTokens(address _owner, uint256 _value) onlyOwner {
        balanceOf[_owner] = balanceOf[_owner].add(_value);
        totalSupply = totalSupply.add(_value);
        Transfer(0, this, _value);
        Transfer(this, _owner, _value);
    }

    function escrowAmount(address _account, uint256 _value) onlyOwner {
        _transfer(msg.sender, _account, _value);
        freezeAccount(_account, true);
    }

    function destroyContract() onlyOwner {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }

    function () {
        revert();
    }

}