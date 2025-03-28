// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Soulbound Token (SBT)
 * @notice This contract mints non-transferable tokens representing a user's verified identity.
 *         Each token is linked to a DID and holds associated metadata.
 */
contract SBT is ERC721, Ownable {
    uint256 public tokenCounter;

    // Metadata struct for SBTs.
    struct Metadata {
        string[] skills;         // Array of skills
        uint256 experience;      // Experience (e.g., years of work)
        uint8 rating;            // Rating (e.g., 1-5)
        uint256 lastUpdated;     // Timestamp of the last update
        string externalDataURI;  // URI pointer (e.g., IPFS hash) for off-chain work history
    }

    // Mapping from tokenId to the associated DID.
    mapping(uint256 => string) public didOfToken;
    // Mapping from tokenId to its metadata.
    mapping(uint256 => Metadata) public tokenMetadata;
    // Mapping to track revoked tokens.
    mapping(uint256 => bool) public revoked;

    event SBTMinted(string did, uint256 tokenId);
    event SBTUpdated(uint256 tokenId);
    event SBTRevoked(uint256 tokenId, string did);

    /**
     * @dev Constructor passes token name, symbol, and sets msg.sender as the initial owner.
     */
    constructor() ERC721("SoulboundToken", "SBT") Ownable(msg.sender) {
        tokenCounter = 1; // Start token IDs at 1
    }

    /**
     * @notice Overrides the internal _update function from ERC721.
     *         When a transfer is attempted (i.e. token already owned and "to" is non-zero), the function reverts.
     *         Minting (from == address(0)) and burning (to == address(0)) are allowed.
     * @param to The address to update the token ownership to.
     * @param tokenId The token ID to update.
     * @param auth The authorization address (if any).
     * @return from The previous owner.
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);
        // If token already exists (from != address(0)) and we're transferring (to != address(0)), revert.
        if (from != address(0) && to != address(0)) {
            revert("Soulbound token is non-transferable");
        }
        return super._update(to, tokenId, auth);
    }

    /**
     * @notice Checks if a token exists using a try/catch on ownerOf.
     * @param tokenId The token ID to check.
     * @return exists True if the token exists, false otherwise.
     */
    function tokenExists(uint256 tokenId) public view returns (bool exists) {
        try this.ownerOf(tokenId) returns (address owner) {
            return owner != address(0);
        } catch {
            return false;
        }
    }

    /**
     * @notice Mints a new SBT linked to a DID with the provided metadata.
     * @param did The decentralized identifier to associate with this token.
     * @param metadata The metadata struct containing user details.
     * @return tokenId The newly minted token ID.
     */
    function mintSBT(string memory did, Metadata memory metadata)
        public
        onlyOwner
        returns (uint256 tokenId)
    {
        tokenId = tokenCounter;
        tokenCounter++;

        _safeMint(msg.sender, tokenId);
        didOfToken[tokenId] = did;
        tokenMetadata[tokenId] = metadata;
        emit SBTMinted(did, tokenId);
        return tokenId;
    }
    
    
    /**
     * @notice Helper function to mint a new SBT by entering fields individually.
     * @param did The decentralized identifier.
     * @param skills Array of skills.
     * @param experience Years of experience.
     * @param rating Rating (e.g., 1-5).
     * @param lastUpdated Timestamp of last update.
     * @param externalDataURI URI pointer for off-chain work history.
     * @return tokenId The minted token ID.
     */
    function mintSBT2(
        string memory did,
        string[] memory skills,
        uint256 experience,
        uint8 rating,
        uint256 lastUpdated,
        string memory externalDataURI
    ) public onlyOwner returns (uint256 tokenId) {
        Metadata memory metadata = Metadata({
            skills: skills,
            experience: experience,
            rating: rating,
            lastUpdated: lastUpdated,
            externalDataURI: externalDataURI
        });
        return mintSBT(did, metadata);
    }
    /**
     * @notice Updates the metadata of an existing SBT.
     * @param tokenId The token ID to update.
     * @param newMetadata The new metadata to set.
     * @return success True if the update is successful.
     */
    function updateSBT(uint256 tokenId, Metadata memory newMetadata)
        public
        onlyOwner
        returns (bool success)
    {
        require(tokenExists(tokenId), "Token does not exist");
        require(!revoked[tokenId], "Token has been revoked");

        tokenMetadata[tokenId] = newMetadata;
        emit SBTUpdated(tokenId);
        return true;
    }

    /**
     * @notice Revokes an SBT, marking it as no longer valid.
     * @param tokenId The token ID to revoke.
     * @return success True if the revocation is successful.
     */
    function revokeSBT(uint256 tokenId)
        public
        onlyOwner
        returns (bool success)
    {
        require(tokenExists(tokenId), "Token does not exist");
        revoked[tokenId] = true;
        emit SBTRevoked(tokenId, didOfToken[tokenId]);
        return true;
    }
}
