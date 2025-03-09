// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title MarketLib
 * @dev Library for managing market items and transactions for NFTs (ERC721 and ERC1155).
 */
library MarketLib {
    using SafeERC20 for IERC20;

    /// @dev Address representing the native token, e.g., Ether (ETH) on Ethereum.
    address constant NATIVE_TOKEN_ADDRESS =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @dev Enum representing the type of token (ERC721 or ERC1155).
    enum TokenType {
        ERC721,
        ERC1155
    }

    /// @dev Struct representing a market item.
    struct MarketItem {
        uint256 itemId;
        address sellToken;
        uint256 tokenId;
        uint256 value;
        uint256 price;
        address seller;
        address buyer;
        address paymentToken;
        bool isComplete;
        bool isDelete;
        TokenType sellTokenType;
    }

    /**
     * @dev Transfers the specified token to the market.
     * @param _sellToken Address of the token contract.
     * @param _seller Address of the seller.
     * @param _tokenId ID of the token.
     * @param _value Amount of the token.
     * @param _sellTokenType Type of the token (ERC721 or ERC1155).
     */
    function _transferToMarket(
        address _sellToken,
        address _seller,
        uint256 _tokenId,
        uint256 _value,
        TokenType _sellTokenType
    ) internal {
        _transferWithSellToken(
            _seller,
            address(this),
            _sellToken,
            _tokenId,
            _value,
            _sellTokenType
        );
    }

    /**
     * @dev Transfers the specified token from the market.
     * @param _sellToken Address of the token contract.
     * @param _seller Address of the seller.
     * @param _tokenId ID of the token.
     * @param _value Amount of the token.
     * @param _sellTokenType Type of the token (ERC721 or ERC1155).
     */
    function _exitMarket(
        address _sellToken,
        address _seller,
        uint256 _tokenId,
        uint256 _value,
        TokenType _sellTokenType
    ) internal {
        _transferWithSellToken(
            address(this),
            _seller,
            _sellToken,
            _tokenId,
            _value,
            _sellTokenType
        );
    }

    /**
     * @dev Payouts the item sale.
     * @param _item Market item details.
     * @param _from Address from which the payment is made.
     * @param _feeCollector Address of the fee collector.
     * @param _fee Fee amount.
     * @param _amountDiscount Discount amount.
     */
    function _payout(
        MarketItem memory _item,
        address _from,
        address _feeCollector,
        uint256 _fee,
        uint256 _amountDiscount
    ) internal {
        // Pay to buyer
        _transferWithSellToken(
            address(this),
            _item.buyer,
            _item.sellToken,
            _item.tokenId,
            _item.value,
            _item.sellTokenType
        );

        if (_amountDiscount > 0) {
            _transferWithPaymentToken(
                _from,
                _item.buyer,
                _item.paymentToken,
                _amountDiscount
            );
        }

        // Pay to seller
        _transferWithPaymentToken(
            _from,
            _item.seller,
            _item.paymentToken,
            _item.value * _item.price - _fee
        );

        // Pay to fee collector
        if (_fee > 0) {
            _transferWithPaymentToken(
                _from,
                _feeCollector,
                _item.paymentToken,
                _fee
            );
        }
    }

    /**
     * @dev Transfers tokens between addresses based on the token type.
     * @param _from Address sending the token.
     * @param _to Address receiving the token.
     * @param _token Address of the token contract.
     * @param _tokenId ID of the token.
     * @param _value Amount of the token.
     * @param _tokenType Type of the token (ERC721 or ERC1155).
     */
    function _transferWithSellToken(
        address _from,
        address _to,
        address _token,
        uint256 _tokenId,
        uint256 _value,
        TokenType _tokenType
    ) internal {
        if (_tokenType == TokenType.ERC721) {
            IERC721(_token).safeTransferFrom(_from, _to, _tokenId);
        } else {
            IERC1155(_token).safeTransferFrom(_from, _to, _tokenId, _value, "");
        }
    }

    /**
     * @dev Transfers payment tokens between addresses.
     * @param _from Address sending the payment.
     * @param _to Address receiving the payment.
     * @param _paymentToken Address of the payment token.
     * @param _amount Amount of the payment.
     */
    function _transferWithPaymentToken(
        address _from,
        address _to,
        address _paymentToken,
        uint256 _amount
    ) internal {
        if (_paymentToken == NATIVE_TOKEN_ADDRESS) {
            _safeTransferETH(_to, _amount);
        } else {
            IERC20(_paymentToken).safeTransferFrom(_from, _to, _amount);
        }
    }

    /**
     * @dev Internal function to safely transfer ETH to the specified address.
     * @param _to Recipient of the transfer.
     * @param _value Amount of ETH to transfer.
     */
    function _safeTransferETH(address _to, uint256 _value) internal {
        (bool success, ) = _to.call{value: _value, gas: 10000}(new bytes(0));
        require(success, "ETH transfer failed");
    }

    /**
     * @dev Ensures the account owns the specified token.
     * @param _token Address of the token contract.
     * @param _account Address of the account.
     * @param _tokenId ID of the token.
     * @param _value Amount of the token.
     * @param _tokenType Type of the token (ERC721 or ERC1155).
     */
    function _requireOwned(
        address _token,
        address _account,
        uint256 _tokenId,
        uint256 _value,
        TokenType _tokenType
    ) internal view {
        if (_tokenType == TokenType.ERC721) {
            require(
                IERC721(_token).ownerOf(_tokenId) == _account,
                "Account does not own the specified ERC721 token ID"
            );
        } else if (_tokenType == TokenType.ERC1155) {
            require(
                IERC1155(_token).balanceOf(_account, _tokenId) >= _value,
                "Account does not own enough balance of the specified ERC1155 token ID"
            );
        }
    }
}
