// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract LiquidityPool {
    address public tokenA;
    address public tokenB;


    uint public totalSupply;

    
    mapping(address => uint) public balances;

    constructor(address _tokenA, address _tokenB){
         tokenA = _tokenA;
         tokenB = _tokenB;
    }

    function deposit(uint amountA, uint amountB) public {
        require(amountA > 0 && amountB > 0, "Amounts must be greater than zero");
        uint liquidity = 0;
        uint balanceA = IERC20(tokenA).balanceOf(address(this));
        uint balanceB = IERC20(tokenB).balanceOf(address(this));
        if (totalSupply == 0) {
            liquidity = sqrt(amountA * amountB);
        } else {
            liquidity = min(amountA * totalSupply / balanceA, amountB * totalSupply / balanceB);
        }
        require(liquidity > 0, "Insufficient liquidity");
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);
        balances[msg.sender] += liquidity;
        totalSupply += liquidity;
    }

    function withdraw(uint liquidity) public {
        require(liquidity > 0, "Liquidity must be greater than zero");
        uint balanceA = IERC20(tokenA).balanceOf(address(this));
        uint balanceB = IERC20(tokenB).balanceOf(address(this));
        uint amountA = liquidity * balanceA / totalSupply;
        uint amountB = liquidity * balanceB / totalSupply;
        require(amountA > 0 && amountB > 0, "Insufficient liquidity");
        balances[msg.sender] -= liquidity;
        totalSupply -= liquidity;
        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function min(uint x, uint y) internal pure returns (uint) {
        return x < y ? x : y;
    }
}
