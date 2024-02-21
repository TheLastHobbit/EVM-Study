![image-20240121152249156](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240121152249156.png)

forge test --match-path test/market_t.sol -vvvvvv 

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

