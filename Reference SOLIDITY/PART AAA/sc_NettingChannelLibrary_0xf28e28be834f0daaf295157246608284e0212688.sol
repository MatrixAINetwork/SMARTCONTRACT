/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;



interface Token {

    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Utils {
    string constant public contract_version = "0.1._";
    /// @notice Check if a contract exists
    /// @param channel The address to check whether a contract is deployed or not
    /// @return True if a contract exists, false otherwise
    function contractExists(address channel) constant returns (bool) {
        uint size;

        assembly {
            size := extcodesize(channel)
        }

        return size > 0;
    }
}




library NettingChannelLibrary {
    string constant public contract_version = "0.1._";

    struct Participant
    {
        address node_address;

        // Total amount of token transferred to this smart contract through the
        // `deposit` function, note that direct token transfer cannot be
        // tracked and will be burned.
        uint256 balance;

        // The latest known merkle root of the pending hash-time locks, used to
        // validate the withdrawn proofs.
        bytes32 locksroot;

        // The latest known transferred_amount from this node to the other
        // participant, used to compute the net balance on settlement.
        uint256 transferred_amount;

        // Value used to order transfers and only accept the latest on calls to
        // update, this will only be relevant after either #182 or #293 is
        // implemented.
        uint64 nonce;

        // A mapping to keep track of locks that have been withdrawn.
        mapping(bytes32 => bool) withdrawn_locks;
    }

    struct Data {
        uint settle_timeout;
        uint opened;
        uint closed;
        uint settled;
        address closing_address;
        Token token;
        Participant[2] participants;
        mapping(address => uint8) participant_index;
        bool updated;
    }


    modifier notSettledButClosed(Data storage self) {
        require(self.settled <= 0 && self.closed > 0);
        _;
    }

    modifier stillTimeout(Data storage self) {
        require(self.closed + self.settle_timeout >= block.number);
        _;
    }

    modifier timeoutOver(Data storage self) {
        require(self.closed + self.settle_timeout <= block.number);
        _;
    }

    modifier channelSettled(Data storage self) {
        require(self.settled != 0);
        _;
    }

    /// @notice Deposit amount to channel.
    /// @dev Deposit an amount to the channel. At least one of the participants
    /// must deposit before the channel is opened.
    /// @param amount The amount to be deposited to the address
    /// @return Success if the transfer was successful
    /// @return The new balance of the invoker
    function deposit(Data storage self, uint256 amount)
        returns (bool success, uint256 balance)
    {
        uint8 index;

        require(self.opened > 0);
        require(self.closed == 0);
        require(self.token.balanceOf(msg.sender) >= amount);

        index = index_or_throw(self, msg.sender);
        Participant storage participant = self.participants[index];

        success = self.token.transferFrom(msg.sender, this, amount);
        if (success == true) {
            balance = participant.balance;
            balance += amount;
            participant.balance = balance;

            return (true, balance);
        }

        return (false, 0);
    }

    /// @notice Close a channel between two parties that was used bidirectionally
    function close(
        Data storage self,
        uint64 nonce,
        uint256 transferred_amount,
        bytes32 locksroot,
        bytes32 extra_hash,
        bytes signature
    ) {
        address transfer_address;
        uint closer_index;
        uint counterparty_index;

        // close can be called only once
        require(self.closed == 0);
        self.closed = block.number;

        // Only a participant can call close
        closer_index = index_or_throw(self, msg.sender);
        self.closing_address = msg.sender;

        // Only the closing party can provide a transfer from the counterparty,
        // and only when this function is called, i.e. this value can not be
        // updated afterwards.

        // An empty value means that the closer never received a transfer, or
        // he is intentionally not providing the latest transfer, in which case
        // the closing party is going to lose the tokens that were transferred
        // to him.
        if (signature.length == 65) {
            transfer_address = recoverAddressFromSignature(
                nonce,
                transferred_amount,
                locksroot,
                extra_hash,
                signature 
            );

            counterparty_index = index_or_throw(self, transfer_address);
            require(closer_index != counterparty_index);

            // update the structure of the counterparty with its data provided
            // by the closing node
            Participant storage counterparty = self.participants[counterparty_index];
            counterparty.nonce = uint64(nonce);
            counterparty.locksroot = locksroot;
            counterparty.transferred_amount = transferred_amount;
        }
    }

    /// @notice Updates counter party transfer after closing.
    function updateTransfer(
        Data storage self,
        uint64 nonce,
        uint256 transferred_amount,
        bytes32 locksroot,
        bytes32 extra_hash,
        bytes signature
    )
        notSettledButClosed(self)
        stillTimeout(self)
    {
        address transfer_address;
        uint8 caller_index;
        uint8 closer_index;

        // updateTransfer can be called by the counter party only once
        require(!self.updated);
        self.updated = true;

        // Only a participant can call updateTransfer (#293 for third parties)
        caller_index = index_or_throw(self, msg.sender);

        // The closer is not allowed to call updateTransfer
        require(self.closing_address != msg.sender);

        // Counter party can only update the closer transfer
        transfer_address = recoverAddressFromSignature(
            nonce,
            transferred_amount,
            locksroot,
            extra_hash,
            signature 
        );
        require(transfer_address == self.closing_address);

        // Update the structure of the closer with its data provided by the
        // counterparty
        closer_index = 1 - caller_index;

        self.participants[closer_index].nonce = nonce;
        self.participants[closer_index].locksroot = locksroot;
        self.participants[closer_index].transferred_amount = transferred_amount;
    }

    function recoverAddressFromSignature(
        uint64 nonce,
        uint256 transferred_amount,
        bytes32 locksroot,
        bytes32 extra_hash,
        bytes signature
    )
        constant internal returns (address)
    {
        bytes32 signed_hash;

        require(signature.length == 65);

        signed_hash = sha3(
            nonce,
            transferred_amount,
            locksroot,
            this,
            extra_hash
        );

        var (r, s, v) = signatureSplit(signature);
        return ecrecover(signed_hash, v, r, s);
    }

    /// @notice Unlock a locked transfer
    /// @dev Unlock a locked transfer
    /// @param locked_encoded The lock
    /// @param merkle_proof The merkle proof
    /// @param secret The secret
    function withdraw(Data storage self, bytes locked_encoded, bytes merkle_proof, bytes32 secret)
        notSettledButClosed(self)
    {
        uint amount;
        uint8 index;
        uint64 expiration;
        bytes32 h;
        bytes32 hashlock;

        // Check if msg.sender is a participant and select the partner (for
        // third party unlock see #541)
        index = 1 - index_or_throw(self, msg.sender);
        Participant storage counterparty = self.participants[index];

        // An empty locksroot means there are no pending locks
        require(counterparty.locksroot != 0);

        (expiration, amount, hashlock) = decodeLock(locked_encoded);

        // A lock can be withdrawn only once per participant
        require(!counterparty.withdrawn_locks[hashlock]);

        counterparty.withdrawn_locks[hashlock] = true;

        // The lock must not have expired, it does not matter how far in the
        // future it would have expired
        require(expiration >= block.number);
        require(hashlock == sha3(secret));

        h = computeMerkleRoot(locked_encoded, merkle_proof);

        require(counterparty.locksroot == h);

        // This implementation allows for each transfer to be set only once, so
        // it's safe to update the transferred_amount in place.
        //
        // Once third parties are allowed to update the counter party transfer
        // (#293, #182) the locksroot may change, if the locksroot change the
        // transferred_amount must be reset and locks must be re-withdrawn, so
        // this is also safe.
        //
        // This may be problematic if an update changes the transferred_amount
        // but not the locksroot, since the locks don't need to be
        // re-withdrawn, the difference in the transferred_amount must be
        // accounted for.
        counterparty.transferred_amount += amount;
    }

    function computeMerkleRoot(bytes lock, bytes merkle_proof)
        internal
        constant
        returns (bytes32)
    {
        require(merkle_proof.length % 32 == 0);

        uint i;
        bytes32 h;
        bytes32 el;

        h = sha3(lock);
        for (i = 32; i <= merkle_proof.length; i += 32) {
            assembly {
                el := mload(add(merkle_proof, i))
            }

            if (h < el) {
                h = sha3(h, el);
            } else {
                h = sha3(el, h);
            }
        }

        return h;
    }

    /// @notice Settles the balance between the two parties
    /// @dev Settles the balances of the two parties fo the channel
    /// @return The participants with netted balances
    function settle(Data storage self)
        notSettledButClosed(self)
        timeoutOver(self)
    {
        uint8 closing_index;
        uint8 counter_index;
        uint256 total_deposit;
        uint256 counter_net;
        uint256 closer_amount;
        uint256 counter_amount;

        self.settled = block.number;

        closing_index = index_or_throw(self, self.closing_address);
        counter_index = 1 - closing_index;

        Participant storage closing_party = self.participants[closing_index];
        Participant storage counter_party = self.participants[counter_index];

        counter_net = (
            counter_party.balance
            + closing_party.transferred_amount
            - counter_party.transferred_amount
        );

        // Direct token transfers done through the token `transfer` function
        // cannot be accounted for, these superfluous tokens will be burned,
        // this is because there is no way to tell which participant (if any)
        // had ownership over the token.
        total_deposit = closing_party.balance + counter_party.balance;

        // When the closing party does not provide the counter party transfer,
        // the `counter_net` may be larger than the `total_deposit`, without
        // the min the token transfer fail and the token is locked.
        counter_amount = min(counter_net, total_deposit);

        // When the counter party does not provide the closing party transfer,
        // then `counter_amount` may be negative and the transfer fails, force
        // the value to 0.
        counter_amount = max(counter_amount, 0);

        // At this point `counter_amount` is between [0,total_deposit], so this
        // is safe.
        closer_amount = total_deposit - counter_amount;

        if (counter_amount > 0) {
            require(self.token.transfer(counter_party.node_address, counter_amount));
        }

        if (closer_amount > 0) {
            require(self.token.transfer(closing_party.node_address, closer_amount));
        }

        kill(self);
    }

    // NOTES:
    //
    // - The EVM is a big-endian, byte addressing machine, with 32bytes/256bits
    //   words.
    // - The Ethereum Contract ABI specifies that variable length types have a
    //   32bytes prefix to define the variable size.
    // - Solidity has additional data types that are narrower than 32bytes
    //   (e.g. uint128 uses a half word).
    // - Solidity uses the *least-significant* bits of the word to store the
    //   values of a narrower type.
    //
    // GENERAL APPROACH:
    //
    // Add to the message pointer the number of bytes required to move the
    // address so that the target data is at the end of the 32bytes word.
    //
    // EXAMPLE:
    //
    // To decode the cmdid, consider this initial state:
    //
    //
    //     v- pointer word start
    //     [ 32 bytes length prefix ][ cmdid ] ----
    //                              ^- pointer word end
    //
    //
    // Because the cmdid has 1 byte length the type uint8 is used, the decoder
    // needs to move the pointer so the cmdid is at the end of the pointer
    // word.
    //
    //
    //             v- pointer word start [moved 1byte ahead]
    //     [ 32 bytes length prefix ][ cmdid ] ----
    //                                       ^- pointer word end
    //
    //
    // Now the data of the cmdid can be loaded to the uint8 variable.
    //
    // REFERENCES:
    // - https://github.com/ethereum/wiki/wiki/Ethereum-Contract-ABI
    // - http://solidity.readthedocs.io/en/develop/assembly.html

    function decodeLock(bytes lock) internal returns (uint64 expiration, uint amount, bytes32 hashlock) {
        require(lock.length == 72);

        // Lock format:
        // [0:8] expiration
        // [8:40] amount
        // [40:72] hashlock
        assembly {
            expiration := mload(add(lock, 8))
            amount := mload(add(lock, 40))
            hashlock := mload(add(lock, 72))
        }
    }

    function signatureSplit(bytes signature) internal returns (bytes32 r, bytes32 s, uint8 v) {
        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            // Here we are loading the last 32 bytes, including 31 bytes
            // of 's'. There is no 'mload8' to do this.
            //
            // 'byte' is not working due to the Solidity parser, so lets
            // use the second best option, 'and'
            v := and(mload(add(signature, 65)), 0xff)
        }

        require(v == 27 || v == 28);
    }

