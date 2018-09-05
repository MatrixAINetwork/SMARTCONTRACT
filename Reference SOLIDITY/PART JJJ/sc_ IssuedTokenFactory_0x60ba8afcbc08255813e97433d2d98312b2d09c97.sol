/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/*
This file is part of WeiFund.
*/

/*
A generic issued EC20 standard token, that can be issued by an issuer which the owner
of the contract sets. The issuer can only be set once if the onlyOnce option is true.
There is a freezePeriod option on transfers, if need be. There is also an date of
last issuance setting, if set, no more tokens can be issued past that time.

The token uses the a standard token API as much as possible, and overrides the transfer
and transferFrom methods. This way, we dont need special API's to issue this token.
We can retain the original StandardToken api, but add additional features.

Upon construction, initial token holders can be specified with their values.
Two arrays must be used. One with the token holer addresses, the other with the token
holder balances. They must be aligned by array index.
*/

pragma solidity ^0.4.4;
/*
This file is part of WeiFund.
*/

/*
A common Owned contract that contains properties for contract ownership.
*/



/// @title A single owned campaign contract for instantiating ownership properties.
/// @author Nick Dodson <