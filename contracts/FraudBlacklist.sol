// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title FraudBlacklist
 * @notice This contract maintains a blacklist of DIDs flagged for fraudulent behavior.
 *         Only the contract owner (or an authorized admin) can add or remove entries.
 */
contract FraudBlacklist is Ownable {
    // Mapping to store blacklisted DIDs
    mapping(string => bool) private blacklist;

    constructor() Ownable(msg.sender) {

    }
    event DIDBlacklisted(string did);
    event DIDRemovedFromBlacklist(string did);

    /**
     * @notice Flags a DID as fraudulent.
     * @param did The decentralized identifier to blacklist.
     */
    function addToBlacklist(string memory did) public onlyOwner {
        require(bytes(did).length > 0, "DID cannot be empty");
        require(!blacklist[did], "DID is already blacklisted");
        blacklist[did] = true;
        emit DIDBlacklisted(did);
    }

    /**
     * @notice Checks if a given DID is blacklisted.
     * @param did The decentralized identifier to check.
     * @return True if the DID is blacklisted, false otherwise.
     */
    function isBlacklisted(string memory did) public view returns (bool) {
        require(bytes(did).length > 0, "DID cannot be empty");
        return blacklist[did];
    }

    /**
     * @notice Removes a DID from the blacklist.
     * @param did The decentralized identifier to remove.
     */
    function removeFromBlacklist(string memory did) public onlyOwner {
        require(bytes(did).length > 0, "DID cannot be empty");
        require(blacklist[did], "DID is not blacklisted");
        blacklist[did] = false;
        emit DIDRemovedFromBlacklist(did);
    }
}
