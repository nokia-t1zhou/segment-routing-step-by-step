# SRv6简介

Segment Routing（以下简称SR）指由思科发明，并主要由IETF SPRING（Source Packet Routing In Networking）工作组进行标准化的新一代网络传送技术。SR基于源路由并且只在网络边缘维持状态，这使得SR非常适合于超大规模SDN部署，在极大简化网络的同时，SR也为网络提供了高度的可编程能力以及端到端的流量工程能力。因此在出现仅短短五年后，SR已经成为业界共识，是新一代网络尤其是5G网络的事实SDN架构标准。

SR数据平面有两种实现方式，一种是SR MPLS，重用了MPLS数据平面；另一种是SRv6，使用IPv6数据平面。SR架构可以运行在这两种数据平面上，这是自SR提出第一天起就确立的原则。

SRv6采用IPv6标准中定义的路由扩展报头(Routing Extension Header)承载新定义的SRH（Segment Routing Header）扩展路由报头，SRH类型号定义为4。在SRH中包含了Segment列表。SRv6 Segment形式上是一个128位的IPv6的地址，但其实此Segment由Locator(定位器)和Function(指令)构成(还可以含有”参数”信息, 本文先略过)，Locator用于IPv6路由，Function用于指定节点需要对数据包施加的各种SRv6操作，实现网络的可编程性。

和SR MPLS不一样，在数据包的转发过程中SRv6通常不会弹出Segment，而是通过SRH中的Segment Left(剩余Segment，是个不小于0 的数值)字段作为指针，指向活动Segment，类似于SR MPLS中的顶层标签。每经过一个SRv6端节点，Segment Left减1，更新IPv6报头的目的地址为Segment 列表中当前Segment Left对应的Segment，并遵循常规的IPv6路由把数据包转发出去。

需要强调的是， 如果网络中有节点只支持常规的IPv6而不支持SRv6，当此节点收到SRv6数据包时, 按照IPv6 RFC的规定，由于数据包目的地址不是节点自身网段地址, 此节点不处理扩展报头，而只是单纯地根据数据包目的地址进行IPv6转发。这意味着，SRv6可以与现有的IPv6网络无缝互操作，换句话说，SRv6可以在IPv6网络上实现增量部署，无须替换现网所有设备。

## SRv6扩展报文（SRH）

为了在IPv6报文中实现SRv6转发，引入了一个SRv6扩展头（Routing Type为4），叫Segment Routing Header（SRH），用于进行Segment的编程组合形成SRv6路径。
下图是SRv6的报文封装格式。

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/SRv6%20introduction/ipv6_header.png)
![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/SRv6%20introduction/SRH_1.png)

IPv6 Next Header字段取值为43，表示后接的是IPv6路由扩展头。Routing Type = 4，表明这是SRH的路由扩展头，这个扩展头里字段解释如下：

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/SRv6%20introduction/SRH_fileds.JPG)

# SRv6操作
目前linux（内核大于4.14）支持的SRv6功能如下：
- End: regular SRH processing
- End.X nh6 <nexthop>: regular SRH processing and forward the resulting packet to the specified nexthop
- End.T table <table>: regular SRH processing and forward to the next-hop looked up in the specified routing table
- End.DX2 oif <interface>: decapsulate an L2 frame and forward it to the specified interface
- End.DX6 nh6 <nexthop>: if the local node is the last segment, or if no SRH is present, then decapsulate the inner IPv6 packet and forward it to the specified nexthop. If the parameter is set to ::, then the nexthop is selected according to the local route lookup process.
- End.DX4 nh4 <nexthop>: same as above, except that the inner payload is an IPv4 packet, and the nexthop is of the IPv4 family.
- End.DT6 table <table>: decapsulate an IPv6 packet and forward it to the next-hop looked up in the specified routing table.
- End.B6 srh segs <segments> [hmac <keyid>]: insert the specified SRH immediately after the outermost IPv6 header. The original SRH is not modified. The destination address of the packet is set to the first segment of the newly inserted SRH and the packet is forwarded accordingly.
- End.B6.Encaps srh segs <segments> [hmac <keyid>]: advance the packet to the next segment (decrement the segments left value and update the DA accordingly), then encapsulate the resulting packet within an outer IPv6 header containing the specified SRH. The DA of the outer IPv6 header is set to the first segment of the specified SRH. The packet is then forwarded accordingly.

# 一个简单的SRv6转发流程
![none]()
上图展示了SRv6转发的一个范例。在这个范例中，结点R1要指定路径（需要通过R2-R3、R4-R5的链路转发）转发到R6，其中R1、R2、R4、R6为有SRv6能力的的设备，R3、R5为不支持SRv6的设备。

- Ingress结点处理：R1将SRv6路径信息封装在SRH扩展头，指定R2和R4的END.X SID，同时初始化SL = 2，并将SL指示的SID A2::11拷贝到外层IPv6头目的地址。R1根据外层IPv6目的地址查路由表转发到R2。
- End Point结点处理：R2收到报文以后，根据外层IPv6地址A2::11查找本地Local SID表，命中END.X SID，执行END.X SID的指令动作：SL—，并将SL指示的SID拷贝到外层IPv6头目的地址，同时根据END.X关联的下一跳转发。
- Transit结点处理：R3根据A4::13查IPv6路由表进行转发，不处理SRH扩展头。具备普通的IPv6转发能力即可。
- End Point结点处理：R4收到报文以后，根据外层IPv6地址A4::13查找本地Local SID表，命中END.X SID，执行END.X SID的指令动作：SL—，并将SL指示的SID拷贝到外层IPv6头目的地址，由于SL = 0, 弹出SRH扩展头，同时根据END.X关联的下一跳转发。
- 弹出SRH扩展头以后，报文就变成普通的IPv6头，由于A6::1是1个正常的IPv6地址，遵循普通的IPv6转发到R6。

从上面的转发可以看出，对于支持SRv6转发的节点，可以通过SID指示经过特定的链路转发，对于不支持SRv6的节点，可以通过普通的IPv6路由转发穿越。这个特性使得SRv6可以很好地在IPv6网络中实现增量部署。