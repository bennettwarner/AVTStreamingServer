#!/bin/bash
# Bennett Warner | Last Updated: May 2018
#########################################

#Check if installer is running under root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

#Updates repositories and installs dependancies
apt-get update && apt-get upgrade -y
apt-get install build-essential libpcre3 libpcre3-dev libssl-dev nload unzip -y

# Create and set permissions on a directory to store HLS Video Segments
mkdir /tmp/hls
chmod -R 777 /tmp/hls/

#Uncompress both files
cd ./install_files
tar -zxvf ./nginx-1.9.15.tar.gz
unzip ./nginx-rtmp-module-master.zip

#Compile Nginx with the RTMP Module
cd nginx-1.9.15/
./configure --with-http_ssl_module --with-http_stub_status_module --add-module=../nginx-rtmp-module-master
make && make install
cd ..
cd ..

#Install and apply Nginx startup entry
mv ./install_files/nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx
update-rc.d nginx defaults
service nginx start
service nginx stop

#Install and set permissions on stats and crossdomain config files
mv ./install_files/stat.xsl /usr/local/nginx/html/
mv ./install_files/crossdomain.xml /usr/local/nginx/html/
chmod 755 /usr/local/nginx/html/*

#Install and apply Nginx config file
rm /usr/local/nginx/conf/nginx.conf
mv ./install_files/nginx.conf /usr/local/nginx/conf/
chmod 755 /usr/local/nginx/conf/nginx.conf
service nginx start

#Install cronjob to report upload bandwidth utilization
chmod +x ./install_files/upload_rate.sh
mv ./install_files/upload_rate.sh /usr/local/bin/upload_rate
crontab -l > mycron
echo "* * * * * /usr/local/bin/upload_rate >/dev/null 2>&1" >> mycron
crontab mycron
rm mycron
echo "Install complete"
