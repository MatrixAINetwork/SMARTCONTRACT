/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.16;

contract Ownable 
{
	address m_addrOwner;

	function Ownable() public	
	{ 
		m_addrOwner = msg.sender;
	}

	modifier onlyOwner() 
	{
		if (msg.sender != m_addrOwner) 
		{
			revert();
		}
    	_;
	}

	// ---

	function transferOwnership(address newOwner) public onlyOwner 
	{
		m_addrOwner = newOwner;
	}

	// ---

	function isOwner() public constant returns (bool bIsOwner) { return (m_addrOwner == msg.sender); }

}

// ------

contract IcoMultiWallet is Ownable
{
	struct Account
	{
		uint nTotalAmount;
		uint nFirstDepositDate;
		uint nDailyPrice;
	}
	
	mapping (address => Account) m_mapAccounts;
	uint m_nDailyPrice = 1 finney;  // Campaign has to pay it daily. Price can increase only for new campaigns.

	uint m_nTotalDeposited = 0;
	
    // --- Events ---

	event eventPaid(address indexed addrDepositFrom, uint nAmount, uint nTotalAmountOnAccount, uint nTotalAmount);
	
	// --- Functions ---

	function IcoMultiWallet() public
	{
	}

	// ---
	
	function() public payable 
	{ 
		depositFunds();
	}	
	
	// ---
	
	function depositFunds() public payable
	{
		if(msg.value < m_nDailyPrice)
			revert();

		m_nTotalDeposited += msg.value;
		
		if(m_mapAccounts[msg.sender].nTotalAmount == 0)
		{
			Account memory newAccount;
			newAccount.nTotalAmount = msg.value;
			newAccount.nFirstDepositDate = now;
			newAccount.nDailyPrice = m_nDailyPrice;
			
			m_mapAccounts[msg.sender] = newAccount;
		}
		else
			m_mapAccounts[msg.sender].nTotalAmount += msg.value;
        
		eventPaid(msg.sender, msg.value, m_mapAccounts[msg.sender].nTotalAmount, m_nTotalDeposited);
	}
	
	// ---
	
	function withdrawOwnersMoney() public onlyOwner
	{
		m_addrOwner.transfer(this.balance);
	}
	
	// ---
	
    function setDailyPrice(uint nDailyPrice) public onlyOwner { m_nDailyPrice = nDailyPrice; }

	// ---
	
	function getBalance(address addr) public constant returns (uint) { return m_mapAccounts[addr].nTotalAmount; }
	function getCampaignDailyPrice(address addr) public constant returns (uint) { return m_mapAccounts[addr].nDailyPrice; }
	function getDailyPrice() public constant returns (uint) { return m_nDailyPrice; }
	
	function getUnusedBalance(address addr) public constant returns (int) 
	{ 
		if(m_mapAccounts[addr].nTotalAmount == 0)
			return 0;
		uint nDays = (now - m_mapAccounts[addr].nFirstDepositDate) / 86400;
		return (int)(m_mapAccounts[addr].nTotalAmount - nDays * m_nDailyPrice); 
	}
}