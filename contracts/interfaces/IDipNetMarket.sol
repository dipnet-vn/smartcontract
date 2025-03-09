// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MarketLib} from "../libraries/MarketLib.sol";

/*
 * @author Pon
 * @title IDipNetMarket.sol
 * @dev Interface for interacting with the NFTGram contract.
 *      Contains function declarations to interact with NFTs and manage collections.
 */
interface IDipNetMarket {
    /**
     * @dev Emitted when permission is granted for an NFT token to be sold.
     * @param token The address of the NFT token contract.
     * @param sellTokenType Type of the token (ERC721 or ERC1155).
     */
    event AddNftTokensForSaleEvent(
        address indexed token,
        MarketLib.TokenType sellTokenType
    );

    /**
     * @dev Emitted when permission is revoked for an NFT token to be sold.
     * @param token The address of the NFT token contract.
     */
    event RemoveNftTokensForSaleEvent(address indexed token);

    /**
     * @dev Emitted when a new payment token is added.
     * @param token The address of the added payment token.
     */
    event AddPaymentTokenEvent(address indexed token);

    /**
     * @dev Emitted when an existing payment token is removed.
     * @param token The address of the removed payment token.
     */
    event RemovePaymentTokenEvent(address indexed token);

    /**
     * @dev Emitted when a new approver role is granted.
     * @param approver The address that was granted the approver role.
     */
    event GrantApproverRoleEvent(address indexed approver);

    /**
     * @dev Emitted when an approver role is revoked.
     * @param approver The address that had the approver role revoked.
     */
    event RevokeApproverRoleEvent(address indexed approver);

    /**
     * @dev Emitted when the base fee is updated.
     * @param newFee The new base fee.
     */
    event UpdateBaseFeeEvent(uint256 newFee);

    /**
     * @dev Emitted when a new NFT collection is created.
     * @param owner The address of the creator of the collection.
     * @param collection The address of the newly created NFT collection contract.
     * @param name The name of the NFT collection.
     * @param symbol The symbol of the NFT collection.
     * @param collectionURI URI of the collection metadata.
     * @param baseURI The base URI for the NFT collection.
     * @param avatarURI The avatar URI for the NFT collection.
     * @param traitMetadataURI URI of the trait metadata.
     * @param description Description of the new collection.
     */
    event CollectionCreatedEvent(
        address indexed owner,
        address indexed collection,
        string name,
        string symbol,
        string collectionURI,
        string baseURI,
        string avatarURI,
        string traitMetadataURI,
        string description
    );

    /**
     * @dev Emitted when an item is listed for sale.
     * @param itemId The ID of the item listed for sale.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the token listed for sale.
     * @param value Amount of the sell token.
     * @param seller The address of the seller.
     * @param tokenAddress The address of the payment token.
     * @param price The price of the item.
     * @param sellTokenType Type of the token (ERC721 or ERC1155).
     */
    event SellItemEvent(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 value,
        address seller,
        address tokenAddress,
        uint256 price,
        MarketLib.TokenType sellTokenType
    );

    /**
     * @dev Emitted when an item listing is canceled.
     * @param itemId The ID of the item canceled.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the token canceled.
     * @param value Amount of the sell token.
     * @param seller The address of the seller.
     * @param sellTokenType Type of the token (ERC721 or ERC1155).
     */
    event CancelItemEvent(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 value,
        address seller,
        MarketLib.TokenType sellTokenType
    );

    /**
     * @dev Emitted when an item sale is approved.
     * @param itemId The ID of the item approved for sale.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the token approved for sale.
     * @param value Amount of the sell token.
     * @param seller The address of the seller.
     * @param buyer The address of the buyer.
     * @param tokenAddress The address of the payment token.
     * @param price The price of the item.
     * @param discount The discount applied to the sale.
     * @param sellTokenType Type of the token (ERC721 or ERC1155).
     */
    event ApproveItemEvent(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 value,
        address seller,
        address buyer,
        address tokenAddress,
        uint256 price,
        uint256 discount,
        MarketLib.TokenType sellTokenType
    );

    /**
     * @dev Emitted when the fee collector address is updated.
     * @param newFeeCollector The new address of the fee collector.
     */
    event UpdateFeeCollectorEvent(address indexed newFeeCollector);

    /****************** Admin functions ****************** */

    /**
     * @dev Grants permission for an NFT token to be sold.
     * Reverts if the caller is not an admin, the token address is zero, or the token is already permitted for sale.
     * @param _token The address of the NFT token contract to permit for sale.
     * @param _tokenType Type of the token (ERC721 or ERC1155).
     */
    function addNftTokensForSale(
        address _token,
        MarketLib.TokenType _tokenType
    ) external;

