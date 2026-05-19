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
iface ens3 inet dhcp
EOF

rm /root/.bash_history
history -c
nano /etc/apt/sources.list
hostnamectl set-hostname hq-cli.au-team.irpo
nano /etc/network/interfaces
timedatectl set-timezone Asia/Krasnoyarsk
apt update && apt install -y realmd sssd sssd-tools libnss-sss libpam-sss adcli
packagekit
realm join -U admininstrator au-team.irpo
pam-auth-update --enable mkhomedir
realm deny --all
realm permit -g hq@au-team.irpo
nano /etc/sudoers.d/hq-users
