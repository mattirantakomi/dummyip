#!/usr/bin/env bash
set -eo pipefail

_term() {
  echo "TERM"
  exit 0
}
trap _term TERM

if [ -z "${INTERFACE}" ]; then
  echo "Environment variable INTERFACE not set"
  set +e
  tail -f /dev/null &
  wait $!
  set -e
fi

MYIP=$(dig +short ch txt whoami.cloudflare @1.1.1.1 | sed -e 's/"//g')

if [ -z "${PORT}" ]; then
  echo "Environment variable PORT not set"
  set +e
  tail -f /dev/null &
  wait $!
  set -e
else
  if [ "${PORT}" != "0" ]; then
    sed -i -e "s/<VirtualHost \*:80>/<VirtualHost \*:$PORT>/g" /etc/apache2/sites-enabled/000-default.conf
    sed -i -e "s/Listen 80/Listen $PORT/g" /etc/apache2/ports.conf

    ln -sf /dev/stdout /var/log/apache2/access.log
    ln -sf /dev/stdout /var/log/apache2/error.log

    /usr/sbin/apachectl start

    if [ "$(curl --connect-timeout 5 -s ${MYIP}:${PORT})" != "$NODENAME $PODNAME" ]; then
      echo "Echotest http://${MYIP}:${PORT}/ -- $NODENAME $PODNAME failed"
      /usr/sbin/apachectl stop

      set +e
      tail -f /dev/null &
      wait $!
      set -e
    else
      echo "Echotest http://${MYIP}:${PORT}/ -- $NODENAME $PODNAME successful"
    fi

    /usr/sbin/apachectl stop

  fi
fi

if [ "$(grep -c ${INTERFACE} /proc/net/dev)" == "1" ]; then
  ip link del ${INTERFACE} type dummy
fi

modprobe -v dummy numdummies=1
ip link add ${INTERFACE} type dummy
ifconfig ${INTERFACE} ${MYIP} netmask 255.255.255.255 broadcast ${MYIP}
ifconfig ${INTERFACE} up
ip route del local ${MYIP} dev ${INTERFACE} table local
ip route del broadcast ${MYIP} dev ${INTERFACE} proto kernel scope link src ${MYIP}

echo "IP address ${MYIP} successfully assigned to interface ${INTERFACE}"

set +e
tail -f /dev/null &
wait $!
