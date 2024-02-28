create2 :

在 Ethereum 上，创建合约的过程中实际上是在执行 `CREATE` 或 `CREATE2` 操作，这会触发新合约的部署。合约部署后，其地址就确定下来，而且可以使用该地址与合约进行交互。所以，在执行完 `createPair` 函数后，`pair` 变量中包含了新创建交易对合约的地址。

部署

![image-20240228142352961](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240228142352961.png)



获取address。

https://www.wtf.academy/docs/solidity-102/Create2/

![image-20240228142448208](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240228142448208.png)