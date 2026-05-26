apt remove git -y
rm -r /root/demon
apt update
cat > /etc/network/interfaces << 'EOF'
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

auto ens3
iface ens3 inet static
address 172.16.2.2/28
gateway 172.16.2.1

auto ens4
iface ens4 inet static
address 192.168.200.1/28

auto tun1
iface tun1 inet tunnel
address 10.10.0.2
netmask 255.255.255.252
mode gre
local 172.16.2.2
endpoint 172.16.1.2
ttl 64

post-up nft -f /etc/nftables.conf
post-up ip link set tun1 up
post-up ip link set gre0 up
EOF
echo > /etc/sysctl.d/sysctl.conf
sed -i '1i net.ipv4.ip_forward=1' /etc/sysctl.d/sysctl.conf
cat > /etc/nftables.conf << 'EOF'
#!/usr/sbin/nft -f

flush ruleset

table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100; policy accept
        meta l4proto { gre, ipip, ospf } counter return
        masquerade
    }
}

table inet filter {
    chain input {
        type filter hook input priority filter;
    }
    chain forward {
        type filter hook forward priority filter;
    }
    chain output {
        type filter hook output priority filter;
    }
}
EOF
sed -i '51a net_admin ALL=(ALL:ALL) NOPASSWD:ALL' /etc/sudoers
apt install -y frr
sed -i 's/ospfd=no/ospfd=yes/' /etc/frr/daemons
systemctl restart frr
cat > /etc/frr/frr.conf << 'EOF'
frr version 10.3
frr defaults traditional
hostname router
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
interface tun1
 ip ospf authentication
 ip ospf authentication-key password
 ip ospf network point-to-point
 no ip ospf passive
!
router ospf
 ospf router-id 2.2.2.2
 network 192.168.200.0/28 area 0
 network 10.10.0.0/30 area 0
 area 0 authentication
 passive-interface default
 no passive-interface tun1
!
line vty
!
EOF
apt install dnsmasq -y
cat > /etc/dnsmasq.conf << 'EOF'
interface=ens3 
server=8.8.8.8 
domain=au-team.irpo 
listen-address=192.168.100.2 
no-resolv 
no-hosts 
address=/hq-rtr.au-team.irpo/192.168.100.1 
ptr-record=1.100.168.192.in-addr.arpa,hq-rtr.au-team.irpo 
address=/br-rtr.au-team.irpo/192.168.200.1 
address=/hq-srv.au-team.irpo/192.168.100.2 
ptr-record=2.100.168.192.in-addr.arpa,hq-srv.au-team.irpo 
address=/hq-cli.au-team.irpo/192.168.100.34 
ptr-record=34.100.168.192.in-addr.arpa,hq-cli.au-team.irpo 
address=/br-srv.au-team.irpo/192.168.200.2 
ptr-record=2.200.168.192.in-addr.arpa,br-srv.au-team.irpo 
address=/docker.au-team.irpo/172.16.1.1 
address=/web.au-team.irpo/172.16.2.1
EOF
cat > /etc/resolv.conf << 'EOF'
search localdomain au-team.irpo
nameserver 127.0.0.1
EOF

rm /root/.bash_history
history -c
nano /etc/apt/sources.list
hostnamectl set-hostname br-rtr.au-team.irpo
nano /etc/network/interfaces
nano /etc/sysctl.d/sysctl.conf
nano /etc/nftables.conf
useradd -m -s /bin/bash net_admin -U
usermod -aG sudo net_admin
passwd net_admin
visudo
apt install -y frr
nano /etc/frr/daemons
systemctl restart frr
nano /etc/frr/frr.conf
timedatectl set-timezone Asia/Krasnoyarsk
apt install dnsmasq -y
nano /etc/dnsmasq.conf
