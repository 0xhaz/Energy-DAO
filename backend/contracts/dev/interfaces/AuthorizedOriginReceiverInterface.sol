// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.6;

/**
 * @notice Modified AuthorizedReceiver abstract for use on the Functions Oracle contract to limit usage
 * @notice Uses tx.origin instead of msg.sender because the client contract sends messages to the Oracle contract
 */
interface AuthorizedOriginReceiverInterface {
    /**
     * @dev Returns true if the contract is paused, and false otherwise
     */
    function authorizedReceiverActive() external view returns (bool);

    /**
     * @dev Triggers AuthorizedOriginReceiver usage to block unauthorized senders
     *
     * Requirements:
     * - The contract must be inactive
     */
    function activateAuthorizedReceiver() external;

    /**
     * @dev Triggers AuthorizedOriginReceiver usage to allow all senders
     *
     * Requirements:
     * - The contract must be active
     */
    function deactivateAuthorizedReceiver() external;

    /**
     * @notice Sets the permission to request for the given wallets
     * @param senders the addresses of the wallet addresses to grant access
     */
    function addAuthorizedSenders(address[] calldata senders) external;

    /**
     * @notice Remove the permissions to request for the given wallet(s)
     * @param senders the addresses of the wallet addresses to revoke access
     */
    function removeAuthorizedSenders(address[] calldata senders) external;

    /**
     * @notice Retrieve a list of authorized senders
     * @return array of addresses
     */
    function getAuthorizedSenders() external view returns (address[] memory);

    /**
     * @notice Use this to check if a ndoe is authorized for fulfilling requests
     * @param sender the address of the Chainlink node
     * @return The authorization status of the node
     */
    function isAuthorizedSender(address sender) external view returns (bool);
}
