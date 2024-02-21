// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./NFT.sol";

// import "@nomiclabs/buidler/console.sol";
// import "truffle/console.sol";

import "./ItokenRecieved.sol";
contract MyContract {
    MyNFT public erc721;

    mapping(uint256 => Order) public orderofId;
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

    function getorderSell(uint256 _id) external view returns (address) {
        return orderofId[_id].seller;
    }

    function getMappingSlot(uint256 key,uint256 Slot)external returns (bytes32){
        return keccak256(abi.encodePacked(key,Slot));
    }

    function read(bytes32 slot) external view returns(bytes32 data){
        assembly {
            data := sload(slot) // load from store    
        }
    }

    modifier (){
        
    }
    function write(bytes32 slot,uint256 value) external {
        assembly{
            sstore(slot,value)
        }
    }

    


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


}
