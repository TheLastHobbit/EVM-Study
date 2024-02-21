import { useEffect, useState } from 'react';
import { NetworkPlugin, ethers } from 'ethers';
import { NFTApprove, mint, balanceOf, OwnerOf } from './utils/nft.js';
import './App.css';
import { getBalance, ERC20approve, getAllowance, ERC20transfer, ERC20contract } from './utils/usdt.js';



function App() {
  const [wallet, setwallet] = useState("");
  const [id, setid] = useState(Number);
  const [price, setprice] = useState(Number);
  const [sellerid, setsellerid] = useState(Number);
  const [ERC20Balance, setERC20Balance] = useState(Number);
  const [MarketContract, setMarketContract] = useState();
  const [Aid, setAid] = useState(Number);
  const [bid, setbid] = useState(Number);
  const [bprice, setbprice] = useState(Number);
  const [NFTList, setNFTLIST] = useState([]);
  const [logsArr, setLogsArr] = useState([])
  const [Tid, setTid] = useState("");
  const [Oid, setOid] = useState(Number);


  // useEffect:想在页面加载时做的
  useEffect(() => {

  }, []);


  async function handleConnection() {

    if (window.ethereum == null) {
      console.log("Please install wallet first!")
    } else {
      let provider = new ethers.BrowserProvider(window.ethereum)
      provider.getSigner().then((signer) => {
        console.log("welcome " + signer.address);
        updateWalletInfo(signer);//更新数据
        initMarketContract();//需要构建对象
        let start = wallet.provider.getBlockNumber();
        getLogs(start, start + 2);
      }).catch(err => {
        console.log(Object.keys(err))
      });
    }

  }


  // 更新钱包信息
  async function updateWalletInfo(signer) {
    setwallet(signer)// update 
  }



  async function E20transfer() {
    const result = await ERC20transfer(Tid);
    console.log("ERC20Transfer:", result);
  }

  const ListNFT = async () => {

    console.log("ListNFT");
    console.log("MarketContract:", MarketContract);
    console.log("wallet:", wallet.address);
    console.log("id:", id);
    console.log("price:", price);
    handleConnection();

    await MarketContract.placeOrder(wallet.address, id, price);

  }


  const getSeller = async () => {
    console.log("id:", id);
    const seller = await MarketContract.getorderSell(id);
    console.log("seller:", seller);
  }

  function getERC20Balance() {
    getBalance(wallet.address).then((balance) => {
      console.log("balance:", balance);
      setERC20Balance(Number(balance));
    });
  }

  async function Mint() {
    await mint(wallet.address, 1);
    console.log(wallet.address);

    const result = await balanceOf(wallet.address);
    console.log("mint success");
    console.log("NFTBalance:", result);
  }

  async function ERC20Approve() {
    console.log("ERC20Approve");
    await ERC20approve(10000000000000);
    const Allowance = await getAllowance(wallet.address);
    console.log("Allowance:", Allowance);
  }

  async function NFTApproveM() {
    console.log("NFTApprove");
    await NFTApprove(Aid);
    console.log("NFTApprove success");

  }

  async function getAllNFT() {
    console.log("MarketContract:", MarketContract);
    const NFTList = MarketContract.getAllOrders();
    console.log("NFTList:", NFTList);
    for (let index = 0; index < NFTList.length; index++) {
      const order = NFTList[index];
      console.log("seller:", order.seller);
      console.log("id:", order.id);
      console.log("price:", order.price);
    }
    console.log("getAllNFT success");
  }

  async function getNFTOwner() {
    const NFTOwner = await OwnerOf(Oid);
    console.log("NFTid:", Oid, "Owner:", NFTOwner);
  }



  async function buyNFT() {
    console.log("buy");
    await MarketContract.buy(bid, bprice);
    console.log("buy success");


  }

  function initMarketContract() {
    var abi = [
      "function buy(uint256 _id, uint _price) external",

      "function placeOrder(address seller, uint256 id, uint256 price) external",

      "function getOrderId(uint256 _index) external view returns (uint256)",

      "function getorderSell(uint256 _id) external view returns (address)",

      "function getorderPrice(uint256 _id) public view returns (uint256)",

      "function getAllOrders() external view returns (tuple(address seller,uint256 id,uint256 price)[] orders)",
      "event Deal(address indexed seller, address indexed buyer, uint256 id, uint256 price)",
      "event List(address indexed seller, uint256 id, uint256 price)",
    ];
    // 合约对象
    // https://docs.ethers.org/v6/api/contract/
    // 需要更新成你自己的合约地址
    const MarketAddress = "0xe5AF54AA3f81E0cc23d7EBEe959570bdbF8eD598";
    const MarketContract = new ethers.Contract(MarketAddress, abi, wallet);
    setMarketContract(MarketContract);
  }

  // 读取链上历史数据
  async function getLogs(from, to) {
    let currentBlock = await wallet.provider.getBlockNumber()

    if (to > currentBlock) {
      to = currentBlock;
    }
    // 两秒后继续获取数据
    wallet.provider.getLogs({ from, to }).then(logs => {
      if (logs.length > 0) decodeEvents(logs)

      if (currentBlock <= from && logs.length == 0) {

        setTimeout(() => {
          getLogs(from, to)
        }, 2000);
      } else if (to + 1 <= currentBlock) {
        getLogs(to + 1, to + 1 + 2);
      }
    }
    )
  }


  function decodeEvents(logs) {

    const DealEvent = MarketContract.getEvent("Deal").fragment;
    const ListEvent = MarketContract.getEvent("List").fragment;
    const ERC20ApproveEvent = ERC20contract.getEvent("Approval").fragment;

    for (var i = 0; i < logs.length; i++) {
      const log = logs[i];
      const eventId = log.topics[0];
      if (eventId == DealEvent.topicHash) {
        const data = MarketContract.interface.decodeEventLog(DealEvent, log.data, log.topics)
        printLog(`Block:(${logs.blockNumber}) ${data.buyer} buy ${data.seller}'s NO.${data.id} NFT ${ethers.formatEther(data.price)} ETH (${log.transactionHash})`)
      } else if (eventId == ListEvent.topicHash) {
        const data = MarketContract.interface.decodeEventLog(ListEvent, log.data, log.topics)
        printLog(`Block:(${logs.blockNumber}) seller:${data.seller} list NO.${data.id} NFT $ transactionHash:(${log.transactionHash})`)

      } else if (eventId == ERC20ApproveEvent.topicHash) {
        const data = ERC20contract.interface.decodeEventLog(ERC20ApproveEvent, log.data, log.topics)
        printLog(`Block:(${log.blockNumber}) ${data.owner} approve ${data.spender} ${data.value} transactionHash:(${log.transactionHash})`)
      }
    }

  }



  function printLog(msg) {
    let newArr = [...logsArr, msg]
    setLogsArr(newArr)
  }


  return (
    <div>
      <h1>Market</h1>
      <button onClick={handleConnection}>Connect Wallet</button>
      <align>Wallet Address: {wallet.address}</align>
      <button onClick={Mint}>Mint</button>

      <label htmlFor="id">Id:</label>
      <input type="uint" id="id" placeholder="Enter id" value={id} onChange={(e) => setid(e.target.value)} required
      />

      <label htmlFor="price">Price:</label>
      <input type="uint" id="price" placeholder="Enter price" value={price} onChange={(e) => setprice((e.target.value))} required
      />
      <button onClick={ListNFT}>List</button>
      <br></br>

      <label htmlFor="seller">sellerID:</label>
      <input type="uint" id="price" placeholder="Enter id" value={sellerid} onChange={(e) => setsellerid((e.target.value))} required
      />
      <button onClick={getSeller}>getSeller</button>
      <br></br>

      <button onClick={getERC20Balance}>get20Balance</button>
      <p>ERC20 Balance: {ERC20Balance}</p>
      <br></br>

      <label htmlFor="NFTApprove">AID:</label>
      <input type="uint" id="AID" placeholder="Enter Aid" value={Aid} onChange={(e) => setAid((e.target.value))} required
      />
      <button onClick={NFTApproveM}>NFTApprove</button>
      <br></br>

      <button onClick={ERC20Approve}>ERC20Approve</button>
      <br></br>


      <label htmlFor="buy">BuyID:</label>
      <input type="uint" id="buyid" placeholder="Enter bid" value={bid}
        onChange={(e) => setbid((e.target.value))} required
      />
      <label htmlFor="buy">BuyPrice:</label>
      <input type="uint" id="buyprice" placeholder="Enter bprice" value={bprice}
        onChange={(e) => setbprice((e.target.value))} required
      />
      <button onClick={buyNFT}>Buy</button>
      <br></br>

      <label htmlFor="ERC20Transfer">account</label>
      <input id="value" placeholder="Enter address" value={Tid}
        onChange={(e) => setTid((e.target.value))} required
      />
      <button onClick={E20transfer}>Transfer</button>
      <br></br>

      <label htmlFor="getNFTOwner">getNFTOwner</label>
      <input id="value" placeholder="Enter NFTid" value={Oid}
        onChange={(e) => setOid((e.target.value))} required
      />
      <button onClick={getNFTOwner}>getNFTOwner</button>
      <br></br>

      <button onClick={getAllNFT}>getAllNFT</button>
      <br></br>
      <p>LOGS Begin:</p>

      <div className='logs'>
        {
          logsArr.map((log, index) => (
            <div key={index}>{log}</div>
          ))
        }
      </div>

    </div>

  )
}



export default App;


