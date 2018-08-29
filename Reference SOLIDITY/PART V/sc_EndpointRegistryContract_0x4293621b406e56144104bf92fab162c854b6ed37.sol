/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract EndpointRegistryContract {
    event AddressRegistered(address indexed eth_address, string socket);

    // Mapping of Ethereum Addresses => SocketEndpoints
    mapping (address => string) address_to_socket;

    modifier noEmptyString(string str)
    {
        require(equals(str, "") != true);
        _;
    }

    /*
     * @notice Registers the Ethereum Address to the Endpoint socket.
     * @dev Registers the Ethereum Address to the Endpoint socket.
     * @param string of socket in this format "127.0.0.1:40001"
     */
    function registerEndpoint(string socket) noEmptyString(socket)
    {
        string storage old_socket = address_to_socket[msg.sender];

        // Compare if the new socket matches the old one, if it does just return
        if (equals(old_socket, socket)) {
            return;
        }

        // Put the ethereum address 0 in front of the old_socket,old_socket:0x0
        address_to_socket[msg.sender] = socket;
        AddressRegistered(msg.sender, socket);
    }

    /*
     * @notice Finds the socket if given an Ethereum Address
     * @dev Finds the socket if given an Ethereum Address
     * @param An eth_address which is a 20 byte Ethereum Address
     * @return A socket which the current Ethereum Address is using.
     */
    function findEndpointByAddress(address eth_address) constant returns (string socket)
    {
        return address_to_socket[eth_address];
    }

    function equals(string a, string b) internal constant returns (bool result)
    {
        if (sha3(a) == sha3(b)) {
            return true;
        }

        return false;
    }
}