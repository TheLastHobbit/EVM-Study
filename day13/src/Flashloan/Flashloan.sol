//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;
import {Test, console} from "forge-std/Test.sol";
import "../dex/core/interfaces/IOutswapV1Pair.sol";
import "../dex/core/interfaces/IOutswapV1Factory.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../dex/router/interfaces/IOutswapV1Router.sol";

interface IOutswapV1Callee {
    function OutswapV1Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}

contract Flashloan is IOutswapV1Callee {
    address private token0;
    address private token1;
    address private factory;
    address private dex1Router;
    address private dex2Router;
    address private WETH;

    IOutswapV1Pair private immutable pair;

    constructor(
        address _token0,
        address _token1,
        address _factory,
        address _dex1Router,
        address _dex2Router,
        address _WETH
    ) {
        token0 = _token0;
        token1 = _token1;
        factory = _factory;
        dex1Router = _dex1Router;
        dex2Router = _dex2Router;
        WETH = _WETH;
        console.log("factory:", factory);
        pair = IOutswapV1Pair(
            IOutswapV1Factory(factory).getPair(_token0, _token1)
        );
    }

    function flashloan(uint amount) external {
        // calldata长度大于1才能触发闪电贷回调函数
        bytes memory data = abi.encode(token1, amount);
        // 要借的是token1
        console.log("data success");
        console.log("pair:", address(pair));
        pair.swap(0, amount, address(this), data);
        console.log("earn:",IERC20(token0).balanceOf(address(this)));
    }

    function OutswapV1Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external override {
        console.log("begin OutswapV1Call");
        address token0 = IOutswapV1Pair(msg.sender).token0(); // 获取token0地址
        address token1 = IOutswapV1Pair(msg.sender).token1(); // 获取token1地址
        assert(
            msg.sender == IOutswapV1Factory(factory).getPair(token0, token1)
        ); // ensure that msg.sender is a V2 pair

        // 解码calldata
        (address tokenBorrow, uint256 amount) = abi.decode(
            data,
            (address, uint256)
        );

        console.log("decode success");
        console.log("begin dex2swap:");

        _dex2swap(amount, amount, address(this), block.timestamp + 100); //在dex2中换出token0
        uint token0Balance = IERC20(token0).balanceOf(address(this));
        console.log("swapout token0  success");
        console.log("begin dex1swap:");
        console.log("token0Balance:",token0Balance);//37986379006524741629

        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;

        uint[] memory amounts = IOutswapV1Router(dex1Router).getAmountsIn(amount, path);

        require(token0Balance >= amounts[0], "Insufficient balance"); //最后判断收益是否大于手续费

        // 归还闪电贷
        IERC20(token0).transfer(address(pair),amounts[0]);
    }


    function _dex2swap(
        uint amountIn,
        uint amountOutMin,
        address to,
        uint deadline
    ) public returns (uint256[] memory amounts) {
        address[] memory path;
        IERC20(token1).approve(dex2Router, amountIn);

        if (address(token1) == WETH) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = address(token0);

            uint[] memory amounts = IOutswapV1Router(dex2Router).getAmountsOut(
                amountIn,
                path
            );
            console.log("amounts[1]", amounts[1]);

            IOutswapV1Router(dex2Router).swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                deadline
            );
        } else {
            path = new address[](3);
            path[0] = address(token1);
            path[1] = WETH;
            path[2] = address(token0);

            IOutswapV1Router(dex2Router).swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                deadline
            );
        }
    }
}
