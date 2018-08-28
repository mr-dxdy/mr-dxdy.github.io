---
title: Настройка monit
date: 2018-08-28 15:14 MSK
tags:
- Новости
- Monit
---

Заходим по ssh на сервер: `ssh user@your-server`

Устанавливаем приложение monit: `sudo apt-get install monit`

Открываем доступ к админке через http:

``` bash
sudo vim /etc/monit/monitrc
```

Находим раздел и редактируем:

``` bash
set httpd port 2812 and
    use address your-server
    allow 0.0.0.0/0.0.0.0
    allow admin:monit
```

Перезагружаем службу `sudo service monit reload`. Проверяем работоспособность админки: `http://your-server:2812`

READMORE

Редактируем раздел, откуда брать конфиги:

``` bash
#   include /etc/monit/conf.d/*
include /etc/monit/conf-enabled/*
```

Напишем конфиг для запуска службы. Хранение конфигов схоже с продуктом nginx.
Все конфиги  надо складывать в папку `/etc/monit/conf-available` и делать линки на эти конфиги в папку `/etc/monit/conf-enabled`.  
Для многих известных служб уже написаны конфиги. Их можно найти [тут](https://mmonit.com/wiki/Monit/ConfigurationExamples).

У Monit свой DSL для написания конфигов, который очень легко читать (подробнее [тут](https://mmonit.com/monit/documentation/monit.html#GENERAL-SYNTAX)). Пример конфига для postgresql:

``` ruby
check process postgresql with pidfile /var/run/postgresql/9.6-main.pid
  group database
  start program = "/etc/init.d/postgresql start"
  stop  program = "/etc/init.d/postgresql stop"
  if failed host localhost port 5432 protocol pgsql then restart
  if 5 restarts with 5 cycles then timeout
```

Теперь проверим, что конфиг - валидный: `sudo monit -t`.
Если синтаксис корректный, то перезагружаем monit: `sudo monit reload`.

Теперь напишем конфиг для запуска сервера Puma:

``` ruby
check process your-app-puma with pidfile /srv/www/your-app/shared/tmp/pids/puma.pid
  group site
  start program = "/bin/su - user -c 'cd /srv/www/your-app/current && bundle exec pumactl -F /srv/www/your-app/shared/puma.rb start'" with timeout 10 seconds
  stop program = "/bin/su - user -c 'cd /srv/www/your-app/current && bundle exec pumactl -F /srv/www/your-app/shared/puma.rb stop'" with timeout 10 seconds
  if 3 restarts within 3 cycles then timeout
```

Пример конфига для запуска gitlab-runner. Здесь проверка службы происходит не по pid, а по названию процесса:

``` ruby
check process gitlab-runner matching "gitlab-runner"
  group gitlab-ci
  start   program = "/usr/sbin/service gitlab-runner start"
  stop    program = "/usr/sbin/service gitlab-runner stop"
  restart program = "/usr/sbin/service gitlab-runner restart"
  if 5 restarts with 5 cycles then timeout
```

Источники:

1. [Официальная документация](https://mmonit.com/monit/documentation/monit.html)
