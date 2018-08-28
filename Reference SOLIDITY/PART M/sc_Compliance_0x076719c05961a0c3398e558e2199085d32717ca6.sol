/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/

interface ICompliance {

    /**
     * @dev `setRegsitrarAddress` This function set the SecurityTokenRegistrar contract address. 
     * @param _STRegistrar It is the `this` reference of STR contract
     * @return bool
     */

    function setRegsitrarAddress(address _STRegistrar) public returns (bool);
    
    /**
     * @dev `createTemplate` is a simple function to create a new compliance template
     * @param _offeringType The name of the security being issued
     * @param _issuerJurisdiction The jurisdiction id of the issuer
     * @param _accredited Accreditation status required for investors
     * @param _KYC KYC provider used by the template
     * @param _details Details of the offering requirements
     * @param _expires Timestamp of when the template will expire
     * @param _fee Amount of POLY to use the template (held in escrow until issuance)
     * @param _quorum Minimum percent of shareholders which need to vote to freeze
     * @param _vestingPeriod Length of time to vest funds 
     */
    function createTemplate(
        string _offeringType,
        bytes32 _issuerJurisdiction,
        bool _accredited,
        address _KYC,
        bytes32 _details,
        uint256 _expires,
        uint256 _fee,
        uint8 _quorum,
        uint256 _vestingPeriod
    ) public;

   /**
     * @dev Propose a bid for a security token issuance
     * @param _securityToken The security token being bid on
     * @param _template The unique template address
     * @return bool success 
     */
    function proposeTemplate(
        address _securityToken,
        address _template
    ) public returns (bool success);

    /**
     * @dev Propose a Security Token Offering Contract for an issuance
     * @param _securityToken The security token being bid on
     * @param _stoContract The security token offering contract address
     * @return bool success 
     */
    function proposeOfferingContract(
        address _securityToken,
        address _stoContract
    ) public returns (bool success);

    /**
     * @dev Cancel a Template proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _templateProposalIndex The template proposal array index
     * @return bool success 
     */
    function cancelTemplateProposal(
        address _securityToken,
        uint256 _templateProposalIndex
    ) public returns (bool success);

    /**
     * @dev Set the STO contract by the issuer.
     * @param _STOAddress address of the STO contract deployed over the network.
     * @param _fee fee to be paid in poly to use that contract
     * @param _vestingPeriod no. of days investor binded to hold the Security token
     * @param _quorum Minimum percent of shareholders which need to vote to freeze
     */
    function setSTO (
        address _STOAddress,
        uint256 _fee,
        uint256 _vestingPeriod,
        uint8 _quorum
    ) public returns (bool success);

    /**
     * @dev Cancel a STO contract proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _offeringProposalIndex The offering proposal array index
     * @return bool success 
     */
    function cancelOfferingProposal(
        address _securityToken,
        uint256 _offeringProposalIndex
    ) public returns (bool success);

    /**
     * @dev `updateTemplateReputation` is a constant function that updates the
       history of a security token template usage to keep track of previous uses
     * @param _template The unique template id
     * @param _templateIndex The array index of the template proposal 
     */
    function updateTemplateReputation (address _template, uint8 _templateIndex) external returns (bool success);

    /**
     * @dev `updateOfferingReputation` is a constant function that updates the
       history of a security token offering contract to keep track of previous uses
     * @param _stoContract The smart contract address of the STO contract
     * @param _offeringProposalIndex The array index of the security token offering proposal 
     */
    function updateOfferingReputation (address _stoContract, uint8 _offeringProposalIndex) external returns (bool success);

    /**
     * @dev Get template details by the proposal index
     * @param _securityTokenAddress The security token ethereum address
     * @param _templateIndex The array index of the template being checked
     * @return Template struct 
     */
    function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex) view public returns (
        address _template
    );

    /** 
     * @dev Get security token offering smart contract details by the proposal index
     * @param _securityTokenAddress The security token ethereum address
     * @param _offeringProposalIndex The array index of the STO contract being checked
     * @return Contract struct 
     */
    function getOfferingByProposal(address _securityTokenAddress, uint8 _offeringProposalIndex) view public returns (
        address stoContract,
        address auditor,
        uint256 vestingPeriod,
        uint8 quorum,
        uint256 fee
    );
}

/// ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
interface IERC20 {
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

interface ICustomers {

  /**
   * @dev Allow new provider applications
   * @param _providerAddress The provider's public key address
   * @param _name The provider's name
   * @param _details A SHA256 hash of the new providers details
   * @param _fee The fee charged for customer verification
   */
  function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public returns (bool success);

  /**
   * @dev Change a providers fee
   * @param _newFee The new fee of the provider
   */
  function changeFee(uint256 _newFee) public returns (bool success);

  /**
   * @dev Verify an investor
   * @param _customer The customer's public key address
   * @param _countryJurisdiction The country urisdiction code of the customer
   * @param _divisionJurisdiction The subdivision jurisdiction code of the customer
   * @param _role The type of customer - investor:1, delegate:2, issuer:3, marketmaker:4, etc.
   * @param _accredited Whether the customer is accredited or not (only applied to investors)
   * @param _expires The time the verification expires
   */
  function verifyCustomer(
    address _customer,
    bytes32 _countryJurisdiction,
    bytes32 _divisionJurisdiction,
    uint8 _role,
    bool _accredited,
    uint256 _expires
  ) public returns (bool success);

   ///////////////////
    /// GET Functions
    //////////////////

  /**
    * @dev Get customer attestation data by KYC provider and customer ethereum address
    * @param _provider Address of the KYC provider.
    * @param _customer Address of the customer ethereum address
    */
  function getCustomer(address _provider, address _customer) public constant returns (
    bytes32,
    bytes32,
    bool,
    uint8,
    bool,
    uint256
  );