    function index_or_throw(Data storage self, address participant_address) private returns (uint8) {
        uint8 n;
        // Return index of participant, or throw
        n = self.participant_index[participant_address];
        assert(n != 0);
        return n - 1;
    }

    function min(uint a, uint b) constant internal returns (uint) {
        return a > b ? b : a;
    }

    function max(uint a, uint b) constant internal returns (uint) {
        return a > b ? a : b;
    }

    function kill(Data storage self) channelSettled(self) {
        selfdestruct(0x00000000000000000000);
    }
}

contract NettingChannelContract {
    string constant public contract_version = "0.1._";

    using NettingChannelLibrary for NettingChannelLibrary.Data;
    NettingChannelLibrary.Data public data;

    event ChannelNewBalance(address token_address, address participant, uint balance, uint block_number);
    event ChannelClosed(address closing_address, uint block_number);
    event TransferUpdated(address node_address, uint block_number);
    event ChannelSettled(uint block_number);
    event ChannelSecretRevealed(bytes32 secret, address receiver_address);

    modifier settleTimeoutNotTooLow(uint t) {
        assert(t >= 6);
        _;
    }

    function NettingChannelContract(
        address token_address,
        address participant1,
        address participant2,
        uint timeout)
        settleTimeoutNotTooLow(timeout)
    {
        require(participant1 != participant2);

        data.participants[0].node_address = participant1;
        data.participants[1].node_address = participant2;
        data.participant_index[participant1] = 1;
        data.participant_index[participant2] = 2;

        data.token = Token(token_address);
        data.settle_timeout = timeout;
        data.opened = block.number;
    }

    /// @notice Caller makes a deposit into their channel balance.
    /// @param amount The amount caller wants to deposit.
    /// @return True if deposit is successful.
    function deposit(uint256 amount) returns (bool) {
        bool success;
        uint256 balance;

        (success, balance) = data.deposit(amount);

        if (success == true) {
            ChannelNewBalance(data.token, msg.sender, balance, block.number);
        }

        return success;
    }

    /// @notice Get the address and balance of both partners in a channel.
    /// @return The address and balance pairs.
    function addressAndBalance()
        constant
        returns (
        address participant1,
        uint balance1,
        address participant2,
        uint balance2)
    {
        NettingChannelLibrary.Participant storage node1 = data.participants[0];
        NettingChannelLibrary.Participant storage node2 = data.participants[1];

        participant1 = node1.node_address;
        balance1 = node1.balance;
        participant2 = node2.node_address;
        balance2 = node2.balance;
    }

    /// @notice Close the channel. Can only be called by a participant in the channel.
    function close(
        uint64 nonce,
        uint256 transferred_amount,
        bytes32 locksroot,
        bytes32 extra_hash,
        bytes signature
    ) {
        data.close(
            nonce,
            transferred_amount,
            locksroot,
            extra_hash,
            signature
        );
        ChannelClosed(msg.sender, data.closed);
    }

    /// @notice Dispute the state after closing, called by the counterparty (the
    ///         participant who did not close the channel).
    function updateTransfer(
        uint64 nonce,
        uint256 transferred_amount,
        bytes32 locksroot,
        bytes32 extra_hash,
        bytes signature
    ) {
        data.updateTransfer(
            nonce,
            transferred_amount,
            locksroot,
            extra_hash,
            signature
        );
        TransferUpdated(msg.sender, block.number);
    }

    /// @notice Unlock a locked transfer.
    /// @param locked_encoded The locked transfer to be unlocked.
    /// @param merkle_proof The merke_proof for the locked transfer.
    /// @param secret The secret to unlock the locked transfer.
    function withdraw(bytes locked_encoded, bytes merkle_proof, bytes32 secret) {
        // throws if sender is not a participant
        data.withdraw(locked_encoded, merkle_proof, secret);
        ChannelSecretRevealed(secret, msg.sender);
    }

    /// @notice Settle the transfers and balances of the channel and pay out to
    ///         each participant. Can only be called after the channel is closed
    ///         and only after the number of blocks in the settlement timeout
    ///         have passed.
    function settle() {
        data.settle();
        ChannelSettled(data.settled);
    }

    /// @notice Returns the number of blocks until the settlement timeout.
    /// @return The number of blocks until the settlement timeout.
    function settleTimeout() constant returns (uint) {
        return data.settle_timeout;
    }

    /// @notice Returns the address of the token.
    /// @return The address of the token.
    function tokenAddress() constant returns (address) {
        return data.token;
    }

    /// @notice Returns the block number for when the channel was opened.
    /// @return The block number for when the channel was opened.
    function opened() constant returns (uint) {
        return data.opened;
    }

    /// @notice Returns the block number for when the channel was closed.
    /// @return The block number for when the channel was closed.
    function closed() constant returns (uint) {
        return data.closed;
    }

    /// @notice Returns the block number for when the channel was settled.
    /// @return The block number for when the channel was settled.
    function settled() constant returns (uint) {
        return data.settled;
    }

    /// @notice Returns the address of the closing participant.
    /// @return The address of the closing participant.
    function closingAddress() constant returns (address) {
        return data.closing_address;
    }

    function () { revert(); }
}

