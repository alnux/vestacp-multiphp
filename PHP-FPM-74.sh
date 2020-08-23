#!/bin/bash
user="$1"
domain="$2"
ip="$3"
home_dir="$4"
docroot="$5"

pool_conf="[$2]
listen = /run/php74-fpm-$2.sock
listen.allowed_clients = 127.0.0.1

user = $1
group = $1

listen.owner = $1
listen.group = apache

pm = ondemand
pm.max_children = 4
pm.max_requests = 4000
pm.process_idle_timeout = 10s
pm.status_path = /status

php_admin_value[upload_tmp_dir] = /home/$1/tmp
php_admin_value[session.save_path] = /home/$1/tmp
php_admin_value[sendmail_path] = \"/usr/sbin/sendmail -t -i -f info@$2\"

env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /home/$1/tmp
env[TMPDIR] = /home/$1/tmp
env[TEMP] = /home/$1/tmp
"

pool_file_56="/opt/remi/php56/root/etc/php-fpm.d/$2.conf"
pool_file_70="/etc/opt/remi/php70/php-fpm.d/$2.conf"
pool_file_71="/etc/opt/remi/php71/php-fpm.d/$2.conf"
pool_file_72="/etc/opt/remi/php72/php-fpm.d/$2.conf"
pool_file_73="/etc/opt/remi/php73/php-fpm.d/$2.conf"
pool_file_74="/etc/opt/remi/php74/php-fpm.d/$2.conf"

if [ -f "$pool_file_56" ]; then
    rm $pool_file_56
    systemctl restart php56-php-fpm
fi

if [ -f "$pool_file_70" ]; then
    rm $pool_file_70
    systemctl restart php70-php-fpm
fi

if [ -f "$pool_file_71" ]; then
    rm $pool_file_71
    systemctl restart php71-php-fpm
fi

if [ -f "$pool_file_72" ]; then
    rm $pool_file_72
    systemctl restart php72-php-fpm
fi

if [ -f "$pool_file_73" ]; then
    rm $pool_file_73
    systemctl restart php73-php-fpm
fi

write_file=0
if [ ! -f "$pool_file_74" ]; then
  write_file=1
else
  user_count=$(grep -c "/home/$1/" $pool_file_74)
  if [ $user_count -eq 0 ]; then
    write_file=1
  fi
fi
if [ $write_file -eq 1 ]; then
    echo "$pool_conf" > $pool_file_74
    systemctl restart php74-php-fpm
fi
if [ -f "/etc/opt/remi/php74/php-fpm.d/www.conf" ]; then
    rm /etc/opt/remi/php74/php-fpm.d/www.conf
fi

exit 0
