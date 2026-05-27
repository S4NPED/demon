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
address 192.168.100.2/27
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
address=/hq-cli.au-team.irpo/192.168.100.35 
ptr-record=34.100.168.192.in-addr.arpa,hq-cli.au-team.irpo 
address=/br-srv.au-team.irpo/192.168.200.2 
ptr-record=2.200.168.192.in-addr.arpa,br-srv.au-team.irpo 
address=/docker.au-team.irpo/172.16.1.1 
address=/web.au-team.irpo/172.16.2.1
EOF
apt install chrony -y
sed -i '5c #pool 2.debian.pool.ntp.org iburst' /etc/chrony/chrony.conf
sed -i '5a server 172.16.1.1 iburst' /etc/chrony/chrony.conf

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
nano /etc/resolv.conf
timedatectl set-timezone Asia/Krasnoyarsk
apt install dnsmasq -y
nano /etc/dnsmasq.conf
apt install chrony -y
nano /etc/chrony/chrony.conf
systemctl restart chronyd
