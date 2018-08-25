/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract TittyBase {

    event Transfer(address indexed from, address indexed to);
    event Creation(address indexed from, uint256 tittyId, uint256 wpId);
    event AddAccessory(uint256 tittyId, uint256 accessoryId);

    struct Accessory {

        uint256 id;
        string name;
        uint256 price;
        bool isActive;

    }

    struct Titty {

        uint256 id;
        string name;
        string gender;
        uint256 originalPrice;
        uint256 salePrice;
        uint256[] accessories;
        bool forSale;
    }

    //Storage
    Titty[] Titties;
    Accessory[] Accessories;
    mapping (uint256 => address) public tittyIndexToOwner;
    mapping (address => uint256) public ownerTittiesCount;
    mapping (uint256 => address) public tittyApproveIndex;

    function _transfer(address _from, address _to, uint256 _tittyId) internal {

        ownerTittiesCount[_to]++;

        tittyIndexToOwner[_tittyId] = _to;
        if (_from != address(0)) {
            ownerTittiesCount[_from]--;
            delete tittyApproveIndex[_tittyId];
        }

        Transfer(_from, _to);

    }

    function _changeTittyPrice (uint256 _newPrice, uint256 _tittyId) internal {

        require(tittyIndexToOwner[_tittyId] == msg.sender);
        Titty storage _titty = Titties[_tittyId];
        _titty.salePrice = _newPrice;

        Titties[_tittyId] = _titty;
    }

    function _setTittyForSale (bool _forSale, uint256 _tittyId) internal {

        require(tittyIndexToOwner[_tittyId] == msg.sender);
        Titty storage _titty = Titties[_tittyId];
        _titty.forSale = _forSale;

        Titties[_tittyId] = _titty;
    }

    function _changeName (string _name, uint256 _tittyId) internal {

        require(tittyIndexToOwner[_tittyId] == msg.sender);
        Titty storage _titty = Titties[_tittyId];
        _titty.name = _name;

        Titties[_tittyId] = _titty;
    }

    function addAccessory (uint256 _id, string _name, uint256 _price, uint256 tittyId ) internal returns (uint) {

        Accessory memory _accessory = Accessory({

            id: _id,
            name: _name,
            price: _price,
            isActive: true

        });

        Titty storage titty = Titties[tittyId];
        uint256 newAccessoryId = Accessories.push(_accessory) - 1;
        titty.accessories.push(newAccessoryId);
        AddAccessory(tittyId, newAccessoryId);

        return newAccessoryId;

    }

    function totalAccessories(uint256 _tittyId) public view returns (uint256) {

        Titty storage titty = Titties[_tittyId];
        return titty.accessories.length;

    }

    function getAccessory(uint256 _tittyId, uint256 _aId) public view returns (uint256 id, string name,  uint256 price, bool active) {

        Titty storage titty = Titties[_tittyId];
        uint256 accId = titty.accessories[_aId];
        Accessory storage accessory = Accessories[accId];
        id = accessory.id;
        name = accessory.name;
        price = accessory.price;
        active = accessory.isActive;

    }

    function createTitty (uint256 _id, string _gender, uint256 _price, address _owner, string _name) internal returns (uint) {
        
        Titty memory _titty = Titty({
            id: _id,
            name: _name,
            gender: _gender,
            originalPrice: _price,
            salePrice: _price,
            accessories: new uint256[](0),
            forSale: false
        });

        uint256 newTittyId = Titties.push(_titty) - 1;

        Creation(
            _owner,
            newTittyId,
            _id
        );

        _transfer(0, _owner, newTittyId);
        return newTittyId;
    }

    

}


/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <