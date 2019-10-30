# OSPF环境搭建

我们选择通过IGP（OSPF）来在网络中分发Segment Routing能力，所以需要先搭建一个如下图所示的OSPF多area环境：

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/ospf-configure/network.jpg)

一共需要用到5个xrv router，构成2个OSPF area（backbone和area1）.

## GNS3 project install

按照上面的网络拓扑图在GNS3中搭建环境，设置好每个router的接口联接，启动这5个router（这一步需要耐心等待，router的初始化比较慢,如果你的电脑的物理内存比较小，可以修改router的内存需求，我这里给每个router分配的内存是2048M）

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/ospf-configure/1.png)


按照先前的网络规划在每个router上配置OSPF，配置命令参考这个文件：![Cisco XRV OPSF configuration](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/ospf-configure/ospf_configure.txt)

配置完成后，依次查看每个router上的OSPF配置和学到的路由：

-- router 1
```bash 
RP/0/0/CPU0:ios#show protocols ospf
Wed Oct 30 07:31:48.494 UTC

Routing Protocol OSPF 1
  Router Id: 0.0.0.1
  Distance: 110
  Non-Stop Forwarding: Disabled
  Redistribution:
    None
  Area 1
    GigabitEthernet0/0/0/0
RP/0/0/CPU0:ios#show ip route ospf
Wed Oct 30 07:31:50.204 UTC

O IA 192.168.3.0/24 [110/2] via 192.168.1.11, 00:16:34, GigabitEthernet0/0/0/0
O IA 192.168.4.0/24 [110/2] via 192.168.1.11, 00:16:34, GigabitEthernet0/0/0/0
O IA 192.168.10.0/24 [110/3] via 192.168.1.11, 00:16:34, GigabitEthernet0/0/0/0
O IA 192.168.12.0/24 [110/3] via 192.168.1.11, 00:16:34, GigabitEthernet0/0/0/0
O IA 192.168.100.0/24 [110/4] via 192.168.1.11, 00:16:34, GigabitEthernet0/0/0/0


```
