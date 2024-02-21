import { ethers } from 'ethers';
import ABI from '../contracts/MyNFT.json';

let provider = new ethers.BrowserProvider(window.ethereum)
const contractAddress = "0xEAEa45b8078f9fcA46DFb42b16016c8C234F7ff3";
const contract = new ethers.Contract(contractAddress, ABI, await provider.getSigner());


export async function NFTApprove(_id) {
    await contract.approve("0xe5AF54AA3f81E0cc23d7EBEe959570bdbF8eD598", _id);
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

export async function mint(to,uri) {
    await contract.safeMint(to,uri);
}



export async function tokenOfOwnerByIndex(owner, index) {
    const result = await contract.tokenOfOwnerByIndex(owner, index);
    return Number(result);
}

export async function tokenURI(tokenId) {
    const result = await contract.tokenURI(tokenId);
    console.log(result);
}
