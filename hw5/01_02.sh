#!/bin/bash
services=('dhcpcd' 'nginx')
mail="mail@mail.com"
mailsubj="example mail subject"

for service in "${services[@]}"; do
        var=`ps -eaf | grep ${service} | grep -v grep | wc -l`
        if [ "$var" -lt "1" ]; then
          systemctl restart ${service}
            if [ "$var" -lt "1" ]; then
              echo "${service} could not be restarted!" | mail -s "$mailsubj" $mail
            else
              echo "${service} was restarted successfully." | mail -s "$mailsubj" $mail
            fi
        else
          echo "${service} is already running."
        fi
done
