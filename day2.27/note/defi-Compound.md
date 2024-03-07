#### defi三板斧-借贷协议（链上银行）



链上暂时无信贷

一般是超额借贷：

左边为抵押资产价值 > 右边为借出资产价值

![image-20240227150722646](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227150722646.png)



![image-20240227151003173](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227151003173.png)



#### how work

![image-20240227151549463](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227151549463.png)

interest:利息

##### lender：放贷人

![image-20240227152007179](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227152007179.png)

cDAI：仍然可以继续质押

##### borrower：借贷人

![image-20240227152512287](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227152512287.png)

利息是怎么算的？

10k怎么只能借6k?

##### 利息 calculate：

![image-20240227152712642](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227152712642.png)

reserves：保证金

UtilizationRate：资金利用率

上图函数拐角就是当资金利用率很高时，提高借贷利率来促使借贷人还款

- 链上的复利是以区块的来计算的
- 资金利用率越高，这个借贷协议越好：放贷100，能被借出90就很好了

不同的资金利用率，借贷利率不同：

资金利用率为0时，利率自然为0

![image-20240227153929612](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227153929612.png)

###### 复利

每次操作都会触发一次update

![image-20240227154036096](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227154036096.png)

计算利息代码：

以每个区块来计算复利

![image-20240227154255494](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227154255494.png)

![image-20240227154449701](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227154449701.png)

#### how to borrow

**Oracle Price**:资产评估价格，必须报价准确（预言机），报价时间要检验是否及时更新。

![image-20240227155021933](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227155021933.png)

#### how to Liquidation:清算

##### 超额抵押

用1000的资产借出800的ETH，这时的抵押率为125%，但借出后，ETH上涨5%，这时抵押率下降到120%以下，触发清算线，则用户损失1000-840 = 160.

![image-20240227155419244](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227155419244.png)



清算套利：清算所得一定收益是给清算人的：监控清算+闪电贷 



### 源码

CERC20

CToken



![image-20240227160853117](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240227160853117.png)





