# OSPF环境搭建

我们选择通过IGP（OSPF）来在网络中分发Segment Routing能力，所以需要先搭建一个如下图所示的OSPF多area环境：

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/ospf-configure/network.jpg)

一共需要用到5个xrv router，构成2个OSPF area（backbone和area1）.

## GNS3 project install

按照上面的网络拓扑图在GNS3中搭建环境，设置好每个router的接口联接，启动这5个router（这一步需要耐心等待，router的初始化比较慢,如果你的电脑的物理内存比较小，可以修改router的内存需求，我这里给每个router分配的内存是2048M）

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/ospf-configure/1.png)

## OSPF配置

按照先前的网络规划在每个router上配置OSPF，配置命令参考这个文件：![Cisco XRV OPSF configuration](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/ospf-configure/ospf_configure.txt)

配置完成后，依次查看每个router上的OSPF配置和学到的路由：

- router 1
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
- router 2
```bash
RP/0/0/CPU0:ios#show protocols ospf
Wed Oct 30 07:46:41.084 UTC

Routing Protocol OSPF 1
  Router Id: 0.0.0.2
  Distance: 110
  Non-Stop Forwarding: Disabled
  Redistribution:
    None
  Area 0
    GigabitEthernet0/0/0/1
    GigabitEthernet0/0/0/2
  Area 1
    GigabitEthernet0/0/0/0
RP/0/0/CPU0:ios#show ip route ospf
Wed Oct 30 07:46:51.644 UTC

O    192.168.10.0/24 [110/2] via 192.168.3.11, 01:30:32, GigabitEthernet0/0/0/1
O    192.168.12.0/24 [110/2] via 192.168.4.11, 01:33:58, GigabitEthernet0/0/0/2
O    192.168.100.0/24 [110/3] via 192.168.4.11, 01:30:32, GigabitEthernet0/0/0/2
                      [110/3] via 192.168.3.11, 01:30:32, GigabitEthernet0/0/0/1
```
- router 3
```bash
RP/0/0/CPU0:ios#show protocols ospf
Wed Oct 30 07:47:46.160 UTC

Routing Protocol OSPF 1
  Router Id: 0.0.0.3
  Distance: 110
  Non-Stop Forwarding: Disabled
  Redistribution:
    None
  Area 0
    GigabitEthernet0/0/0/0
    GigabitEthernet0/0/0/1
RP/0/0/CPU0:ios#show ip route ospf
Wed Oct 30 07:47:50.110 UTC

O IA 192.168.1.0/24 [110/2] via 192.168.3.10, 00:32:43, GigabitEthernet0/0/0/0
O    192.168.4.0/24 [110/2] via 192.168.3.10, 01:31:31, GigabitEthernet0/0/0/0
O    192.168.12.0/24 [110/2] via 192.168.10.10, 01:31:31, GigabitEthernet0/0/0/1
O    192.168.100.0/24 [110/2] via 192.168.10.10, 01:31:31, GigabitEthernet0/0/0/1
```
- router 4
```bash
RP/0/0/CPU0:ios#show protocols ospf
Wed Oct 30 07:48:28.147 UTC

Routing Protocol OSPF 1
  Router Id: 0.0.0.4
  Distance: 110
  Non-Stop Forwarding: Disabled
  Redistribution:
    None
  Area 0
    GigabitEthernet0/0/0/0
    GigabitEthernet0/0/0/1
RP/0/0/CPU0:ios#show ip route ospf
Wed Oct 30 07:48:31.327 UTC

O IA 192.168.1.0/24 [110/2] via 192.168.4.10, 00:33:23, GigabitEthernet0/0/0/0
O    192.168.3.0/24 [110/2] via 192.168.4.10, 01:35:37, GigabitEthernet0/0/0/0
O    192.168.10.0/24 [110/2] via 192.168.12.10, 01:40:34, GigabitEthernet0/0/0/1
O    192.168.100.0/24 [110/2] via 192.168.12.10, 01:40:34, GigabitEthernet0/0/0/1
```
- router 5
```bash
RP/0/0/CPU0:ios#show protocols ospf
Wed Oct 30 07:48:59.817 UTC

Routing Protocol OSPF 1
  Router Id: 0.0.0.5
  Distance: 110
  Non-Stop Forwarding: Disabled
  Redistribution:
    None
  Area 0
    GigabitEthernet0/0/0/0
    GigabitEthernet0/0/0/1
    GigabitEthernet0/0/0/2
RP/0/0/CPU0:ios#show ip route ospf
Wed Oct 30 07:49:05.517 UTC

O IA 192.168.1.0/24 [110/3] via 192.168.12.11, 00:33:58, GigabitEthernet0/0/0/2
                    [110/3] via 192.168.10.11, 00:33:58, GigabitEthernet0/0/0/1
O    192.168.3.0/24 [110/2] via 192.168.10.11, 01:32:46, GigabitEthernet0/0/0/1
O    192.168.4.0/24 [110/2] via 192.168.12.11, 01:41:09, GigabitEthernet0/0/0/2
```
我们来验证一下，从router 1去访问router 5的*192.168.100.10*地址
```bash
RP/0/0/CPU0:ios#ping 192.168.100.10
Wed Oct 30 07:52:55.807 UTC
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 192.168.100.10, timeout is 2 seconds:
Success rate is 100 percent (5/5), round-trip min/avg/max = 1/5/9 ms
```
我们再来验证一下中间经过的router
```bash
RP/0/0/CPU0:ios#traceroute 192.168.100.12
Wed Oct 30 08:01:35.642 UTC

Type escape sequence to abort.
Tracing the route to 192.168.100.12

 1  192.168.1.11 0 msec  0 msec  0 msec
 2  192.168.3.11 0 msec  0 msec  0 msec
 3  192.168.10.10 0 msec  0 msec  0 msec
RP/0/0/CPU0:ios#traceroute 192.168.100.21
Wed Oct 30 08:01:40.851 UTC

Type escape sequence to abort.
Tracing the route to 192.168.100.21

 1  192.168.1.11 0 msec  0 msec  0 msec
 2  192.168.4.11 0 msec  0 msec  0 msec
 3  192.168.12.10 0 msec  0 msec  0 msec
```
可以看出，根据目的地址的不同，router 2选择了不同的路径，这是符合我们设计初衷的