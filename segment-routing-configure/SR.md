# Segment routing配置

在上面几个步骤中，我们已经搭建好了一个包含2个area的OSPF网络，下面来配置Segment routing。
![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/segment-routing-configure/1.png)

## SRGB -全局Segment配置

为了避免复杂度，我们在所有的router中统一SRGB

```bash
configure
segment-routing global-block 16000 23999
commit
```

配置完成后，可以查看到OSPF已经使用这个SRGB
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
commit
```

## Prefix-SID配置
Prefix-SID是一个全局的segment，必须是全局范围内唯一标识，Cisco IOS要求使用loopback接口上的地址作为Prefix-SID，并且必须被显示配置。
我们先按照上面图中定义的prefix-SID来配置router 1。

```bash
configure
router ospf 1
area 1
interface loopback 0
passive enable
prefix-sid index 100
commit
```

因为我们已经在所有router上指定了相同的SRGB,所以这里用index模式prefix-SID。
配置完成后，我们看到OSPF已经使用type10的LSA向整个网络通告了router的Segment routing能力和Prefix-SID。
```bash
RP/0/0/CPU0:ios#show ospf database opaque-area 1.1.1.1/32
Thu Oct 31 03:55:01.665 UTC
            OSPF Router with ID (1.1.1.1) (Process ID 1)
                Type-10 Opaque Link Area Link States (Area 1)
  LS age: 1020
  Options: (No TOS-capability, DC)
  LS Type: Opaque Area Link
  Link State ID: 7.0.0.1
  Opaque Type: 7
  Opaque ID: 1
  Advertising Router: 1.1.1.1
  LS Seq Number: 80000001
  Checksum: 0xfd35
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
