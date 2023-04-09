// SPDX-License-Identifier:MIT
pragma solidity 0.8.7;

interface IPixelReward {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(
        address onwer,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mint(address to, uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;
}
