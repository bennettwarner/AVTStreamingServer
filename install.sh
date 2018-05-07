#!/bin/bash
# Bennett Warner | Last Updated: May 2018
#########################################

#Updates repositories and installs dependancies
apt-get update && apt-get upgrade -y
apt-get install build-essential libpcre3 libpcre3-dev libssl-dev nload unzip -y

# Create and move into a temp directory to build programs in
mkdir /root/working
cd /root/working/

#Download Nginx and its RTMP module
wget http://nginx.org/download/nginx-1.9.15.tar.gz
wget https://github.com/arut/nginx-rtmp-module/archive/master.zip

#Uncompress both files and move into the Nginx folder
tar -zxvf nginx-1.9.15.tar.gz
unzip master.zip
cd nginx-1.9.15/

#Prepare to compile Nginx with the RTMP Module
./configure --with-http_ssl_module --with-http_stub_status_module --add-module=../nginx-rtmp-module-master

# Create and set permissions on a directory to store HLS Video Segments
mkdir /tmp/hls
chmod -R 777 /tmp/hls/

#Compile Nginx with the RTMP Module
make
make install

#Download and apply Nginx startup entry
wget https://raw.github.com/JasonGiedymin/nginx-init-ubuntu/master/nginx -O /etc/init.d/nginx
chmod +x /etc/init.d/nginx
update-rc.d nginx defaults
service nginx start
service nginx stop

#Download and set permissions on stats and crossdomain config files
cd /usr/local/nginx/html/
wget https://github.com/arut/nginx-rtmp-module/raw/master/stat.xsl
chmod 755 stat.xsl
wget http://phxmediagroup.com/code/crossdomain.xml
chmod 755 crossdomain.xml

#Download and apply Nginx config file
cd /usr/local/nginx/conf/
rm nginx.conf
wget http://www.phxmediagroup.com/code/nginx.conf
chmod 755 nginx.conf
service nginx start

#Install cronjob to report upload bandwidth utilization
cd /root
wget http://www.phxmediagroup.com/code/upload_rate.sh
chmod +x ./upload_rate.sh
crontab -l > mycron
echo "* * * * * /root/upload_rate.sh >/dev/null 2>&1" >> mycron
crontab mycron
rm mycron
