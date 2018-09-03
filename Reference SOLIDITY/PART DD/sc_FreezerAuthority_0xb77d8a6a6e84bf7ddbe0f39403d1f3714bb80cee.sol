/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract FreezerAuthority is DSAuthority {
    address[] internal c_freezers;
    // sha3("setFreezing(address,uint256,uint256,uint8)").slice(0,10)
    bytes4 constant setFreezingSig = bytes4(0x51c3b8a6);
    // sha3("transferAndFreezing(address,uint256,uint256,uint256,uint8)").slice(0,10)
    bytes4 constant transferAndFreezingSig = bytes4(0xb8a1fdb6);

    function canCall(address caller, address, bytes4 sig) public view returns (bool) {
        // freezer can call setFreezing, transferAndFreezing
        if (isFreezer(caller) && sig == setFreezingSig || sig == transferAndFreezingSig) {
            return true;
        } else {
            return false;
        }
    }

    function addFreezer(address freezer) public {
        int i = indexOf(c_freezers, freezer);
        if (i < 0) {
            c_freezers.push(freezer);
        }
    }

    function removeFreezer(address freezer) public {
        int index = indexOf(c_freezers, freezer);
        if (index >= 0) {
            uint i = uint(index);
            while (i < c_freezers.length - 1) {
                c_freezers[i] = c_freezers[i + 1];
            }
            c_freezers.length--;
        }
    }

    /** Finds the index of a given value in an array. */
    function indexOf(address[] values, address value) internal pure returns (int) {
        uint i = 0;
        while (i < values.length) {
            if (values[i] == value) {
                return int(i);
            }
            i++;
        }
        return int(- 1);
    }

    function isFreezer(address addr) public constant returns (bool) {
        return indexOf(c_freezers, addr) >= 0;
    }
}