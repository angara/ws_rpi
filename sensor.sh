#!/bin/bash

# ws_rpi

# /etc/crontabs/root:
# */5 *   *  *  *  /www/sensor.sh
# 3   */2 *  *  *  /www/watch.sh

# /etc/crontab:
# */5 *   *  *  * root  /www/sensor.sh
# 7   */1 *  *  * root  /www/watch.sh

# rc.local:
#  sleep 10; /www/sensor.sh

# /www/watch.sh:

#!/bin/sh
#
# if ! ping -q -c 1 -W 9  "8.8.8.8"  > /dev/null;
# then
#   /sbin/reboot
# fi

dir=$(dirname "$0")

set -a
source "${dir}/.env"

url='http://rs.angara.net/meteo/_in?'
curl='curl -s -u ${USERNAME}:${PASSWORD} '

# ethernet mac
#hwid=`/sbin/ifconfig | grep eth0 | grep HWaddr | head -1 | awk '{print $5}'`

# raspberry-pi serial
hwid=$(cat /proc/cpuinfo | grep Serial | tr -d '[[:space:]]' | cut -d ':' -f 2)

# key=$(cat "${dir}/secret")

cycle_file='/tmp/cycle'
cycle_data='/tmp/cycle.dat'

touch $cycle_file
cycle=$(($(cat $cycle_file)+1))
echo $cycle > $cycle_file
echo "cycle:" $cycle


# tp=$("${dir}/bmp085.py")

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
# hk=`echo -n "${qs}${key}" | sha1sum | cut -f 1 -d " "`

echo "q:" $qs 

#qs="${qs}&_hkey=${hk}"
rc=$(${curl} ${url}${qs})

echo "rc: ${rc}"

exit 0

#.
