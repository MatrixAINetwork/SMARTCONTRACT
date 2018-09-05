/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != owner) {
      revert();
    }
    _;
  }
}

contract RBInformationStore is Ownable {
    address public profitContainerAddress;
    address public companyWalletAddress;
    uint public etherRatioForOwner;
    address public multisig;

    function RBInformationStore(address _profitContainerAddress, address _companyWalletAddress, uint _etherRatioForOwner, address _multisig) {
        profitContainerAddress = _profitContainerAddress;
        companyWalletAddress = _companyWalletAddress;
        etherRatioForOwner = _etherRatioForOwner;
        multisig = _multisig;
    }

    function setProfitContainerAddress(address _address)  {
        require(multisig == msg.sender);
        if(_address != 0x0) {
            profitContainerAddress = _address;
        }
    }

    function setCompanyWalletAddress(address _address)  {
        require(multisig == msg.sender);
        if(_address != 0x0) {
            companyWalletAddress = _address;
        }
    }

    function setEtherRatioForOwner(uint _value)  {
        require(multisig == msg.sender);
        if(_value != 0) {
            etherRatioForOwner = _value;
        }
    }

    function changeMultiSig(address newAddress){
        require(multisig == msg.sender);
        multisig = newAddress;
    }

    function changeOwner(address newOwner){
        require(multisig == msg.sender);
        owner = newOwner;
    }
}

contract Rate {
    uint public ETH_USD_rate;
    RBInformationStore public rbInformationStore;

    modifier onlyOwner() {
        if (msg.sender != rbInformationStore.owner()) {
            revert();
        }
        _;
    }

    function Rate(uint _rate, address _address) {
        ETH_USD_rate = _rate;
        rbInformationStore = RBInformationStore(_address);
    }

    function setRate(uint _rate) onlyOwner {
        ETH_USD_rate = _rate;
    }
}