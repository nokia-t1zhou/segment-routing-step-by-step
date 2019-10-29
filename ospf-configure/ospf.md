# OSPF环境搭建

我们选择通过IGP（OSPF）来在网络中分发Segment Routing能力，所以需要先搭建一个如下图所示的OSPF多area环境：

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/ospf-configure/network.jpg)

一共需要用到6个xrv router，构成2个OSPF area（backbone和area1）.

## GNS3 project install

