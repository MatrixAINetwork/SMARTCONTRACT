/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

/**
 * @title 사전판매를 위한 주소 등록
 */

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
 * @dev 사전판매를 위해서 등록된 주소로 ICO를 진행할 수 있습니다.
 *      관리자는 해당 계정(주소)를 등록할 수 있습니다.
 */
contract PRE is Owned {
  // 토큰을 판매하기 위해서 등록된 주소를 확인합니다.
  mapping (address => mapping (bool => bool)) public RegisteredAddress;

  // 관리자 주소인지 확인합니다.
  mapping (address => bool) public admin;

  event Registered(address indexed _addr);
  event Unregistered(address indexed _addr);
  event SetAdmin(address indexed _addr);

  /**
   * @dev           사전판매를 위해 해당 주소가 등록되어있는지 확인합니다.
   * @ _addr      : 해당 주소
   * @ _isPresale : 주소가 사전 판매 또는 메인 판매에 등록되었는지 여부
   */
  modifier PRERegistered(address _addr, bool _isPresale) {
    require(RegisteredAddress[_addr][_isPresale]);
    _;
  }

  /**
   * @dev 관리자 여부를 확인합니다.
   */
  modifier OnlyAdmin() {
    require(admin[msg.sender]);
    _;
  }

  function PRE() public {
    admin[msg.sender] = true;
  }

  /**
   * @dev      새로운 관리자를 설정할 수 있습니다.
   *           해당 주소로 새로운 관리자를 등록합니다.
   * @ _addr : 해당 주소 
   */
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

  /**
   * @dev           주소가 등록되어있는지 확인합니다.
   * @ _addr      : 해당 주소
   * @ _isPresale : 해당 주소가 판매에 등록되어있는지 확인합니다.
   */
  function isRegistered(address _addr, bool _isPresale)
    public
    view
    returns (bool) {
    return RegisteredAddress[_addr][_isPresale];
  }

  /**
   * @dev           사전판매를 위해서 주소를 등록할 수 있습니다.
   * @ _addr      : 해당 주소
   * @ _isPresale : 사전판매 등록 여부를 선택합니다.
   */
  function register(address _addr, bool _isPresale)
    public
    OnlyAdmin {
    require(_addr != address(0) && RegisteredAddress[_addr][_isPresale] == false);

    RegisteredAddress[_addr][_isPresale] = true;

    Registered(_addr);
  }

  /**
   * @dev               사전판매를 위해서 주소를 리스트에 등록할 수 있습니다.
   * _addrs address[] : 사전 판매를 위해 주소를 추가할 수 있습니다.
   * _isPresale       : 사전판매 등록 여부를 선택합니다.
   */
  function RegisterList(address[] _addrs, bool _isPresale)
    public
    OnlyAdmin {
    for(uint256 i = 0; i < _addrs.length; i++) {
      register(_addrs[i], _isPresale);
    }
  }

  /**
   * @dev           등록된 주소를 삭제할 수 있습니다.
   * @ _addr      : 해당 주소
   * @ _isPresale : 사전판매 등록 취소 여부를 선택합니다.
   */
  function Unregister(address _addr, bool _isPresale)
    public
    OnlyAdmin
    PRERegistered(_addr, _isPresale) {
    RegisteredAddress[_addr][_isPresale] = false;

    Unregistered(_addr);
  }

  /**
   * @dev                 사전판매를 위해서 주소를 리스트에서 삭제할 수 있습니다.
   * @ _addrs address[] : 사전판매 리스트 등록 취소 여부를 선택합니다.
   * @ _isPresale       : 사전판매 리스트 등록 취소 여부를 선택합니다.
   */
  function UnregisterList(address[] _addrs, bool _isPresale)
    public
    OnlyAdmin {
    for(uint256 i = 0; i < _addrs.length; i++) {
      Unregister(_addrs[i], _isPresale);
    }
  }
}