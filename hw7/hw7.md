# Homework 7

## Управление процессами

### Написать свою реализацию ps ax используя анализ /proc

Решил попробовать именно этот пункт, показался доступным, но столкнувшись с форматированием, понял, что все не так просто.

Сам скрипт (доступен здесь [ps_ax_proc.sh](./ps_ax_proc.sh):
```bash
#!/bin/bash

for i in $(ls -d /proc/[0-9]* | sort -V);
  do
     PID="$(basename $i)"
     if [ -f "$i/cmdline" ] && [ "`awk 'END { print (NR > 0 && NF > 0) ? "1" : "0"}' $i/cmdline`" == "1" ]
     then
       echo -ne "$(basename $i)\t" \
       && awk -F'[ ()]' '{ printf $5 "\t"}' $i/stat 
       awk '{ if(match($NF,/[a-z]+/)) printf $NF; }' $i/cmdline && echo; 
     else
       if [ -f "$i/comm" ] && [ "`awk 'END { print (NR > 0 && NF > 0) ? "1" : "0"}' $i/comm`" == "1" ]
       then
         echo -ne "$(basename $i)\t" \
         && awk -F'[ ()]' '{ printf $5 "\t"}' $i/stat 
         awk '{ if(match($NF,/[a-z]+/)) printf $NF; }' $i/comm && echo;
       fi
     fi
done
```
И его результат:
```
1	S	/sbin/initsplash
2	S	kthreadd
4	I	kworker/0:0H
6	I	mm_percpu_wq
7	S	ksoftirqd/0
8	I	rcu_preempt
9	I	rcu_sched
10	I	rcu_bh
11	S	rcuc/0
12	S	rcub/0
13	S	migration/0
14	S	watchdog/0
15	S	cpuhp/0
16	S	cpuhp/1
17	S	watchdog/1
18	S	migration/1
19	S	rcuc/1
20	S	ksoftirqd/1
```
