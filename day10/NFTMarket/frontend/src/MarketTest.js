import { ethers } from "ethers";
import React from "react";
import { useState, useEffect } from 'react';


const MarketAddress = "";
const Market =async ()=>{
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const MarketContract = new ethers.Contract(MarketAddress, MarketABI, signer);

    const [id,setid]=useState(Number);
    const [price,setprice]=useState(Number);

    const [walletAddress, setWalletAddress] = useState("");
    const [MarketContract, setMarketContract] = useState<ethers.Contract | null>(null)

    useEffect(()=>{

        walletListener();

       
      },[]);
        
    const connectWallet = async () => {
        if (window.ethereum){
            const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
            setWalletAddress(accounts[0]);
        }
    };

    const walletListener = () => {
        if(window.ethereum){
            window.ethereum.on('accountsChanged', (accounts) => {
              if (accounts.length > 0) {
                setWalletAddress(accounts[0]);
              }else{
                setWalletAddress("");
              }
            });
          }
    }

    const refreshMarket = async () => {




    function List(){
        MarketContract.plceOrder(walletAddress,id,price);
        console.log("List",id,price);

    }

    function getList(){
        console.log("OrderList:");
        MarketContract.getAllOrders();
    }





    return(
        <div>
            <h1>Market</h1>
            <button onClick={connectWallet}>Connect Wallet</button>
            <label htmlFor="id">Id *</label>
            <input 
             type="uint" 
             id="id" 
             placeholder="Enter id" 
             value={id} 
             onChange={(e) => setid(e.target.valueAsNumber)}
             required 
             />

             <label htmlFor="price">Price *</label>
             <input
             type="uint"
             id="price"
             placeholder="Enter price"
             value={price}
             onChange={(e) => setprice((e.target.valueAsNumber))}
             required
             />
        
            <button onClick={List}>List</button>
            <button onClick={getList}>Get List</button>


        </div>
    )

    }
}