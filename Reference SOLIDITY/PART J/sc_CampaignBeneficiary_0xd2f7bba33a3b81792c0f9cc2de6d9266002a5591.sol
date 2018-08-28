/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^ 0.4 .6;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract CampaignBeneficiary is owned{

        address public Resilience;

        function CampaignBeneficiary() {
            Resilience = 0xDA922E473796bc372d4a2cb95395ED17aF8b309B;

            bytes4 setBeneficiarySig = bytes4(sha3("setBeneficiary()"));
            if (!Resilience.call(setBeneficiarySig)) throw;
        }
        
        function() payable {
            if(msg.sender != Resilience) throw;
        }
        
        function simulatePathwayFromBeneficiary() public payable {

                bytes4 buySig = bytes4(sha3("buy()"));
                if (!Resilience.call.value(msg.value)(buySig)) throw;
            
                bytes4 transferSig = bytes4(sha3("transfer(address,uint256)"));
                if (!Resilience.call(transferSig, msg.sender, msg.value)) throw;
        }

        function sell(uint256 _value) onlyOwner {
                bytes4 sellSig = bytes4(sha3("sell(uint256)"));
                if (!Resilience.call(sellSig, _value)) throw;
        }
        
        function withdraw(uint256 _value) onlyOwner {
                if (!msg.sender.send(_value)) throw;
        }
        
        function closeCampaign() onlyOwner {
            bytes4 closeCampaignSig = bytes4(sha3("closeCampaign()"));
            if (!Resilience.call(closeCampaignSig)) throw;
        }
}