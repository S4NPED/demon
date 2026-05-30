apt update
cat > /etc/network/interfaces << 'EOF'
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

auto ens3
iface ens3 inet dhcp
EOF
apt install -y realmd sssd sssd-tools libnss-sss libpam-sss adcli packagekit
cat > /etc/sudoers.d/hq-users << 'EOF'
%hq@au-team.irpo ALL=(ALL) /usr/bin/cat, /usr/bin/grep, /usr/bin/id
EOF
sed -i '2c search localdomain au-team.irpo' /etc/resolv.conf
sed -i '3c nameserver 192.168.100.2' /etc/resolv.conf

apt remove git -y
rm -r /root/demon
rm /root/.bash_history
history -c
nano /etc/apt/sources.list
hostnamectl set-hostname hq-cli.au-team.irpo
nano /etc/network/interfaces
timedatectl set-timezone Asia/Krasnoyarsk
apt update && apt install -y realmd sssd sssd-tools libnss-sss libpam-sss adcli packagekit
nano /etc/resolv.conf
realm join -U administrator au-team.irpo
pam-auth-update --enable mkhomedir
realm deny --all
realm permit -g hq@au-team.irpo
nano /etc/sudoers.d/hq-users
apt install openssh-server -y
useradd -m -s /bin/bash sshuser -U
usermod -aG sudo sshuser
passwd sshuser
xdg-open "https://drive.google.com/file/d/1wOvy1El4w5-UZ4h2Fc8JRlxLqCtUsEYd/view?usp=sharing"
read -p "Нажмите Enter для продолжения..."
cp /root/Загрузки/Additional.7z /root
apt install p7zip-full
7z x /root/Additional.7z
apt install ./Yandex.deb -y
yandex-browser-stable --no-sandbox
