

# 通过脚本结合 scan方式获取分布式redis的key和对应的超时时间（TTL）

#!/bin/bash
redis=`echo "scan 0" | redis-cli -h localhost | awk -F'"' "{print $1}"`

for key in ${redis[*]}
do
   echo -n $key ":"
   echo -n get $key | redis-cli -h localhost
done