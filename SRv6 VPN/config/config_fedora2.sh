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
sysctl -w net.ipv6.conf.lo.seg6_enabled=1

ip addr add 192.168.119.12/24 dev ens32
ip addr add 2000:2001::1002/120 dev ens35
ip addr add 2000:2002::1002/120 dev ens34
ip addr add 3000::22/128 dev lo

ip -6 route add 3000::2/128 encap seg6local action End dev ens34
ip -6 route add 3000::4 via 2000:2002::1004