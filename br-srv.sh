apt remove git -y
rm -r /root/demon
cat > /etc/network/interfaces << 'EOF'
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto ens3
iface ens3 inet static
address 192.168.200.2
netmask 255.255.255.240
gateway 192.168.200.1
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
cat > /etc/resolv.conf << 'EOF'
nameserver 192.168.100.2
search au-team.irpo
EOF

rm /root/.bash_history
history -c
nano /etc/apt/sources.list
hostnamectl set-hostname br-srv.au-team.irpo
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