library ChannelManagerLibrary {
    string constant public contract_version = "0.1._";

    struct Data {
        Token token;

        address[] all_channels;
        mapping(bytes32 => uint) partyhash_to_channelpos;

        mapping(address => address[]) nodeaddress_to_channeladdresses;
        mapping(address => mapping(address => uint)) node_index;
    }

    /// @notice Get the address of channel with a partner
    /// @param partner The address of the partner
    /// @return The address of the channel
    function getChannelWith(Data storage self, address partner) constant returns (address) {
        bytes32 party_hash = partyHash(msg.sender, partner);
        uint channel_pos = self.partyhash_to_channelpos[party_hash];

        if (channel_pos != 0) {
            return self.all_channels[channel_pos - 1];
        }
    }

    /// @notice Create a new payment channel between two parties
    /// @param partner The address of the partner
    /// @param settle_timeout The settle timeout in blocks
    /// @return The address of the newly created NettingChannelContract.
    function newChannel(Data storage self, address partner, uint settle_timeout)
        returns (address)
    {
        address[] storage caller_channels = self.nodeaddress_to_channeladdresses[msg.sender];
        address[] storage partner_channels = self.nodeaddress_to_channeladdresses[partner];

        bytes32 party_hash = partyHash(msg.sender, partner);
        uint channel_pos = self.partyhash_to_channelpos[party_hash];

        address new_channel_address = new NettingChannelContract(
            self.token,
            msg.sender,
            partner,
            settle_timeout
        );

        if (channel_pos != 0) {
            // Check if the channel was settled. Once a channel is settled it
            // kills itself, so address must not have code.
            address settled_channel = self.all_channels[channel_pos - 1];
            require(!contractExists(settled_channel));

            uint caller_pos = self.node_index[msg.sender][partner];
            uint partner_pos = self.node_index[partner][msg.sender];

            // replace the channel address in-place
            self.all_channels[channel_pos - 1] = new_channel_address;
            caller_channels[caller_pos - 1] = new_channel_address;
            partner_channels[partner_pos - 1] = new_channel_address;

        } else {
            self.all_channels.push(new_channel_address);
            caller_channels.push(new_channel_address);
            partner_channels.push(new_channel_address);

            // using the 1-index, 0 is used for the absence of a value
            self.partyhash_to_channelpos[party_hash] = self.all_channels.length;
            self.node_index[msg.sender][partner] = caller_channels.length;
            self.node_index[partner][msg.sender] = partner_channels.length;
        }

        return new_channel_address;
    }

    /// @notice Get the hash of the two addresses
    /// @param address_one address of one party
    /// @param address_two of the other party
    /// @return The sha3 hash of both parties sorted by size of address
    function partyHash(address address_one, address address_two) internal constant returns (bytes32) {
        if (address_one < address_two) {
            return sha3(address_one, address_two);
        } else {
            // The two participants can't be the same here due to this check in
            // the netting channel constructor:
            // https://github.com/raiden-network/raiden/blob/e17d96db375d31b134ae7b4e2ad2c1f905b47857/raiden/smart_contracts/NettingChannelContract.sol#L27
            return sha3(address_two, address_one);
        }
    }

    /// TODO: Find a way to remove this function duplication from Utils.sol here
    ///       At the moment libraries can't inherit so we need to add this here
    ///       explicitly.
    /// @notice Check if a contract exists
    /// @param channel The address to check whether a contract is deployed or not
    /// @return True if a contract exists, false otherwise
    function contractExists(address channel) private constant returns (bool) {
        uint size;

        assembly {
            size := extcodesize(channel)
        }

        return size > 0;
    }
}

