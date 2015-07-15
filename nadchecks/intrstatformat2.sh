#!/usr/bin/bash
while true
 do
  intrstat -c 2 5 1 | sed 's/[|,#]//g' | sed '1,3d' | awk '!($2="")' | sed 's/  /:intrcpu2 L /g' > /var/log/intrst/intrst2.tmp 
   mv /var/log/intrst/intrst2.tmp /var/log/intrst/intrstatresult2.txt
 done
