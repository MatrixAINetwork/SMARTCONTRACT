/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.16;

contract Manifesto {

  struct Vote {
    address sender; 
    bool vote; 
    string message;
  } 

  uint public votesSupport;
  uint public votesDecline;

  mapping(address => Vote) public votesArr;
  
  event Voted(address _sender, bool _vote, string _message);

  function set(bool _vote, string _message) public {

    Vote storage voteEl = votesArr[msg.sender];

    if (voteEl.sender != 0) {
      if (voteEl.vote != _vote) {
        if (_vote) {
          votesSupport += 1;
          votesDecline -= 1;
        } else {
          votesSupport -= 1;
          votesDecline += 1;
        }
      }
    } else {
      if (_vote) {
        votesSupport += 1;
      } else {
        votesDecline += 1;
      }
    } 

    voteEl.sender = msg.sender;
    voteEl.vote = _vote;
    voteEl.message = _message;
    Voted(msg.sender, _vote, _message);

  }

  function get(address _addr) view public returns (bool r_vote, string r_message) {
    r_vote = votesArr[_addr].vote;
    r_message = votesArr[_addr].message;
  }

}