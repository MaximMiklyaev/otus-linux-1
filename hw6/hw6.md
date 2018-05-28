# Homework 6

## Systemd

### Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig

Скрипт парсинга лог файла ```searchlog.sh```:
```bash
#!/bin/bash
awk "/$keyword/ { print $12" "$18}" $logfile
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
ExecStart=/bin/bash searchlog.sh
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

```yum install epel-release -y && yum install spawn-fcgi -y && yum install httpd -y && yum install php php-cli mod_fcgid -y``` - самая сложная часть задания, которая тянет явно на * :) 

пару часов пришлось потратить, что бы понять, что собвстенно нужно этому ```spawn-fcgi``` что бы нормально запуститься.

Unit-файл достаточно простой, мне его хватило:
```
[Unit]
Description=Spawn FastCGI scripts to be used by web servers
After=network.target

[Service]
Type=simple
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
```
Также в конфиге ```/etc/sysconfig/spawn-fcgi``` нужно раскоментировать строки, без опций сервис не запустится.

-------------
### Дополнить юнит-файл apache httpd возможностьб запустить несколько инстансов сервера с разными конфигами

```cp /usr/lib/systemd/system/httpd.service /usr/lib/systemd/system/httpd@instance1.service``` - создаем шаблон для инстанса httpd

В unit-файле инстанса изменил лишь одну строку для загрузки httpd с другим конфигом:
```
ExecStart=/usr/sbin/httpd -f %i.conf -DFOREGROUND
```
И создал этот конфиг в ```/etc/httpd/instance1.conf```, который является копией оригинального httpd конфига, в котором изменен ```PidFile``` и ```Listen``` порт.

```systemctl start httpd@instance1.service``` - запускаем еще один инстанс httpd

```systemctl status httpd@instance1.service``` - получаем статус:
```
● httpd@instance1.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd@instance1.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2018-05-19 20:03:54 EDT; 8min ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 2411 (httpd)
   Status: "Total requests: 1; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@instance1.service
           ├─2411 /usr/sbin/httpd -f instance1.conf -DFOREGROUND
           ├─2412 /usr/sbin/httpd -f instance1.conf -DFOREGROUND
           ├─2413 /usr/sbin/httpd -f instance1.conf -DFOREGROUND
           ├─2414 /usr/sbin/httpd -f instance1.conf -DFOREGROUND
           ├─2415 /usr/sbin/httpd -f instance1.conf -DFOREGROUND
           ├─2416 /usr/sbin/httpd -f instance1.conf -DFOREGROUND
           └─2417 /usr/sbin/httpd -f instance1.conf -DFOREGROUND

May 19 20:03:54 localhost.localdomain systemd[1]: Starting The Apache HTTP Server...
May 19 20:03:54 localhost.localdomain systemd[1]: Started The Apache HTTP Server.
```

