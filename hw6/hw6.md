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

Для установки и запуска перенесем ```searchlog.service``` и ```searchlog.timer``` в ```/etc/systemd/system/```.

```systemctl daemon-reload``` - что бы systemd увидел новые юниты

```systemctl enable searchlog.service``` - установим наш сервис

```systemctl enable searchlog.timer``` - установим таймер для сервиса

```systemctl start searchlog.timer``` - запустим таймер

```systemctl list-timers --all``` - убедимся что наш таймер в списке:
```
NEXT                         LEFT     LAST                         PASSED    UNIT                         ACTIVATES
Sat 2018-05-19 17:23:15 EDT  26s ago  Sat 2018-05-19 17:23:41 EDT  7ms ago   searchlog.timer              searchlog.service
```
```systemctl status searchlog -l``` - проверим как работает наш сервис:
```
● searchlog.service - Parsing Nginx log
   Loaded: loaded (/etc/systemd/system/searchlog.service; disabled; vendor preset: disabled)
   Active: inactive (dead) since Sat 2018-05-19 17:26:19 EDT; 2s ago
  Process: 10874 ExecStart=/bin/bash searchlog.sh start (code=exited, status=0/SUCCESS)
 Main PID: 10874 (code=exited, status=0/SUCCESS)

May 19 17:26:19 localhost.localdomain bash[10874]: "Mozilla/5.0 Firefox/58.0"
May 19 17:26:19 localhost.localdomain bash[10874]: "Mozilla/5.0 Firefox/58.0"
May 19 17:26:19 localhost.localdomain bash[10874]: "Mozilla/5.0 Firefox/58.0"
May 19 17:26:19 localhost.localdomain bash[10874]: "Mozilla/5.0 Firefox/58.0"
May 19 17:26:19 localhost.localdomain bash[10874]: "Mozilla/5.0 Firefox/58.0"
May 19 17:26:19 localhost.localdomain bash[10874]: "Mozilla/5.0 Firefox/58.0"
May 19 17:26:19 localhost.localdomain bash[10874]: "Mozilla/5.0 Firefox/58.0"
May 19 17:26:19 localhost.localdomain bash[10874]: "Mozilla/5.0 Firefox/58.0"
May 19 17:26:19 localhost.localdomain bash[10874]: "Mozilla/5.0 Firefox/58.0"
May 19 17:26:19 localhost.localdomain bash[10874]: "Mozilla/5.0 Firefox/58.0"

```
-------------
### Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл. Имя сервиса должно так же называться.

```yum install epel-release -y && yum install spawn-fcgi -y && yum install httpd -y && yum install php php-cli mod_fcgid -y``` - самая сложная часть задания, которая тянет явно на * :) пару часов пришлось потратить, что бы понять, что собвстенно нужно этому ```spawn-fcgi``` что бы нормально запуститься.

Unit-файл достаточно простой, мне его хватило:
```
[Unit]
Description=Spawn FastCGI scripts to be used by web servers
After=network.target

[Service]
Type=forking
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
```
Также в конфиге ```/etc/sysconfig/spawn-fcgi``` нужно раскоментировать строки, без опций сервис не запустится.
-------------

