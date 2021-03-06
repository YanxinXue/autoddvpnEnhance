#!/bin/sh

LOG='/tmp/autoddvpn.log'
LOCK='/tmp/autoddvpn.lock'
PID=$$
INFO="[INFO#${PID}]"
DEBUG="[DEBUG#${PID}]"
ERROR="[ERROR#${PID}]"

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") checkvpn.sh started" >> $LOG
/jffs/pptp/run.sh
#Wait vpn connect at 1st times
sleep 180
while true
do
  if ping -c 1 www.facebook.com
  then
    n=1
  else
    sleep 60
    echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpn is down. Re-check at 1st time." >> $LOG
    if ping -c 1 www.facebook.com
    then
      n=2
    else
      sleep 60
      echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpn is down. Re-check at 2nd times." >> $LOG
      if ping -c 1 www.facebook.com
      then
        n=3
      else
        echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") Re-connect" >> $LOG
        pidof vpnup.sh | xargs kill -s 9
        pidof vpndown.sh | xargs kill -s 9
        pidof run.sh | xargs kill -s 9
        rm -f $LOCK
        echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") Kill shell script" >> $LOG
        /jffs/pptp/vpndown.sh
        sleep 60
        echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") Add route back" >> $LOG
        /tmp/pptpd_client/vpn stop
        sleep 60
        /etc/config/pptpd_client.sh
        sleep 60
        /jffs/pptp/run.sh
      fi
    fi
  fi
  sleep 60
done