// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20Interface {
    // Transfer from one to another
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    // Approve token
    function approve(address sender, uint256 amount) external returns (bool);
    // Check balance of specific token
    function balanceOf(address account) external view returns (uint256);
}

contract TokenTransferContract {
    // Owner of contract, can add verified tokens
    address public owner;
    // Check if the token is verified within the contract, users can only transfer verified tokens
    mapping(address => bool) private verifiedTokens;
    // List of verified tokens
    address[] public verifiedTokensList;

    // Need data for transaction
    struct Transaction {
        address sender;
        address receiver;
        uint256 amount;
        string message;
    }

    event TransactionCompleted (
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        string message
    );

    constructor() {
        // Whoever deploys the contract will be the owner
        owner = msg.sender;

    }

    modifier onlyOwner() {
        // Only the owner can call specific function
        require(msg.sender == owner, 'Only owner can call this function!');
        _;
    }

    modifier onlyVerifiedTokens(address _token) {
        // Only verified tokens can be transacted
        require(verifiedTokens[_token], "Token is not verified!");
        _;
    }

    // Add verified tokens
    function addVerifiedTokens(address _token) public onlyOwner {
        require(!verifiedTokens[_token], "Token is already verified!");
        verifiedTokens[_token] = true;
        verifiedTokensList.push(_token);
    }

    function removeVerifiedTokens(address _token) public onlyOwner {
        require(verifiedTokens[_token] == true, "Token is not verified!");
        verifiedTokens[_token] = false;

        for (uint256 i = 0; i < verifiedTokensList.length; i++) {
            // Check if the verified token is in the list
            if (verifiedTokensList[i] == _token) {
                verifiedTokensList[i] = verifiedTokensList[verifiedTokensList.length - 1];
                // Remove token
                verifiedTokensList.pop();
                break;
            }
        }
    }

    // Get all verified tokens ready for transfered
    function getVerifiedTokens() public view returns (address[] memory) {
        return verifiedTokensList;
    }

    function transfer(IERC20Interface token, address to, uint256 amount, string memory message) public onlyVerifiedTokens(address(token)) returns (bool) {
        // Check if the sender's balance enough to transfer
        uint256 senderBalance = token.balanceOf(msg.sender);
        require(senderBalance >= amount, "Insufficient balance!");

        bool success = token.transferFrom(msg.sender, to, amount);
        require(success, "Transfer failed!");

        Transaction memory transaction =  Transaction({
            sender: msg.sender,
            receiver: to,
            amount: amount,
            message: message
        });

        // Emit event onto blockchain
        emit TransactionCompleted(msg.sender, transaction.receiver, transaction.amount, transaction.message);

        return true;
    }
}
