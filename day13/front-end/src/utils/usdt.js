import { ethers } from 'ethers';
import ABI from "../contracts/MyERC20.json";

let provider = new ethers.BrowserProvider(window.ethereum)
const contractAddress = "0xD86bc69b52508368622E4F9f8f70a603FFbFC89C";
export const ERC20contract = new ethers.Contract(contractAddress, ABI, await provider.getSigner());


export async function ERC20approve(amount) {
  const result = await ERC20contract.approve("0xe5AF54AA3f81E0cc23d7EBEe959570bdbF8eD598", amount);
  console.log(result.hash);
}

export async function getBalance(account) {
  const result = await ERC20contract.balanceOf(account);
  return result;
}

export async function ERC20transfer(account) {
  const bool =  await ERC20contract.transfer(account,100000);
  console.log("Transfer success?",bool);
  return bool;
}

export async function getAllowance(owner) {
  const result = await ERC20contract.allowance(owner, "0xe5AF54AA3f81E0cc23d7EBEe959570bdbF8eD598");
  return Number(result);
}

