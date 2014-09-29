#!/bin/sh
while [ 1 ]
do
    #NUMCON=`netstat -ant | awk '{print $5}' | grep -c 192.168.3.245`
    NUMCON=`netstat -ant | grep 8080 | wc -l`
    MEM=`ps -o rss= -p 26446`
    CPUZ=`top -p 8993 -bn 2 -d 0.01 | grep '^%Cpu'| tail -n 1 | awk '{print $2+$4+$6}'`
    echo -e "`date +%s` $NUMCON"
    sleep 5
done | tee -a mochimem.log
