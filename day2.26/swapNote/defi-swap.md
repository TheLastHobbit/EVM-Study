Uniswap

![image-20240226143439965](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240226143439965.png)

![image-20240226144213004](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240226144213004.png)

用户接口：挂单，swap，add lip



#### defi三板斧-Swap

![image-20240226144419732](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240226144419732.png)



核心代码

![image-20240226150720194](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240226150720194.png)



![image-20240226150930865](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240226150930865.png)

createPair：

![image-20240226151143444](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240226151143444.png)

mint



##### TWAP

![image-20240226153052806](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240226153052806.png)



##### 闪电贷

![image-20240226153447427](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240226153447427.png)



![image-20240226154635414](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240226154635414.png)

### 作业

#### 理解源码

主要文件分为三个：

1. Router
2. Factory
3. Pair

##### 主要功能1：addLiquidity

源码基本逻辑在于 

1. 用户在Router文件调用addLiquidity方法，输入需要增加的交易对token地址

   ![image-20240228123554652](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240228123554652.png)

   可见此函数先调用了_addLiquidity方法，这里的第一个就是判断次交易对是否已经被创建了，若没创建则调用factory中createPair方法（2）

   ![image-20240228123706543](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240228123706543.png)

   下面的判断主要完成：

   >1. `if (reserveA == 0 && reserveB == 0) { (amountA, amountB) = (amountADesired, amountBDesired); }`: 如果储备量为零，说明这是对于这对代币的初始流动性添加，那么用户期望添加的数量就是实际添加的数量。
   >2. 如果储备量不为零，那么需要计算出最优的添加数量。这里使用 `OutswapV1Library.quote` 函数来根据用户期望添加的一种代币的数量，计算另一种代币应该添加的数量。
   >3. 如果计算出的最优数量小于等于用户期望添加的数量，那么使用这个最优数量作为实际添加的数量，否则，反过来计算。这样做是为了确保添加的流动性是用户期望的范围内的。

2. factory的createPair方法：以Pair文件创建交易对pair地址（使用create2预测pair合约地址），创建后将存入factory的pairmapping中，以防重复创建交易对。（create2和预测合约地址详见另外文章详解）。

   ![image-20240228123413096](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240228123413096.png)

3. 创建完交易对后，再调用pairFor方法获取对应交易对的地址

   ![image-20240228124555831](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240228124555831.png)

   这里又再次使用create2的另一种方法获取交易对地址：

   ![image-20240228124707680](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240228124707680.png)

4. 获取交易对地址后，向交易对里存token：

   ![image-20240228130242935](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240228130242935.png)

5. 最后mint相应的凭证给贡献者。

   ![image-20240228130340037](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240228130340037.png)

   







评讲：

![image-20240227145100709](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227145100709.png)

swap：

![image-20240227145322598](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227145322598.png)



token swap token，但给seller是eth，还要加上：

![image-20240227145801931](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227145801931.png)

思考，如果seller拒收eth怎么办？





学习OutRunSwap：

他们思路很清晰，首先将直接需要的文件整理出来，并更改version，在将他们所需依赖找出来，放在文件夹中统一使用，这些操作看似简单，但需要读懂源码。