  /**
   * Get provider details and fee by ethereum address
   * @param _providerAddress Address of the KYC provider
   */
  function getProvider(address _providerAddress) public constant returns (
    string name,
    uint256 joined,
    bytes32 details,
    uint256 fee
  );
}

/*
  Polymath customer registry is used to ensure regulatory compliance
  of the investors, provider, and issuers. The customers registry is a central
  place where ethereum addresses can be whitelisted to purchase certain security
  tokens based on their verifications by providers.
*/




/**
 * @title Customers
 * @dev Contract use to register the user on the Platform platform
 */

contract Customers is ICustomers {

    string public VERSION = "1";

    IERC20 POLY;                                                        // Instance of the POLY token

    struct Customer {                                                   // Structure use to store the details of the customers
        bytes32 countryJurisdiction;                                    // Customers country jurisdiction as ex - ISO3166
        bytes32 divisionJurisdiction;                                   // Customers sub-division jurisdiction as ex - ISO3166
        uint256 joined;                                                 // Timestamp when customer register
        uint8 role;                                                     // role of the customer
        bool verified;                                                  // Boolean variable to check the status of the customer whether it is verified or not
        bool accredited;                                                // Accrediation status of the customer
        bytes32 proof;                                                  // Proof for customer
        uint256 expires;                                                // Timestamp when customer verification expires
    }

    mapping(address => mapping(address => Customer)) public customers;  // Customers (kyc provider address => customer address)

    struct Provider {                                                   // KYC/Accreditation Provider
        string name;                                                    // Name of the provider
        uint256 joined;                                                 // Timestamp when provider register
        bytes32 details;                                                // Details of provider
        uint256 fee;                                                    // Fee charged by the KYC providers
    }

    mapping(address => Provider) public providers;                      // KYC/Accreditation Providers

    // Notifications
    event LogNewProvider(address providerAddress, string name, bytes32 details);
    event LogCustomerVerified(address customer, address provider, uint8 role);

    // Modifier
    modifier onlyProvider() {
        require(providers[msg.sender].details != 0x0);
        _;
    }

    /**
     * @dev Constructor
     */
    function Customers(address _polyTokenAddress) public {
        POLY = IERC20(_polyTokenAddress);
    }

    /**
     * @dev Allow new provider applications
     * @param _providerAddress The provider's public key address
     * @param _name The provider's name
     * @param _details A SHA256 hash of the new providers details
     * @param _fee The fee charged for customer verification
     */
    function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public returns (bool success) {
        require(_providerAddress != address(0));
        require(_details != 0x0);
        require(providers[_providerAddress].details == 0x0);
        providers[_providerAddress] = Provider(_name, now, _details, _fee);
        LogNewProvider(_providerAddress, _name, _details);
        return true;
    }

    /**
     * @dev Change a providers fee
     * @param _newFee The new fee of the provider
     */
    function changeFee(uint256 _newFee) public returns (bool success) {
        require(providers[msg.sender].details != 0x0);
        providers[msg.sender].fee = _newFee;
        return true;
    }

    /**
     * @dev Verify an investor
     * @param _customer The customer's public key address
     * @param _countryJurisdiction The jurisdiction country code of the customer
     * @param _divisionJurisdiction The jurisdiction subdivision code of the customer
     * @param _role The type of customer - investor:1, delegate:2, issuer:3, marketmaker:4, etc.
     * @param _accredited Whether the customer is accredited or not (only applied to investors)
     * @param _expires The time the verification expires
     */
    function verifyCustomer(
        address _customer,
        bytes32 _countryJurisdiction,
        bytes32 _divisionJurisdiction,
        uint8 _role,
        bool _accredited,
        uint256 _expires
    ) public onlyProvider returns (bool success)
    {
        require(_expires > now);
        require(POLY.transferFrom(_customer, msg.sender, providers[msg.sender].fee));
        customers[msg.sender][_customer].countryJurisdiction = _countryJurisdiction;
        customers[msg.sender][_customer].divisionJurisdiction = _divisionJurisdiction;
        customers[msg.sender][_customer].role = _role;
        customers[msg.sender][_customer].accredited = _accredited;
        customers[msg.sender][_customer].expires = _expires;
        customers[msg.sender][_customer].verified = true;
        LogCustomerVerified(_customer, msg.sender, _role);
        return true;
    }

    ///////////////////
    /// GET Functions
    //////////////////

    /**
     * @dev Get customer attestation data by KYC provider and customer ethereum address
     * @param _provider Address of the KYC provider.
     * @param _customer Address of the customer ethereum address
     */
    function getCustomer(address _provider, address _customer) public constant returns (
        bytes32,
        bytes32,
        bool,
        uint8,
        bool,
        uint256
    ) {
      return (
        customers[_provider][_customer].countryJurisdiction,
        customers[_provider][_customer].divisionJurisdiction,
        customers[_provider][_customer].accredited,
        customers[_provider][_customer].role,
        customers[_provider][_customer].verified,
        customers[_provider][_customer].expires
      );
    }

    /**
     * Get provider details and fee by ethereum address
     * @param _providerAddress Address of the KYC provider
     */
    function getProvider(address _providerAddress) public constant returns (
        string name,
        uint256 joined,
        bytes32 details,
        uint256 fee
    ) {
      return (
        providers[_providerAddress].name,
        providers[_providerAddress].joined,
        providers[_providerAddress].details,
        providers[_providerAddress].fee
      );
    }

}

interface ITemplate {

  /**
   * @dev `addJurisdiction` allows the adding of new jurisdictions to a template
   * @param _allowedJurisdictions An array of jurisdictions
   * @param _allowed An array of whether the jurisdiction is allowed to purchase the security or not
   */
  function addJurisdiction(bytes32[] _allowedJurisdictions, bool[] _allowed) public;

  /**
   * @dev `addDivisionJurisdiction` allows the adding of new jurisdictions to a template
   * @param _blockedDivisionJurisdictions An array of jurisdictions
   * @param _blocked An array of whether the jurisdiction is allowed to purchase the security or not
   */
  function addDivisionJurisdiction(bytes32[] _blockedDivisionJurisdictions, bool[] _blocked) public;

  /**
   * @dev `addRole` allows the adding of new roles to be added to whitelist
   * @param _allowedRoles User roles that can purchase the security
   */
  function addRoles(uint8[] _allowedRoles) public;

  /**
   * @notice `updateDetails`
   * @param _details details of the template need to change
   * @return allowed boolean variable
   */
  function updateDetails(bytes32 _details) public returns (bool allowed);

  /**
   * @dev `finalizeTemplate` is used to finalize template.full compliance process/requirements
   * @return success
   */
  function finalizeTemplate() public returns (bool success);

  /**
   * @dev `checkTemplateRequirements` is a constant function that checks if templates requirements are met
   * @param _countryJurisdiction The ISO-3166 code of the investors country jurisdiction
   * @param _divisionJurisdiction The ISO-3166 code of the investors subdivision jurisdiction
   * @param _accredited Whether the investor is accredited or not
   * @param _role role of the user
   * @return allowed boolean variable
   */
  function checkTemplateRequirements(
      bytes32 _countryJurisdiction,
      bytes32 _divisionJurisdiction,
      bool _accredited,
      uint8 _role
  ) public constant returns (bool allowed);

  /**
   * @dev getTemplateDetails is a constant function that gets template details
   * @return bytes32 details, bool finalized
   */
  function getTemplateDetails() view public returns (bytes32, bool);

