/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;

/*
    ERC20 Standard Token interface
*/
contract IERC20Token {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    function name() public constant returns (string) { name; }
    function symbol() public constant returns (string) { symbol; }
    function decimals() public constant returns (uint8) { decimals; }
    function totalSupply() public constant returns (uint256) { totalSupply; }
    function balanceOf(address _owner) public constant returns (uint256 balance) { _owner; balance; }
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { _owner; _spender; remaining; }

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

contract IENJToken is IERC20Token {
    function crowdfundAddress() public constant returns (address);
    function incentivisationFundAddress() public constant returns (address);
    function totalAllocated() public constant returns (uint256);
}

contract ENJAllocation {
    address public tokenAddress;
    IENJToken token;

    function ENJAllocation(address _tokenAddress){
        tokenAddress = _tokenAddress;
        token = IENJToken(tokenAddress);
    }

    function circulation() constant returns (uint256) {
        return token.totalAllocated() - token.balanceOf(token.incentivisationFundAddress());
    }
}