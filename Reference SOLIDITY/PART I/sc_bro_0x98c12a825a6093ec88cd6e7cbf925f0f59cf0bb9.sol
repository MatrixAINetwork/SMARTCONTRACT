/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;
contract bro {
    uint8 nextNonce;
    address nextBroAddress;
    address[] bros;
    function Bro() 
        public 
    {
        nextNonce = 1;
        bros.push(0x0);
    }
    function nextBro()
        public
        returns(address)
    {
        nextBroAddress = findNextBro(nextNonce);
        
        bros.push(nextBroAddress);
        nextNonce += 1;
        return nextBroAddress;
    }
    function findNextBro(uint8 _nonce) 
        private 
        pure
        returns (address)
    {
        require(_nonce < 127);
        return address(keccak256(0xd6, 0x94, 0x0EA7AB495A36e59cc53A02C8F4a48C96df69DCDe, _nonce));
    }
}