  /**
   * @dev `getUsageFees` is a function to get all the details on template usage fees
   * @return uint256 fee, uint8 quorum, uint256 vestingPeriod, address owner, address KYC
   */
  function getUsageDetails() view public returns (uint256, uint8, uint256, address, address);
}

/*
  Polymath compliance template is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  template allows security tokens to enforce purchase restrictions on chain and
  keep a log of documents for future auditing purposes.
*/



/**
 * @title Template
 * @dev  Template details used for the security token offering to ensure the regulatory compliance
 */

contract Template is ITemplate {

    string public VERSION = "1";

    address public owner;                                           // Address of the owner of template
    string public offeringType;                                     // Name of the security being issued
    bytes32 public issuerJurisdiction;                              // Variable contains the jurisdiction of the issuer of the template
    mapping(bytes32 => bool) public allowedJurisdictions;           // Mapping that contains the allowed staus of Jurisdictions
    mapping(bytes32 => bool) public blockedDivisionJurisdictions;   // Mapping that contains the allowed staus of Jurisdictions
    mapping(uint8 => bool) public allowedRoles;                     // Mapping that contains the allowed status of Roles
    bool public accredited;                                         // Variable that define the required level of accrediation for the investor
    address public KYC;                                             // Address of the KYC provider
    bytes32 details;                                                // Details of the offering requirements
    bool finalized;                                                 // Variable to know the status of the template (complete - true, not complete - false)
    uint256 public expires;                                         // Timestamp when template expires
    uint256 fee;                                                    // Amount of POLY to use the template (held in escrow until issuance)
    uint8 quorum;                                                   // Minimum percent of shareholders which need to vote to freeze
    uint256 vestingPeriod;                                          // Length of time to vest funds

    event DetailsUpdated(bytes32 _prevDetails, bytes32 _newDetails, uint _updateDate);

    function Template (
        address _owner,
        string _offeringType,
        bytes32 _issuerJurisdiction,
        bool _accredited,
        address _KYC,
        bytes32 _details,
        uint256 _expires,
        uint256 _fee,
        uint8 _quorum,
        uint256 _vestingPeriod
    ) public
    {
        require(_KYC != address(0) && _owner != address(0));
        require(_fee > 0);
        require(_details.length > 0 && _expires > now && _issuerJurisdiction.length > 0);
        require(_quorum > 0 && _quorum <= 100);
        require(_vestingPeriod > 0);
        owner = _owner;
        offeringType = _offeringType;
        issuerJurisdiction = _issuerJurisdiction;
        accredited = _accredited;
        KYC = _KYC;
        details = _details;
        finalized = false;
        expires = _expires;
        fee = _fee;
        quorum = _quorum;
        vestingPeriod = _vestingPeriod;
    }

    /**
     * @dev `addJurisdiction` allows the adding of new jurisdictions to a template
     * @param _allowedJurisdictions An array of jurisdictions
     * @param _allowed An array of whether the jurisdiction is allowed to purchase the security or not
     */
    function addJurisdiction(bytes32[] _allowedJurisdictions, bool[] _allowed) public {
        require(owner == msg.sender);
        require(_allowedJurisdictions.length == _allowed.length);
        require(!finalized);
        for (uint i = 0; i < _allowedJurisdictions.length; ++i) {
            allowedJurisdictions[_allowedJurisdictions[i]] = _allowed[i];
        }
    }

    /**
     * @dev `addJurisdiction` allows the adding of new jurisdictions to a template
     * @param _blockedDivisionJurisdictions An array of subdivision jurisdictions
     * @param _blocked An array of whether the subdivision jurisdiction is blocked to purchase the security or not
     */
    function addDivisionJurisdiction(bytes32[] _blockedDivisionJurisdictions, bool[] _blocked) public {
        require(owner == msg.sender);
        require(_blockedDivisionJurisdictions.length == _blocked.length);
        require(!finalized);
        for (uint i = 0; i < _blockedDivisionJurisdictions.length; ++i) {
            blockedDivisionJurisdictions[_blockedDivisionJurisdictions[i]] = _blocked[i];
        }
    }

    /**
     * @dev `addRole` allows the adding of new roles to be added to whitelist
     * @param _allowedRoles User roles that can purchase the security
     */
    function addRoles(uint8[] _allowedRoles) public {
        require(owner == msg.sender);
        require(!finalized);
        for (uint i = 0; i < _allowedRoles.length; ++i) {
            allowedRoles[_allowedRoles[i]] = true;
        }
    }

    /**
     * @notice `updateDetails`
     * @param _details details of the template need to change
     * @return allowed boolean variable
     */
    function updateDetails(bytes32 _details) public returns (bool allowed) {
        require(_details != 0x0);
        require(owner == msg.sender);
        bytes32 prevDetails = details;
        details = _details;
        DetailsUpdated(prevDetails, details, now);
        return true;
    }

    /**
     * @dev `finalizeTemplate` is used to finalize template.full compliance process/requirements
     * @return success
     */
    function finalizeTemplate() public returns (bool success) {
        require(owner == msg.sender);
        finalized = true;
        return true;
    }

    /**
     * @dev `checkTemplateRequirements` is a constant function that checks if templates requirements are met
     * @param _countryJurisdiction The ISO-3166 code of the investors country jurisdiction
     * @param _divisionJurisdiction The ISO-3166 code of the investors subdivision jurisdiction
     * @param _accredited Whether the investor is accredited or not
     * @param _role role of the user
     * @return allowed boolean variable
     */
    function checkTemplateRequirements(
        bytes32 _countryJurisdiction,
        bytes32 _divisionJurisdiction,
        bool _accredited,
        uint8 _role
    ) public constant returns (bool allowed)
    {
        require(_countryJurisdiction != 0x0);
        require(allowedJurisdictions[_countryJurisdiction] || !blockedDivisionJurisdictions[_divisionJurisdiction]);
        require(allowedRoles[_role]);
        if (accredited) {
            require(_accredited);
        }
        return true;
    }

    /**
     * @dev getTemplateDetails is a constant function that gets template details
     * @return bytes32 details, bool finalized
     */
    function getTemplateDetails() view public returns (bytes32, bool) {
        require(expires > now);
        return (details, finalized);
    }

    /**
     * @dev `getUsageFees` is a function to get all the details on template usage fees
     * @return uint256 fee, uint8 quorum, uint256 vestingPeriod, address owner, address KYC
     */
    function getUsageDetails() view public returns (uint256, uint8, uint256, address, address) {
        return (fee, quorum, vestingPeriod, owner, KYC);
    }
}

interface ISecurityToken {

    /**
     * @dev Set default security token parameters
     * @param _name Name of the security token
     * @param _ticker Ticker name of the security
     * @param _totalSupply Total amount of tokens being created
     * @param _decimals Decimals for token
     * @param _owner Ethereum address of the security token owner
     * @param _maxPoly Amount of maximum poly issuer want to raise
     * @param _lockupPeriod Length of time raised POLY will be locked up for dispute
     * @param _quorum Percent of initial investors required to freeze POLY raise
     * @param _polyTokenAddress Ethereum address of the POLY token contract
     * @param _polyCustomersAddress Ethereum address of the PolyCustomers contract
     * @param _polyComplianceAddress Ethereum address of the PolyCompliance contract
     */
    function SecurityToken(
        string _name,
        string _ticker,
        uint256 _totalSupply,
        uint8 _decimals,
        address _owner,
        uint256 _maxPoly,
        uint256 _lockupPeriod,
        uint8 _quorum,
        address _polyTokenAddress,
        address _polyCustomersAddress,
        address _polyComplianceAddress
    ) public;

   /**
     * @dev `selectTemplate` Select a proposed template for the issuance
     * @param _templateIndex Array index of the delegates proposed template
     * @return bool success
     */
    function selectTemplate(uint8 _templateIndex) public returns (bool success);

    /**
     * @dev Update compliance proof hash for the issuance
     * @param _newMerkleRoot New merkle root hash of the compliance Proofs
     * @param _complianceProof Compliance Proof hash
     * @return bool success
     */
    function updateComplianceProof(
        bytes32 _newMerkleRoot,
        bytes32 _complianceProof
    ) public returns (bool success);

