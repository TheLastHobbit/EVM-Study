import { ConnectButton } from '@rainbow-me/rainbowkit';

const AccounHeader = () => {
  return <div>
     <ConnectButton accountStatus={{
        smallScreen: 'avatar',
        largeScreen: 'full',}} 
      />  
  </div>
}

export default AccounHeader