#!/bin/sh

LOG='/tmp/autoddvpn.log'
LOCK='/tmp/autoddvpn.lock'
PID=$$
INFO="[INFO#${PID}]"
DEBUG="[DEBUG#${PID}]"
ERROR="[ERROR#${PID}]"

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") checkvpn.sh started" >> $LOG
/jffs/pptp/run.sh
while true
do
  if ping -c 1 192.168.100.1
  then
    n=1
  else
    sleep 60
    echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpn is down. Re-check at 1st time." >> $LOG
    if ping -c 1 192.168.100.1
    then
      n=2
    else
      sleep 60
      echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpn is down. Re-check at 2nd times." >> $LOG
      if ping -c 1 192.168.100.1
      then
        n=3
      else
        echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") Re-connect" >> $LOG
        #Clean the system
        pidof vpnup.sh | xargs kill -s 9
        pidof vpndown.sh | xargs kill -s 9
        rm -f $LOCK
        #Stop the VPN
        /tmp/pptpd_client/vpn stop
        sleep 15
        #Restart system VPN
        /etc/config/pptpd_client.sh
        sleep 15
        /jffs/pptp/run.sh
      fi
    fi
  fi
  sleep 60
done
