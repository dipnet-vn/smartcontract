// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {ERC1155URIStorage} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {DynamicTraits} from "./DynamicTraits.sol";

/**
 * @title Collection
 * @dev A contract for managing a collection of ERC1155 tokens with dynamic traits.
 */
contract Collection is
    ERC1155,
    ERC1155Burnable,
    ERC1155Supply,
    ERC1155URIStorage,
    DynamicTraits,
    Ownable
{
    /**
     * @dev Struct representing a metadata of tokens.
     */
    struct TokenMetadata {
        string name;
        string description;
    }

    /**
     * @notice Mapping from token ID to its metadata.
     */
    mapping(uint256 => TokenMetadata) public metadata;

    /**
     * @notice Name of the collection.
     */
    string public name;

    /**
     * @notice Symbol of the collection.
     */
    string public symbol;

    /**
     * @notice Avatar of the collection.
     */
    string public collectionAvatar;

    /**
     * @notice Description of the collection.
     */
    string public description;

    /**
     * @dev Counter for generating new token IDs.
     */
    uint256 private _id;

    /**
     * @dev Emitted when a new token is minted.
     * @param to Address to which the token is minted.
     * @param tokenId ID of the token minted.
     * @param supply Number of tokens minted.
     * @param tokenName Name of tokens to minted.
     * @param tokenURI URI of the token metadata.
     * @param description Description of the token.
     */
    event Minted(
        address indexed to,
        uint256 indexed tokenId,
        uint256 supply,
        string tokenName,
        string tokenURI,
        string description
    );

    /**
     * @dev Event emitted when the collection description is updated.
     * @param newDescription The new description set for the collection.
     */
    event CollectionDescriptionUpdated(string newDescription);

    /**
     * @dev Constructor for initializing the contract.
     * @param _owner Address of the contract owner.
     * @param _name Name of the collection.
     * @param _symbol Symbol of the collection.
     * @param _description Description of the Collection.
     * @param _collectionURI URI of the collection metadata.
     * @param _collectionBaseURI Base URI of the collection.
     * @param _collectionAvatar Avatar of the collection.
     * @param _traitMetadataURI URI of the trait metadata.
     */
    constructor(
        address _owner,
        string memory _name,
        string memory _symbol,
        string memory _description,
        string memory _collectionURI,
        string memory _collectionBaseURI,
        string memory _collectionAvatar,
        string memory _traitMetadataURI
    ) ERC1155(_collectionURI) Ownable(_owner) {
        _onlyNonEmptyString(_name);
        _onlyNonEmptyString(_symbol);
        name = _name;
        symbol = _symbol;
        description = _description;
        collectionAvatar = _collectionAvatar;
        _setBaseURI(_collectionBaseURI);
        _setTraitMetadataURI(_traitMetadataURI);
    }

    /**
     * @dev Updates the description of the collection.
     * @param _newDescription The new description to set for the collection.
     */
    function updateCollectionDescription(
        string memory _newDescription
    ) external onlyOwner {
        description = _newDescription;

        emit CollectionDescriptionUpdated(_newDescription);
    }

    /**
     * @dev Mints new tokens.
     * @param to Address to which the tokens will be minted.
     * @param supply Number of tokens to mint.
     * @param tokenName Name of tokens to mint
     * @param tokenURI URI of the token metadata.
     * @param tokenDescription Description of the token.
     * @param traitKeys Array of trait keys.
     * @param values Array of trait values.
     * @return _tokenId The ID of the newly minted token.
     */
    function mint(
        address to,
        uint256 supply,
        string memory tokenName,
        string memory tokenURI,
        string memory tokenDescription,
        bytes32[] memory traitKeys,
        bytes32[] memory values
    ) external onlyOwner returns (uint256 _tokenId) {
        _onlyNonEmptyString(tokenName);
        require(supply != 0, "Collection: Supply should be positive");

        _tokenId = _id;
        _id++;

        _mint(to, _tokenId, supply, "");
        _setURI(_tokenId, tokenURI);
        metadata[_tokenId].name = tokenName;
        metadata[_tokenId].description = tokenDescription;

        _setTraits(_tokenId, traitKeys, values);

        emit Minted(
            to,
            _tokenId,
            supply,
            tokenName,
            tokenURI,
            tokenDescription
        );
    }

    /**
     * @dev Sets the URI for trait metadata.
     * @param _traitMetadataURI New URI for the trait metadata.
     */
    function setTraitMetadataURI(
        string calldata _traitMetadataURI
    ) external onlyOwner {
        _setTraitMetadataURI(_traitMetadataURI);
    }

    /**
     * @dev Sets multiple traits for a token.
     * @param tokenId ID of the token.
     * @param traitKeys Array of trait keys.
     * @param values Array of trait values.
     */
    function setTraits(
        uint256 tokenId,
        bytes32[] memory traitKeys,
        bytes32[] memory values
    ) external onlyOwner {
        // Revert if the token doesn't exist.
        _requireExists(tokenId);
        _setTraits(tokenId, traitKeys, values);
    }

    /**
     * @dev Sets a trait for a token.
     * @param tokenId ID of the token.
     * @param traitKey Key of the trait.
     * @param value Value of the trait.
     */
    function setTrait(
        uint256 tokenId,
        bytes32 traitKey,
        bytes32 value
    ) public virtual override onlyOwner {
        // Revert if the token doesn't exist.
        _requireExists(tokenId);

        // Call the internal function to set the trait.
        DynamicTraits.setTrait(tokenId, traitKey, value);
    }

    /**
     * @dev Gets the value of a trait for a token.
     * @param tokenId ID of the token.
     * @param traitKey Key of the trait.
     * @return traitValue Value of the trait.
     */
    function getTraitValue(
        uint256 tokenId,
        bytes32 traitKey
    ) public view virtual override returns (bytes32 traitValue) {
        // Revert if the token doesn't exist.
        _requireExists(tokenId);

        // Call the internal function to get the trait value.
        return DynamicTraits.getTraitValue(tokenId, traitKey);
    }

    /**
     * @dev Gets the values of multiple traits for a token.
     * @param tokenId ID of the token.
     * @param traitKeys Array of keys for the traits.
     * @return traitValues Array of values for the traits.
     */
    function getTraitValues(
        uint256 tokenId,
        bytes32[] calldata traitKeys
    ) public view virtual override returns (bytes32[] memory traitValues) {
        // Revert if the token doesn't exist.
        _requireExists(tokenId);

        // Call the internal function to get the trait values.
        return DynamicTraits.getTraitValues(tokenId, traitKeys);
    }

    /**
     * @dev See {ERC1155URIStorage-uri}.
     */
    function uri(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC1155, ERC1155URIStorage)
        returns (string memory)
    {
        return super.uri(tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     * @param interfaceId The interface identifier, as specified in ERC-165.
     * @return `true` if the contract implements the requested interface.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, DynamicTraits) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {ERC1155-_update}.
     */
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal virtual override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }

    /**
     * @dev Internal function to set multiple traits for a token.
     * @param _tokenId ID of the token.
     * @param _traitKeys Array of trait keys.
     * @param _values Array of trait values.
     */
    function _setTraits(
        uint256 _tokenId,
        bytes32[] memory _traitKeys,
        bytes32[] memory _values
    ) internal {
        require(
            _traitKeys.length == _values.length,
            "Collection: Mismatched trait keys and values length"
        );

        for (uint256 i = 0; i < _traitKeys.length; i++) {
            // Call the internal function to set the trait.
            DynamicTraits.setTrait(_tokenId, _traitKeys[i], _values[i]);
        }
    }

    /**
     * @dev Internal function to check that a string is non-empty.
     * @param _string The string to check.
     */
    function _onlyNonEmptyString(string memory _string) internal pure {
        require(
            bytes(_string).length != 0,
            "Collection: Only non-empty string"
        );
    }

    /**
     * @dev Internal function to check if a token exists.
     * @param _tokenId ID of the token to check.
     */
    function _requireExists(uint256 _tokenId) internal view {
        require(exists(_tokenId), "Collection: Token doesn't exist");
    }
}
