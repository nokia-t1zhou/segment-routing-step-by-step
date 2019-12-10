systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl disable firewalld
systemctl stop firewalldd
ip addr add 192.168.119.13/24 dev ens32
systemctl enable sshd
systemctl restart sshd

ip addr add 2000:2003::1003/120 dev ens35
ip addr add 2000:2004::1003/120 dev ens34
ip addr add 3000::33/128 dev lo

sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1
sysctl -w net.ipv6.conf.default.seg6_enabled=1
sysctl -w net.ipv6.conf.ens32.seg6_enabled=1
sysctl -w net.ipv6.conf.ens34.seg6_enabled=1
sysctl -w net.ipv6.conf.ens35.seg6_enabled=1
sysctl -w net.ipv6.conf.lo.seg6_enabled=1

ip -6 route add 3000::3/128 encap seg6local action End dev ens35
ip -6 route add 3000::1/128 via 2000:2003::1001