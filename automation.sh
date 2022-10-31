sudo apt update -y
s3_bucket='mayankupgrad'
myname='Mayank'
if [[ `apache2 -v | grep 'Server version' | wc -l`  -ne 1 ]]
then
	sudo apt install apache2
fi
if [[ `sudo systemctl status apache2.service | grep dead | wc -l` -eq 1 ]]
then
	sudo systemctl start apache2.service
fi
timestamp=$(date '+%d%m%Y-%H%M%S')
cd /var/log/apache2
tar -cvf "/tmp/$myname-httpd-logs-$timestamp.tar" ./*.log

aws s3 \
cp /tmp/$myname-httpd-logs-$timestamp.tar \
s3://$s3_bucket/$myname-httpd-logs-$timestamp.tar
