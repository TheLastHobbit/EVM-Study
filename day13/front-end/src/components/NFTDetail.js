import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { getMetadata } from '../utils/nft.js';
import { getOrder, buy} from '../utils/market.js';
import { getAllowance, approve } from '../utils/usdt.js';
import '../App.css';

const NFTDetail = () => {
  const { tokenId } = useParams();
  const [metadata, setMetadata] = useState('');
  const [order, setOrder] = useState('');
  const [allowance, setAllowance] = useState(0);
  
  const getWalletAddress = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        return accounts[0];
      } catch (error) {
        console.error('Error connecting to wallet:', error);
      }
    }
  };

  const handleBuyClick = async () => {
    if (allowance === 0) {
      await approve("0x9E545E3C0baAB3E08CdfD552C960A1050f373042", "10000000000000000000000");
    } else {
      await buy(tokenId);
    }
  };

  useEffect(() => {
    const getInfo = async () => {
      const address = await getWalletAddress();
      const metadata = await getMetadata(tokenId);
      const order = await getOrder(tokenId);
      const allowance = await getAllowance(address, "0x9E545E3C0baAB3E08CdfD552C960A1050f373042");
      // console.log('address', address)
      // console.log('allowance', allowance);
  
      setMetadata(metadata);
      setOrder(order);
      setAllowance(allowance);
    }
    getInfo();
  }, [allowance]);

  return (
    <div className="nft-detail">
      <div className="nft-image">
        <img src={metadata.imageURL} alt={metadata.title} />
      </div>
      <div className="nft-info">
        <h3>{metadata.title}</h3>
        <p>{metadata.description}</p>
        <p>Seller: {order.seller}</p>
        <p>Price: {order.price} USDT</p>
        <p>Token ID: {order.tokenId}</p>
        <button onClick={handleBuyClick}>Buy</button>
      </div>
    </div>
  );
}

export default NFTDetail;