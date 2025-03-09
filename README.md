# NFTGram Marketplace Smart Contract Documentation

## Overview

The NFTGram smart contract, developed by EZCON Inc, facilitates the management of NFT transactions and collections. This marketplace allows users to create collections, list NFTs for sale, and manage transactions securely.

## Key Features

### 1. Role-Based Access Control:

- Utilizes the `AccessControlUpgradeable` from OpenZeppelin to manage roles.
- Admins have the ability to manage NFT tokens for sale, payment tokens, and fees.

### 2. NFT Token Management:

- **Add/Remove NFT Tokens:** Admins can add or remove NFT tokens that are permitted for sale.
- **Token Types:** Supports both ERC721 and ERC1155 token standards.

### 3. Payment Token Management:

- **Add/Remove Payment Tokens:** Admins can specify which tokens can be used as payment in the marketplace.

### 4. Fee Management:

- **Base Fee:** Admins can set and update the base fee for transactions, up to a maximum of 10%.
- **Fee Collection:** Fees are collected by a designated fee collector address.

### 5. Marketplace Operations:

- **Create Collections:** Users can create new NFT collections with specific metadata and URIs.
- **Sell NFTs:** Users can list their NFTs for sale by specifying the contract address, token ID, value, price, and payment token.
- **Cancel Listings:** Sellers can cancel their NFT listings if they are not yet sold.
- **Approve Purchases:** Approvers can finalize NFT sales, transferring ownership to the buyer and handling payments including discounts.

### 6. Security and Utility Features:

- **Pausable Contract:** The contract can be paused and unpaused by admins to manage contract state during maintenance or emergencies.
- **Reentrancy Guard:** Protects against reentrancy attacks during critical operations.
- **Token Sweeping:** Admins can sweep tokens from the contract to manage balances.

## Events

- **AddNftTokensForSaleEvent:** Emitted when an NFT token is permitted for sale.
- **RemoveNftTokensForSaleEvent:** Emitted when an NFT token is removed from sale.
- **AddPaymentTokenEvent:** Emitted when a new payment token is added.
- **RemovePaymentTokenEvent:** Emitted when a payment token is removed.
- **GrantApproverRoleEvent:** Emitted when a new approver is granted the role.
- **RevokeApproverRoleEvent:** Emitted when an approver role is revoked.
- **UpdateBaseFeeEvent:** Emitted when the base fee is updated.
- **UpdateFeeCollectorEvent:** Emitted when the fee collector address is updated.
- **SellItemEvent:** Emitted when an NFT is listed for sale.
- **CancelItemEvent:** Emitted when an NFT listing is canceled.
- **ApproveItemEvent:** Emitted when an NFT sale is approved and finalized.
- **CollectionCreatedEvent:** Emitted when a new NFT collection is created.

## Usage

### 1. Initialization:

- The contract is initialized with roles and parameters. The deployer is assigned as the default admin and fee collector.

### 2. Role Management:

- Admins can grant and revoke the `APPROVER_ROLE` to manage who can approve NFT sales.

### 3. NFT and Payment Token Management:

- Admins can add or remove NFT tokens for sale and payment tokens using respective functions.

### 4. Marketplace Operations:

- Users can create collections, list NFTs for sale, cancel listings, and approvers can approve sales to complete transactions.

## Admin Functions

- **addNftTokensForSale**
- **removeNftTokensForSale**
- **addPaymentToken**
- **removePaymentToken**
- **grantApprover**
- **revokeApprover**
- **updateBaseFee**
- **pause**
- **unpause**
- **sweepToken**
- **updateFeeCollector**

## User Functions

- **createNewCollection**

- **sell**

![alt text](flowcharts/sell_flowchart.png)

- **cancel**

![alt text](flowcharts/cancel_flowchart.png)

## Approver Function

- **approve**

![alt text](flowcharts/approve_flowchart.png)

## Discount and Collector Fee Management

### Discount Handling:

- **Approve Function:** The `approve` function allows approvers to finalize NFT sales and apply a discount to the sale price. The discount is specified as a percentage.

### Collector Fee:

- **Base Fee Setting:** Admins can set a base fee for transactions, which is collected as part of the sale. This fee is capped at **10%**.
- **Fee Collection:** The collected fee is sent to the fee collector address, which can be updated by admins using the `updateFeeCollector` function.

## Security Considerations

- **Role-Based Security:** Ensures that only authorized addresses can perform critical operations.
- **Reentrancy Guard:** Protects against reentrancy attacks.
- **Pausable Contract:** Allows pausing of contract operations in case of emergencies.

This documentation provides a high-level overview of the NFTGram smart contract's features and functionality, ensuring users and developers understand the key aspects of the marketplace operations and management.

Copyright (C) 2024 EZCON Inc. All Rights Reserved.