    /**
     * @dev `selectOfferingProposal` Select an security token offering proposal for the issuance
     * @param _offeringProposalIndex Array index of the STO proposal
     * @return bool success
     */
    function selectOfferingProposal (
        uint8 _offeringProposalIndex
    ) public returns (bool success);

    /**
     * @dev Start the offering by sending all the tokens to STO contract
     * @return bool
     */
    function startOffering() external returns (bool success);

    /**
     * @dev Add a verified address to the Security Token whitelist
     * @param _whitelistAddress Address attempting to join ST whitelist
     * @return bool success
     */
    function addToWhitelist(uint8 KYCProviderIndex, address _whitelistAddress) public returns (bool success);

     /**
      * @dev Allow POLY allocations to be withdrawn by owner, delegate, and the STO auditor at appropriate times
      * @return bool success 
      */
    function withdrawPoly() public returns (bool success);

    /**
     * @dev Vote to freeze the fee of a certain network participant
     * @param _recipient The fee recipient being protested
     * @return bool success
     */
    function voteToFreeze(address _recipient) public returns (bool success);

    /**
     * @dev `issueSecurityTokens` is used by the STO to keep track of STO investors
     * @param _contributor The address of the person whose contributing
     * @param _amountOfSecurityTokens The amount of ST to pay out.
     * @param _polyContributed The amount of POLY paid for the security tokens.
     */
    function issueSecurityTokens(address _contributor, uint256 _amountOfSecurityTokens, uint256 _polyContributed) public returns (bool success);

    /// Get token details
    function getTokenDetails() view public returns (address, address, bytes32, address, address);

    /**
     * @dev Trasfer tokens from one address to another
     * @param _to Ethereum public address to transfer tokens to
     * @param _value Amount of tokens to send
     * @return bool success
     */
    function transfer(address _to, uint256 _value) public returns (bool success);

    /**
     * @dev Allows contracts to transfer tokens on behalf of token holders
     * @param _from Address to transfer tokens from
     * @param _to Address to send tokens to
     * @param _value Number of tokens to transfer
     * @return bool success
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /**
     * @dev `balanceOf` used to get the balance of shareholders
     * @param _owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _owner) public constant returns (uint256 balance);

    /**
     * @dev Approve transfer of tokens manually
     * @param _spender Address to approve transfer to
     * @param _value Amount of tokens to approve for transfer
     * @return bool success
     */
    function approve(address _spender, uint256 _value) public returns (bool success);

    /**
     * @dev Use to get the allowance provided to the spender
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
  }

interface ISTRegistrar {

   /**
    * @dev Creates a new Security Token and saves it to the registry
    * @param _name Name of the security token
    * @param _ticker Ticker name of the security
    * @param _totalSupply Total amount of tokens being created
    * @param _owner Ethereum public key address of the security token owner
    * @param _maxPoly Amount of maximum poly issuer want to raise
    * @param _host The host of the security token wizard
    * @param _fee Fee being requested by the wizard host
    * @param _type Type of security being tokenized
    * @param _lockupPeriod Length of time raised POLY will be locked up for dispute
    * @param _quorum Percent of initial investors required to freeze POLY raise
    */
    function createSecurityToken (
        string _name,
        string _ticker,
        uint256 _totalSupply,
        uint8 _decimals,
        address _owner,
        uint256 _maxPoly,
        address _host,
        uint256 _fee,
        uint8 _type,
        uint256 _lockupPeriod,
        uint8 _quorum
    ) external;

}

/**
 *  SafeMath <https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol/>
 *  Copyright (c) 2016 Smart Contract Solutions, Inc.
 *  Released under the MIT License (MIT)
 */

/// @title Math operations with safety checks
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract STO20 {

    uint256 public startTime;
    uint256 public endTime;

    /** 
     * @dev Initializes the STO with certain params
     * @dev _tokenAddress Address of the security token
     * @param _startTime Given in UNIX time this is the time that the offering will begin
     * @param _endTime Given in UNIX time this is the time that the offering will end 
     */
    function securityTokenOffering(
        address _tokenAddress,
        uint256 _startTime,
        uint256 _endTime
    ) external ;

}

/**
 * @title SecurityToken
 * @dev Contract (A Blueprint) that contains the functionalities of the security token
 */

contract SecurityToken is IERC20 {

    using SafeMath for uint256;

    string public VERSION = "1";

    IERC20 public POLY;                                               // Instance of the POLY token contract

    ICompliance public PolyCompliance;                                // Instance of the Compliance contract

    ITemplate public Template;                                        // Instance of the Template contract

    ICustomers public PolyCustomers;                                  // Instance of the Customers contract

    STO20 public STO;

    // ERC20 Fields
    string public name;                                               // Name of the security token
    uint8 public decimals;                                            // Decimals for the security token it should be 0 as standard
    string public symbol;                                             // Symbol of the security token
    address public owner;                                             // Address of the owner of the security token
    uint256 public totalSupply;                                       // Total number of security token generated
    mapping(address => mapping(address => uint256)) allowed;          // Mapping as same as in ERC20 token
    mapping(address => uint256) balances;                             // Array used to store the balances of the security token holders

    // Template
    address public delegate;                                          // Address who create the template
    bytes32 public merkleRoot;                                        //
    address public KYC;                                               // Address of the KYC provider which aloowed the roles and jurisdictions in the template

    // Security token shareholders
    struct Shareholder {                                              // Structure that contains the data of the shareholders
        address verifier;                                             // verifier - address of the KYC oracle
        bool allowed;                                                 // allowed - whether the shareholder is allowed to transfer or recieve the security token
        uint8 role;                                                   // role - role of the shareholder {1,2,3,4}
    }

    mapping(address => Shareholder) public shareholders;              // Mapping that holds the data of the shareholder corresponding to investor address

    // STO
    bool public isSTOProposed = false;
    bool public hasOfferingStarted = false;
    uint256 public maxPoly;

    // The start and end time of the STO
    uint256 public startSTO;                                          // Timestamp when Security Token Offering will be start
    uint256 public endSTO;                                            // Timestamp when Security Token Offering contract will ends

    // POLY allocations
    struct Allocation {                                               // Structure that contains the allocation of the POLY for stakeholders
        uint256 amount;                                               // stakeholders - delegate, issuer(owner), auditor
        uint256 vestingPeriod;
        uint8 quorum;
        uint256 yayVotes;
        uint256 yayPercent;
        bool frozen;
    }
    mapping(address => mapping(address => bool)) public voted;               // Voting mapping
    mapping(address => Allocation) public allocations;                       // Mapping that contains the data of allocation corresponding to stakeholder address

	   // Security Token Offering statistics
    mapping(address => uint256) public contributedToSTO;                     // Mapping for tracking the POLY contribution by the contributor
    uint256 public tokensIssuedBySTO = 0;                             // Flag variable to track the security token issued by the offering contract

    // Notifications
    event LogTemplateSet(address indexed _delegateAddress, address _template, address indexed _KYC);
    event LogUpdatedComplianceProof(bytes32 _merkleRoot, bytes32 _complianceProofHash);
    event LogSetSTOContract(address _STO, address indexed _STOtemplate, address indexed _auditor, uint256 _startTime, uint256 _endTime);
    event LogNewWhitelistedAddress(address _KYC, address _shareholder, uint8 _role);
    event LogNewBlacklistedAddress(address _KYC, address _shareholder);
    event LogVoteToFreeze(address _recipient, uint256 _yayPercent, uint8 _quorum, bool _frozen);
    event LogTokenIssued(address indexed _contributor, uint256 _stAmount, uint256 _polyContributed, uint256 _timestamp);

    //Modifiers
    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }

