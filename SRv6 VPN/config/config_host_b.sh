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
sysctl -w net.ipv6.conf.lo.seg6_enabled=1
sysctl -w net.ipv4.conf.all.rp_filter=0

ip addr add 192.168.119.22/24 dev ens32
ip addr add 20.20.20.1/24 dev ens34
ip r add 30.30.30.0/24 via 20.20.20.2

