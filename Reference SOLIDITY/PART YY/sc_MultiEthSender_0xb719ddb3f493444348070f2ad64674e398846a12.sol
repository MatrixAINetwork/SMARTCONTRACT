/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract MultiEthSender {
    using SafeMath for uint256;

    event Send(uint256 _amount, address indexed _receiver);

    function multiSendEth(uint256 amount, address[] list) public returns (bool){
        uint256 _userCount = list.length;

        require( address(this).balance > amount.mul(_userCount));

        for(uint256 _i = 0; _i < _userCount; _i++){
            list[_i].transfer(amount);
            emit Send(amount, list[_i]);
        }

        return true;
    }

    function() public payable{}
}