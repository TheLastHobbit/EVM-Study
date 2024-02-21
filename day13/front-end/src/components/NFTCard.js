import { useEffect, useState } from 'react';
import { getMetadata } from '../utils/nft.js';
import { getOrder} from '../utils/market.js';
import '../App.css';

const NFTCard = ({tokenId, onClick}) => {
  // console.log(tokenId)
  const [metadata, setMetadata] = useState('');
  const [order, setOrder] = useState('');

  useEffect(() => {
    const getInfo = async () => {
      const metadata = await getMetadata(tokenId);
      const order = await getOrder(tokenId);

      console.log("metadata.imag:",metadata.imageURL);
      console.log("metadata.title:",metadata.title);
  
      setMetadata(metadata);
      setOrder(order);
    }
    getInfo();
  }, []);

  return (
    <div className="nft-card" onClick={onClick}>
      <div className="nft-image">
        <img src={metadata.imageURL} alt={metadata.title} />
      </div>
      <div className="nft-info">
        <h3>{metadata.title}</h3>
        <p>Price: {order.price} USDT</p>
      </div>
    </div>
  );
};

export default NFTCard;
