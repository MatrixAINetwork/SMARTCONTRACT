/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

// File: contracts/LikeCoinInterface.sol

//    Copyright (C) 2017 LikeCoin Foundation Limited
//
//    This file is part of LikeCoin Smart Contract.
//
//    LikeCoin Smart Contract is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    LikeCoin Smart Contract is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with LikeCoin Smart Contract.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.4.18;

contract LikeCoinInterface {
	function balanceOf(address _owner) public constant returns (uint256 balance);
	function transfer(address _to, uint256 _value) public returns (bool success);
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
	function approve(address _spender, uint256 _value) public returns (bool success);
}

// File: contracts/Ownable.sol

contract Ownable {

	address public owner;
	address public pendingOwner;
	address public operator;

	event OwnershipTransferred(
		address indexed previousOwner,
		address indexed newOwner
	);

	/**
	 * @dev The Ownable constructor sets the original `owner` of the contract to the sender
	 * account.
	 */
	constructor() public {
		owner = msg.sender;
	}

	/**
	 * @dev Throws if called by any account other than the owner.
	 */
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	/**
	 * @dev Modifier throws if called by any account other than the pendingOwner.
	 */
	modifier onlyPendingOwner() {
		require(msg.sender == pendingOwner);
		_;
	}

	modifier ownerOrOperator {
		require(msg.sender == owner || msg.sender == operator);
		_;
	}

	/**
	 * @dev Allows the current owner to set the pendingOwner address.
	 * @param newOwner The address to transfer ownership to.
	 */
	function transferOwnership(address newOwner) onlyOwner public {
		pendingOwner = newOwner;
	}

	/**
	 * @dev Allows the pendingOwner address to finalize the transfer.
	 */
	function claimOwnership() onlyPendingOwner public {
		emit OwnershipTransferred(owner, pendingOwner);
		owner = pendingOwner;
		pendingOwner = address(0);
	}

	function setOperator(address _operator) onlyOwner public {
		operator = _operator;
	}

}

// File: contracts/ArtMuseumBase.sol

