// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {Nonces} from "lib/openzeppelin-contracts/contracts/utils/Nonces.sol";
import {console} from "forge-std/console.sol";

import "./NFT.sol";
import "./MyERC20.sol";

// import "@nomiclabs/buidler/console.sol";
// import "truffle/console.sol";

import "./IUniswapV2Router02.sol";

contract UniMarket is EIP712, Nonces {
    using ECDSA for bytes32;
    bytes32 private constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant STORAGE_TYPEHASH = keccak256("Storage(address owner,uint256 price,uint256 id)");
    bytes32 private DOMAIN_SEPARATOR;

    

    MyNFT public erc721;
    MyERC20 public erc20;

    address public uniswapRouter;

    event Deal(address indexed seller, address indexed buyer, uint256 id, uint256 price);
    event verify(address indexed verifyer,uint256 id,uint256 price,bytes signature);

    constructor(address _erc721,address _erc20,address _uniswapRouter)EIP712("Market","1")  {
        erc721 = MyNFT(_erc721);
        erc20 = MyERC20(_erc20);

        uniswapRouter = _uniswapRouter;

        DOMAIN_SEPARATOR = keccak256(abi.encode(
        EIP712DOMAIN_TYPEHASH, // type hash
        keccak256(bytes("MarketV2")), // name
        keccak256(bytes("1")), // version
        block.chainid, // chain id
        address(this) // contract address
        ));
    }

    function _swap(address tokenIn,uint amountIn,uint amountInMax,uint deadline) internal returns (uint[] memory amounts) {
        
        IERC20(tokenIn).transferFrom(msg.sender,address(this),amountIn);
        IERC20(tokenIn).approve(uniswapRouter,amountIn);

        address[] memory path;
        path[0] = tokenIn;
        path[1] = address(erc20);
        uint[] memory amounts;
        amounts =  IUniswapV2Router02(uniswapRouter).swapTokensForExactTokens(amountIn,amountInMax,path,address(this),deadline);
        return amounts;
    }

    function addLip(address tokenA,address tokenB,uint amountADesired,uint amountBDesired,uint amountAMin,uint amountBMin,uint deadline) external{
        IERC20(tokenA).transferFrom(msg.sender,address(this),amountADesired);
        IERC20(tokenA).approve(uniswapRouter,amountADesired);
        IERC20(tokenB).transferFrom(msg.sender,address(this),amountADesired);
        IERC20(tokenB).approve(uniswapRouter,amountADesired);
        IUniswapV2Router02(uniswapRouter).addLiquidity(tokenA,tokenB,amountADesired,amountBDesired,amountAMin,amountBMin,msg.sender,deadline);
        //to 是接收流动性token的地址
    }
    

    function buy(address tokenIn,uint amountIn,uint amountInMax,uint deadline,address seller,uint256 _id, uint _price) public {
        address buyer = msg.sender;
        console.log("buyer:",buyer);

        uint balanceBefore = erc20.balanceOf(address(this));
        _swap(tokenIn,_price, _price+100,block.timestamp+10);
        // console.log("amounts:",amounts);

        uint balanceAfter = erc20.balanceOf(address(this));

        require(balanceAfter - balanceBefore >= _price,"swap error");

        require(IERC20(erc20).transfer(seller, _price),"erc20Transfer Fail");
        console.log("transferFrom success:",_price);

        erc721.safeTransferFrom(seller, buyer, _id);
        console.log("safeTransferFrom success:",_id);

        emit Deal(seller, buyer, _id, _price);
    }

//      function permitStore(address owner,uint256 NFTid,uint256 price,bytes memory _signature) public {
//         // 检查签名长度，65是标准r,s,v签名的长度
//         require(_signature.length == 65, "invalid signature length");
//         bytes32 r;
//         bytes32 s;
//         uint8 v;
//         // 目前只能用assembly (内联汇编)来从签名中获得r,s,v的值
//         assembly {
//             /*
//             前32 bytes存储签名的长度 (动态数组存储规则)
//             add(sig, 32) = sig的指针 + 32
//             等效为略过signature的前32 bytes
//             mload(p) 载入从内存地址p起始的接下来32 bytes数据
//             */
//             // 读取长度数据后的32 bytes
//             r := mload(add(_signature, 0x20))
//             // 读取之后的32 bytes
//             s := mload(add(_signature, 0x40))
//             // 读取最后一个byte
//             v := byte(0, mload(add(_signature, 0x60)))
//         }

//         // 获取签名消息hash
//         bytes32 digest = keccak256(abi.encodePacked(
//             "\x19\x01",
//             DOMAIN_SEPARATOR,
//             keccak256(abi.encode(STORAGE_TYPEHASH, owner, price, NFTid))
//         )); 
        
//         address signer = digest.recover(v, r, s); // 恢复签名者
//         require(signer == owner, "EIP712Storage: Invalid signature"); // 检查签名

//         emit verify(msg.sender,price, NFTid, _signature);
//     }

//    function permitListbuy(address owner, uint price,uint NFTid,bytes memory _signature) external {
//         permitStore(owner, NFTid, price, _signature);
//         console.log("permitStore success!");
//         buy(owner,NFTid, price);
//     }
}
