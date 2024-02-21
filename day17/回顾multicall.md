##### 回顾multicall

![image-20240131144620780](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240131144620780.png)

![image-20240131145103477](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240131145103477.png)

##### gas技巧

![image-20240131145733984](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240131145733984.png)

数组开销太大，而mapping无论多少gas都不变，但mapping不能遍历。

所以我们需要链表：

![image-20240131152423777](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240131152423777.png)

![image-20240131152453268](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240131152453268.png)

##### 白名单实现

链下生成默克尔树

![image-20240131155523750](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240131155523750.png)

链上验证

![image-20240131155556524](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240131155556524.png)

![image-20240131155414937](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20240131155414937.png)