

# 脚本使用说明
# 该脚本，定期对登录日志进行扫描，对于登录失败次数超过10的，自动加入到 hosts.deny 中，实现对异常登录行为封禁的效果。
# 代码如下：


#!/bin/sh

cat /usr/local/src/secure.log | awk '/Failed/{print $(NF-3)}' | sort | uniq -c | awk '{print $2"="$1;}' > /root/satools/black.txt
DEFINE="10"

for i in `cat /usr/local/src/black.txt`
do

IP=`echo $i | awk -F= '{print $1}'`
NUM=`echo $i | awk -F= '{print $2}'`

if [ $NUM -gt $DEFINE ];then
	grep $IP /etc/hosts.deny > /dev/null

if [ $? -gt 0 ];then
	echo "sshd:$IP" >> /etc/hosts.deny
fi
fi

done


# 定时任务执行
vim /etc/crontab
# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed
*/5 * * * * /bin/sh /data/scripts/secure.sh
# 每天的每间隔5分钟执行一次