# Homework 4

## Загрузка системы

### Попасть в систему без пароля несколькими способами

При загрузке VM в меню Grub используем `e`, что позволит отредактировать опции загрузки:
* в строке `linux16 ...` добавляем `init=/bin/bash`
* в строке `linux16 ...` добавляем `rd.break`

Подобным способом можно также загрузиться в emergency и rescure режимы:
* в строке `linux16 ...` добавляем `systemd.unit=rescue.target`
* в строке `linux16 ...` добавляем `systemd.unit=emergency.target`



### Установить систему с LVM, после чего переименовать VG

Устанавливаем CentOS в VM, в разделе настройки диска выбираем установку на LVM.

После установки используя `vgs` получаем имя VG = `centos`.

`lvs` покажет, что существут LV c именем = `root`, где и примонтирован `/`

`vgrename -v centos rootvg` - переименовываем VG

`vi /etc/defaults/grub` - изменяем опцию `GRUB_CMDLINE_LINUX`, заменяя в ней имя VG на новое `rootvg`

`vi /etc/fstab` - изменяем опцию монтирования, также указывая новую VG `rootvg`

Перезагружаем VM и с установочного диска стартуем rescue режим, используем `chroot /mnt/sysimage` и получаем доступ к нашей системе.

`grub2-mkconfig -o /boot/grub2/grub.cfg` - создаем новый конфиг для Grub

Перезагружаем VM, запускаем систему штатно. Загрузка успешна с новым именем VG.



### Добавить модуль в initrd

`mkdir /usr/lib/dracut/modules.d/01test` - создаем каталог для тестового модуля

Модуль взят из слайдов лекции.

`test.sh` - сценарий модуля

`module-setup.sh` - сценарий установки модуля

`dracut -f /boot/initramfs-$(uname -r).img` - создаем новый образ initrd

`lsinitrd -m /boot/initramfs-$(uname -r).img` - получаем список модулей обновленного initrd, видим в нем наш модуль `test`

Посмотреть содержимое initrd собранного с использованием dracut можно командой:

`/usr/lib/dracut/skipcpio /boot/initramfs-$(uname -r).img | zcat | cpio -ivd`


### Сконфигурировать систему без отдельного раздела с /boot, а только с LVM

Добавим еще один VDI-диск для нашей VM. Подготовим его предварительно (отформатируем)

`pvcreate /dev/sdb1/ --bootloaderareasize 1M` - на новом диске создадим PV

`vgextend rootvg /dev/sdb1` - добавим в нашу VG новый PV

`pvmove /dev/sda2 /dev/sdv1` - перенесем данные на новый диск

`vgreduce rootvg /dev/sda2` -  избавимся от старого PV в нашей VG

`lvcreate -L 1G -n boot rootvg` - создадим новый LV для boot

`mkfs.xfs /dev/rootvg/boot` - отформатируем

Перезагружаем VM и с установочного диска стартуем rescue режим, где через `xfsdump` и `xfsrestore` переносим наш существующий `/boot` на созданный LV (детально команды описывать не стал, они были в прошлом домашнем задании).

Перезагружаем VM, запускаем систему штатно.

Правим `/etc/fstab`, где в строке монтирования `/boot` указываем вместо `UUID`, наш LV - `/dev/mapper/rootvg-boot`.

`yum-config-manager --add-repo=https://yum.rumyantsev.com/centos/7/x86_64/` - добавляем репозиторий с пропатченным под LVM Grub

`yum install grub2 -y --nogpgcheck` - устанавливаем grub

`grub2-install /dev/sdb1` - не уверен, что необходимо после установки Grub, но сделал на всякий случай

Выключаем  VM. Убираем из конфигурации первый диск, PORT 0 на контроллере назначаем для нашего /dev/sdb диска, добавленного ранее, который станет /dev/sda.

Включаем VM. Загрузка с LVM прошла успешно.
