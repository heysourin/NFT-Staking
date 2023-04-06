// SPDX-License-Identifier:MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract PixelNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string public baseURI;
    string public constant baseExtension = ".json";

    uint256 public cost;
    uint256 public immutable maxSupply;
    uint256 public maxMintAmountPerTx;

    uint256 public paused = 1; // Use uint256 instead of bool to save gas, paused = 1 & active = 2

    error PixelNFT__ContractIsPaused();
    error PixelNFT__NftSupplyLimitExceeded();
    error PixelNFT__InvalidMintAmount();
    error PixelNFT__MaxMintAmountExceeded();
    error PixelNFT__InsufficientFunds();
    error PixelNFT__QueryForNonExistentToken();

    constructor(
        uint256 _maxSupply,
        uint256 _cost,
        uint256 _maxMintAmountPerTx
    ) ERC721("Pixel NFTs", "PxN") {
        cost = _cost;
        maxMintAmountPerTx = _maxMintAmountPerTx;
        maxSupply = _maxSupply;
    }

    function mint(uint256 _mintAmount) external payable {
        if (paused == 1) revert PixelNFT__ContractIsPaused();
        if (_mintAmount == 0) revert PixelNFT__InvalidMintAmount();
        if (_mintAmount > maxMintAmountPerTx)
            revert PixelNFT__MaxMintAmountExceeded();

        uint256 supply = totalSupply();

        if (supply + _mintAmount > maxSupply)
            revert PixelNFT__NftSupplyLimitExceeded();

        if (msg.sender != owner()) {
            if (msg.value < cost * _mintAmount) {
                revert PixelNFT__InsufficientFunds();
            }
        }
        _safeMint(msg.sender, _mintAmount);
    }

    function setCost(uint256 _cost) external payable onlyOwner {
        cost = _cost;
    }

    function setMaxMintAmountPerTx(
        uint256 _maxMintAmountPerTx
    ) external payable onlyOwner {
        maxMintAmountPerTx = _maxMintAmountPerTx;
    }

    function setBaseURI(string memory _newBaseURI) external payable onlyOwner {
        baseURI = _newBaseURI;
    }

    function pause(uint256 _state) external payable onlyOwner {
        paused = _state;
    }

    function withdraw() external payable onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert PixelNFT__QueryForNonExistentToken();

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}
