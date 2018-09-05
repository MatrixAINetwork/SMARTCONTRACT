/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract Owned {
    address public Owner;
  
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Owned() public {
        Owner = msg.sender;
    }

    modifier OnlyOwner() {
        require(msg.sender == Owner);
        _;
    }

    function transferOwnership(address newOwner) public OnlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(Owner, newOwner);
        Owner = newOwner;
  }
}

/**
 * @title 안전 점검
 * @dev   오류가 발생할 경우 안전점검을 통해 오류를 수정합니다.
 */
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

/**
 * @title 사전판매되는 동안 자금을 저장하기 위해서 사용됩니다.
 * @dev   사전판매가 실패하면 자금을 환불합니다.
 *        사전판매가 성공하면 전송합니다.
 */
contract RefundVault is Owned {
    using SafeMath for uint256;

    enum State { Active, Refunding, Closed }

    mapping (address => uint256) public deposited;
    address public wallet;
    State public state;

    event Closed();
    event RefundsEnabled();
    event Refunded(address indexed beneficiary, uint256 weiAmount);

    function RefundVault(address _wallet) public {
        require(_wallet != address(0));
        wallet = _wallet;
        state = State.Active;
    }

    function deposit(address investor) OnlyOwner public payable {
        require(state == State.Active);
        deposited[investor] = deposited[investor].add(msg.value);
    }

    function close() OnlyOwner public {
        require(state == State.Active);
        state = State.Closed;
        Closed();
        wallet.transfer(this.balance);
    }

    function enableRefunds() OnlyOwner public {
        require(state == State.Active);
        state = State.Refunding;
        RefundsEnabled();
    }

    function refund(address investor) public {
        require(state == State.Refunding);
        uint256 depositedValue = deposited[investor];
        deposited[investor] = 0;
        investor.transfer(depositedValue);
        Refunded(investor, depositedValue);
    }
}

/**
 * @title 사전판매 금고
 * @dev   이 계약은 자금을 저장하는 데 사용됩니다.
 *        사전판매를 실패할 경우 자금을 환불합니다.
 *        사전판매를 성공할 경우 자금을 전달합니다.
 *        PresaleVaultR.sol 배포 된 주소를 처리하기 위해 존재합니다.
 */
contract PresaleVaultR is RefundVault {
    bool public forPresale = true;
    function PresaleVaultR(address _wallet) RefundVault(_wallet) public {}
}