// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

/**
 * @title DipNetMarketProxy.sol
 * @dev This contract implements a proxy that is upgradeable by an admin.
 * It uses the TransparentUpgradeableProxy from OpenZeppelin.
 */
contract DipNetMarketProxy is TransparentUpgradeableProxy {
    /**
     * @dev Initializes the proxy with an initial logic implementation, an owner, and an optional data payload.
     * @param _logic The address of the initial implementation contract.
     * @param initialOwner The address of the proxy owner who can upgrade the implementation.
     * @param _data Optional data to send as the msg.data to the implementation to initialize it.
     */
    constructor(
        address _logic,
        address initialOwner,
        bytes memory _data
    ) TransparentUpgradeableProxy(_logic, initialOwner, _data) {}
}
