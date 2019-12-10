systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl disable firewalld
systemctl stop firewalldd
systemctl enable sshd
systemctl restart sshd
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

ip addr add 192.168.119.11/24 dev ens32
ip addr add 30.30.30.2/24 dev ens36
ip addr add 2000:2001::1001/120 dev ens34
ip addr add 2000:2003::1001/120 dev ens35
ip addr add 3000::11/128 dev lo

ip rule add from 30.30.30.1/32 table 100

ip route add 20.20.20.0/24 encap seg6 mode encap segs 3000::2,3000::4 dev ens34 table 100
ip -6 route add 3000::2/128 via 2000:2001::1002
ip -6 route add 3000::1/128 encap seg6local action End.DX4 nh4 30.30.30.1 dev ens36



