import { ethers } from 'ethers';

export async function signNFT(wallet, price, id) {
    // 创建 EIP712 Domain
    let contractName = "MarketV2"
    let version = "1"
    let chainId = "137"
    let contractAddress = "0xe6570e5A8499326Ce15E3F5641fD2B1FadE90A77"
    const domain = {
        name: contractName,
        version: version,
        chainId: chainId,
        verifyingContract: contractAddress,
    };
    const types = {
        Storage: [
            { name: "owner", type: "address" },
            { name: "price", type: "uint256" },
            { name: "id", type: "uint256" },
        ],
    };
    const message = {
        owner: wallet.address,
        price: price,
        id: id
    };
    console.log(message);
    const signature = await wallet.signTypedData(domain, types, message);
    console.log("Signature:", signature);
    return signature;
}

export async function signToken(wallet, spender, value) {
    // 创建 EIP712 Domain
    let contractName = "ERC2612"
    let version = "1"
    let chainId = "137"
    let contractAddress = "0x97df52b63a4E506fB5d7E2bb231aF552c02b5fa1"
    const domain = {
        name: contractName,
        version: version,
        chainId: chainId,
        verifyingContract: contractAddress,
    };
    const tokenAbi = ["function nonces(address owner) view returns (uint256)"];
    let tokenContract;
    let nonce;
    tokenContract = new ethers.Contract("0x97df52b63a4E506fB5d7E2bb231aF552c02b5fa1", tokenAbi, wallet);
    nonce = await tokenContract.nonces(wallet.address);
    const types = {
        Permit: [
            { name: "owner", type: "address" },
            { name: "spender", type: "address" },
            { name: "value", type: "uint256" },
            { name: "nonce", type: "uint256" },
            { name: "deadline", type: "uint256" }
        ],
    };
    const message = {
        owner: wallet.address,
        spender: spender,
        value: value,
        nonce: nonce,
        deadline: Date.now() + 24 * 60 * 60 * 1000,
    };
    console.log(message);
    console.log("wallet",wallet);
    const signature = await wallet.signTypedData(domain, types, message);
    console.log("Signature:", signature);
    const signatureResult = ethers.Signature.from(signature);
    console.log("v: ", signatureResult.v);
    console.log("r: ", signatureResult.r);
    console.log("s: ", signatureResult.s);
    let result = [];
    result.push(signatureResult.v);
    result.push(signatureResult.r);
    result.push(signatureResult.s);
    console.log("result: ", result);
    return result;
}