contract ArtMuseumBase is Ownable {

	struct Artwork {
		uint8 artworkType;
		uint32 sequenceNumber;
		uint128 value;
		address player;
	}
	LikeCoinInterface public like;

	/** array holding ids mapping of the curret artworks*/
	uint32[] public ids;
	/** the last sequence id to be given to the link artwork **/
	uint32 public lastId;
	/** the id of the oldest artwork */
	uint32 public oldest;
	/** the artwork belonging to a given id */
	mapping(uint32 => Artwork) artworks;
	/** the user purchase sequence number per each artwork type */
	mapping(address=>mapping(uint8 => uint32)) userArtworkSequenceNumber;
	/** the cost of each artwork type */
	uint128[] public costs;
	/** the value of each artwork type (cost - fee), so it's not necessary to compute it each time*/
	uint128[] public values;
	/** the fee to be paid each time an artwork is bought in percent*/
	uint8 public fee;

	/** total number of artworks in the game (uint32 because of multiplication issues) */
	uint32 public numArtworks;
	/** The maximum of artworks allowed in the game */
	uint16 public maxArtworks;
	/** number of artworks per type */
	uint32[] numArtworksXType;

	/** initializes the contract parameters */
	function init(address _likeAddr) public onlyOwner {
		require(like==address(0));
		like = LikeCoinInterface(_likeAddr);
		costs = [800 ether, 2000 ether, 5000 ether, 12000 ether, 25000 ether];
		setFee(5);
		maxArtworks = 1000;
		lastId = 1;
		oldest = 0;
	}

	function deposit() payable public {

	}

	function withdrawBalance() public onlyOwner returns(bool res) {
		owner.transfer(address(this).balance);
		return true;
	}

	/**
	 * allows the owner to collect the accumulated fees
	 * sends the given amount to the owner's address if the amount does not exceed the
	 * fees (cannot touch the players' balances)
	 * */
	function collectFees(uint128 amount) public onlyOwner {
		uint collectedFees = getFees();
		if (amount <= collectedFees) {
			like.transfer(owner,amount);
		}
	}

	function getArtwork(uint32 artworkId) public constant returns(uint8 artworkType, uint32 sequenceNumber, uint128 value, address player) {
		return (artworks[artworkId].artworkType, artworks[artworkId].sequenceNumber, artworks[artworkId].value, artworks[artworkId].player);
	}

	function getAllArtworks() public constant returns(uint32[] artworkIds,uint8[] types,uint32[] sequenceNumbers, uint128[] artworkValues) {
		uint32 id;
		artworkIds = new uint32[](numArtworks);
		types = new uint8[](numArtworks);
		sequenceNumbers = new uint32[](numArtworks);
		artworkValues = new uint128[](numArtworks);
		for (uint16 i = 0; i < numArtworks; i++) {
			id = ids[i];
			artworkIds[i] = id;
			types[i] = artworks[id].artworkType;
			sequenceNumbers[i] = artworks[id].sequenceNumber;
			artworkValues[i] = artworks[id].value;
		}
	}

	function getAllArtworksByOwner() public constant returns(uint32[] artworkIds,uint8[] types,uint32[] sequenceNumbers, uint128[] artworkValues) {
		uint32 id;
		uint16 j = 0;
		uint16 howmany = 0;
		address player = address(msg.sender);
		for (uint16 k = 0; k < numArtworks; k++) {
			if (artworks[ids[k]].player == player)
				howmany++;
		}
		artworkIds = new uint32[](howmany);
		types = new uint8[](howmany);
		sequenceNumbers = new uint32[](howmany);
		artworkValues = new uint128[](howmany);
		for (uint16 i = 0; i < numArtworks; i++) {
			if (artworks[ids[i]].player == player) {
				id = ids[i];
				artworkIds[j] = id;
				types[j] = artworks[id].artworkType;
				sequenceNumbers[j] = artworks[id].sequenceNumber;
				artworkValues[j] = artworks[id].value;
				j++;
			}
		}
	}

	function setCosts(uint128[] _costs) public onlyOwner {
		require(_costs.length >= costs.length);
		costs = _costs;
		setFee(fee);
	}
	
	function setFee(uint8 _fee) public onlyOwner {
		fee = _fee;
		for (uint8 i = 0; i < costs.length; i++) {
			if (i < values.length)
				values[i] = costs[i] - costs[i] / 100 * fee;
			else {
				values.push(costs[i] - costs[i] / 100 * fee);
				numArtworksXType.push(0);
			}
		}
	}

	function getFees() public constant returns(uint) {
		uint reserved = 0;
		for (uint16 j = 0; j < numArtworks; j++)
			reserved += artworks[ids[j]].value;
		return like.balanceOf(this) - reserved;
	}


}

// File: contracts/oraclizeAPI.sol

