# Homework 8

## Управление пакетами. Дистрибьюция софта. 

### Cоздать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями)

Для этого задания в nginx был добавлен модуль и собран RPM пакет.
Хост расположен в Google Cloud на базе Centos 7.

Установим все, что нам понадобится в этой домашней работе:
```bash
sudo yum install -y rpmdevtools \
                    gcc \ 
                    make \
                    wget \
                    gd-devel \
                    automake \ 
                    yum-utils \
                    perl-devel \
                    zlib-devel \
                    createrepo \
                    pcre-devel \
                    GeoIP-devel \
                    openssl-devel \
                    libxslt-devel \
                    openldap-devel \
                    perl-ExtUtils-Embed 
```
Создаем пользователя и логинимся в него:
```bash
sudo adduser builder
sudo passwd builder
sudo gpasswd -a builder wheel
sudo su - builder
```
Создаем структуру каталогов и скачиваем ```SRPM``` пакет nginx:
```bash
rpmdev-setuptree
rpm -Uvh http://nginx.org/packages/rhel/7/SRPMS/nginx-1.10.1-1.el7.ngx.src.rpm
```
Далее забираем с Github модуль nginx, который хотим добавить и готовим его нужным образом, кладем в ```SOURCES```:
```bash
wget -O master.zip https://github.com/kvspb/nginx-auth-ldap/archive/master.zip
unzip master.zip
mv nginx-auth-ldap-master/ nginx-auth-ldap-0.1
tar cfz nginx-auth-ldap-0.1.tar.gz nginx-auth-ldap-0.1
mv nginx-auth-ldap-0.1.tar.gz  ~/rpmbuild/SOURCES/
rm -rf master.zip nginx-auth-ldap-0.1/
```
Правим SPEC файл:
```bash
vi /home/builder/rpmbuild/SPECS/nginx.spec

# Добавим в Source
  Source14: nginx-auth-ldap-0.1.tar.gz
  
# Добавим в %prep
  %{__tar} zxvf %{SOURCE14}
  %setup -T -D -a 14
  
# Добавим в %build
./configure %{COMMON_CONFIGURE_ARGS} \
    --with-cc-opt="%{WITH_CC_OPT}" \
    --add-module=%{_builddir}/%{name}-%{main_version}/nginx-auth-ldap-0.1
```
Соберем новый пакет и установим его:
```bash
rpmbuild -ba /home/builder/rpmbuild/SPECS/nginx.spec
sudo rpm -i /home/builder/rpmbuild/RPMS/x86_64/nginx-1.10.1-1.el7.ngx.x86_64.rpm
```
Получим удачную установку nginx:
```
----------------------------------------------------------------------

Thanks for using nginx!

Please find the official documentation for nginx here:
* http://nginx.org/en/docs/

Commercial subscriptions for nginx are available on:
* http://nginx.com/products/

----------------------------------------------------------------------
```
Проверим, что модуль установлен через ```nginx -V```:

```--add-module=/home/builder/rpmbuild/BUILD/nginx-1.10.1/nginx-auth-ldap-0.1```

Готово!

### Создать свой репо и разместить там свой RPM

Раз уж nginx у нас уже установлен, сделаем из него репозиторий для yum

Почистим стандартные шаблоны nginx и положим вместо них наши RPM пакеты, собранные в первой части ДЗ:
```bash
sudo rm -rf /usr/share/nginx/html/*
sudo cp /home/builder/rpmbuild/RPMS/x86_64/*.rpm /usr/share/nginx/html/
```
Создадим репозиторий и подготовим:
```
sudo createrepo /usr/share/nginx/html/
sudo createrepo --update /usr/share/nginx/html/
```
Запустим nginx, что бы получить доступ к репозиторию:
```bash
sudo systemctl start nginx
```
Создадим новый конфиг для yum репозитория:
```bash
sudo vi /etc/yum.repos.d/zolti.repo

[zolti]
name=zolti
baseurl=http://35.189.228.32
gpgcheck=0
```
Взять конфиг для репозитория (для проверки) можно здесь [zolti.repo](./zolti.repo)

Адрес доступен извне, можно протестировать репозиторий.

Запросим список пакетов с репозитория:
```bash
yum repo-pkgs zolti list
```
И установим из него пакет:
```bash
yum --enablerepo=zolti install nginx-debuginfo
```
Готово!

### Реализовать дополнительно пакет через docker 
Докер очень надоел на работе, поэтому это дополнительное задание делать не стал, надо скорее браться за ДЗ №9 :)