    modifier onlyDelegate() {
        require (msg.sender == delegate);
        _;
    }

    modifier onlyOwnerOrDelegate() {
        require (msg.sender == delegate || msg.sender == owner);
        _;
    }

    modifier onlySTO() {
        require (msg.sender == address(STO));
        _;
    }

    modifier onlyShareholder() {
        require (shareholders[msg.sender].allowed);
        _;
    }

    /**
     * @dev Set default security token parameters
     * @param _name Name of the security token
     * @param _ticker Ticker name of the security
     * @param _totalSupply Total amount of tokens being created
     * @param _owner Ethereum address of the security token owner
     * @param _maxPoly Amount of maximum poly issuer want to raise
     * @param _lockupPeriod Length of time raised POLY will be locked up for dispute
     * @param _quorum Percent of initial investors required to freeze POLY raise
     * @param _polyTokenAddress Ethereum address of the POLY token contract
     * @param _polyCustomersAddress Ethereum address of the PolyCustomers contract
     * @param _polyComplianceAddress Ethereum address of the PolyCompliance contract
     */
    function SecurityToken(
        string _name,
        string _ticker,
        uint256 _totalSupply,
        uint8 _decimals,
        address _owner,
        uint256 _maxPoly,
        uint256 _lockupPeriod,
        uint8 _quorum,
        address _polyTokenAddress,
        address _polyCustomersAddress,
        address _polyComplianceAddress
    ) public
    {
        decimals = _decimals;
        name = _name;
        symbol = _ticker;
        owner = _owner;
        maxPoly = _maxPoly;
        totalSupply = _totalSupply;
        balances[_owner] = _totalSupply;
        POLY = IERC20(_polyTokenAddress);
        PolyCustomers = ICustomers(_polyCustomersAddress);
        PolyCompliance = ICompliance(_polyComplianceAddress);
        allocations[owner] = Allocation(0, _lockupPeriod, _quorum, 0, 0, false);
        Transfer(0x0, _owner, _totalSupply);
    }

    /* function initialiseBalances(uint256) */

    /**
     * @dev `selectTemplate` Select a proposed template for the issuance
     * @param _templateIndex Array index of the delegates proposed template
     * @return bool success
     */
    function selectTemplate(uint8 _templateIndex) public onlyOwner returns (bool success) {
        require(!isSTOProposed);
        address _template = PolyCompliance.getTemplateByProposal(this, _templateIndex);
        require(_template != address(0));
        Template = ITemplate(_template);
        var (_fee, _quorum, _vestingPeriod, _delegate, _KYC) = Template.getUsageDetails();
        require(POLY.balanceOf(this) >= _fee);
        allocations[_delegate] = Allocation(_fee, _vestingPeriod, _quorum, 0, 0, false);
        delegate = _delegate;
        KYC = _KYC;
        PolyCompliance.updateTemplateReputation(_template, _templateIndex);
        LogTemplateSet(_delegate, _template, _KYC);
        return true;
    }

    /**
     * @dev Update compliance proof hash for the issuance
     * @param _newMerkleRoot New merkle root hash of the compliance Proofs
     * @param _merkleRoot Compliance Proof hash
     * @return bool success
     */
    function updateComplianceProof(
        bytes32 _newMerkleRoot,
        bytes32 _merkleRoot
    ) public onlyOwnerOrDelegate returns (bool success)
    {
        merkleRoot = _newMerkleRoot;
        LogUpdatedComplianceProof(merkleRoot, _merkleRoot);
        return true;
    }

    /**
     * @dev `selectOfferingProposal` Select an security token offering proposal for the issuance
     * @param _offeringProposalIndex Array index of the STO proposal
     * @return bool success
     */
    function selectOfferingProposal (uint8 _offeringProposalIndex) public onlyDelegate returns (bool success) {
        require(!isSTOProposed);
        var (_stoContract, _auditor, _vestingPeriod, _quorum, _fee) = PolyCompliance.getOfferingByProposal(this, _offeringProposalIndex);
        require(_stoContract != address(0));
        require(merkleRoot != 0x0);
        require(delegate != address(0));
        require(POLY.balanceOf(this) >= allocations[delegate].amount.add(_fee));
        STO = STO20(_stoContract);
        require(STO.startTime() > now && STO.endTime() > STO.startTime());
        allocations[_auditor] = Allocation(_fee, _vestingPeriod, _quorum, 0, 0, false);
        shareholders[address(STO)] = Shareholder(this, true, 5);
        startSTO = STO.startTime();
        endSTO = STO.endTime();
        isSTOProposed = !isSTOProposed;
        PolyCompliance.updateOfferingReputation(_stoContract, _offeringProposalIndex);
        LogSetSTOContract(STO, _stoContract, _auditor, startSTO, endSTO);
        return true;
    }

    /**
     * @dev Start the offering by sending all the tokens to STO contract
     * @return bool
     */
    function startOffering() onlyOwner external returns (bool success) {
        require(isSTOProposed);
        require(!hasOfferingStarted);
        uint256 tokenAmount = this.balanceOf(msg.sender);
        require(tokenAmount == totalSupply);
        balances[STO] = balances[STO].add(tokenAmount);
        balances[msg.sender] = balances[msg.sender].sub(tokenAmount);
        hasOfferingStarted = true;
        Transfer(owner, STO, tokenAmount);
        return true;
    }

    /**
     * @dev Add a verified address to the Security Token whitelist
     * The Issuer can add an address to the whitelist by themselves by
     * creating their own KYC provider and using it to verify the accounts
     * they want to add to the whitelist.
     * @param _whitelistAddress Address attempting to join ST whitelist
     * @return bool success
     */
    function addToWhitelist(address _whitelistAddress) onlyOwner public returns (bool success) {
        var (countryJurisdiction, divisionJurisdiction, accredited, role, verified, expires) = PolyCustomers.getCustomer(KYC, _whitelistAddress);
        require(verified && expires > now);
        require(Template.checkTemplateRequirements(countryJurisdiction, divisionJurisdiction, accredited, role));
        shareholders[_whitelistAddress] = Shareholder(msg.sender, true, role);
        LogNewWhitelistedAddress(msg.sender, _whitelistAddress, role);
        return true;
    }

    /**
     * @dev Add a verified address to the Security Token blacklist
     * @param _blacklistAddress Address being added to the blacklist
     * @return bool success
     */
    function addToBlacklist(address _blacklistAddress) onlyOwner public returns (bool success) {
        require(shareholders[_blacklistAddress].allowed);
        shareholders[_blacklistAddress].allowed = false;
        LogNewBlacklistedAddress(msg.sender, _blacklistAddress);
        return true;
    }

