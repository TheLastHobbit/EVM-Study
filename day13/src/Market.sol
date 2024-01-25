// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./NFT.sol";
import "./MyERC20.sol";

// import "@nomiclabs/buidler/console.sol";
// import "truffle/console.sol";

import "./ItokenRecieved.sol";
contract MyContract {
    MyNFT public erc721;
    MyERC20 public erc20;

    mapping(uint256 => Order) public orderofId;
    mapping(uint index => uint) public idToOrderIndex;
    mapping(address => uint) public _balance;
    Order[] public orders;
    struct Order {
        address seller;
        uint256 id;
        uint256 price;
    }

    event Deal(address indexed seller, address indexed buyer, uint256 id, uint256 price);
    event changePrice(uint _id, uint _price);
    event cancelOrder(uint _id);
    event List(address indexed seller, uint256 id, uint256 price);

    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    constructor(address _erc721, address _erc20) {
        erc721 = MyNFT(_erc721);
        erc20 = MyERC20(_erc20);
    }

    function getAllOrders() external view returns (Order[] memory) {
        return orders;
    }

    function getOrderCount() external view returns (uint256) {
        return orders.length;
    }

    function getOrderId(uint256 _index) external view returns (uint256) {
        return orders[_index].id;
    }

    function getOrderBuyer(uint256 _id) external view returns (address) {
        return orderofId[_id].seller;
    }

    function getorderSell(uint256 _id) external view returns (address) {
        return orderofId[_id].seller;
    }

    function getorderPrice(uint256 _id) public view returns (uint256) {
        return orderofId[_id].price;
    }

    function getorderIndex(uint256 _id) external view returns (uint256) {
        return idToOrderIndex[_id];
    }

    // 需要approve
    function buy(uint256 _id, uint _price) public {
        Order memory order = orderofId[_id];
        uint price = order.price;
        require(price == _price, "Market: Price mismatch");
        address seller = order.seller;
        address buyer = msg.sender;

        erc20.transferFrom(buyer, seller, _price);

        erc721.safeTransferFrom(seller, buyer, _id);
        delete orderofId[_id];
        delete idToOrderIndex[_id];

        emit Deal(seller, buyer, _id, _price);
    }


   function permitbuy(address user, uint amount,uint NFTid, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        MyNFT(erc721).NFTpermit(msg.sender, deadline, v, r, s);
        MyNFT(erc721).Approvepermit(msg.sender, address(this),NFTid,deadline, v, r, s);
        buy(NFTid, amount);
    }

    function bytesToUint(bytes32 b) public view returns (uint256) {
        uint256 number;
        for (uint i = 0; i < b.length; i++) {
            number = number + uint8(b[i]) * (2 ** (8 * (b.length - (i + 1))));
        }
        return number;
    }

    // ERC20不需要approve
    // function tokenReceive(
    //     address from,
    //     uint256 value,
    //     uint256 _id
    // ) public returns (bool) {
    //     // uint256  _id = bytesToUint(data);
    //     Order memory order = orderofId[_id];
    //     // uint price = order.price;
    //     address seller = order.seller;
    //     // 这里调用函数的msg.sender是Market合约
    //     IERC721(erc721).safeTransferFrom(seller, from, _id);
    //     require(erc20.transfer(seller, value), "erc20 fail");
    //     return true;
    // }

    function ChangePrice(uint256 _id, uint256 _price) external {
        require(orderofId[_id].seller != address(0), "Product not available");
        require(
            orderofId[_id].seller == msg.sender,
            "You are not the owner of this product"
        );
        Order memory order = orderofId[_id];
        order.price = _price;
        orderofId[_id] = order;

        emit changePrice(_id, _price);
    }

    function CancelOrder(uint256 _id) external {
        require(orderofId[_id].seller != address(0), "Product not available");
        require(
            orderofId[_id].seller == msg.sender,
            "You are not the owner of this product"
        );
        delete orderofId[_id];
        delete idToOrderIndex[_id];

        emit cancelOrder(_id);
    }

    function getMyNFT(address account) external view returns (Order[] memory) {
        Order[] memory myNFT = new Order[](orders.length);
        uint256 count = 0;
        for (uint256 i = 0; i < orders.length; i++) {
            if (orders[i].seller == account) {
                myNFT[count] = orders[i];
                count++;
            }
        }
        Order[] memory result = new Order[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = myNFT[i];
        }
        return result;
    }

    function placeOrder(address seller, uint256 id, uint256 price) public {
        Order memory order = Order(seller, id, price);
        orders.push(order);
        orderofId[id] = order;

        idToOrderIndex[id] = orders.length - 1;
        emit List(seller,id, price);
    }

    //  function onERC721Received(
    //     address _operator,
    //     address _seller,
    //     uint256 _tokenId,
    //     bytes calldata _data
    // ) public override returns (bytes4) {
    //     require(_operator == _seller, "Market: Seller must be operator");
    //     uint256 _price = toUint256(_data, 0);
    //     // 上架
    //     placeOrder(_seller, _tokenId, _price);

    //     return MAGIC_ON_ERC721_RECEIVED;
    // }

    function toUint256(
        bytes memory _bytes,
        uint256 _start
    ) public pure returns (uint256) {
        require(_start + 32 >= _start, "Market: toUint256_overflow");
        require(_bytes.length >= _start + 32, "Market: toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    // function tokenRecieve(
    //     address from,
    //     uint256 value,
    //     uint256 _id
    // ) external override {
    //      Order memory order = orderofId[_id];
    //     // uint price = order.price;
    //     address seller = order.seller;
    //     // 这里调用函数的msg.sender是Market合约
    //     IERC721(erc721).safeTransferFrom(seller, from, _id);
    //     require(erc20.transfer(seller, value), "erc20 fail");

    // }



}
