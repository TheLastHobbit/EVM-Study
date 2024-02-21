import { ethers } from 'ethers';
import ABI from '../contracts/MyNFT.json';

let provider = new ethers.BrowserProvider(window.ethereum)
const contractAddress = "0x4FCe758EceE5aA7Fda5b1A04356Dbfa265061BE3";
const contract = new ethers.Contract(contractAddress, ABI, await provider.getSigner());

export async function isApprovedForall() {
     const bool = await contract.isApprovedForAll("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266","0xe6570e5A8499326Ce15E3F5641fD2B1FadE90A77");
     return bool;
}


export async function setApproveForAll(address) {
    await contract.setApprovalForAll(address, true);
}

export async function NFTApprove(_id) {
    await contract.approve("0xC7B8506F810Ff6ab16d1Ad1503d39783Bd0f55df",_id);
}

export async function OwnerOf(_id) {
    const owner = await contract.ownerOf(_id);
    console.log(owner);
    return owner;

}

export async function balanceOf(address) {
    const result = await contract.balanceOf(address);
    console.log(result);
    return Number(result);
}

export async function mint(to) {
    await contract.safeMint(to,"1");
}



export async function tokenOfOwnerByIndex(owner, index) {
    const result = await contract.tokenOfOwnerByIndex(owner, index);
    return Number(result);
}

export async function tokenURI(tokenId) {
    const result = await contract.tokenURI(tokenId);
    console.log(result);
}
