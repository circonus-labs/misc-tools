#!/usr/bin/bash
while true
 do
  intrstat -c 0 5 1 | sed 's/[|,#]//g' | sed '1,3d' | awk '!($2="")' | sed 's/  /:intrcpu0 L /g' > /var/log/intrst/intrst0.tmp 
   mv /var/log/intrst/intrst0.tmp /var/log/intrst/intrstatresult0.txt
 done
