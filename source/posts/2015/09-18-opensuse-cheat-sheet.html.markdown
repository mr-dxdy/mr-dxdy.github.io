---
title: Шпаргалка по OpenSUSE
date: 2015-09-18 11:21 MSK
tags:
- Новости
- Linux
---

## Обновление дистрибутива

Пример обновления OpenSuse с версии 13.1 до 13.2:

``` bash
sed -i 's/13\.1/13\.2/g' /etc/zypp/repos.d/*
zypper clean -a
zypper ref
zypper dup

```

## Настройка WI-FI

Настройка WI-FI для OpenSUSE 13.2:

``` bash
lspci | grep Network
# => BCM4312 802.11b/g LP-PHY (rev 01)

zypper addrepo --refresh --name "packman" http://packman.inode.at/suse/openSUSE_13.2/ packman
zypper in broadcom-wl broadcom-wl-kmp-desktop
```

### Источник

* [OpenSUSE GUIDE. Wifi Driver Installation](http://opensuse-guide.org/wlan.php)
