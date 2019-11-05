# Segment routing配置

在上面几个步骤中，我们已经搭建好了一个包含2个area的OSPF网络，下面来配置Segment routing。
![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/segment-routing-configure/1.png)

## SRGB -全局Segment配置

- 为了避免复杂度，我们在所有的router中统一SRGB

```bash
configure
segment-routing global-block 16000 23999
commit
```

- 配置完成后，可以查看到OSPF已经使用这个SRGB
```bash
RP/0/0/CPU0:ios#show mpls label table detail
Thu Oct 31 02:48:07.010 UTC
Table Label   Owner                           State  Rewrite
----- ------- ------------------------------- ------ -------
0     0       LSD(A)                          InUse  Yes
0     1       LSD(A)                          InUse  Yes
0     2       LSD(A)                          InUse  Yes
0     13      LSD(A)                          InUse  Yes
0     16000   OSPF(A):ospf-1                  InUse  No
  (Lbl-blk SRGB, vers:0, (start_label=16000, size=8000)
```

## 打开Segment routing

在每个router上执行

```bash
configure
router ospf 1
segment-routing mpls
segment-routing forwarding mpls
commit
```

## Prefix-SID配置
Prefix-SID是一个全局的segment，必须是全局范围内唯一标识，Cisco IOS要求使用loopback接口上的地址作为Prefix-SID，并且必须被显示配置。
我们先按照上面图中定义的prefix-SID来配置router 1。(在这里，loopback接口必须也加入OSPF area).

```bash
configure
router ospf 1
area 1
interface loopback 0
passive enable
prefix-sid absolute 16100
commit
```
我这里使用绝对值来指定prefix-sid（16100），但是如果在所有router上指定了相同的SRGB,那么也可以用index模式prefix-SID（100）。
配置完成后，我们看到OSPF已经使用type10的LSA向整个网络通告了router的Segment routing能力和Prefix-SID。
```bash
RP/0/0/CPU0:ios#show ospf database opaque-area 1.1.1.1/32
Tue Nov  5 07:32:31.169 UTC
            OSPF Router with ID (1.1.1.1) (Process ID 1)
                Type-10 Opaque Link Area Link States (Area 1)
  LS age: 1433
  Options: (No TOS-capability, DC)
  LS Type: Opaque Area Link
  Link State ID: 7.0.0.1
  Opaque Type: 7
  Opaque ID: 1
  Advertising Router: 1.1.1.1
  LS Seq Number: 80000003
  Checksum: 0xf937
  Length: 44

    Extended Prefix TLV: Length: 20
      Route-type: 1
      AF        : 0
      Flags     : 0x40
      Prefix    : 1.1.1.1/32

      SID sub-TLV: Length: 8
        Flags     : 0x0
        MTID      : 0
        Algo      : 0
        SID Index : 100
```

下面到router 2上打开Segment routing（别忘了分别在area 0和area 1中各自加入loopback，并且分别指定prefix-sid）
```bash
configure
router ospf 1
area 1
interface loopback 1
passive enable
prefix-sid absolute 16201
area 0
interface loopback 0
passive enable
prefix-sid absolute 16200
commit
```
通过查看OSPF database，发现在router 2上OSPF发送了2个10类的LSA(针对1.1.1.2/32)，看来prefix-sid是对所有area生效的。
```bash
RP/0/0/CPU0:ios#show ospf database opaque-area 1.1.1.2/32
Tue Nov  5 07:35:50.129 UTC
            OSPF Router with ID (1.1.1.2) (Process ID 1)
                Type-10 Opaque Link Area Link States (Area 0)
  LS age: 337
  Options: (No TOS-capability, DC)
  LS Type: Opaque Area Link
  Link State ID: 7.0.0.1
  Opaque Type: 7
  Opaque ID: 1
  Advertising Router: 1.1.1.2
  LS Seq Number: 8000000a
  Checksum: 0x269d
  Length: 44

    Extended Prefix TLV: Length: 20
      Route-type: 1
      AF        : 0
      Flags     : 0x40
      Prefix    : 1.1.1.2/32

      SID sub-TLV: Length: 8
        Flags     : 0x0
        MTID      : 0
        Algo      : 0
        SID Index : 200

                Type-10 Opaque Link Area Link States (Area 1)

  LS age: 1824
  Options: (No TOS-capability, DC)
  LS Type: Opaque Area Link
  Link State ID: 7.0.0.2
  Opaque Type: 7
  Opaque ID: 2
  Advertising Router: 1.1.1.2
  LS Seq Number: 80000003
  Checksum: 0x388f
  Length: 44

    Extended Prefix TLV: Length: 20
      Route-type: 3
      AF        : 0
      Flags     : 0x40
      Prefix    : 1.1.1.2/32

      SID sub-TLV: Length: 8
        Flags     : 0x0
        MTID      : 0
        Algo      : 0
        SID Index : 200
```

