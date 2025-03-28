// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Reputation
 * @notice This contract manages extended reputation data for each token.
 *         It allows for independent updates to reputation scores and work history references (stored off-chain).
 */
contract Reputation is Ownable {
    struct ReputationData {
        uint8 rating;           // A rating between 1 and 5
        string workHistoryURI;  // URI pointing to off-chain work history (e.g., an IPFS hash)
        uint256 lastUpdated;    // Timestamp of the last update
    }

    // Mapping from tokenId to its reputation data
    mapping(uint256 => ReputationData) private reputationData;

    constructor() Ownable(msg.sender){
    }
    event ReputationUpdated(
        uint256 indexed tokenId,
        uint8 newRating,
        string newWorkHistoryURI,
        uint256 timestamp
    );

    /**
     * @notice Updates the reputation data for a given token.
     * @param tokenId The token ID whose reputation is being updated.
     * @param newRating The new rating (must be between 1 and 5).
     * @param newWorkHistoryURI The URI (e.g., IPFS hash) for the updated work history.
     */
    function updateReputation(
        uint256 tokenId,
        uint8 newRating,
        string memory newWorkHistoryURI
    ) public onlyOwner {
        require(newRating > 0 && newRating <= 5, "Rating must be between 1 and 5");
        require(bytes(newWorkHistoryURI).length > 0, "Work History URI cannot be empty");

        reputationData[tokenId] = ReputationData({
            rating: newRating,
            workHistoryURI: newWorkHistoryURI,
            lastUpdated: block.timestamp
        });

        emit ReputationUpdated(tokenId, newRating, newWorkHistoryURI, block.timestamp);
    }

    /**
     * @notice Retrieves the reputation data for a given token.
     * @param tokenId The token ID to query.
     * @return rating The reputation rating.
     * @return workHistoryURI The URI pointing to the work history.
     * @return lastUpdated The timestamp when the reputation was last updated.
     */
    function getReputation(uint256 tokenId)
        public
        view
        returns (
            uint8 rating,
            string memory workHistoryURI,
            uint256 lastUpdated
        )
    {
        ReputationData memory rep = reputationData[tokenId];
        require(rep.lastUpdated != 0, "No reputation data available for this token");
        return (rep.rating, rep.workHistoryURI, rep.lastUpdated);
    }
}
