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
address 192.168.200.2/28
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
sed -i '2c search localdomain au-team.irpo' /etc/resolv.conf
sed -i '3c nameserver 127.0.0.1' /etc/resolv.conf
systemctl restart dnsmasq 
apt install chrony -y
sed -i '5c #pool 2.debian.pool.ntp.org iburst' /etc/chrony/chrony.conf
sed -i '5a server 172.16.2.1 iburst' /etc/chrony/chrony.conf
apt install ansible sshpass -y
mkdir -p /etc/ansible
cat > /etc/ansible/ansible.cfg << 'EOF'
[defaults]
host_key_checking=False
EOF
cat > /etc/ansible/hosts << 'EOF'
[hq]
192.168.100.1 ansible_user=net_admin ansible_password=P@ssw0rd
192.168.100.2 ansible_user=sshuser ansible_password=P@ssw0rd ansible_port=2026
192.168.100.35 ansible_user=sshuser ansible_password=P@ssw0rd

[br]
192.168.200.1 ansible_user=net_admin ansible_password=P@ssw0rd

[all: vars]
ansible_python_interpreter=/usr/bin/python3.13
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
apt install -y samba smbclient winbind libnss-winbind krb5-user net-tools
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
systemctl stop smbd nmbd winbind
systemctl stop samba-ad-dc
samba-tool domain provision --use-rfc2307 --interactive
systemctl start smbd nmbd winbind
systemctl start samba-ad-dc
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
samba-tool group add hq
samba-tool user create hquser1 P@ssw0rd
samba-tool group addmembers hq hquser1
samba-tool user create hquser2 P@ssw0rd
samba-tool group addmembers hq hquser2
samba-tool user create hquser3 P@ssw0rd
samba-tool group addmembers hq hquser3
samba-tool user create hquser4 P@ssw0rd
samba-tool group addmembers hq hquser4
samba-tool user create hquser5 P@ssw0rd
samba-tool group addmembers hq hquser5
apt install dnsmasq -y
nano /etc/dnsmasq.conf
apt install chrony -y
nano /etc/chrony/chrony.conf
systemctl restart chronyd
apt install ansible sshpass -y
nano /etc/ansible/ansible.cfg
nano /etc/ansible/hosts
ansible all -m ping