    /**
     * @dev Allow POLY allocations to be withdrawn by owner, delegate, and the STO auditor at appropriate times
     * @return bool success
     */
    function withdrawPoly() public returns (bool success) {
  	    if (delegate == address(0)) {
          return POLY.transfer(owner, POLY.balanceOf(this));
        }
        require(now > endSTO + allocations[msg.sender].vestingPeriod);
        require(!allocations[msg.sender].frozen);
        require(allocations[msg.sender].amount > 0);
        require(POLY.transfer(msg.sender, allocations[msg.sender].amount));
        allocations[msg.sender].amount = 0;
        return true;
    }

    /**
     * @dev Vote to freeze the fee of a certain network participant
     * @param _recipient The fee recipient being protested
     * @return bool success
     */
    function voteToFreeze(address _recipient) public onlyShareholder returns (bool success) {
        require(delegate != address(0));
        require(now > endSTO);
        require(now < endSTO.add(allocations[_recipient].vestingPeriod));
        require(!voted[msg.sender][_recipient]);
        voted[msg.sender][_recipient] = true;
        allocations[_recipient].yayVotes = allocations[_recipient].yayVotes.add(contributedToSTO[msg.sender]);
        allocations[_recipient].yayPercent = allocations[_recipient].yayVotes.mul(100).div(allocations[owner].amount);
        if (allocations[_recipient].yayPercent >= allocations[_recipient].quorum) {
          allocations[_recipient].frozen = true;
        }
        LogVoteToFreeze(_recipient, allocations[_recipient].yayPercent, allocations[_recipient].quorum, allocations[_recipient].frozen);
        return true;
    }

	/**
     * @dev `issueSecurityTokens` is used by the STO to keep track of STO investors
     * @param _contributor The address of the person whose contributing
     * @param _amountOfSecurityTokens The amount of ST to pay out.
     * @param _polyContributed The amount of POLY paid for the security tokens.
     */
    function issueSecurityTokens(address _contributor, uint256 _amountOfSecurityTokens, uint256 _polyContributed) public onlySTO returns (bool success) {
        // Check whether the offering active or not
        require(hasOfferingStarted);
        // The _contributor being issued tokens must be in the whitelist
        require(shareholders[_contributor].allowed);
        // Tokens may only be issued while the STO is running
        require(now >= startSTO && now <= endSTO);
        // In order to issue the ST, the _contributor first pays in POLY
        require(POLY.transferFrom(_contributor, this, _polyContributed));
        // ST being issued can't be higher than the totalSupply
        require(tokensIssuedBySTO.add(_amountOfSecurityTokens) <= totalSupply);
        // POLY contributed can't be higher than maxPoly set by STO
        require(maxPoly >= allocations[owner].amount.add(_polyContributed));
        // Update ST balances (transfers ST from STO to _contributor)
        balances[STO] = balances[STO].sub(_amountOfSecurityTokens);
        balances[_contributor] = balances[_contributor].add(_amountOfSecurityTokens);
        // ERC20 Transfer event
        Transfer(STO, _contributor, _amountOfSecurityTokens);
        // Update the amount of tokens issued by STO
        tokensIssuedBySTO = tokensIssuedBySTO.add(_amountOfSecurityTokens);
        // Update the amount of POLY a contributor has contributed and allocated to the owner
        contributedToSTO[_contributor] = contributedToSTO[_contributor].add(_polyContributed);
        allocations[owner].amount = allocations[owner].amount.add(_polyContributed);
        LogTokenIssued(_contributor, _amountOfSecurityTokens, _polyContributed, now);
        return true;
    }

    // Get token details
    function getTokenDetails() view public returns (address, address, bytes32, address, address) {
        return (Template, delegate, merkleRoot, STO, KYC);
    }

/////////////////////////////////////////////// Customized ERC20 Functions ////////////////////////////////////////////////////////////

