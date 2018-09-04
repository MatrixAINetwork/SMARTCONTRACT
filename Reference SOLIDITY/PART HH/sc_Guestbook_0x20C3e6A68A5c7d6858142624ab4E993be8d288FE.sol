/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.10;

// A simple decentralized guestbook.
contract Guestbook {
  address creator;

  event Post(address indexed _from, string _name, string _body);

  function Guestbook() {
    creator = msg.sender;
  }

  function post(string _name, string _body) {
    require(bytes(_name).length > 0);
    require(bytes(_body).length > 0);

    Post(msg.sender, _name, _body);
  }

  function destroy() {
    require(msg.sender == creator);

    selfdestruct(creator);
  }
}