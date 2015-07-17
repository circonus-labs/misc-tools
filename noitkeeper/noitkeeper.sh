#!/bin/bash

pgrep noitd
noitrc=$?; if [[ $noitrc != 0 ]]; 
  then echo "noitd is not running"; 
    /etc/init.d/noitd start;
  else echo "noitd is running"; fi

pgrep java
jezebelrc=$?; if [[ $jezebelrc != 0 ]]; 
  then echo "Jezebel is not running";
    /etc/init.d/jezebel start;
else echo "Jezebel is running"; fi

pgrep unbound
unboundrc=$?; if [[ $unboundrc != 0 ]];
  then echo "unbound is not running";
    /etc/init.d/circonus-unbound start;
  else echo "unbound is running"; fi
