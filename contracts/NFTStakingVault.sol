// SPDX-License-Identifier:MIT
pragma solidity 0.8.7;

import "./Interfaces/IPixelNFT.sol";
import "./Interfaces/IPixelReward.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTStakingVault is Ownable, IERC721Receiver {
    uint256 public totalItemsStaked;
    uint256 private constant MONTH = 30 days;

    IPixelNFT immutable nft;
    IPixelReward immutable token;

    struct Stake {
        address owner;
        uint256 stakedAt;
    }

    mapping(uint256 => Stake) vault;

    event ItemStaked(uint256 tokenId, address owner, uint256 timestamp);
    event ItemUnstaked(uint256 tokenId, address owner, uint256 timestamp);
    event Claimed(address owner, uint256 reward);

    error NFTStakingVault__ItemAlreadyStaked();
    error NFTStakingVault__NotItemOwner();

    constructor(address _nftAddress, address _tokenAddress) {
        nft = IPixelNFT(_nftAddress);
        token = IPixelReward(_tokenAddress);
    }

    function stake(uint256[] calldata tokenIds) external {
        uint256 tokenId;
        uint256 stakedCount;

        uint256 len = tokenIds.length;
        for (uint256 i; i < len; ) {
            tokenId = tokenIds[i];

            if (vault[tokenId].owner != address(0)) {
                revert NFTStakingVault__ItemAlreadyStaked();
            }

            if (nft.ownerOf(tokenId) != msg.sender) {
                revert NFTStakingVault__NotItemOwner();
            }

            nft.safeTransferFrom(msg.sender, address(this), tokenId);

            vault[tokenId] = Stake(msg.sender, block.timestamp);

            emit ItemStaked(tokenId, msg.sender, block.timestamp);

            unchecked {
                stakedCount++;
                ++i;
            }
        }

        totalItemsStaked += stakedCount;
    }
}
