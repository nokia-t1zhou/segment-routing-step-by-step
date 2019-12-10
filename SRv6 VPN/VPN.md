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


## 验证


