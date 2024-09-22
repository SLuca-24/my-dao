# DAO Project

## Overview

This project implements a Decentralized Autonomous Organization (DAO) using Solidity smart contracts. 
The DAO allows members to purchase shares of the DAO to become members, once member a user can create proposal that are going to be accepted if the vote in support of it are more than the vote against it after the fixed time of 5 days is expire (or the owner or the proposal owner decide to close is before the 5 days expiration). 
Only members can vote on proposals. 
The core components of the project include the `DAOContract`, the `Slunicoin` token, and the `DAOVoting` contract.

## Technical Choices

### Smart Contracts

1. **DAOContract**
   - **Purpose**: Manages the sale of shares and the overall governance structure of the DAO.
   - **Key Features**:
     - **Ownership**: Only the contract owner can perform certain actions, such as decide if the DAO shares are available for sale or not or withdrawing funds from the contract.
     - **Shares Management**: Members can buy shares using Ether following the fixed price of 1 share = 1 ETH, and each share corresponds to a reward in the native token, Slunicoin, so for each shares purchased you will receive 1 SLC that will represent you membership in the DAO.
     - **Token Integration**: Connects with the `Slunicoin` contract to reward members for their investment.

2. **Slunicoin**
   - **Purpose**: Represents the native token of the DAO, used for rewarding members.
   - **Key Features**:
     - **Standard ERC20-like Functionality**: Implements basic transfer mechanics, allowing for token transfers between addresses.
     - **Controlled Supply**: The total supply is set to 20 million tokens, ensuring that the DAO has a finite amount of currency.
     - **Direct Transfers**: Includes a function to transfer a portion of the total supply (19 milion) directly to the DAO contract, ensuring liquidity for rewards.

3. **DAOVoting**
   - **Purpose**: Manages the proposal and voting process within the DAO.
   - **Key Features**:
     - **Proposal Management**: Members can create proposals, vote on them, and track their status (active, accepted, rejected).
     - **Voting Rights**: Only members of the DAO can vote, ensuring that governance is truly decentralized and based on share ownership.
     - **Proposal Closure**: Proposals can be closed by the proposer or the contract owner.

### Development Environment

- **Solidity Version**: The contracts are written in Solidity version ^0.8.0.
- **Modular Architecture**: The contracts are separated into different files for clarity and maintainability.
- **Events for Transparency**: All critical actions are logged through events, allowing users to track the contract’s state changes easily.

### Deployment

- **Deployment Order**: The deployment follows a specific sequence where the `Slunicoin` token is deployed first, followed by the `DAOVoting` contract, and finally the `DAOContract';
  **Important** is to set the respective contract addresses in order to let the contracts comunicate and share functionalities and information, error will advise you to do so if neeeded.
- **Testing**: Each contract has been tested.

