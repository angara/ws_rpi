#!/bin/bash

# ws_rpi 2025.11.10

# /etc/crontab:
# */5 *   *  *  * root  /root/sensor.sh
# 7   */1 *  *  * root  /root/watch.sh

# rc.local:
#  sleep 10; /root/sensor.sh


# /root/watch.sh:

#!/bin/sh
#
# if ! ping -q -c 1 -W 9  "8.8.8.8"  > /dev/null;
# then
#   /sbin/reboot
# fi


dir=$(dirname "$0")

set -a
source "${dir}/.env"

url="http://rs.angara.net/meteo/_in?"
curl="curl -s -u ${USERNAME}:${PASSWORD} "

# ethernet mac
#hwid=`/sbin/ifconfig | grep eth0 | grep HWaddr | head -1 | awk '{print $5}'`

# raspberry-pi serial
hwid=$(cat /proc/cpuinfo | grep Serial | tr -d '[[:space:]]' | cut -d ':' -f 2)

cycle_file='/tmp/cycle'
cycle_data='/tmp/cycle.dat'

touch $cycle_file
cycle=$(($(cat $cycle_file)+1))
echo $cycle > $cycle_file
echo "cycle:" $cycle


# ds18b20:
#
ds=`find /sys/bus/w1/devices -name "28-*" | head -1`
rd=`cat $ds/w1_slave | tr '\n' ' '`

if [[ $rd =~ ^.*YES.*t=([\-0-9]+).*$ ]] ;
then
  val=${BASH_REMATCH[1]}
  echo "w1_slave: $val"
  val=`printf "%f" ${val}e-3`
else
  val=""
fi

tp="&t=${val}"

echo $cycle > $cycle_data
echo $tp   >> $cycle_data

qs="hwid=${hwid}&cycle=${cycle}${tp}"
echo "q:" $qs

rc=$(${curl} ${url}${qs})
echo "rc: ${rc}"

exit 0

#.
