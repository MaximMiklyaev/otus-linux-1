# Homework 6

## Systemd

### Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig

Скрипт парсинга лог файла ```searchlog.sh```:
```bash
#!/bin/bash
cat $logfile | grep $keyword | awk '{print $12" "$18}'
```
Environmentfile для скрипта ```/etc/sysconfig/searchlog```:
```
keyword="Mozilla"
logfile="/var/log/nginx/access.log"
```
Unit-файл для сервиса ```searchlog.service```:
```
[Unit]
Description=Parsing Nginx log
After=network.target

[Service]
EnvironmentFile=-/etc/sysconfig/searchlog
WorkingDirectory=/home/user
ExecStart=/bin/bash searchlog.sh start
Type=simple

[Install]
WantedBy=multi-user.target
```
Unit-файл для таймера ```searchlog.timer```:
```
[Unit]
Description=Run every 30 seconds

[Timer]
OnBootSec=1m
OnUnitActiveSec=30s
Unit=searchlog.service

[Install]
WantedBy=timers.target
```
-------------
