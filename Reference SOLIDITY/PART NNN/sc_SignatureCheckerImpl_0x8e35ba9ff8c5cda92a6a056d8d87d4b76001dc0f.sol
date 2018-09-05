/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract SignatureChecker {
    function checkTransferDelegated(
        address _from,
        address _to,
        uint256 _value,
        uint256 _maxReward,
        uint256 _nonce,
        bytes _signature
    ) public constant returns (bool);

    function checkTransferAndCallDelegated(
        address _from,
        address _to,
        uint256 _value,
        bytes _data,
        uint256 _maxReward,
        uint256 _nonce,
        bytes _signature
    ) public constant returns (bool);

    function checkTransferMultipleDelegated(
        address _from,
        address[] _addrs,
        uint256[] _values,
        uint256 _maxReward,
        uint256 _nonce,
        bytes _signature
    ) public constant returns (bool);
}

contract SignatureCheckerImpl {
    function _bytesToSignature(bytes sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := and(mload(add(sig, 65)), 0xFF)
        }
        return (v, r, s);
    }

    bytes32 transferDelegatedHash = keccak256(
        "address contract",
        "string method",
        "address to",
        "uint256 value",
        "uint256 maxReward",
        "uint256 nonce"
    );

    function checkTransferDelegated(
        address _from,
        address _to,
        uint256 _value,
        uint256 _maxReward,
        uint256 _nonce,
        bytes _signature
    ) public constant returns (bool) {
        bytes32 hash = keccak256(
            transferDelegatedHash,
            keccak256(msg.sender, "transferDelegated", _to, _value, _maxReward, _nonce)
        );
        var (v, r, s) = _bytesToSignature(_signature);
        return ecrecover(hash, v, r, s) == _from;
    }

    bytes32 transferAndCallDelegatedHash = keccak256(
        "address contract",
        "string method",
        "address to",
        "uint256 value",
        "bytes data",
        "uint256 maxReward",
        "uint256 nonce"
    );

    function checkTransferAndCallDelegated(
        address _from,
        address _to,
        uint256 _value,
        bytes _data,
        uint256 _maxReward,
        uint256 _nonce,
        bytes _signature
    ) public constant returns (bool) {
        bytes32 hash = keccak256(
            transferAndCallDelegatedHash,
            keccak256(msg.sender, "transferAndCallDelegated", _to, _value, _data, _maxReward, _nonce)
        );
        var (v, r, s) = _bytesToSignature(_signature);
        return ecrecover(hash, v, r, s) == _from;
    }

    bytes32 transferMultipleDelegatedHash = keccak256(
        "address contract",
        "string method",
        "address[] addrs",
        "uint256[] values",
        "uint256 maxReward",
        "uint256 nonce"
    );

    function checkTransferMultipleDelegated(
        address _from,
        address[] _addrs,
        uint256[] _values,
        uint256 _maxReward,
        uint256 _nonce,
        bytes _signature
    ) public constant returns (bool) {
        bytes32 hash = keccak256(
            transferMultipleDelegatedHash,
            keccak256(msg.sender, "transferMultipleDelegated", _addrs, _values, _maxReward, _nonce)
        );
        var (v, r, s) = _bytesToSignature(_signature);
        return ecrecover(hash, v, r, s) == _from;
    }
}