// <ORACLIZE_API>
/*
Copyright (c) 2015-2016 Oraclize SRL
Copyright (c) 2016 Oraclize LTD



Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:



The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

// This api is currently targeted at 0.4.18, please import oraclizeAPI_pre0.4.sol or oraclizeAPI_0.4 where necessary

pragma solidity ^0.4.20;//<=0.4.20;// Incompatible compiler version... please select one stated within pragma solidity or use different oraclizeAPI version

contract OraclizeI {
	address public cbAddress;
	function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);
	function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);
	function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);
	function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);
	function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);
	function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);
	function getPrice(string _datasource) public returns (uint _dsprice);
	function getPrice(string _datasource, uint gaslimit) public returns (uint _dsprice);
	function setProofType(byte _proofType) external;
	function setCustomGasPrice(uint _gasPrice) external;
	function randomDS_getSessionPubKeyHash() external constant returns(bytes32);
}

contract OraclizeAddrResolverI {
	function getAddress() public returns (address _addr);
}

contract usingOraclize { // is ArtMuseumBase {
	uint constant day = 60*60*24;
	uint constant week = 60*60*24*7;
	uint constant month = 60*60*24*30;
	byte constant proofType_NONE = 0x00;
	byte constant proofType_TLSNotary = 0x10;
	byte constant proofType_Android = 0x20;
	byte constant proofType_Ledger = 0x30;
	byte constant proofType_Native = 0xF0;
	byte constant proofStorage_IPFS = 0x01;
	uint8 constant networkID_auto = 0;
	uint8 constant networkID_mainnet = 1;
	uint8 constant networkID_testnet = 2;
	uint8 constant networkID_morden = 2;
	uint8 constant networkID_consensys = 161;
	string oraclize_network_name;
	OraclizeAddrResolverI OAR;
	OraclizeI oraclize;
	modifier oraclizeAPI {
		if((address(OAR)==0)||(getCodeSize(address(OAR))==0))
			oraclize_setNetwork(networkID_auto);

		if(address(oraclize) != OAR.getAddress())
			oraclize = OraclizeI(OAR.getAddress());

		_;
	}
	function oraclize_setNetwork(uint8 networkID) internal returns(bool){
	  return oraclize_setNetwork();
	  networkID; // silence the warning and remain backwards compatible
	}
	function oraclize_setNetwork() internal returns(bool){
		if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet
			OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
			oraclize_setNetworkName("eth_mainnet");
			return true;
		}
		if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet
			OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
			oraclize_setNetworkName("eth_ropsten3");
			return true;
		}
		if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet
			OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);
			oraclize_setNetworkName("eth_kovan");
			return true;
		}
		if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet
			OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);
			oraclize_setNetworkName("eth_rinkeby");
			return true;
		}
		if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge
			OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
			return true;
		}
		if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide
			OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
			return true;
		}
		if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity
			OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);
			return true;
		}
		return false;
	}
	function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){
		return oraclize.getPrice(datasource);
	}
	function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){
		return oraclize.getPrice(datasource, gaslimit);
	}
	function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
		uint price = oraclize.getPrice(datasource);
		if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
		return oraclize.query.value(price)(0, datasource, arg);
	}
	function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
		uint price = oraclize.getPrice(datasource);
		if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
		return oraclize.query.value(price)(timestamp, datasource, arg);
	}
	function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
		uint price = oraclize.getPrice(datasource, gaslimit);
		if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
		return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
	}
	function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
		uint price = oraclize.getPrice(datasource, gaslimit);
		if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
		return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);
	}
	function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
		uint price = oraclize.getPrice(datasource);
		if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
		return oraclize.query2.value(price)(0, datasource, arg1, arg2);
	}
	function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
		uint price = oraclize.getPrice(datasource);
		if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
		return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);
	}
	function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
		uint price = oraclize.getPrice(datasource, gaslimit);
		if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
		return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
	}
	function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
		uint price = oraclize.getPrice(datasource, gaslimit);
		if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
		return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);
	}

	function oraclize_cbAddress() oraclizeAPI internal returns (address){
		return oraclize.cbAddress();
	}
	function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {
		return oraclize.setCustomGasPrice(gasPrice);
	}
	function getCodeSize(address _addr) constant internal returns(uint _size) {
		assembly {
			_size := extcodesize(_addr)
		}
	}
	// parseInt
	function parseInt(string _a) internal pure returns (uint) {
		return parseInt(_a, 0);
	}
	// parseInt(parseFloat*10^_b)
	function parseInt(string _a, uint _b) internal pure returns (uint) {
		bytes memory bresult = bytes(_a);
		uint mint = 0;
		bool decimals = false;
		for (uint i=0; i<bresult.length; i++){
			if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
				if (decimals){
				   if (_b == 0) break;
					else _b--;
				}
				mint *= 10;
				mint += uint(bresult[i]) - 48;
			} else if (bresult[i] == 46) decimals = true;
		}
		if (_b > 0) mint *= 10**_b;
		return mint;
	}
	function oraclize_setNetworkName(string _network_name) internal {
		oraclize_network_name = _network_name;
	}
	function oraclize_getNetworkName() internal view returns (string) {
		return oraclize_network_name;
	}
}

// File: contracts/strings.sol

/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <