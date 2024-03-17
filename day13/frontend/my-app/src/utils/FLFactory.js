import { ethers } from 'ethers';
import ABI from '../contracts/FLFactory.json';

let provider = new ethers.BrowserProvider(window.ethereum)
const contractAddress = "0x4FCe758EceE5aA7Fda5b1A04356Dbfa265061BE3";
const contract = new ethers.Contract(contractAddress, ABI, await provider.getSigner());

export async function deployMing(name,symbol,totalSupply,perMint) {
    await contract.deployInscription(name,symbol,totalSupply,perMint);
    
}