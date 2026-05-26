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
nano /etc/resolv.conf
timedatectl set-timezone Asia/Krasnoyarsk
