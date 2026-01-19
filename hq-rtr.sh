apt remove git -y
rm -r /root/demon
cat > /etc/network/interfaces << 'EOF'
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

auto ens3
iface ens3 inet static
address 172.16.1.2
netmask 255.255.255.240
gateway 172.16.1.1

auto vlan100
iface vlan100 inet static
address 192.168.100.1
netmask 255.255.255.224

auto vlan200
iface vlan200 inet static
address 192.168.100.33
netmask 255.255.255.240

auto vlan999
iface vlan999 inet static
address 192.168.100.49
netmask 255.255.255.248

auto tun1
iface tun1 inet tunnel
address 10.10.0.1
netmask 255.255.255.252
mode gre
local 172.16.1.2
endpoint 172.16.2.2
ttl 64

post-up nft -f /etc/nftables.conf
post-up ip link set hq-sw up
post-up ip link set tun1 up
post-up ip link set gre0 up
EOF
apt install -y network-manager
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
 ospf router-id 1.1.1.1
 network 192.168.100.0/27 area 0
 network 192.168.100.32/28 area 0
 network 10.10.0.0/30 area 0
 area 0 authentication
 passive-interface default
 no passive-interface tun1
!
line vty
!
EOF
apt install -y isc-dhcp-server
cat > /etc/default/isc-dhcp-server << 'EOF'
INTERFACESv4="vlan200"
INTERFACESv6=""
EOF
cat > /etc/dhcp/dhcpd.conf << 'EOF'
option domain-name "au-team.irpo";
option domain-name-servers 192.168.100.2;

default-lease-time 600;
max-lease-time 7200;

ddns-update-style none;

authoritative;

subnet 192.168.100.32 netmask 255.255.255.240 {
    range 192.168.100.34 192.168.100.47;
    option routers 192.168.100.33;
}
EOF

rm /root/.bash_history
history -c
nano /etc/apt/sources.list
hostnamectl set-hostname hq-rtr.au-team.irpo
nano /etc/network/interfaces
nano /etc/sysctl.d/sysctl.conf
nano /etc/nftables.conf
useradd -m -s /bin/bash net_admin -U
usermod -aG sudo net_admin
passwd net_admin
visudo
apt install -y openvswitch-switch
ovs-vsctl add-br hq-sw
ovs-vsctl add-port hq-sw ens4 tag=100
ovs-vsctl add-port hq-sw ens5 tag=200
ovs-vsctl add-port hq-sw ens6 tag=999
ovs-vsctl add-port hq-sw vlan100 tag=100 -- set interface vlan100 type=internal
ovs-vsctl add-port hq-sw vlan200 tag=200 -- set interface vlan200 type=internal
ovs-vsctl add-port hq-sw vlan999 tag=999 -- set interface vlan999 type=internal
apt install -y frr
nano /etc/frr/daemons
nano /etc/frr/frr.conf
apt install -y isc-dhcp-server
nano /etc/default/isc-dhcp-server
nano /etc/dhcp/dhcpd.conf
timedatectl set-timezone Asia/Krasnoyarsk
