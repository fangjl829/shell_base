

#场景：MySQL分库备份
#!/bin/sh

user=root
#用户名
pass=root
#密码
backfile=/root/mysql/backup
#备份路径

[ ! -d $backfile ] && mkdir -p $backfile #判断是否有备份路径cmd="mysql -u$user -p$pass"  #登录数据库dump="mysqldump -u$user -p$pass " #mysqldump备份参数dblist=`$cmd -e "show databases;" 2>/dev/null |sed 1d|egrep -v "_schema|mysql"`
#获取库名列表

echo "需要备份的数据列表:"
echo $dblistecho "开始备份:"
for db_name in $dblist
#for循环备份库列表

do printf '正在备份数据库:%s' ${db_name} $dump $db_name 2>/dev/null |gzip >${backfile}/${db_name}_$(date +%m%d).sql.gz
#库名+时间备份打包至指定路径下
printf ',备份完成\n'
done

echo "全部备份完成!!!"



#MySQL数据库分库分表备份
#场景描述
#工作中，往往数据库备份是件非常重要的事情，毕竟数据就是金钱，就是生命！废话不多，
#下面介绍一下：如何实现对MySQL数据库进行分库备份（shell脚本）
#Mysq数据库dump备份/还原语法：
#mysqldump -u 用户名 –p 数据库名 > 导出的文件名;
#mysqldump -u 用户名 –p 数据库名 < 导入的文件名;
#首先，我们需要知道是备份全库还是部分库；
#其次，我们需要获取到需要备份的库名列表；
#最后，编写脚本实现数据备份。
#**分库备份：**
#1、查看当前环境是否启动了MySQL服务，如果没启动，便启动该服务：
#2、获取分库备份的库名列表：
#登录MySQL数据库两种方式：sock方式和tcp/ip方式
#详情https://my.oschina.net/zjllovecode/blog/1617755

#脚本范例
#!/bin/sh
# ******************************************************
# Author       : 锦衣卫
# Last modified: 2019-05-18 13:25
# Email        : 1147076062@qq.com
# blog         : https://www.cnblogs.com/su-root
# Filename     : mysqldb.sh
# Description  : mysql_dmup
# ******************************************************

user=root
#用户名
pass=123456
#密码
socket=/tmp/mysql.sock
#登录方式
backfile=/server/backup
#备份路径


[ ! -d $backfile ] && mkdir -p $backfile
#判断是否有备份路径
cmd="mysql -u$user -p$pass -S $socket"
#登录数据库
dump="mysqldump -u$user -p$pass -S $socket -B -X -F -R"
#mysqldump备份参数
dblist=`$cmd -e "show databases;"|sed 1d|egrep -v "_schema|mysql"`
#获取库名列表

for db_name in $dblist
#for循环备份库列表
do
 $dump $db_name|gzip >/server/backup/${db_name}_$(date +%F).sql.gz
 #库名+时间备份打包至指定路径下
done