/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract AmIOnTheFork {
    function forked() constant returns(bool);
}

contract ClassicOnlyTransfer {

  // Fork oracle to use
  AmIOnTheFork amIOnTheFork = AmIOnTheFork(0x2bd2326c993dfaef84f696526064ff22eba5b362);

  address public transferTo = 0x502f9aa95d45426915bff7b92ef90468b100cc9b;
  
  function () {
    if ( amIOnTheFork.forked() ) throw;

    transferTo.send( msg.value );
  }
  
}