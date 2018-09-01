/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.20;

library SafeMath256 {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

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

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

// github.com/ethereum/EIPs/issues/223
contract ERC223 {
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    function transfer(address _to, uint256 _value) public;
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Fintechnics is ERC223 {
    using SafeMath256 for uint256;

    string public constant name = "Fintechnics";
    string public constant symbol = "FINTC";
    uint256 public constant decimals = 18;
    uint256 public constant totalSupply = 1500000 * 10**decimals;
    address public owner = address(0);
    mapping (address => uint256) public balanceOf;

    function isContract(address _addr) internal view returns (bool is_contract) {
        uint256 length;
        assembly { length := extcodesize(_addr) }
        return length > 0;
    }

    function transfer(address _to, uint256 _value) public {
        require(!isContract(_to) && msg.sender != _to && balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(msg.sender, _to, _value);
    }

    function Fintechnics() public {
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
        Transfer(address(0), owner, totalSupply);
    }
}