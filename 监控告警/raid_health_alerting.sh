

#场景：服务器中常用raid卡这种硬件设备对多块硬盘组合起来，形成一种大容量高可用的解决方案。对raid组的检查状态就很重要。能够及时的知晓硬件的损坏健康状态。参考如下脚本来实现。
#采用工具 MegaCli
#下载地址：https://raw.githubusercontent.com/crazy-zhangcong/tools/master/MegaCli8.07.10.tar.gz
#参考链接：http://t.zoukankan.com/chenjw-note-p-10316197.html
#脚本代码：

#!/bin/sh
flag=1

for ste in /sbin/megacli -LDInfo -Lall -aALL |grep "State" | awk '{print $3}'
do
  if [ $ste == “Optimal” ]
    then
      flag=expr $flag + 0
    else
      flag=expr $flag + 1
  fi
done

if [ flag -eq 1 ]
  then
    echo "status:good."
  else
    echo “status:bad:”$flag" "
fi