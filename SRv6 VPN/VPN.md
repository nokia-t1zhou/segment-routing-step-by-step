# Linux SRv6实现VPN+流量工程

使2台仅支持IPv4的主机（主机a和主机b），通过SRv6实现VPN互通，并实现流量工程。

## 网络拓扑图如下：
![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/SRv6%20VPN/network.jpg)

图中路由器R1、R2、R3和R4为支持SRv6的路由器，通过配置静态路由，路由器与路由器之间仅通过IPv6实现互通。

在这个例子中，我们的目的是让主机a(30.30.30.1)与主机b(20.20.20.1)实现IPv4互通，并让icmp request经由R2路由器，icmp reply经由R3路由器，从而实现VPN及流量工程。

icmp数据包如下图所示
![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/SRv6%20VPN/path.png)

图中黄色区域是一个VPN区域，数据包进入区域后额外封装了IPv6包头，来实现VPN功能，蓝色箭头图标是主机a发出的icmp request所走的路径，红色箭头图标是主机b回复的icmp reply所走的路径。

## 配置
- 主机a
配置路由，发往主机b的数据包送到R1
```
ip addr add 30.30.30.1/24 dev ens34
ip route add 20.20.20.0/24 via 30.30.30.2
```
- 主机b
配置路由，发往主机a的数据包送到R4
```
ip addr add 20.20.20.1/24 dev ens34
ip r add 30.30.30.0/24 via 20.20.20.2
```
- R1

先在各个接口上配置IPv6地址，和主机a邻接的接口需要一个IPv4地址
```
ip addr add 30.30.30.2/24 dev ens36
ip addr add 2000:2001::1001/120 dev ens34
ip addr add 2000:2003::1001/120 dev ens35
ip addr add 3000::11/128 dev lo
```
增加一个策略路由表，应用到所有从30.30.30.1(主机a)发来的数据包。（这一步是为将来实现多路径VPN做准备，当前这个例子可以不用）
在策略路由表中增加T.Encaps操作(SRv6流量工程)，将去往20.20.20.0/24的数据包，封装入SRv6，并配置SRH包含的Segment列表（->3002::2->3000::4）
```
ip rule add from 30.30.30.1/32 table 100
ip route add 20.20.20.0/24 encap seg6 mode encap segs 3000::2,3000::4 dev ens34 table 100
```
这里的3000::2和3000::4是SRv6的segment，后面会在R2，R3和R4上定义。

同时在配置针对回程数据包的End.DX4操作，让去往主机a的数据包在R1做IPv6的解封装，解出IPv4数据包后发送给主机a
```
ip -6 route add 3000::1/128 encap seg6local action End.DX4 nh4 30.30.30.1 dev ens36
```
最后还有重要一步，需要配置一条普通的IPv6路由：
```
ip -6 route add 3000::2/128 via 2000:2001::1002
```
为什么需要这条路由呢？ 答案如下：经过T.Encaps操作的数据包的IPv6报文中的目的地址填的是segment list中的第一跳，并且这个报文会发回到本地路由表进行寻址操作，所以我们需要这么一条普通IPv6来将数据包送到R2. （请回顾上一章节的SRv6转发规则）

- R2

配置IP
```
ip addr add 2000:2001::1002/120 dev ens35
ip addr add 2000:2002::1002/120 dev ens34
ip addr add 3000::22/128 dev lo
```
配置End操作，以让R3在收到R1发来的数据包时，Segment Left减1，并更新IPv6 目的地址为当前Segment Left指定的Segment。
```
ip -6 route add 3000::2/128 encap seg6local action End dev ens34
ip -6 route add 3000::4 via 2000:2002::1004
```

- R4

配置IP
```
ip addr add 20.20.20.2/24 dev ens36
ip addr add 2000:2002::1004/120 dev ens35
ip addr add 2000:2004::1004/120 dev ens34
ip addr add 3000::44/128 dev lo
```

配置End.DX4操作，以让R4收到数据包之后能够做IPv6解封装，并转发给指定地址。
```
ip -6 route add 3000::4/128 encap seg6local action End.DX4 nh4 20.20.20.1 dev ens36
```

同时别忘了配置imcp reply的T.Encaps操作，对Ping回程IPv4数据包进行封装。
```
ip route add 30.30.30.0/24 encap seg6 mode encap segs 3000::3,3000::1 dev ens34
ip -6 route add 3000::3 via 2000:2004::1003
```

- R3

R3和R2类似，都是做为一个中转路由器存在
```
ip addr add 2000:2003::1003/120 dev ens35
ip addr add 2000:2004::1003/120 dev ens34
ip addr add 3000::33/128 dev lo
ip -6 route add 3000::3/128 encap seg6local action End dev ens35
ip -6 route add 3000::1/128 via 2000:2003::1001
```

## 验证

从主机a上发起ping，由于R1配置了策略路由，所以我们让发出去的icmp request使用30.30.30.1做为source地址。
![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/SRv6%20VPN/ping_cmd.jpg)
ping是成功的，我们再在路由器上用tcpdump抓包，看看每一跳的数据包是否和我们预期的一样。
