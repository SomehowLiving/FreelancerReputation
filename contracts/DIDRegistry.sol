// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DIDRegistry
 * @notice This contract is used to register and store verified decentralized identifiers (DIDs)
 *         along with a hash of the unique identifier used for verification, the user's wallet address,
 *         and a timestamp.
 */
contract DIDRegistry {
    struct DIDRecord {
        string did;                     // Decentralized Identifier (e.g., "did:example:abc123")
        address userWallet;             // User's wallet address
        string uniqueIdentifierHash;    // Hash of the unique ID (e.g., government ID or ZKP)
        uint256 timestamp;              // Registration timestamp
    }

    // Mapping from DID (string) to its record
    mapping(string => DIDRecord) public didRecords;
    // Mapping from user address to their DID (assuming one per user)
    mapping(address => string) public userToDID;

    event DIDRegistered(address indexed user, string did, uint256 timestamp);

    /**
     * @notice Registers a new DID for a verified user.
     * @param userWallet The address of the user's wallet.
     * @param did The decentralized identifier.
     * @param uniqueIdentifierHash A hash of the unique identifier (to enforce uniqueness).
     * @param timestamp The time of registration.
     */
    function registerDID(
        address userWallet,
        string memory did,
        string memory uniqueIdentifierHash,
        uint256 timestamp
    ) public {
        // Ensure the DID hasn't already been registered
        require(bytes(didRecords[did].did).length == 0, "DID already registered");

        didRecords[did] = DIDRecord({
            did: did,
            userWallet: userWallet,
            uniqueIdentifierHash: uniqueIdentifierHash,
            timestamp: timestamp
        });
        userToDID[userWallet] = did;
        emit DIDRegistered(userWallet, did, timestamp);
    }
}
