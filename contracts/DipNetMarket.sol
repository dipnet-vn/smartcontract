// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {IDipNetMarket, MarketLib} from "./interfaces/IDipNetMarket.sol";
import {Collection} from "./Collection.sol";

/**
 * @title NFTGram
 * @dev DipNetMarket contract for managing NFT (Non-Fungible Token) transactions and collections.
 *      Implements the IDipNetMarket.sol interface, initialized with Access Control, Reentrancy Guard, Pausable, ERC721Holder and ERC1155Holder functionalities.
 */
contract DipNetMarket is
    IDipNetMarket,
    Initializable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    ERC721Holder,
    ERC1155Holder
{
    using MarketLib for *;
    using SafeERC20 for IERC20;

    /**
     * @dev Role identifier for the approver role.
     */
    bytes32 public constant APPROVER_ROLE = keccak256("APPROVER_ROLE");

    /**
     * @dev Factor used for calculating base fees and discounts, where 10000 represents 100%.
     */
    uint256 public constant BASE_FEE_FACTOR = 10000;

    /**
     * @dev Factor used for calculating discounts, where 10000 represents 100%.
     */
    uint256 public constant DISCOUNT_FACTOR = 10000;

    /**
     * @dev Maximum base fee percentage that can be set, represented as a fraction of 10000.
     */
    uint256 public constant MAX_BASE_FEE = 1000; // 10%

    /**
     * @dev Address representing the native token, e.g., Ether (ETH) on Ethereum.
     */
    address public constant NATIVE_TOKEN_ADDRESS =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /**
     * @dev Mapping to track which NFT tokens are permitted for sale.
     */
    mapping(address => bool) public nftTokensForSale;

    /**
     * @dev Mapping to track which type of tokens for sale.
     */
    mapping(address => MarketLib.TokenType) public typeOfTokenForSale;

    /**
     * @dev Mapping to track which tokens are accepted as payment tokens.
     */
    mapping(address => bool) public paymentTokens;

    /**
     * @dev Mapping to store market items by their unique item IDs.
     */
    mapping(uint256 => MarketLib.MarketItem) public idToMarketItem;

    /**
     * @dev Base fee percentage applied to transactions, represented as a fraction of BASE_FEE_FACTOR.
     */
    uint256 public baseFee;

    /**
     * @dev Address designated to collect fees from transactions.
     */
    address public feeCollector;

    /**
     * @dev Counter for generating unique item IDs.
     */
    uint256 private _itemIdCounter;

    /**
     * @dev Initializes the contract with required initializations.
     * Grants the default admin role to the deployer, sets the fee collector to the deployer's address,
     * and initializes the base fee to 1% (100 basis points).
     *
     * This function is used during contract deployment to set up initial roles and parameters.
     */
    function initialize() public initializer {
        __AccessControl_init_unchained();
        __ReentrancyGuard_init_unchained();
        __Pausable_init_unchained();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        feeCollector = msg.sender;
        baseFee = 100; // 1%
    }

    /**
     * @dev Receives Ether sent directly to the contract address, typically used to handle accidental transfers.
     */
    receive() external payable {}

    /**
     * @dev Fallback function to handle Ether transfers, useful for managing accidental transfers to the contract.
     */
    fallback() external payable {}

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
    ) external {
        _onlyAdmin();
        _onlyNonZeroAddress(_token);
        require(
            !nftTokensForSale[_token],
            "NFTGram: NFT token is already permitted for sale"
        );
        nftTokensForSale[_token] = true;
        typeOfTokenForSale[_token] = _tokenType;

        emit AddNftTokensForSaleEvent(_token, _tokenType);
    }

    /**
     * @dev Revokes permission for an NFT token to be sold.
     * Reverts if the caller is not an admin or the token is not already permitted for sale.
     * @param _token The address of the NFT token contract to remove from sale.
     */
    function removeNftTokensForSale(address _token) external {
        _onlyAdmin();
        _onlyNftTokensForSale(_token);
        nftTokensForSale[_token] = false;

        emit RemoveNftTokensForSaleEvent(_token);
    }

    /**
     * @dev Adds a new payment token.
     * Reverts if the caller is not an admin, the token address is zero, or the token is already a payment token.
     * @param _token The address of the token to add.
     */
    function addPaymentToken(address _token) external {
        _onlyAdmin();
        _onlyNonZeroAddress(_token);
        require(
            !paymentTokens[_token],
            "NFTGram: Token has already been payment token"
        );
        paymentTokens[_token] = true;

        emit AddPaymentTokenEvent(_token);
    }

    /**
     * @dev Removes an existing payment token.
     * Reverts if the caller is not an admin or the token is not a payment token.
     * @param _token The address of the token to remove.
     */
    function removePaymentToken(address _token) external {
        _onlyAdmin();
        _onlyPaymentToken(_token);
        paymentTokens[_token] = false;

        emit RemovePaymentTokenEvent(_token);
    }

    /**
     * @dev Grants the approver role to a new address.
     * Reverts if the caller is not an admin or the new approver address is zero.
     * @param _newApprover The address to grant the approver role to.
     */
    function grantApprover(address _newApprover) external {
        _onlyAdmin();
        _onlyNonZeroAddress(_newApprover);
        grantRole(APPROVER_ROLE, _newApprover);

        emit GrantApproverRoleEvent(_newApprover);
    }

    /**
     * @dev Revokes the approver role from an address.
     * Reverts if the caller is not an admin or the approver address is zero.
     * @param _approver The address to revoke the approver role from.
     */
    function revokeApprover(address _approver) external {
        _onlyAdmin();
        _onlyNonZeroAddress(_approver);
        revokeRole(APPROVER_ROLE, _approver);

        emit RevokeApproverRoleEvent(_approver);
    }

    /**
     * @dev Updates the base fee.
     * Reverts if the caller is not an admin or the fee is not within the valid range.
     * @param _fee The new base fee.
     */
    function updateBaseFee(uint256 _fee) external {
        _onlyAdmin();
        require(_fee <= MAX_BASE_FEE, "NFTGram: Fee is not valid");
        baseFee = _fee;

        emit UpdateBaseFeeEvent(_fee);
    }

    /**
     * @dev Pauses the contract.
     * Reverts if the caller is not an admin.
     */
    function pause() external {
        _onlyAdmin();
        _pause();
    }

    /**
     * @dev Unpauses the contract.
     * Reverts if the caller is not an admin.
     */
    function unpaused() external {
        _onlyAdmin();
        _unpause();
    }

    /**
     * @dev Sweeps tokens from the contract to the admin's address.
     * Reverts if the caller is not an admin, the token address is zero.
     * Transfers ETH balance if the token is ETH_ADDRESS, otherwise transfers IERC20 token balance.
     * @param _token The address of the token to sweep.
     */
    function sweepToken(address _token) external {
        _onlyAdmin();
        _onlyNonZeroAddress(_token);

        if (_token == NATIVE_TOKEN_ADDRESS) {
            payable(msg.sender).transfer(address(this).balance);
        } else {
            uint256 balance = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(msg.sender, balance);
        }
    }

    /**
     * @dev Updates the address of the fee collector.
     * Reverts if the caller is not an admin or the provided address is zero.
     * @param _feeCollector The new address of the fee collector.
     */
    function updateFeeCollector(address _feeCollector) external {
        _onlyAdmin();
        _onlyNonZeroAddress(_feeCollector);
        feeCollector = _feeCollector;

        emit UpdateFeeCollectorEvent(_feeCollector);
    }

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
    ) external nonReentrant whenNotPaused returns (address _collectionAddress) {
        // Deploy a new Collection contract
        Collection _newCollection = new Collection(
            msg.sender,
            _name,
            _symbol,
            _description,
            _collectionURI,
            _baseURI,
            _avatarURI,
            _traitMetadataURI
        );
        _collectionAddress = address(_newCollection);

        // Mark the new collection as available for sale
        nftTokensForSale[_collectionAddress] = true;
        typeOfTokenForSale[_collectionAddress] = MarketLib.TokenType.ERC1155;

        emit CollectionCreatedEvent(
            msg.sender,
            _collectionAddress,
            _name,
            _symbol,
            _collectionURI,
            _baseURI,
            _avatarURI,
            _traitMetadataURI,
            _description
        );
    }

    /**
     * @dev Places an item for sale on the marketplace.
     * Reverts if the caller is not the owner of the token, the payment token is not supported, or the price is zero.
     * Transfers the NFT from the seller to the contract.
     * @param _nftContract The address of the NFT contract.
     * @param _tokenId The ID of the token to sell.
     * @param _value Amount of the sell token.
     * @param _price The price of the token.
     * @param _paymentToken The address of the payment token.
     */
    function sell(
        address _nftContract,
        uint256 _tokenId,
        uint256 _value,
        uint256 _price,
        address _paymentToken
    ) external nonReentrant whenNotPaused {
        // Ensure the NFT contract is approved for sale on the platform
        _onlyNftTokensForSale(_nftContract);

        // Ensure the payment token is supported by the platform
        _onlyPaymentToken(_paymentToken);

        // Ensure the price is greater than zero
        require(_price > 0, "NFTGram: Price must be at least 1 wei");

        address seller = msg.sender;
        MarketLib.TokenType sellTokenType = typeOfTokenForSale[_nftContract];

        // For ERC721 tokens, the value should always be 1
        if (sellTokenType == MarketLib.TokenType.ERC721) {
            _value = 1;
        }

        // Ensure the seller owns the specified token and has the required balance
        MarketLib._requireOwned(
            _nftContract,
            seller,
            _tokenId,
            _value,
            sellTokenType
        );

        // Get the new item ID
        uint256 itemId = _itemIdCounter;

        // Create the market item
        idToMarketItem[itemId] = MarketLib.MarketItem(
            itemId,
            _nftContract,
            _tokenId,
            _value,
            _price,
            seller,
            address(0),
            _paymentToken,
            false,
            false,
            sellTokenType
        );

        // Transfer the token from the seller to the marketplace
        MarketLib._transferToMarket(
            _nftContract,
            seller,
            _tokenId,
            _value,
            sellTokenType
        );

        // Increment the item ID counter for the next item
        _itemIdCounter++;

        emit SellItemEvent(
            itemId,
            _nftContract,
            _tokenId,
            _value,
            seller,
            _paymentToken,
            _price,
            sellTokenType
        );
    }

    /**
     * @dev Cancels an item listing.
     * Reverts if the item ID is not valid, the item is already deleted or completed, or the caller is not the seller.
     * Transfers the NFT from the contract back to the seller.
     * @param _itemId The ID of the item to cancel.
     */
    function cancel(uint256 _itemId) external nonReentrant whenNotPaused {
        // Ensure the item ID is valid
        _onlyValidItemId(_itemId);

        // Ensure the item is active
        _onlyActiveItem(_itemId);

        // Retrieve the market item using the item ID
        MarketLib.MarketItem storage item = idToMarketItem[_itemId];

        // Check if the caller is the seller of the item
        require(
            item.seller == msg.sender,
            "NFTGram: Only the seller can cancel the item"
        );

        // Transfer the token from the contract back to the seller
        MarketLib._exitMarket(
            item.sellToken,
            item.seller,
            item.tokenId,
            item.value,
            item.sellTokenType
        );

        // Mark the item as deleted
        item.isDelete = true;

        // Emit the CancelItemEvent
        emit CancelItemEvent(
            _itemId,
            item.sellToken,
            item.tokenId,
            item.value,
            item.seller,
            item.sellTokenType
        );
    }

    /**
     * @dev Approves the purchase of an NFT item, transferring ownership to the buyer and handling payments.
     * Reverts if the caller is not an approver, or if any conditions for valid item ID, non-zero buyer address,
     * valid discount percentage, item not deleted or completed are not met.
     * Transfers the NFT from the contract to the buyer, calculates and handles payments (either in Ether or IERC20 tokens),
     * marks the item as completed, and emits an event for the approved transaction.
     * @param _itemId The ID of the item being approved for purchase.
     */
    function buy(uint256 _itemId) external payable nonReentrant whenNotPaused {

        // Ensure the item ID is valid
        _onlyValidItemId(_itemId);

        // Ensure the item is active
        _onlyActiveItem(_itemId);

        // Ensure the buyer address is not zero
        _onlyNonZeroAddress(msg.sender);

        // Retrieve the market item using the item ID
        MarketLib.MarketItem storage item = idToMarketItem[_itemId];

        // Calculate the total payout for the item
        uint256 totalPayout = item.price * item.value;

        // Calculate the fee based on the base fee percentage
        uint256 fee = (totalPayout * baseFee) / BASE_FEE_FACTOR;

        if (item.paymentToken == NATIVE_TOKEN_ADDRESS) {
            // Ensure msg.value matches the total ETH required (total payout + discount amount)
            require(
                msg.value == totalPayout ,
                "NFTGram: Incorrect msg.value"
            );
        }

        item.buyer = msg.sender;

        // Handle the payout using the MarketLib library
        MarketLib._payout(item, msg.sender, feeCollector, fee, 0);

        // Mark the item as completed
        item.isComplete = true;

        // Emit the ApproveItemEvent
        emit ApproveItemEvent(
            _itemId,
            item.sellToken,
            item.tokenId,
            item.value,
            item.seller,
            msg.sender,
            item.paymentToken,
            item.price,
            0,
            item.sellTokenType
        );
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     * @param interfaceId The interface identifier, as specified in ERC-165.
     * @return `true` if the contract implements the requested interface.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(AccessControlUpgradeable, ERC1155Holder)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /****************** Internal functions ****************** */

    /**
     * @dev Ensures that the caller has the default admin role.
     */
    function _onlyAdmin() internal view {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "NFTGram: Caller is not an admin"
        );
    }

    /**
     * @dev Ensures that the caller has the approver role.
     */
    function _onlyApprover() internal view {
        require(
            hasRole(APPROVER_ROLE, msg.sender),
            "NFTGram: Caller is not an approver"
        );
    }

    /**
     * @dev Ensures that the provided address is not the zero address.
     * @param _address The address to check.
     */
    function _onlyNonZeroAddress(address _address) internal pure {
        require(
            _address != address(0),
            "NFTGram: Address cannot be the zero address"
        );
    }

    /**
     * @dev Ensures that the token is already permitted for sale.
     * Reverts if the token is not already permitted for sale.
     * @param _token The address of the NFT token contract to check.
     */
    function _onlyNftTokensForSale(address _token) internal view {
        require(
            nftTokensForSale[_token],
            "NFTGram: Token must be already permitted for sale"
        );
    }

    /**
     * @dev Ensures that the provided token is a payment token.
     * @param _token The token address to check.
     */
    function _onlyPaymentToken(address _token) internal view {
        require(
            paymentTokens[_token],
            "NFTGram: Token must be a payment token"
        );
    }

    /**
     * @dev Ensures that the provided item ID is valid.
     * @param _itemId The item ID to check.
     */
    function _onlyValidItemId(uint256 _itemId) internal view {
        require(_itemId < _itemIdCounter, "NFTGram: Invalid item ID");
    }

    /**
     * @dev Internal function to check if the item is active (not deleted or completed).
     * Reverts with "NFTGram: The item has already been completed or deleted" if the item is either completed or deleted.
     * @param _itemId The item ID to check.
     */
    function _onlyActiveItem(uint256 _itemId) internal view {
        require(
            !idToMarketItem[_itemId].isDelete &&
                !idToMarketItem[_itemId].isComplete,
            "NFTGram: The item has already been completed or deleted"
        );
    }
}
