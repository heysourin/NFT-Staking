// SPDX-License-Identifier:MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract PixelReward is ERC20, ERC20Burnable, Ownable {
    mapping(address => bool) controllers;

    error PixelReward__OnlyControllersCanMint();

    constructor() ERC20("Piexl Rewards", "PR") {}

    function mint(address to, uint256 amount) public {
        if (controllers[msg.sender] = false)
            revert PixelReward__OnlyControllersCanMint();
        _mint(to, amount);
    }

    function burnFrom(address account, uint256 amount) public override {
        if (controllers[msg.sender] = true) {
            _burn(account, amount);
        }
    }

    function setController(
        address controller,
        bool _state
    ) external payable onlyOwner {
        controllers[controller] = _state;
    }
}
