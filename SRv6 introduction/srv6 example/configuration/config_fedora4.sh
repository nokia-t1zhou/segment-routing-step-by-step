sysctl -w net.ipv6.conf.all.disable_ipv6=1
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl disable firewalld
systemctl stop firewalldd
systemctl enable sshd
systemctl restart sshd
sysctl -w net.ipv6.conf.all.disable_ipv6=0
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1
sysctl -w net.ipv6.conf.default.seg6_enabled=1
sysctl -w net.ipv6.conf.ens32.seg6_enabled=1
sysctl -w net.ipv6.conf.ens34.seg6_enabled=1
sysctl -w net.ipv6.conf.ens35.seg6_enabled=1
sysctl -w net.ipv6.conf.ens36.seg6_enabled=1
sysctl -w net.ipv6.conf.lo.seg6_enabled=1
sysctl -w net.ipv4.conf.all.rp_filter=0

ip addr add 192.168.119.14/24 dev ens32
ip addr add 2000:2002::1004/120 dev ens35
ip addr add 2000:200b::1004/120 dev ens36
ip addr add 3000::44/128 dev lo

ip -6 route add 3000::4/128 encap seg6local action End.X nh6 2000:200b::100b dev ens36
ip -6 route add 2000:200a::1000/120  encap seg6 mode inline segs 3000::2,3000::1 dev ens35
ip -6 route add 3000::2 via 2000:2002::1002