// for each token a manager will be deployed, to reduce gas usage for manager
// deployment the logic is moved into a library and this contract will work
// only as a proxy/state container.
contract ChannelManagerContract is Utils {
    string constant public contract_version = "0.1._";

    using ChannelManagerLibrary for ChannelManagerLibrary.Data;
    ChannelManagerLibrary.Data data;

    event ChannelNew(
        address netting_channel,
        address participant1,
        address participant2,
        uint settle_timeout
    );

    event ChannelDeleted(
        address caller_address,
        address partner
    );

    function ChannelManagerContract(address token_address) {
        data.token = Token(token_address);
    }

    /// @notice Get all channels
    /// @return All the open channels
    function getChannelsAddresses() constant returns (address[]) {
        return data.all_channels;
    }

    /// @notice Get all participants of all channels
    /// @return All participants in all channels
    function getChannelsParticipants() constant returns (address[]) {
        uint i;
        uint pos;
        address[] memory result;
        NettingChannelContract channel;

        uint open_channels_num = 0;
        for (i = 0; i < data.all_channels.length; i++) {
            if (contractExists(data.all_channels[i])) {
                open_channels_num += 1;
            }
        }
        result = new address[](open_channels_num * 2);

        pos = 0;
        for (i = 0; i < data.all_channels.length; i++) {
            if (!contractExists(data.all_channels[i])) {
                continue;
            }
            channel = NettingChannelContract(data.all_channels[i]);

            var (address1, , address2, ) = channel.addressAndBalance();

            result[pos] = address1;
            pos += 1;
            result[pos] = address2;
            pos += 1;
        }

        return result;
    }

    /// @notice Get all channels that an address participates in.
    /// @param node_address The address of the node
    /// @return The channel's addresses that node_address participates in.
    function nettingContractsByAddress(address node_address) constant returns (address[]) {
        return data.nodeaddress_to_channeladdresses[node_address];
    }

    /// @notice Get the address of the channel token
    /// @return The token
    function tokenAddress() constant returns (address) {
        return data.token;
    }

    /// @notice Get the address of channel with a partner
    /// @param partner The address of the partner
    /// @return The address of the channel
    function getChannelWith(address partner) constant returns (address) {
        return data.getChannelWith(partner);
    }

    /// @notice Create a new payment channel between two parties
    /// @param partner The address of the partner
    /// @param settle_timeout The settle timeout in blocks
    /// @return The address of the newly created NettingChannelContract.
    function newChannel(address partner, uint settle_timeout) returns (address) {
        address old_channel = getChannelWith(partner);
        if (old_channel != 0) {
            ChannelDeleted(msg.sender, partner);
        }

        address new_channel = data.newChannel(partner, settle_timeout);
        ChannelNew(new_channel, msg.sender, partner, settle_timeout);
        return new_channel;
    }

    function () { revert(); }
}

