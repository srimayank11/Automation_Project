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

filename="/var/www/html/inventory.html"
if [ ! -f $filename ]
then
    touch $filename
    echo $'Log Type\tTime Created\tType\tSize' > $filename
fi

if [[ `aws s3 ls s3://$s3_bucket --human-readable| grep $timestamp  | awk '{print $3}' | wc -l` -eq 1 ]]
then
	size=`aws s3 ls s3://$s3_bucket --human-readable| grep $timestamp  | awk '{print $3}'`
	echo "httpd,$timestamp,tar,$size" | sed -e 's/,/\t/g' >> $filename
fi


if [[ `crontab -l | grep automation.sh | wc -l` -ne 1 ]]
then
	crontab -l > /etc/cron.d/automation
	echo "* * * * * /root/Automation/.automation.sh" >> /etc/cron.d/automation
	crontab /etc/cron.d/automation
fi