    /**
     * @dev Trasfer tokens from one address to another
     * @param _to Ethereum public address to transfer tokens to
     * @param _value Amount of tokens to send
     * @return bool success
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (shareholders[_to].allowed && shareholders[msg.sender].allowed && balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Allows contracts to transfer tokens on behalf of token holders
     * @param _from Address to transfer tokens from
     * @param _to Address to send tokens to
     * @param _value Number of tokens to transfer
     * @return bool success
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (shareholders[_to].allowed && shareholders[_from].allowed && balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            uint256 _allowance = allowed[_from][msg.sender];
            balances[_from] = balances[_from].sub(_value);
            allowed[_from][msg.sender] = _allowance.sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev `balanceOf` used to get the balance of shareholders
     * @param _owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    /**
     * @dev Approve transfer of tokens manually
     * @param _spender Address to approve transfer to
     * @param _value Amount of tokens to approve for transfer
     * @return bool success
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_value != 0);
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Use to get the allowance provided to the spender
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

/*
  The Polymath Security Token Registrar provides a way to lookup security token details
  from a single place and allows wizard creators to earn POLY fees by uploading to the
  registrar.
*/






/**
 * @title SecurityTokenRegistrar
 * @dev Contract use to register the security token on Polymath platform
 */

contract SecurityTokenRegistrar is ISTRegistrar {

    string public VERSION = "1";
    SecurityToken securityToken;
    address public polyTokenAddress;                                // Address of POLY token
    address public polyCustomersAddress;                            // Address of the polymath-core Customers contract address
    address public polyComplianceAddress;                           // Address of the polymath-core Compliance contract address

    // Security Token
    struct SecurityTokenData {                                      // A structure that contains the specific info of each ST
      uint256 totalSupply;                                          // created ever using the Polymath platform
      address owner;
      uint8 decimals;
      string ticker;
      uint8 securityType;
    }
    mapping(address => SecurityTokenData) securityTokens;           // Array contains the details of security token corresponds to security token address
    mapping(string => address) tickers;                             // Mapping of ticker name to Security Token

    event LogNewSecurityToken(string ticker, address securityTokenAddress, address owner, address host, uint256 fee, uint8 _type);
    /**
     * @dev Constructor use to set the essentials addresses to facilitate
     * the creation of the security token
     */
    function SecurityTokenRegistrar(
      address _polyTokenAddress,
      address _polyCustomersAddress,
      address _polyComplianceAddress
    ) public
    {
      polyTokenAddress = _polyTokenAddress;
      polyCustomersAddress = _polyCustomersAddress;
      polyComplianceAddress = _polyComplianceAddress;
      // Creating the instance of the compliance contract and assign the STR contract 
      // address (this) into the compliance contract
      Compliance PolyCompliance = Compliance(polyComplianceAddress);
      require(PolyCompliance.setRegsitrarAddress(this));
    }

    /**
     * @dev Creates a new Security Token and saves it to the registry
     * @param _name Name of the security token
     * @param _ticker Ticker name of the security
     * @param _totalSupply Total amount of tokens being created
     * @param _decimals Decimals value for token
     * @param _owner Ethereum public key address of the security token owner
     * @param _maxPoly Amount of maximum poly issuer want to raise
     * @param _host The host of the security token wizard
     * @param _fee Fee being requested by the wizard host
     * @param _type Type of security being tokenized
     * @param _lockupPeriod Length of time raised POLY will be locked up for dispute
     * @param _quorum Percent of initial investors required to freeze POLY raise
     */
    function createSecurityToken (
      string _name,
      string _ticker,
      uint256 _totalSupply,
      uint8 _decimals,
      address _owner,
      uint256 _maxPoly,
      address _host,
      uint256 _fee,
      uint8 _type,
      uint256 _lockupPeriod,
      uint8 _quorum
    ) external
    {
      require(_totalSupply > 0 && _maxPoly > 0 && _fee > 0);
      require(tickers[_ticker] == 0x0);
      require(_lockupPeriod >= now);
      require(_owner != address(0) && _host != address(0));
      require(bytes(_name).length > 0 && bytes(_ticker).length > 0);
      IERC20 POLY = IERC20(polyTokenAddress);
      POLY.transferFrom(msg.sender, _host, _fee);
      address newSecurityTokenAddress = initialiseSecurityToken(_name, _ticker, _totalSupply, _decimals, _owner, _maxPoly, _type, _lockupPeriod, _quorum);
      LogNewSecurityToken(_ticker, newSecurityTokenAddress, _owner, _host, _fee, _type);
    }

    function initialiseSecurityToken(
      string _name,
      string _ticker,
      uint256 _totalSupply,
      uint8 _decimals,
      address _owner,
      uint256 _maxPoly,
      uint8 _type,
      uint256 _lockupPeriod,
      uint8 _quorum
    ) internal returns (address)
    {
      address newSecurityTokenAddress = new SecurityToken(
        _name,
        _ticker,
        _totalSupply,
        _decimals,
        _owner,
        _maxPoly,
        _lockupPeriod,
        _quorum,
        polyTokenAddress,
        polyCustomersAddress,
        polyComplianceAddress
      );
      tickers[_ticker] = newSecurityTokenAddress;
      securityTokens[newSecurityTokenAddress] = SecurityTokenData(
        _totalSupply,
        _owner,
        _decimals,
        _ticker,
        _type
      );
      return newSecurityTokenAddress;
    }

    //////////////////////////////
    ///////// Get Functions
    //////////////////////////////
    /**
     * @dev Get security token address by ticker name
     * @param _ticker Symbol of the Scurity token
     * @return address _ticker
     */
    function getSecurityTokenAddress(string _ticker) public constant returns (address) {
      return tickers[_ticker];
    }

    /**
     * @dev Get Security token details by its ethereum address
     * @param _STAddress Security token address
     */
    function getSecurityTokenData(address _STAddress) public constant returns (
      uint256 totalSupply,
      address owner,
      uint8 decimals,
      string ticker,
      uint8 securityType
    ) {
      return (
        securityTokens[_STAddress].totalSupply,
        securityTokens[_STAddress].owner,
        securityTokens[_STAddress].decimals,
        securityTokens[_STAddress].ticker,
        securityTokens[_STAddress].securityType
      );
    }

}

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/







/**
 * @title Compilance
 * @dev Regulatory details offered by the security token
 */

contract Compliance is ICompliance {

    string public VERSION = "1";

    ITemplate template;

    SecurityTokenRegistrar public STRegistrar;

    struct TemplateReputation {                                         // Structure contains the compliance template details
        address owner;                                                  // Address of the template owner
        uint256 totalRaised;                                            // Total amount raised by the issuers that used the template
        uint256 timesUsed;                                              // How many times template will be used as the compliance regulator for different security token
        uint256 expires;                                                // Timestamp when template get expire
        address[] usedBy;                                               // Array of security token addresses that used the particular template
    }
    mapping(address => TemplateReputation) public templates;                   // Mapping used for storing the template past records corresponds to template address
    mapping(address => address[]) public templateProposals;             // Template proposals for a specific security token

    struct Offering {                                                   // Smart contract proposals for a specific security token offering
        address auditor;
        uint256 fee;
        uint256 vestingPeriod;
        uint8 quorum;
        address[] usedBy;
    }
    mapping(address => Offering) offerings;                             // Mapping used for storing the Offering detials corresponds to offering contract address
    mapping(address => address[]) public offeringProposals;             // Security token contract proposals for a specific security token

    Customers public PolyCustomers;                                      // Instance of the Compliance contract
    uint256 public constant MINIMUM_VESTING_PERIOD = 60 * 60 * 24 * 100; // 100 Day minimum vesting period for POLY earned

    // Notifications
    event LogTemplateCreated(address indexed _creator, address _template, string _offeringType);
    event LogNewTemplateProposal(address indexed _securityToken, address _template, address _delegate, uint _templateProposalIndex);
    event LogCancelTemplateProposal(address indexed _securityToken, address _template, uint _templateProposalIndex);
    event LogNewContractProposal(address indexed _securityToken, address _offeringContract, address _delegate, uint _offeringProposalIndex);
    event LogCancelContractProposal(address indexed _securityToken, address _offeringContract, uint _offeringProposalIndex);

    /* @param _polyCustomersAddress The address of the Polymath Customers contract */
    function Compliance(address _polyCustomersAddress) public {
        PolyCustomers = Customers(_polyCustomersAddress);
    }

    /**
     * @dev `setRegsitrarAddress` This function set the SecurityTokenRegistrar contract address.
     * @param _STRegistrar It is the `this` reference of STR contract
     * @return bool
     */

    function setRegsitrarAddress(address _STRegistrar) public returns (bool) {
        require(STRegistrar == address(0));
        STRegistrar = SecurityTokenRegistrar(_STRegistrar);
        return true;
    }

    /**
     * @dev `createTemplate` is a simple function to create a new compliance template
     * @param _offeringType The name of the security being issued
     * @param _issuerJurisdiction The jurisdiction id of the issuer
     * @param _accredited Accreditation status required for investors
     * @param _KYC KYC provider used by the template
     * @param _details Details of the offering requirements
     * @param _expires Timestamp of when the template will expire
     * @param _fee Amount of POLY to use the template (held in escrow until issuance)
     * @param _quorum Minimum percent of shareholders which need to vote to freeze
     * @param _vestingPeriod Length of time to vest funds
     */
    function createTemplate(
        string _offeringType,
        bytes32 _issuerJurisdiction,
        bool _accredited,
        address _KYC,
        bytes32 _details,
        uint256 _expires,
        uint256 _fee,
        uint8 _quorum,
        uint256 _vestingPeriod
    ) public
    {
      require(_KYC != address(0));
      require(_vestingPeriod >= MINIMUM_VESTING_PERIOD);
      address _template = new Template(
          msg.sender,
          _offeringType,
          _issuerJurisdiction,
          _accredited,
          _KYC,
          _details,
          _expires,
          _fee,
          _quorum,
          _vestingPeriod
      );
      templates[_template] = TemplateReputation({
          owner: msg.sender,
          totalRaised: 0,
          timesUsed: 0,
          expires: _expires,
          usedBy: new address[](0)
      });
      LogTemplateCreated(msg.sender, _template, _offeringType);
    }

    /**
     * @dev Propose a bid for a security token issuance
     * @param _securityToken The security token being bid on
     * @param _template The unique template address
     * @return bool success
     */
    function proposeTemplate(
        address _securityToken,
        address _template
    ) public returns (bool success)
    {
        // Verifying that provided _securityToken is generated by securityTokenRegistrar only
        var (totalSupply, owner,,) = STRegistrar.getSecurityTokenData(_securityToken);
        require(totalSupply > 0 && owner != address(0));
        // Require that template has not expired, that the caller is the
        // owner of the template and that the template has been finalized
        require(templates[_template].expires > now);
        require(templates[_template].owner == msg.sender);
        // Creating the instance of template to avail the function calling
        template = Template(_template);
        var (,finalized) = template.getTemplateDetails();
        require(finalized);

        //Get a reference of the template contract and add it to the templateProposals array
        templateProposals[_securityToken].push(_template);
        LogNewTemplateProposal(_securityToken, _template, msg.sender,templateProposals[_securityToken].length -1);
        return true;
    }

    /**
     * @dev Cancel a Template proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _templateProposalIndex The template proposal array index
     * @return bool success
     */
    function cancelTemplateProposal(
        address _securityToken,
        uint256 _templateProposalIndex
    ) public returns (bool success)
    {
        address proposedTemplate = templateProposals[_securityToken][_templateProposalIndex];
        require(templates[proposedTemplate].owner == msg.sender);
        var (chosenTemplate,,,,) = ISecurityToken(_securityToken).getTokenDetails();
        require(chosenTemplate != proposedTemplate);
        templateProposals[_securityToken][_templateProposalIndex] = address(0);
        LogCancelTemplateProposal(_securityToken, proposedTemplate, _templateProposalIndex);

        return true;
    }

    /**
     * @dev Set the STO contract by the issuer.
     * @param _STOAddress address of the STO contract deployed over the network.
     * @param _fee fee to be paid in poly to use that contract
     * @param _vestingPeriod no. of days investor binded to hold the Security token
     * @param _quorum Minimum percent of shareholders which need to vote to freeze
     */
    function setSTO (
        address _STOAddress,
        uint256 _fee,
        uint256 _vestingPeriod,
        uint8 _quorum
        ) public returns (bool success)
    {
            require(offerings[_STOAddress].auditor == address(0));
            require(_STOAddress != address(0));
            require(_quorum > 0 && _quorum <= 100);
            require(_vestingPeriod >= MINIMUM_VESTING_PERIOD);
            require(_fee > 0);
            offerings[_STOAddress].auditor = msg.sender;
            offerings[_STOAddress].fee = _fee;
            offerings[_STOAddress].vestingPeriod = _vestingPeriod;
            offerings[_STOAddress].quorum = _quorum;
            return true;
    }

    /**
     * @dev Propose a Security Token Offering Contract for an issuance
     * @param _securityToken The security token being bid on
     * @param _stoContract The security token offering contract address
     * @return bool success
     */
    function proposeOfferingContract(
        address _securityToken,
        address _stoContract
    ) public returns (bool success)
    {
        // Verifying that provided _securityToken is generated by securityTokenRegistrar only
        var (totalSupply, owner,,) = STRegistrar.getSecurityTokenData(_securityToken);
        require(totalSupply > 0 && owner != address(0));

        var (,,,,KYC) = ISecurityToken(_securityToken).getTokenDetails();
        var (,,, verified, expires) = PolyCustomers.getCustomer(KYC, offerings[_stoContract].auditor);
        require(offerings[_stoContract].auditor == msg.sender);
        require(verified);
        require(expires > now);
        offeringProposals[_securityToken].push(_stoContract);
        LogNewContractProposal(_securityToken, _stoContract, msg.sender,offeringProposals[_securityToken].length -1);
        return true;
    }

    /**
     * @dev Cancel a STO contract proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _offeringProposalIndex The offering proposal array index
     * @return bool success
     */
    function cancelOfferingProposal(
        address _securityToken,
        uint256 _offeringProposalIndex
    ) public returns (bool success)
    {
        address proposedOffering = offeringProposals[_securityToken][_offeringProposalIndex];
        require(offerings[proposedOffering].auditor == msg.sender);
        var (,,,,chosenOffering) = ISecurityToken(_securityToken).getTokenDetails();
        require(chosenOffering != proposedOffering);
        offeringProposals[_securityToken][_offeringProposalIndex] = address(0);
        LogCancelContractProposal(_securityToken, proposedOffering, _offeringProposalIndex);

        return true;
    }

    /**
     * @dev `updateTemplateReputation` is a constant function that updates the
       history of a security token template usage to keep track of previous uses
     * @param _template The unique template id
     * @param _templateIndex The array index of the template proposal
     */
    function updateTemplateReputation (address _template, uint8 _templateIndex) external returns (bool success) {
        require(templateProposals[msg.sender][_templateIndex] == _template);
        templates[_template].usedBy.push(msg.sender);
        return true;
    }

    /**
     * @dev `updateOfferingReputation` is a constant function that updates the
       history of a security token offering contract to keep track of previous uses
     * @param _stoContract The smart contract address of the STO contract
     * @param _offeringProposalIndex The array index of the security token offering proposal
     */
    function updateOfferingReputation (address _stoContract, uint8 _offeringProposalIndex) external returns (bool success) {
        require(offeringProposals[msg.sender][_offeringProposalIndex] == _stoContract);
        offerings[_stoContract].usedBy.push(msg.sender);
        return true;
    }

    /**
     * @dev Get template details by the proposal index
     * @param _securityTokenAddress The security token ethereum address
     * @param _templateIndex The array index of the template being checked
     * @return Template struct
     */
    function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex) view public returns (
        address _template
    ){
        return templateProposals[_securityTokenAddress][_templateIndex];
    }

