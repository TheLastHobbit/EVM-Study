import { useEffect, useState } from 'react'
import { NetworkPlugin, ethers } from 'ethers';
import aggregatorV3Abi from "../../contracts/aggregatorV3Interface.json"
import { Link } from 'react-router-dom'
import { Card, Space, Button } from 'antd';
function Home() {
    const [ETHPrice, setETHPrice] = useState(0);

    useEffect(() => {
        getETHPrice();
    }, []);

    function getETHPrice() {
        const provider = new ethers.JsonRpcProvider("https://rpc.ankr.com/eth_sepolia");
        const addr = "0x694AA1769357215DE4FAC081bf1f309aDC325306"
        const priceFeed = new ethers.Contract(addr, aggregatorV3Abi, provider);
        priceFeed.latestRoundData().then((roundData) => {
            // Do something with roundData
            console.log("Latest Round Data", roundData);

            setETHPrice(ethers.formatUnits(roundData[1], 8));
        })
    }

    return (
        <>
            <div>
                <h1>Home</h1>
                <h1>ETH/USD:{ETHPrice}</h1>
                <Link to="/market">
                    <Button className="market-button" size="large" ghost type="primary">
                        Market
                    </Button>
                </Link>

               
            </div>
        </>
    )
}

export default Home
