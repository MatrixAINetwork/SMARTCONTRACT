/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18; // solhint-disable-line

contract CelebrityTokenInterface {
    function purchase(uint256 _tokenId) public payable;
    function transfer(address _to, uint256 _tokenId) public;
}

contract SellBruceToRaj {
    CelebrityTokenInterface private CCContract;
    
    function SellTokenToRaj() public {
        CCContract = CelebrityTokenInterface(address(0xbb5Ed1EdeB5149AF3ab43ea9c7a6963b3C1374F7));
    }
    
    function purchase() public {
        // Buy Bruce on CC for 2.24 ETH.
        CCContract.purchase.value(2245076957899502036)(558);
        
        // Send Bruce to Raj.
        CCContract.transfer(address(0x9A2Bd3D08d648b4721Ef41B8D21a69C2BD7Ba17d), 558);
        
        // Send 1.2 ETH to Armadillo.
        address(0xa57F0CecEdE74CbE0675c31AFAbF06E61a9A3C14).transfer(1200000000000000000);
        
        // If Raj sent too much, return the rest to him.
        if (this.balance > 0) {
            address(0x9A2Bd3D08d648b4721Ef41B8D21a69C2BD7Ba17d).transfer(this.balance);
        }
    }

    function payout() public {
        // If Raj doesn't want to do it anymore (or somebody has already bought Bruce), 
        // Armadillo can withdraw what he deposited to this contract.
        address(0xa57F0CecEdE74CbE0675c31AFAbF06E61a9A3C14).transfer(this.balance);
    }

    function () public payable {}
}