    /**
     * @dev Get an array containing the address of all template proposals for a given ST
     * @param _securityTokenAddress The security token ethereum address
     * @return Template proposals array
     */
    function getAllTemplateProposals(address _securityTokenAddress) view public returns (address[]){
        return templateProposals[_securityTokenAddress];
    }

    /**
     * @dev Get security token offering smart contract details by the proposal index
     * @param _securityTokenAddress The security token ethereum address
     * @param _offeringProposalIndex The array index of the STO contract being checked
     * @return Contract struct
     */
    function getOfferingByProposal(address _securityTokenAddress, uint8 _offeringProposalIndex) view public returns (
        address stoContract,
        address auditor,
        uint256 vestingPeriod,
        uint8 quorum,
        uint256 fee
    ){
        address _stoContract = offeringProposals[_securityTokenAddress][_offeringProposalIndex];
        return (
            _stoContract,
            offerings[_stoContract].auditor,
            offerings[_stoContract].vestingPeriod,
            offerings[_stoContract].quorum,
            offerings[_stoContract].fee
        );
    }

    /**
     * @dev Get an array containing the address of all offering proposals for a given ST
     * @param _securityTokenAddress The security token ethereum address
     * @return Offering proposals array
     */
    function getAllOfferingProposals(address _securityTokenAddress) view public returns (address[]){
        return offeringProposals[_securityTokenAddress];
    }

}