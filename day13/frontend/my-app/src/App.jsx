import { useEffect, useState } from 'react'
import { NetworkPlugin, ethers } from 'ethers';
import './App.css'
import { createClient } from "@supabase/supabase-js";
import { MerkleTree } from "merkletreejs";
import ABI from "../contracts/MarketV2.json";
import AccounHeader from './components/AccounHeader'
import { signNFT, signToken } from "../src/utils/signTool.js"
import Airabi from "./contracts/AirdropNFT.json";
import { toHex, encodePacked, keccak256 } from 'viem';
const supabase = createClient("https://aogdarqrsnhmhxrmgqps.supabase.co", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvZ2RhcnFyc25obWh4cm1ncXBzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDY1MjI3NDMsImV4cCI6MjAyMjA5ODc0M30.Q-huYLGRe_skR9CZJaMGRqj8SQqDsYU9k01fakZOCXE");
import { setApproveForAll, mint,isApprovedForall,OwnerOf} from './utils/nft.js';
import {ERC20approve, ERC20transfer} from './utils/token.js'

function App() {

  const users = [
    { address: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", NFTid: 1, price: 100 },
    { address: "0xb7D15753D3F76e7C892B63db6b4729f700C01298", NFTid: 2, price: 100 },
    { address: "0xf69Ca530Cd4849e3d1329FBEC06787a96a3f9A68", NFTid: 3, price: 100 },
    { address: "0xa8532aAa27E9f7c3a96d754674c99F1E2f824800", NFTid: 4, price: 100 },
  ];

  let calldata = [];


  const [AirDropContract, setAirDropContract] = useState();
  const [root, setRoot] = useState("");
  const [merkleTree, setMerkleTree] = useState("");
  const elements = users.map((x) => keccak256(encodePacked(["address", "uint256", "uint256"], [x.address, x.NFTid.toString(), x.price.toString()])));

  const [wallet, setwallet] = useState("");
  const [price, setprice] = useState(0);
  const [id, setid] = useState(0);
  const [NFTData, setNFTData] = useState("");
  const [MarketContract, setMarketContract] = useState();
  const [buyer,setbuyer] = useState("");

  // const initFormData = {
  //   account: '',
  //   address: '',
  //   price: 0
  // }
  // const [form, setForm] = useState(initFormData); 

  // setForm({
  //   ...form,
  //   price: 10
  // })

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
        console.log("proxyAddress:", MarketContract);
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

  async function getNFTData() {
    let { data } = await supabase.from('List_Sign').select();
    setNFTData(data);
  }

  function initMarketContract() {
    // 将合约对象变为代理合约
    // https://docs.ethers.org/v6/api/contract/
    const MarketProxyAddress = "0xe6570e5A8499326Ce15E3F5641fD2B1FadE90A77";
    const MarketContract = new ethers.Contract(MarketProxyAddress, ABI, wallet);
    setMarketContract(MarketContract);
  }

  async function ListbyContract() {
    handleConnection();
    console.log("ListbyContract:");
    await MarketContract.placeOrder(wallet.address, id, price);

  }

  //上架不再在合约内执行，而是放在链下，并在上架时执行签名，存储在后端数据库
  async function List() {
    const signature =await signNFT(wallet, price, id);
    let { data } = await supabase.from('List_Sign').insert([{
      ownerAddr: wallet.address,
      id: id,
      price: price,
      sign: signature
    }])
    setApproveForAll("0xe6570e5A8499326Ce15E3F5641fD2B1FadE90A77");
    console.log("setApproveForAll success!")
    setNFTData(data);
  }

  // 
  async function V2Buy() {
    handleConnection();
    let { data: List_Sign, error } = await supabase
      .from('List_Sign')
      .select('*')
      console.log("List_Sign_Data:", List_Sign);

    let {data:NFTOwner} = await supabase.from('List_Sign').select("ownerAddr").eq('id', id)
    let {data:signature} = await supabase.from('List_Sign').select("sign").eq('id', id)
    let NFTOwnerString = NFTOwner[0].ownerAddr;
    let signatureString = signature[0].sign;
    console.log("NFTOwner:", NFTOwnerString);
    console.log("signature:", signatureString);
   
    await MarketContract.permitListbuy(NFTOwnerString, price, id, signatureString);

    console.log("permitListbuy success!")
  }

  function createMerkleTree() {
    console.log(elements)
    const merkleTree = new MerkleTree(elements, keccak256, { sort: true });
    setMerkleTree(merkleTree);
    const root = merkleTree.getHexRoot();
    setRoot(root);
    console.log("MerkleRoot:", root);
  }

  async function airdrop(buyer, price, NFTid, num) {
    let result = [];
    result = await signToken(wallet, "0xC7B8506F810Ff6ab16d1Ad1503d39783Bd0f55df", 100);
    const leaf = elements[num];
    const proof = merkleTree.getHexProof(leaf);
    console.log("MerkleTreeProof:", proof);
    const AirAddress = "0xC7B8506F810Ff6ab16d1Ad1503d39783Bd0f55df";
    const AirContract = new ethers.Contract(AirAddress, Airabi, wallet);
    console.log("airdrop encode:", buyer, price, Date.now() + 24 * 60 * 60 * 1000, result[0], result[1], result[2]);
    const call = AirContract.interface.encodeFunctionData("permitPrePay(address,uint,uint,uint8,bytes32,bytes32)",
      [buyer, price, Date.now() + 24 * 60 * 60 * 1000, result[0], result[1], result[2]]);
    calldata.push(call);
    calldata.push(AirContract.interface.encodeFunctionData("claimNFT",
      [buyer, NFTid, proof]));
    setAirDropContract(AirContract);
    console.log("calldata:", calldata);
    let results = [];
    results = AirContract.permitPrePay(buyer, price, (Date.now() + 24 * 60 * 60 * 1000), result[0], result[1], result[2]);
    console.log("results:", results);
  }

  // 请求买NFT
  function airDrop() {
    console.log("wallet", wallet);
    // 对表中第一个账户进行验证
    airdrop(wallet.address, 100, id, 0);
  }

  async function getOwnerOf() {
   const owner =  await OwnerOf(id);
   console.log("No.",id,"NFTowner:", owner);
  }

  async function mintNFT() {
    console.log("wallet:", wallet);
    await mint(wallet.address);
  }

  async function TokenTransfer() {
    await ERC20transfer(buyer);
  }

  async function TokenApprove() {
    await ERC20approve(10000);
  }

  async function isApproveForall() {
    const bool = await isApprovedForall();
    console.log("getApprovedAddress:", bool);
  }
  return (
    <>
      <div>
        <AccounHeader />
        <h1>Market</h1>
        <button onClick={handleConnection}>Connect Wallet</button>
        <br />
        <div>Wallet Address: {wallet.address}</div>
      </div>

      <div>
        <button onClick={List}>List</button>
        <button onClick={ListbyContract}>ListbyContract</button>
        <input type="number" placeholder="price" onChange={(e) => setprice(e.target.value)} />
        <br />
        <input type="number" placeholder="id" onChange={(e) => setid(e.target.value)} />
        <br />
      </div>

      <div>
      <input type="text" placeholder="account" onChange={(e) => setbuyer(e.target.value)} />
        <button onClick={TokenTransfer}>TokenTransfer</button>
        <button onClick={TokenApprove}>TokenApprove</button>
        <button onClick={isApproveForall}>isApproveForAll</button>
        <button onClick={getOwnerOf}>getOwnerOf</button>
      </div>

      <div>
        <button onClick={createMerkleTree}>createMerkleTree</button>
      </div>
      <div>
        <input type="number" placeholder="price" onChange={(e) => setprice(e.target.value)} />
        <br />
        <input type="number" placeholder="id" onChange={(e) => setid(e.target.value)} />
        <button onClick={V2Buy}>V2Buy</button>
      </div>

      <div>
        <input type="number" placeholder="price" onChange={(e) => setprice(e.target.value)} />
        <br />
        <input type="number" placeholder="id" onChange={(e) => setid(e.target.value)} />
        <button onClick={airDrop}>airDrop</button>
        <button onClick={mintNFT}>mintNFT</button>
      </div>
    </>
  )
}

export default App
