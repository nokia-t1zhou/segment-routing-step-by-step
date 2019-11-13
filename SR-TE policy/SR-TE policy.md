# SR-TE policy

SR其中一个关键功能是SR-TE。SR-TE将用户的意图（延迟、不相交路径、SRLG、带宽等）转换为Segment列表（每个Segment代表特定的操作，Segment列表是指这些Segment的有序列表），然后将Segment列表编程到单域/跨域网络的边缘设备上，同时引导流量至Segment列表所对应的路径上，从而实现“基于意图的网络(IBN)”，完成传统网络向下一代网络平台的演进。
对于简单的SR-TE功能，基于隧道接口体系实现起来比较简单，在SR-TE的导入期，能满足大多数用户的需要。其引流方式也沿用RSVP-TE的方式，用户也比较习惯。

但是，也正是由于隧道接口体系继承了RSVP-TE的实现，使得这种体系下的SR-TE实现存在着明显不足：

- 隧道接口和引流两者是分开实现的，引流方式往往非常麻烦且造成性能损失；
- 往往需要预先配置隧道，在无法明确隧道终点的情况下，只能是部署全网状的隧道，造成可扩展性问题；
- 绝大多数厂商在沿用隧道接口体系的同时，也沿用了RSVP-TE的电路算法[2]，表现为只能用Adj-SID编码路径，而无法使用Prefix-SID编码路径，导致无法利用IP ECMP的能力，并且造成Segment列表长度过长，容易超出一些低端设备的支持能力；
- 隧道与路径一对一的关系，因此要配置多个隧道接口用于实现在多条路径上的（等价/不等价）负载均衡，配置繁琐且影响扩展性；
- 隧道接口占用了设备上的逻辑资源，使得设备能支持的SR-TE数量有限
- 不支持一些新的SR功能例如灵活算法（Flex-Algo）、性能测量（Performance Measurement）等

SR Policy完全抛弃了隧道接口的概念，是重新设计的一套SR-TE体系。

SR Policy通过解决方案Segment列表来实现流量工程意图。Segment列表对数据包在网络中的任意转发路径进行编码。列表中的Segment可以是任何类型：IGP Segment、IGP Flex-Algo Segment、BGP Segment等。

SR Policy由以下三元组标识：

- 头端（Headend）：SR Policy生成/实现的地方；
- 颜色（Color）：是任意的32位数值，用于区分同一头端和端点对之间的多条SR Policy；
- 端点（Endpoint）：SR Policy的终结点，是一个IPv4/IPv6地址。

关于SR Policy的细节，可以参考[SR Policy](https://www.sdnlab.com/23509.html)

![none](https://img1.sdnlab.com/wp-content/uploads/2019/09/SR-policy-3.png)

## 配置SR-TE Policy

我们目前使用的IOS image还不支持SR Policy，所以这儿只能用SR-TE policy来做segment router traffic引流实验。
在前面的步骤中，我们已经搭建好了一个Segment Routing的网络，从router 1到router 5有2条路径，所以在这一步走，我们来创建2个SR-TE policy分别代表这2条路径。

- router 2 配置


