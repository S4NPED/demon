apt remove git -y
rm -r /root/demon
cat > /etc/network/interfaces << 'EOF'
source /etc/network/interfaces.d/*

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
