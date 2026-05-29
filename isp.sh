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

auto ens4
iface ens4 inet static
address 172.16.1.1/28

auto ens5
iface ens5 inet static
address 172.16.2.1/28

post-up nft -f /etc/nftables.conf
EOF
echo > /etc/sysctl.d/sysctl.conf
sed -i '1i net.ipv4.ip_forward=1' /etc/sysctl.d/sysctl.conf
cat > /etc/nftables.conf << 'EOF'
#!/usr/sbin/nft -f

flush ruleset

table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100; policy accept
        meta l4proto { gre, ipip, ospf } counter return
        masquerade
    }
}

table inet filter {
    chain input {
        type filter hook input priority filter;
    }
    chain forward {
        type filter hook forward priority filter;
    }
    chain output {
        type filter hook output priority filter;
    }
}
EOF
apt install chrony -y
sed -i '5c #pool 2.debian.pool.ntp.org iburst' /etc/chrony/chrony.conf
sed -i '5a server ntp1.vniiftri.ru iburst prefer' /etc/chrony/chrony.conf
sed -i '6a local stratum 5' /etc/chrony/chrony.conf
sed -i '7a allow 0.0.0.0/0' /etc/chrony/chrony.conf

rm /root/.bash_history
history -c
nano /etc/apt/sources.list
hostnamectl set-hostname isp.au-team.irpo
nano /etc/network/interfaces
nano /etc/sysctl.d/sysctl.conf
nano /etc/nftables.conf
timedatectl set-timezone Asia/Krasnoyarsk
apt install chrony -y
nano /etc/chrony/chrony.conf
apt install nginx -y
apt install apache2-utils -y
cat > /etc/nginx/sites-available/proxy << 'EOF'
server {
    listen 80;
    server_name web.au-team.irpo;
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    location / {
        proxy_pass http://172.16.1.2:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

server {
    listen 80;
    server_name docker.au-team.irpo;
    location / {
        proxy_pass http://172.16.2.2:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF
ln -s /etc/nginx/sites-available/proxy /etc/nginx/sites-enabled
sed -i '24c server_names_hash_bucket_size 64;' /etc/nginx/nginx.conf
sed -i '1c 172.16.1.1	web.au-team.irpo' /etc/hosts
sed -i '2c 172.16.2.1	docker.au-team.irpo' /etc/hosts
htpasswd -bc /etc/nginx/.htpasswd WEB P@ssw0rd
systemctl restart nginx
