![image-20240121152249156](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240121152249156.png)



##### 启动本地的一个测试网节点：

anvil --fork-url https://polygon-rpc.com

将合约部署在测试网上：

>forge create --rpc-url <your_rpc_url> --private-key <your_private_key> src/MyContract.sol:MyContract

[forge create - Foundry 中文文档 (learnblockchain.cn)](https://learnblockchain.cn/docs/foundry/i18n/zh/reference/forge/forge-create.html)

使用 `--constructor-args` 标志将参数传递给构造函数：

注意：`--constructor-args` 标志必须在命令中放在**最后**，因为它需要多个值。

注意：部署合约不要开梯子

要使用以下本地账户记得将网络切换为：

![image-20240120153928569](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240120153928569.png)

>##### Available Accounts
>
>(0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000.000000000000000000 ETH)
>(1) 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000.000000000000000000 ETH)
>......
>
>###### Private Keys
>
>(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
>(1) 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
>....

