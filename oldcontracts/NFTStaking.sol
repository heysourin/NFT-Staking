// SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

import "./Collection.sol";
import "./Rewards.sol";

contract NFTStakeing {
    uint256 public totalStaked;

    ///struct to store a staker's token, owner and earning values

    struct Stake {
        uint24 tokenId;
        uint48 timestamp;
        address owner;
    }

    event NFTStaked(address owner, uint256 tokenId, uint256 value);
    event NFTUnstaked(address owner, uint256 tokenId, uint256 value);
    event Claimed(address owner, uint256 amount);

    //Creating instances of erc721 token and reward token. This is the way we are going to interact with those smart contracts from this smart contract
    Collection nft;
    Rewards token;

    mapping(uint256 => Stake) public vault;

    constructor(Collection _nft, Rewards _token) {
        nft = _nft;
        token = _token;
    }

    function stake(uint256[] calldata tokenIds) external {
        totalStaked += tokenIds.length;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(nft.ownerOf(tokenId) == msg.sender, "Not your token");
            require(vault[tokenId].tokenId == 0, "Already staked");

            nft.transferFrom(msg.sender, address(this), tokenId);
            emit NFTStaked(msg.sender, tokenId, block.timestamp);
            vault[tokenId] = Stake(
                uint24(tokenId),
                uint48(block.timestamp),
                msg.sender
            );
        }
    }

    // function _unstake(uint256[] calldata tokenIds) internal {
    //     uint256 tokenId;
    //     totalStaked -= tokenIds.length;
    //     for (uint256 i = 0; i < tokenIds.length; i++) {
    //         tokenId = tokenIds[i];
    //         Stake memory stake = vault[tokenId];
    //         require(stake.owner == msg.sender, "Not an owner");

    //         delete vault[tokenId];

    //         emit NFTUnstaked(account, tokenId, block.timestamp);
    //         nft.transferFrom(address(this), account, tokenId);
    //     }
    // }

    function _unstakeMany(
        address account,
        uint256[] calldata tokenIds
    ) internal {
        totalStaked -= tokenIds.length;
        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];

            Stake memory staked = vault[tokenId];
            require(staked.owner == msg.sender, "not an owner");

            delete vault[tokenId];

            emit NFTUnstaked(account, tokenId, block.timestamp);

            nft.transferFrom(address(this), account, tokenId);
        }
    }

    function claim(uint256[] calldata tokenIds) external {
        _claim(msg.sender, tokenIds, false);
    }

    function claimForAddress(
        address account,
        uint256[] calldata tokenIds
    ) external {
        _claim(account, tokenIds, false);
    }

    function unstake(uint256[] calldata tokenIds) external {
        _claim(msg.sender, tokenIds, true);
    }

    function _claim(
        address account,
        uint256[] calldata tokenIds,
        bool _unstake
    ) internal {
        uint256 tokenId;
        uint256 earned = 0;
        Stake memory stake = vault[tokenId];

        require(stake.owner == msg.sender, "Not an owner");
        uint256 stakedAt = stake.timestamp;
        earned += (1000 ether * (block.timestamp - stakedAt)) / 1 days;
        vault[tokenId] = Stake(
            uint24(tokenId),
            uint48(block.timestamp),
            account
        );
        if (earned > 0) {
            earned = earned / 10000;
            token.mint(account, earned);
        }
        if (_unstake) {
            _unstakeMany(account, tokenIds);
        }

        emit Claimed(account, earned);
    }

    function earningInfo(
        uint256[] calldata tokenIds
    ) external view returns (uint256[2] memory info) {
        uint256 tokenId;
        uint256 totalScore = 0;

        uint256 earned = 0;

        Stake memory staked = vault[tokenId];
        uint256 staketAt = staked.timestamp;
        earned += (1000 ether * (block.timestamp - staketAt)) / 1 days;
        uint256 earnRatePerSecond = (totalScore * 1 ether) / 1 days;
        earnRatePerSecond = earnRatePerSecond / 100000;
        // earned, earnRatePerSecond
        return [earned, earnRatePerSecond];
    }

    function balanceOf(address account) public view returns (uint256) {
        uint256 balance = 0;
        uint256 supply = nft.totalSupply();
        for (uint256 i = 1; i <= supply; i++) {
            if (vault[i].owner == account) {
                balance += 1;
            }
        }
    }

    function tokensOfOwner(
        address account
    ) public view returns (uint256[] memory ownerTokens) {
        uint256 supply = nft.totalSupply();
        uint256[] memory tmp = new uint256[](supply);

        uint256 index = 0;
        for (uint tokenId = 1; tokenId <= supply; tokenId++) {
            if (vault[tokenId].owner == account) {
                tmp[index] = vault[tokenId].tokenId;
                index += 1;
            }
        }

        uint256[] memory tokens = new uint256[](index);
        for (uint i = 0; i < index; i++) {
            tokens[i] = tmp[i];
        }

        return tokens;
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        require(from == address(0x0), "Cannot send nfts to Vault directly");
        return IERC721Receiver.onERC721Received.selector;
    }
}
