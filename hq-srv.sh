apt remove git -y
rm -r /root/demon
apt-get update
cat > /etc/network/interfaces << 'EOF'
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

auto ens3
iface ens3 inet static
address 192.168.100.2
netmask 255.255.255.224
gateway 192.168.100.1
EOF
sed -i '51a sshuser ALL=(ALL:ALL) NOPASSWD:ALL' /etc/sudoers
apt install -y openssh-server
cat > /etc/ssh_banner << 'EOF'
*******************************************************
*                                                     *
*                 Authorized access only              *
*                                                     *
*******************************************************
EOF
cat > /etc/ssh/sshd_config << 'EOF'
Port 2026
AllowUsers sshuser
MaxAuthTries 2
Banner /etc/ssh_banner
PasswordAuthentication yes
PermitRootLogin no
EOF
apt install -y bind9 
mkdir /etc/bind/zones
mkdir /var/cache/bind/master
cat > /etc/bind/named.conf.options << 'EOF'
options {
    directory "/var/cache/bind";
    allow-query { any; };
    forwarders {
        8.8.8.8;
    };
    dnssec-validation no;
    listen-on-v6 port 53 { none; };
    listen-on port 53 { 127.0.0.1; 192.168.100.0/27; 192.168.100.32/28; 192.168.200.0/28; };
};
EOF
cat > /etc/bind/named.conf.local << 'EOF'
zone "au-team.irpo" {
    type master;
    file "master/au-team.db";
};

zone "100.168.192.in-addr.arpa" {
    type master;
    file "master/au-team_rev.db";
};
EOF
cat > /etc/bind/zones/au-team.db << 'EOF'
$TTL 604800
@   IN  SOA localhost. root.localhost. (
    2          ; Serial
    604800     ; Refresh
    86400      ; Retry
    2419200    ; Expire
    604800 )   ; Negative Cache TTL

@   IN  NS  au-team.irpo.
@   IN  A   192.168.100.2

hq-rtr   IN  A   192.168.100.1
br-rtr   IN  A   192.168.200.1
hq-srv   IN  A   192.168.100.2
hq-cli   IN  A   192.168.100.35
br-srv   IN  A   192.168.200.2
moodle   IN  CNAME hq-rtr.au-team.irpo.
wiki     IN  CNAME hq-rtr.au-team.irpo.
EOF
cat > /etc/bind/zones/au-team_rev.db << 'EOF'
$TTL 604800
@   IN  SOA localhost. root.localhost. (
    1          ; Serial
    604800     ; Refresh
    86400      ; Retry
    2419200    ; Expire
    604800 )   ; Negative Cache TTL

@   IN  NS  au-team.irpo.
1   IN  PTR hq-rtr.au-team.irpo.
2   IN  PTR hq-srv.au-team.irpo.
66  IN  PTR hq-cli.au-team.irpo.
EOF
chown -R root /etc/bind/zones
chown 0640 /etc/bind/zones/*
cp /etc/bind/zones/au-team.db /var/cache/bind/master
cp /etc/bind/zones/au-team_rev.db /var/cache/bind/master
echo "nameserver 192.168.100.2" > /etc/resolv.conf

rm /root/.bash_history
history -c
nano /etc/apt/sources.list
hostnamectl set-hostname hq-srv.au-team.irpo
nano /etc/network/interfaces
useradd -m -s /bin/bash sshuser -u 2026 -U
usermod -aG sudo sshuser
passwd sshuser
visudo
apt install -y openssh-server
nano /etc/ssh_banner
nano /etc/ssh/sshd_config
apt-get update
apt install -y bind9 
nano /etc/bind/named.conf.options
nano /etc/bind/named.conf.local
named-checkconf
mkdir /etc/bind/zones
nano /etc/bind/zones/au-team.db
nano /etc/bind/zones/au-team_rev.db
mkdir /var/cache/bind/master
cp /etc/bind/zones/au-team.db /var/cache/bind/master
cp /etc/bind/zones/au-team_rev.db /var/cache/bind/master
named-checkconf -z
nano /etc/resolv.conf
timedatectl set-timezone Asia/Krasnoyarsk
