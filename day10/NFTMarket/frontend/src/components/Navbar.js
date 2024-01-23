import { Link } from 'react-router-dom';

const Navbar = ({ onConnectWallet, walletAddress }) => {
  return (
    <nav className="navbar">
      <div className="navbar-brand">NFT Marketplace</div>
      <Link to="/">Home</Link>
      <Link to="/create-nft">Create NFT</Link>
      <div className="navbar-menu">
        <button className="connect-wallet-button" onClick={onConnectWallet}>
          {walletAddress.slice(0,6) || "Connect Wallet"}
        </button>
      </div>
    </nav>
  );
};

export default Navbar;
