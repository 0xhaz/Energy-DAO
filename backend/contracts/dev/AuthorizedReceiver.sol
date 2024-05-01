// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./interfaces/AuthorizedReceiverInterface.sol";

abstract contract AuthorizedReceiver is AuthorizedReceiverInterface {
    /// @dev Library for managing sets of primitive types
    /// @dev Sets have the following properties:
    /// @dev - Elements are added, removed, and checked for existence in constant time (O(1))
    /// @dev - Elements are enumerated in 0(n). No guarantees are made on the ordering.
    /// @dev Reference Link - https://ethereum.stackexchange.com/questions/123571/enumerableset-vs-access-control-in-openzeppelin
    /// @dev Reference Link - https://twitter.com/CharlesWangP/status/1773390237500092781
    using EnumerableSet for EnumerableSet.AddressSet;

    event AuthorizedSendersChanged(address[] senders, address changedBy);

    error EmptySendersList();
    error UnauthorizedSender();
    error NotAllowedToSetSenders();

    EnumerableSet.AddressSet private s_authorizedSenders;
    address[] private s_authorizedSendersList;

    /**
     * @notice Sets the fulfillment permission for a given node. Use `true` to allow , `false` to disallow.
     * @param senders The addresses of the authorized Chailink node
     */
    function setAuthorizedSenders(address[] calldata senders) external override validateAuthorizedSenderSetter {
        if (senders.length == 0) revert EmptySendersList();

        for (uint256 i; i < s_authorizedSendersList.length; i++) {
            s_authorizedSenders.remove(s_authorizedSendersList[i]);
        }

        for (uint256 i; i < senders.length; i++) {
            s_authorizedSenders.add(senders[i]);
        }

        s_authorizedSendersList = senders;

        emit AuthorizedSendersChanged(senders, msg.sender);
    }

    /**
     * @notice Retrieve a list of authorized senders
     * @return array of addresses
     */
    function getAuthorizedSenders() public view override returns (address[] memory) {
        return s_authorizedSendersList;
    }

    /**
     * @notice Use this to check if a node is authorized for fulfilling requests
     * @param sender The address of the Chailink node
     * @return The authorization status of the Chailink node
     */
    function isAuthorizedSender(address sender) public view override returns (bool) {
        return s_authorizedSenders.contains(sender);
    }

    /**
     * @notice customizable guard of who can update the authorized sender list
     * @return bool whethere sender can update authorized sender list
     */
    function _canSetAuthorizedSenders() internal view virtual returns (bool);

    /**
     * @notice prevents non-authorized addresses from calling this method
     */
    modifier validateAuthorizedSenderSetter() {
        if (!_canSetAuthorizedSenders()) revert NotAllowedToSetSenders();
        _;
    }
}
