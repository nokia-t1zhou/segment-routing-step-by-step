# 配置prefix mapping server

什么是prefix mapping server，我们来看一下cisco的解释
```text
The mapping server is a key component of the interworking between LDP and segment routing. It enables SR-capable nodes to interwork with LDP nodes. The mapping server advertises Prefix-to-SID mappings in IGP on behalf of other non-SR-capable nodes.
The mapping server functionality in Cisco IOS XR segment routing centrally assigns prefix-SIDs for some or all of the known prefixes. A router must be able to act as a mapping server, a mapping client, or both.
A router that acts as a mapping server allows the user to configure SID mapping entries to specify the prefix-SIDs for some or all prefixes. This creates the local SID-mapping policy. The local SID-mapping policy contains non-overlapping SID-mapping entries. The mapping server advertises the local SID-mapping policy to the mapping clients.
A router that acts as a mapping client receives and parses remotely received SIDs from the mapping server to create remote SID-mapping entries.
A router that acts as a mapping server and mapping client uses the remotely learnt and locally configured mapping entries to construct the non-overlapping consistent active mapping policy. IGP instance uses the active mapping policy to calculate the prefix-SIDs of some or all prefixes.
The mapping server automatically manages the insertions and deletions of mapping entries to always yield an active mapping policy that contains non-overlapping consistent SID-mapping entries.
Locally configured mapping entries must not overlap each other.
The mapping server takes the locally configured mapping policy, as well as remotely learned mapping entries from a particular IGP instance, as input, and selects a single mapping entry among overlapping mapping entries according to the preference rules for that IGP instance. The result is an active mapping policy that consists of non-overlapping consistent mapping entries.
At steady state, all routers, at least in the same area or level, must have identical active mapping policies.
```
总结下来就几点：
- 在OSPF中声明的SR能力是针对loopback口，prefix-sid也是配置在lookback口上，对于router上的其它接口地址，并没有在area中声明，这时候就需要启动prefix mapping server来在OSPF各个area中发布IP地址（prefix）和segment（label）的一个mapping list。
- 每个router默认都是一个prefix mapping client，会接收server发布的prefix mapping list，并安装到FIB（路由转发表）中
- area中可以配置多个server，我们这儿只配置一个（不考虑冗余）
- prefix mapping server也可以声明非SR能力的router上的prefix，来达到SR->LDP的流量转发

## 配置命令
我们选定router 5做为prefix mapping server。
- 先配置prefix mapping list，在这里我们为192.168.100.0/24指定了segment 510(这里必需填相对index，最后得出的segment=SRGB+index = 16510)，范围是30（192.168.100.0/24=16510，192.168.101.0/24=16511,依此类推，一共30个segment）
```bash
configure
segment-routing
mapping-server prefix-sid-map address-family ipv4
192.168.100.0/24 510 range 30
commit
```

- 打开prefix mapping server的发布功能
```bash
configure
router ospf 1
segment-routing prefix-sid-map advertise-local
commit
```

- 到router 1上查看是否已经学到了这个segment
```bash
RP/0/0/CPU0:ios#show mpls forwarding prefix 192.168.100.0/24
Wed Nov  6 02:53:03.243 UTC
Local  Outgoing    Prefix             Outgoing     Next Hop        Bytes
Label  Label       or ID              Interface                    Switched
------ ----------- ------------------ ------------ --------------- ------------
16510  16510       SR Pfx (idx 510)   Gi0/0/0/0    192.168.1.11    0

RP/0/0/CPU0:ios#show ospf segment-routing prefix-sid-map active-policy
Wed Nov  6 03:06:45.837 UTC

        SRMS active policy for Process ID 1

Prefix               SID Index    Range        Flags
192.168.100.0/24     510          30

Number of mapping entries: 1
```
- 可以看到16510已经存在router 1的mpls转发表中，再来traceroute一下
```bash
RP/0/0/CPU0:ios#traceroute 192.168.100.10
Wed Nov  6 02:53:26.912 UTC

Type escape sequence to abort.
Tracing the route to 192.168.100.10

 1  192.168.1.11 [MPLS: Label 16510 Exp 0] 89 msec  9 msec  0 msec
 2  192.168.3.11 [MPLS: Label 16510 Exp 0] 9 msec  0 msec  9 msec
 3  192.168.10.10 0 msec  *  19 msec
```
- 在router 1和router 2中间抓包，确认router 1发出的icmp包已经带了mpls报文
![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/prefix_mapping_server/1.png)

至此，计划中的segment routing网络已经准备完成，下面章节我们来使用它

### 到这一步骤的所有router的配置
![router configuration list](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/prefix_mapping_server/router%20configure.txt)
