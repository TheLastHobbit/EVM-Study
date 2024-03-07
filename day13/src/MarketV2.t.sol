// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {Nonces} from "lib/openzeppelin-contracts/contracts/utils/Nonces.sol";
import {console} from "forge-std/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "./NFT.sol";
import "./MyERC20.sol";

import "./dex/router/OutswapV1Router.sol";
import "./dex/router/interfaces/IOutswapV1Router.sol";

import "./transFeeStake.sol";

import "./KKERC20.sol";

import "./ItokenRecieved.sol";

// MarketV2 非升级版本
contract MarketV2 is EIP712, Nonces, Ownable {
    using ECDSA for bytes32;
    bytes32 private constant EIP712DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 private constant STORAGE_TYPEHASH =
        keccak256("Storage(address owner,uint256 price,uint256 id)");
    bytes32 private DOMAIN_SEPARATOR;

    MyNFT public erc721;
    KKERC20 public erc20;
    address public FeeStake;
    address public WETH;

    address public router;

    uint private transfeeRate;

    event Deal(
        address indexed seller,
        address indexed buyer,
        uint256 id,
        uint256 price
    );
    event verify(
        address indexed verifyer,
        uint256 id,
        uint256 price,
        bytes signature
    );

    constructor(
        address _owner,
        address _erc721,
        address _erc20,
        address _router,
        address _FeeStake,
        address _WETH
    ) EIP712("Market", "1") Ownable(_owner) {
        // _disableInitializers();
        erc721 = MyNFT(_erc721);
        erc20 = KKERC20(_erc20);
        router = _router;
        FeeStake = _FeeStake;
        WETH = _WETH;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712DOMAIN_TYPEHASH, // type hash
                keccak256(bytes("MarketV2")), // name
                keccak256(bytes("1")), // version
                block.chainid, // chain id
                address(this) // contract address
            )
        );
    }

    /**
     *
     * @param tokenIn buyer's token address
     * @param amountOut 希望换出的平台币的数量，一般为nft价格
     * @param amountInMax buyer最多能接受滑点价格
     * @param deadline 交易截止时间
     */
    function _swap(
        address tokenIn,
        uint256 amountOut,
        uint256 amountInMax,
        uint256 deadline
    ) public returns (uint256[] memory amounts) {
        address[] memory path;

        if (address(tokenIn) == WETH) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = address(erc20);
            // 提前获取swap具体所需的token数量，以便后面向Market转入准确的数量
            // 返回的数组顺序与path相对应
            uint[] memory amountsIn = IOutswapV1Router(router).getAmountsIn(
                amountOut,
                path
            );
            console.log("amountsIn:", amountsIn[0]);
            console.log("amountInMax:", amountInMax);
            // 如果此时的amountIn大于amountInMax，则不会交易
            require(amountsIn[0] <= amountInMax, "swap: amountInMax");
            IERC20(tokenIn).transferFrom(
                msg.sender,
                address(this),
                amountsIn[0]
            );
            IERC20(tokenIn).approve(router, amountsIn[0]);

            IOutswapV1Router(router).swapTokensForExactTokens(
                amountOut,
                amountInMax,
                path,
                address(this),
                deadline
            );
        } else {
            path = new address[](3);
            path[0] = address(tokenIn);
            path[1] = WETH;
            path[2] = address(erc20);
            uint[] memory amountsIn = IOutswapV1Router(router).getAmountsIn(
                amountOut,
                path
            );
            IERC20(tokenIn).transferFrom(
                msg.sender,
                address(this),
                amountsIn[0]
            );
            IERC20(tokenIn).approve(router, amountsIn[0]);
            IOutswapV1Router(router).swapTokensForExactTokens(
                amountOut,
                amountInMax,
                path,
                address(this),
                deadline
            );
        }
    }

    //  判断传入的token是否为平台币KK
    function isKK(address _addr) internal view returns (bool) {
        return _addr == address(erc20);
    }

    // 2.29 加入swap功能，支持buyer采用不同的token进行购买
    function buy(
        address tokenIn,
        uint amountInMax,
        address seller,
        uint256 _id,
        uint _price
    ) public {
        
        address buyer = msg.sender;
        console.log("buyer:", buyer);

        if (isKK(tokenIn)) {
            // 转账时收取手续费,存入池子
            uint transfee = (_price * transfeeRate) / 1000;
            require(
                erc20.transferFrom(buyer,address(FeeStake), transfee),
                "transfee Fail"
            );
            require(
                erc20.transferFrom(buyer, seller, (_price * (1000 - transfeeRate)) / 1000),
                "erc20Transfer Fail"
            );
            console.log("transferFrom success:", _price);
        } else {
            _swap(tokenIn, _price, amountInMax, block.timestamp + 100);

            // 转账时收取手续费,存入池子
            uint transfee = (_price * transfeeRate) / 1000;
            require(
                erc20.transfer(address(FeeStake), transfee),
                "transfee Fail"
            );

            // 如果使用了swap，那么swap过后会将KK存到Market合约中，所以这里需要该为transfer。
            require(
                erc20.transfer(seller, (_price * (1000 - transfeeRate)) / 1000),
                "erc20Transfer Fail"
            );
            console.log("transferFrom success:", _price);
        }

        erc721.safeTransferFrom(seller, buyer, _id);
        console.log("safeTransferFrom success:", _id);

        tranFeeStakePool(FeeStake).accrueInterest_KK();

        emit Deal(seller, buyer, _id, _price);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity) {
        // 添加流动性
        IOutswapV1Router(router).addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
    }

    function permitStore(
        address owner,
        uint256 NFTid,
        uint256 price,
        bytes memory _signature
    ) public {
        // 检查签名长度，65是标准r,s,v签名的长度
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        // 目前只能用assembly (内联汇编)来从签名中获得r,s,v的值
        assembly {
            /*
            前32 bytes存储签名的长度 (动态数组存储规则)
            add(sig, 32) = sig的指针 + 32
            等效为略过signature的前32 bytes
            mload(p) 载入从内存地址p起始的接下来32 bytes数据
            */
            // 读取长度数据后的32 bytes
            r := mload(add(_signature, 0x20))
            // 读取之后的32 bytes
            s := mload(add(_signature, 0x40))
            // 读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }

        // 获取签名消息hash
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(STORAGE_TYPEHASH, owner, price, NFTid))
            )
        );

        address signer = digest.recover(v, r, s); // 恢复签名者
        require(signer == owner, "EIP712Storage: Invalid signature"); // 检查签名

        emit verify(msg.sender, price, NFTid, _signature);
    }

    function permitListbuy(
        address tokenIn,
        address seller,
        uint amountInMax,
        uint _price,
        uint _id,
        bytes memory _signature
    ) external {
        permitStore(seller, _id, _price, _signature);
        console.log("permitStore success!");
        buy(tokenIn, amountInMax, seller, _id, _price);
    }

    // 2.28 增加交易手续费，允许用户质押ETH分手续费
    function setTransfee(uint rate) external onlyOwner {
        require(rate <= 1000, "EIP712Storage: Invalid rate");
        transfeeRate = rate;
    }
}
