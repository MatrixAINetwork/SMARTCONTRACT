/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;

contract ContractCatalog {
    function validateContract(Versionable target) constant returns (bool);
}

contract Versionable {
    string public versionCode;

    function getVersionByte(uint index) constant returns (bytes1) { 
        return bytes(versionCode)[index];
    }

    function getVersionLength() constant returns (uint256) {
        return bytes(versionCode).length;
    }
}

contract Loan is Versionable {
    uint8 public constant STATUS_INITIAL = 1;
    uint8 public constant STATUS_LENT = 2;
    uint8 public constant STATUS_PAID = 3;
    uint8 public constant STATUS_DESTROYED = 4;

    string public versionCode;
    
    address public borrower;
    address public lender;

    uint8 public status;

    uint256 public amount;
    uint256 public paid;

    event ApprovedBy(address _address);
    event DestroyedBy(address _address);
    event PartialPayment(address _sender, address _from, uint256 _amount);
    event Transfer(address _from, address _to);
    event TotalPayment();

    function pay(uint256 _amount, address _from) returns (bool);
    function destroy() returns (bool);
    function lend() returns (bool);
    function approve() returns (bool);
    function isApproved() returns (bool);
}

contract LoanDirectory {
    uint256 public constant VERSION = 2;

    ContractCatalog public catalog;
    Loan[] public loans;
    
    function LoanDirectory() {
        catalog = ContractCatalog(0x50fD51B624Ca86Be3DBc640515ebC407A163cd6C);
    }

    function validateLoan(Loan loan) private returns (bool) {
        require(loan.status() == loan.STATUS_INITIAL());
        require(catalog.validateContract(loan));
    }

    function registerLoan(Loan loan) {
        validateLoan(loan);
        loans.push(loan);
    }
    
    function registerLoanReplace(Loan loan, uint256 indexReplace) {
        require(indexReplace < loans.length);
        Loan replaceLoan = loans[indexReplace];
        require(replaceLoan.status() != replaceLoan.STATUS_INITIAL());
        validateLoan(loan);
        loans[indexReplace] = loan;
    }

    function registerLoanReplaceDuplicated(Loan loan, uint256 replaceA, uint256 replaceB) {
        require(replaceA < loans.length && replaceB < loans.length);
        require(replaceA != replaceB);
        require(loans[replaceA] == loans[replaceB]);
        validateLoan(loan);
        loans[replaceA] = loan;
    }

    function getAllLoans() constant returns (Loan[]) {
        return loans;
    }
}