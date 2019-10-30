# OSPF环境搭建

我们选择通过IGP（OSPF）来在网络中分发Segment Routing能力，所以需要先搭建一个如下图所示的OSPF多area环境：

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/ospf-configure/network.jpg)

一共需要用到5个xrv router，构成2个OSPF area（backbone和area1）.

## GNS3 project install

按照上面的网络拓扑图在GNS3中搭建环境，设置好每个router的接口联接，启动这5个router（这一步需要耐心等待，router的初始化比较慢,如果你的电脑的物理内存比较小，可以修改router的内存需求，我这里给每个router分配的内存是2048M）

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/ospf-configure/1.png)


![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/ospf-configure/ospf_configure.txt)