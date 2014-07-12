#!/bin/sh

LOG='/tmp/autoddvpn.log'
PID=$$
INFO="[INFO#${PID}]"
DEBUG="[DEBUG#${PID}]"
ERROR="[ERROR#${PID}]"

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") checkvpn.sh started" >> $LOG
/jffs/pptp/run.sh
while true
do
  if ping -c 1 www.facebook.com
  then
    n=1
  else
    sleep 10
    echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpn is down. Re-check at 1st time." >> $LOG
    if ping -c 1 www.facebook.com
    then
      n=2
    else
      sleep 10
      echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpn is down. Re-check at 2nd times." >> $LOG
      if ping -c 1 www.facebook.com
      then
        n=3
      else
        echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") Re-connect" >> $LOG
        /tmp/pptpd_client/vpn stop
        sleep 10
        /etc/config/pptpd_client.sh
        sleep 10
        /jffs/pptp/run.sh
      fi
    fi
  fi
  sleep 60
done
