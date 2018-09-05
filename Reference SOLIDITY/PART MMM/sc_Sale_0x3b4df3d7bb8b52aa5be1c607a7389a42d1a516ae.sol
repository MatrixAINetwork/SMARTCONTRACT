/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity^0.4.18;

contract Token {

    function transfer(address, uint) public pure returns(bool) { }

    function balanceOf(address) public pure returns(uint) { }

    function decimals() public pure returns(uint8) { }

}

contract Sale {

    Token public token;
	uint tokenPrice = uint((10**18)/uint(210)); //in wei
    address beneficiary;
    uint threshold1 = 500*(10**18);
    uint threshold2 = 1000*(10**18);
    uint threshold3 = 1500*(10**18);
    uint threshold4 = 2500*(10**18);

    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length == size + 4);
        _;
    }

    function Sale(address _tokenAddress, address _beneficiary)  public {
        beneficiary = _beneficiary;
        token = Token(_tokenAddress);
    }

    function () public payable {
        require(msg.value > 0);
        uint tokens = msg.value*(10**uint(token.decimals()))/tokenPrice;
        var bonus = calculateBonus(msg.value);
        var amount = bonus*tokens/100;
        require(token.balanceOf(address(this)) >= amount);
        beneficiary.transfer(msg.value);
        token.transfer(msg.sender, amount);
    }

    //purchasing from exchange address
    function purchase(address _to) public payable onlyPayloadSize(1*32) {
        require(msg.value > 0);
        uint tokens = msg.value*(10**uint(token.decimals()))/tokenPrice;
        var bonus = calculateBonus(msg.value);
        var amount = bonus*tokens/100;
        require(token.balanceOf(address(this)) >= amount);
        beneficiary.transfer(msg.value);
        token.transfer(_to, amount);
    }

    function withdraw() public {
        assert(msg.sender == beneficiary);
        token.transfer(beneficiary, token.balanceOf(address(this)));
        selfdestruct(beneficiary);
    }

    function calculateBonus(uint _investment) internal constant returns(uint bonus) {
		if (_investment <= threshold1) {
			bonus = 103;
		} else if (_investment <= threshold2) {
			bonus = 105;
		} else if (_investment <= threshold3) {
			bonus = 107;
		} else if (_investment <= threshold4) {
			bonus = 112;
        } else {
			bonus = 115;
        }
    }

}