    /**
     * @dev Revokes permission for an NFT token to be sold.
     * Reverts if the caller is not an admin or the token is not already permitted for sale.
     * @param _token The address of the NFT token contract to remove from sale.
     */
    function removeNftTokensForSale(address _token) external;

    /**
     * @dev Adds a new payment token.
     * Reverts if the caller is not an admin, the token address is zero, or the token is already a payment token.
     * @param _token The address of the token to add.
     */
    function addPaymentToken(address _token) external;

    /**
     * @dev Removes an existing payment token.
     * Reverts if the caller is not an admin or the token is not a payment token.
     * @param _token The address of the token to remove.
     */
    function removePaymentToken(address _token) external;

    /**
     * @dev Grants the approver role to a new address.
     * Reverts if the caller is not an admin or the new approver address is zero.
     * @param _newApprover The address to grant the approver role to.
     */
    function grantApprover(address _newApprover) external;

    /**
     * @dev Revokes the approver role from an address.
     * Reverts if the caller is not an admin or the approver address is zero.
     * @param _approver The address to revoke the approver role from.
     */
    function revokeApprover(address _approver) external;

    /**
     * @dev Updates the base fee.
     * Reverts if the caller is not an admin or the fee is not within the valid range.
     * @param _fee The new base fee.
     */
    function updateBaseFee(uint256 _fee) external;

    /**
     * @dev Pauses the contract.
     * Reverts if the caller is not an admin.
     */
    function pause() external;

    /**
     * @dev Unpauses the contract.
     * Reverts if the caller is not an admin.
     */
    function unpaused() external;

    /**
     * @dev Sweeps non-payment tokens from the contract to the admin's address.
     * Reverts if the caller is not an admin, the token address is zero, or the token is a payment token.
     * Transfers ETH balance if the token is ETH_ADDRESS, otherwise transfers ERC20 token balance.
     * @param _token The address of the token to sweep.
     */
    function sweepToken(address _token) external;

    /**
     * @dev Updates the address of the fee collector.
     * Reverts if the caller is not an admin or the provided address is zero.
     * @param _feeCollector The new address of the fee collector.
     */
    function updateFeeCollector(address _feeCollector) external;

    /****************** Trade functions ****************** */

    /**
     * @dev Creates a new Collection contract.
     * @param _name Name of the new collection.
     * @param _symbol Symbol of the new collection.
     * @param _description Description of the new collection.
     * @param _collectionURI URI of the collection metadata.
     * @param _baseURI Base URI for the new collection.
     * @param _avatarURI Avatar URI for the new collection.
     * @param _traitMetadataURI URI of the trait metadata.
     */
    function createNewCollection(
        string memory _name,
        string memory _symbol,
        string memory _description,
        string memory _collectionURI,
        string memory _baseURI,
        string memory _avatarURI,
        string memory _traitMetadataURI
    ) external returns (address);

    /**
     * @dev Places an item for sale on the marketplace.
     * Reverts if the caller is not the owner of the token, the payment token is not supported, or the price is zero.
     * Transfers the NFT from the seller to the contract.
     * @param _nftContract The address of the NFT contract.
     * @param _tokenId The ID of the token to sell.
     * @param _value Amount of the token.
     * @param _price The price of the token.
     * @param _paymentToken The address of the payment token.
     */
    function sell(
        address _nftContract,
        uint256 _tokenId,
        uint256 _value,
        uint256 _price,
        address _paymentToken
    ) external;

    /**
     * @dev Cancels an item listing.
     * Reverts if the item ID is not valid, the item is already deleted or completed, or the caller is not the seller.
     * Transfers the NFT from the contract back to the seller.
     * @param _itemId The ID of the item to cancel.
     */
    function cancel(uint256 _itemId) external;

    /**
     * @dev Approves the purchase of an item by transferring ownership to the buyer and handling payments.
     * Reverts if the caller is not an approver, or if any conditions for valid item ID, non-zero buyer address,
     * valid discount percentage, item not deleted or completed, and discount not exceeding price are not met.
     * Transfers the NFT from the contract to the buyer, calculates and transfers fees and discounts in ERC20 tokens,
     * marks the item as completed, and emits an event for the approved transaction.
     * @param _itemId The ID of the item being approved for purchase.
     */
    function buy(
        uint256 _itemId
    ) external payable;
}
