// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./MyERC20.sol";
contract Market is IERC721Receiver{

    IERC721 public erc721;
    MyERC20 public erc20;

    mapping(uint id => Order) public orderofId;
    mapping(uint index =>uint) public idToOrderIndex;
    mapping(address => uint) public _balance;
    Order[] public orders;
    struct Order{
        address seller;
        uint256 id;
        uint price;
    }

    event Deal(address seller,address buyer, uint256 id, uint256 price);
    event changePrice(uint _id,uint _price);
    event cancelOrder(uint _id);



    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    constructor(address _erc721, address _erc20){
        erc721 = IERC721(_erc721);
        erc20 = MyERC20(_erc20);
    }

    function buy(uint256 _id) external {
        require(orderofId[_id].seller != address(0),"Product not available");
        Order memory order = orderofId[_id];
        uint  price = order.price;
        address  seller = order.seller;
        address buyer = msg.sender;

        erc20.transferWithCallback(buyer,price);
        erc20.transfer(seller,price);

        erc721.safeTransferFrom(seller,buyer,_id);
        delete orderofId[_id];
        delete idToOrderIndex[_id];

        emit Deal(seller,buyer,_id,price);
    }

    function tokenReceive(address from,uint256 value) external  returns(bool){
        _balance[address(this)] +=value;
        _balance[from] +=value;
        return true;
    }

    function ChangePrice(uint256 _id, uint256 _price) external {
        require(orderofId[_id].seller != address(0),"Product not available");
        require(orderofId[_id].seller == msg.sender,"You are not the owner of this product");
        Order memory order = orderofId[_id];
        order.price = _price;
        orderofId[_id] = order;

        emit changePrice(_id,_price);
    }

    function CancelOrder(uint256 _id) external {
        require(orderofId[_id].seller != address(0),"Product not available");
        require(orderofId[_id].seller == msg.sender,"You are not the owner of this product");
        delete orderofId[_id];
        delete idToOrderIndex[_id];

        emit cancelOrder(_id);

    }

    function getMyNFT(address account) external view returns(Order[] memory){
        Order[] memory myNFT = new Order[](orders.length);
        uint256 count = 0;
        for(uint256 i=0;i<orders.length;i++){
            if(orders[i].seller == account){
                myNFT[count] = orders[i];
                count++;
            }
        }
        Order[] memory result = new Order[](count);
        for(uint256 i=0;i<count;i++){
            result[i] = myNFT[i];
        }
        return result;
    }



    function placeOrder(address seller,uint256 id,uint256 price) internal {
        Order memory order = Order(seller,id,price);
        orders.push(order);
        orderofId[id] = order;

        idToOrderIndex[id]= orders.length-1;

    }


     function onERC721Received(
        address _operator,
        address _seller,
        uint256 _tokenId,
        bytes calldata _data
    ) public override returns (bytes4) {
        require(_operator == _seller, "Market: Seller must be operator");
        uint256 _price = toUint256(_data, 0);
        // 上架
        placeOrder(_seller, _tokenId, _price);

        return MAGIC_ON_ERC721_RECEIVED;
    }

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



}