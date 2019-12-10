# Linux SRv6实现VPN+流量工程

使2台仅支持IPv4的主机（主机a和主机b），通过SRv6实现VPN互通，并实现流量工程。

## 网络拓扑图如下：
![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/SRv6%20VPN/network.jpg)

图中路由器R1、R2、R3和R4为支持SRv6的路由器，通过配置静态路由，路由器与路由器之间仅通过IPv6实现互通。

在这个例子中，我们的目的是让主机a与主机b实现IPv4互通，并让icmp request经由R2路由器，icmp reply经由R3路由器，从而实现VPN及流量工程。

icmp数据包如下图所示
![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/SRv6%20VPN/path.png)

图中黄色区域是一个VPN区域，数据包中区域中额外封装了IPv6包头，来实现VPN功能，蓝色箭头图标是主机a发出的icmp request所走的路径，红色箭头图标是主机b回复的icmp reply所走的路径。