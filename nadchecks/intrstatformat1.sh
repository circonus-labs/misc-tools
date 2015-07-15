#!/usr/bin/bash
while true
 do
  intrstat -c 1 5 1 | sed 's/[|,#]//g' | sed '1,3d' | awk '!($2="")' | sed 's/  /:intrcpu1 L /g' > /var/log/intrst/intrst1.tmp 
   mv /var/log/intrst/intrst1.tmp /var/log/intrst/intrstatresult1.txt
 done