再来检查一下router 1是否收到了router 2的Segment routing通告
```bash
RP/0/0/CPU0:ios#show mpls forwarding labels 16100
Thu Oct 31 04:38:14.348 UTC
Local  Outgoing    Prefix             Outgoing     Next Hop        Bytes
Label  Label       or ID              Interface                    Switched
------ ----------- ------------------ ------------ --------------- ------------
16100  Pop         SR Pfx (idx 100)   Gi0/0/0/0    192.168.1.10    0

```
可以看到在router 2中，已经生成了Segment Routing的转发表， label 16100（router 1的prefix-sid）对应的接口是Gi0/0/0/0。

在router 1上，同样可以看到16200的转发表
```bash
RP/0/0/CPU0:ios#show mpls forwarding labels 16200 16201
Tue Nov  5 07:39:38.630 UTC
Local  Outgoing    Prefix             Outgoing     Next Hop        Bytes
Label  Label       or ID              Interface                    Switched
------ ----------- ------------------ ------------ --------------- ------------
16200  Pop         SR Pfx (idx 200)   Gi0/0/0/0    192.168.1.11    0
16201  Pop         SR Pfx (idx 201)   Gi0/0/0/0    192.168.1.11    0
```

下面，在剩余的router中分别打开SR和配置prefix-sid。

一切配置完成后，在router 5中可以看到SR的转发表：
```bash
RP/0/0/CPU0:ios#show mpls forwarding
Tue Nov  5 07:40:18.681 UTC
Local  Outgoing    Prefix             Outgoing     Next Hop        Bytes
Label  Label       or ID              Interface                    Switched
------ ----------- ------------------ ------------ --------------- ------------
16100  16100       SR Pfx (idx 100)   Gi0/0/0/1    192.168.10.11   1032
       16100       SR Pfx (idx 100)   Gi0/0/0/2    192.168.12.11   2472
16200  16200       SR Pfx (idx 200)   Gi0/0/0/1    192.168.10.11   0
       16200       SR Pfx (idx 200)   Gi0/0/0/2    192.168.12.11   0
16201  16201       SR Pfx (idx 201)   Gi0/0/0/1    192.168.10.11   0
       16201       SR Pfx (idx 201)   Gi0/0/0/2    192.168.12.11   0
16300  Pop         SR Pfx (idx 300)   Gi0/0/0/1    192.168.10.11   0
16400  Pop         SR Pfx (idx 400)   Gi0/0/0/2    192.168.12.11   0
24000  Pop         SR Adj (idx 0)     Gi0/0/0/1    192.168.10.11   0
24001  Pop         SR Adj (idx 0)     Gi0/0/0/1    192.168.10.11   0
24002  Pop         SR Adj (idx 0)     Gi0/0/0/2    192.168.12.11   0
24003  Pop         SR Adj (idx 0)     Gi0/0/0/2    192.168.12.11   0
```
2400x是OSPF自动分配的Adj-sid。
完美符合预期，基本的Segment Routing的配置完成，我们来测试一下,在router 1上“traceroute” router 5环回地址
```bash
RP/0/0/CPU0:ios#traceroute 1.1.1.5
Tue Nov  5 07:42:11.709 UTC

Type escape sequence to abort.
Tracing the route to 1.1.1.5

 1  192.168.1.11 [MPLS: Label 16500 Exp 0] 9 msec  0 msec  0 msec
 2  192.168.3.11 [MPLS: Label 16500 Exp 0] 19 msec  0 msec  0 msec
 3  192.168.10.10 0 msec  *  0 msec
 ```
 可以看到router 1发出去的ICMP包已经带上了mpls label，并且中间的router都对这个label做了switch动作。
 我们在router 1到router 2的路上抓个包看一下
 ![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/segment-routing-configure/2.png)

 ## 遗留问题
 到了这儿，我们已经搭建好了一个基础的Segment routing网络，依赖于OSPF来通告SR能力和标签。
 通过查询MPLS的forwarding表格，我们可以查到所有router的环回地址对应的MPLS的转发规则，但是查不到其他地址的转发规则，这是为什么呢？
```bash
RP/0/0/CPU0:ios#show mpls forwarding prefix 1.1.1.5/32
Tue Nov  5 07:50:46.544 UTC
Local  Outgoing    Prefix             Outgoing     Next Hop        Bytes
Label  Label       or ID              Interface                    Switched
------ ----------- ------------------ ------------ --------------- ------------
16500  16500       SR Pfx (idx 500)   Gi0/0/0/0    192.168.1.11    3752
RP/0/0/CPU0:ios#show mpls forwarding prefix 1.1.1.3/32
Tue Nov  5 07:50:57.163 UTC
Local  Outgoing    Prefix             Outgoing     Next Hop        Bytes
Label  Label       or ID              Interface                    Switched
------ ----------- ------------------ ------------ --------------- ------------
16300  16300       SR Pfx (idx 300)   Gi0/0/0/0    192.168.1.11    0
RP/0/0/CPU0:ios#show mpls forwarding prefix 192.168.100.10/32
Tue Nov  5 07:51:14.682 UTC
```
在下一章节中我们将解决这个问题。
