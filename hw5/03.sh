Анализ access.log

cd /var/log/nginx

На взлом: обращение к несуществующим php сценариям:

awk '($9 ~ /404/)' access.log | awk -F\" '($2 ~ "^GET .*\.php")' | awk '{print $7}' | sort | uniq -c | sort -r | head -n 20

Вывод:

      3 /phpMyAdmin.old/index.php
      3 /phpmyadmin-old/index.php
      3 /phpMyAdmin/index.php
      3 /phpmyadmin/index.php
      3 /phpMyadmin_bak/index.php


Анализ IP адресов и количество обращений от них:

awk '{print $1}' access.log | sort | uniq -c | sort -rn

Вывод:

    558 109.202.18.119
    162 95.216.16.17
    124 128.140.193.74
    120 141.8.142.49
    108 176.59.201.95
    105 37.147.153.37
     96 213.33.164.26
     82 109.110.37.56
     75 176.59.44.140
     58 213.87.123.98
