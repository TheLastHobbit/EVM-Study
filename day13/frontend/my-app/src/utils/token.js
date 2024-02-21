import { ethers } from 'ethers';
import ABI from "../contracts/MyERC20.json";

let provider = new ethers.BrowserProvider(window.ethereum)
const contractAddress = "0x25bDeB03a8f9f02928Bf035730363eBdef9bdA31";
export const ERC20contract = new ethers.Contract(contractAddress, ABI, await provider.getSigner());


export async function ERC20approve(amount) {
  const result = await ERC20contract.approve("0xe6570e5A8499326Ce15E3F5641fD2B1FadE90A77", amount);
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

