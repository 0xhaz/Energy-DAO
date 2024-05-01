// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.6;

interface AuthorizedReceiverInterface {
    function isAuthorizedSender(address sender) external view returns (bool);

    function getAuthorizedSenders() external returns (address[] memory);

    function setAuthorizedSenders(address[] calldata senders) external;
}
