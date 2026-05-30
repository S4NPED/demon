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
sed -i '2c search localdomain au-team.irpo' /etc/resolv.conf
sed -i '3c nameserver 192.168.100.2' /etc/resolv.conf

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
apt update
xdg-open "https://drive.google.com/file/d/1wOvy1El4w5-UZ4h2Fc8JRlxLqCtUsEYd/view?usp=sharing"
read -p "Нажмите Enter для продолжения..."
cp /root/Загрузки/Additional.7z /root
apt install p7zip-full
7z x /root/Additional.7z
7z x Additional.iso -o/root/Additional
apt install apache* -y
apt install php php8.4 php-curl php-zip php-xml libapache2-mod-php php-mysql php-mbstring php-gd php-intl php-soap -y
apt install mariadb-* -y
systemctl stop mariadb
systemctl stop apache2 
cp /root/Additional/web/index.php /var/www/html
mount /root/Additional.iso /mnt/
cp /mnt/web/index.php /var/www/html
cp /mnt/web/logo.png /var/www/html
sed -i '3c $username = "web";' /var/www/html/index.php
sed -i '4c $password = "P@ssw0rd";' /var/www/html/index.php
sed -i '5c $dbname = "webdb";' /var/www/html/index.php
systemctl enable --now mariadb
mariadb -u root
read -p "Нажмите Enter для продолжения..."
mariadb -u web -p -D webdb < /mnt/web/dump.sql
rm /var/www/html/index.html
sed -i '1c <VirtualHost *:8080>' /etc/apache2/sites-available/000-default.conf
sed -i '5c Listen 8080' /etc/apache2/ports.conf
systemctl restart apache2