contract Registry {
    string constant public contract_version = "0.1._";

    mapping(address => address) public registry;
    address[] public tokens;

    event TokenAdded(address token_address, address channel_manager_address);

    modifier addressExists(address _address) {
        require(registry[_address] != 0x0);
        _;
    }

    modifier doesNotExist(address _address) {
        // Check if it's already registered or token contract is invalid.
        // We assume if it has a valid totalSupply() function it's a valid Token contract
        require(registry[_address] == 0x0);
        Token token = Token(_address);
        token.totalSupply();
        _;
    }

    /// @notice Register a new ERC20 token
    /// @param token_address Address of the token
    /// @return The address of the channel manager
    function addToken(address token_address)
        doesNotExist(token_address)
        returns (address)
    {
        address manager_address;

        manager_address = new ChannelManagerContract(token_address);

        registry[token_address] = manager_address;
        tokens.push(token_address);

        TokenAdded(token_address, manager_address);

        return manager_address;
    }

    /// @notice Get the ChannelManager address for a specific token
    /// @param token_address The address of the given token
    /// @return Address of channel manager
    function channelManagerByToken(address token_address)
        addressExists(token_address)
        constant
        returns (address)
    {
        return registry[token_address];
    }

    /// @notice Get all registered tokens
    /// @return addresses of all registered tokens
    function tokenAddresses()
        constant
        returns (address[])
    {
        return tokens;
    }

    /// @notice Get the addresses of all channel managers for all registered tokens
    /// @return addresses of all channel managers
    function channelManagerAddresses()
        constant
        returns (address[])
    {
        uint i;
        address token_address;
        address[] memory result;

        result = new address[](tokens.length);

        for (i = 0; i < tokens.length; i++) {
            token_address = tokens[i];
            result[i] = registry[token_address];
        }

        return result;
    }

    function () { revert(); }
}