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
192.168.100.2 ansible_user=sshuser ansible_password=P@$$word ansible_port=2026
192.168.100.34 ansible_user=sshuser ansible_password=P@ssw0rd

[br]
192.168.200.1 ansible_user=net_admin ansible_password=P@ssw0rd

[all:vars]
ansible_python_interpreter=/usr/bin/python3.13

[clients]
192.168.100.37
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
sed -i '8c kdc = au-team.irpo' /var/lib/samba/private/krb5.conf
sed -i '8a admin_server = br-srv.au-team.irpo' /var/lib/samba/private/krb5.conf
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
apt install chrony -y
nano /etc/chrony/chrony.conf
systemctl restart chronyd
apt install ansible sshpass -y
nano /etc/ansible/ansible.cfg
nano /etc/ansible/hosts
ansible all -m ping
apt install docker.io docker-compose -y
xdg-open "https://drive.google.com/file/d/1wOvy1El4w5-UZ4h2Fc8JRlxLqCtUsEYd/view?usp=sharing"
read -p "Нажмите Enter для продолжения..."
cp /root/Загрузки/Additional.7z /root
apt install p7zip-full
7z x /root/Additional.7z
7z x Additional.iso -o/root/Additional
docker image load -i /root/Additional/docker/site_latest.tar
docker image load -i /root/Additional/docker/mariadb_latest.tar
docker images
mkdir testapp
cd testapp/
cat > docker-compose.yaml << 'EOF'
version: '3.8'

services:
  testapp:
    image: site:latest
    container_name: testapp
    restart: always
    depends_on:
      - db
    ports:
      - "8080:8000"
    environment:
      DB_TYPE: maria
      DB_HOST: db
      DB_NAME: testdb
      DB_PORT: "3306"
      DB_USER: test
      DB_PASS: Passw0rd

  db:
    image: mariadb:10.11
    container_name: db
    restart: always
    environment:
      MARIADB_DATABASE: testdb
      MARIADB_USER: test
      MARIADB_PASSWORD: Passw0rd
      MARIADB_ROOT_PASSWORD: Passw0rd
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
EOF
docker-compose -f docker-compose.yaml up -d
docker ps
