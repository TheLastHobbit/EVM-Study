import React from 'react'
import ReactDOM from 'react-dom/client'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { WagmiProvider } from 'wagmi'
import { mainnet, sepolia} from 'wagmi/chains'; 
import { getDefaultConfig, RainbowKitProvider } from '@rainbow-me/rainbowkit';
import App from './App.jsx'
import './index.css'
import '@rainbow-me/rainbowkit/styles.css';

const mylocalhost = {
  id: 137,
  name: 'forkPolygon',
  nativeCurrency: { name: 'tETH', symbol: 'tETH', decimals: 18 },
  rpcUrls: {
    default: {
      http: ['http://127.0.0.1:8545'],
    },
  },
  testnet: true,
}
// const myLocalhost = {
//   ...localhost,
//  id: 137, 
// }

const config = getDefaultConfig({
  chains: [mylocalhost, mainnet, sepolia],
  appName: "NFT-market",
  projectId: "6211caeb5ac9b0d369664cb674c64d73",
});

const queryClient = new QueryClient();

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
            <App />
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  </React.StrictMode>,
)