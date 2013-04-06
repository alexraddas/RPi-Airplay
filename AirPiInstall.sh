menu(){
airpiname=$(grep DAEMON_ARGS= /etc/init.d/shairport | awk 'BEGIN {FS=" "} {print $4}' | awk 'BEGIN {FS="\""} {print $1}')
airpissid=$(grep ssid=\" /etc/wpa_supplicant/wpa_supplicant.conf | awk 'BEGIN {FS="\""}{print $2}')
airpissidpassword=$(grep psk=\" /etc/wpa_supplicant/wpa_supplicant.conf | awk 'BEGIN {FS="\""}{print $2}')
clear
echo "What would you like to do?"
echo "1: Install AirPi"
echo "2: Change SSID Association (Current SSID Name:$airpissid Current SSID Password:$airpissidpassword)"
echo "3: Change AirPi Name (Current Name:$airpiname)"
echo "4: Exit"
echo -n "Choice:"
read option
case $option in
1) airpiinstall;;
2) airpichangessid;;
3) airpichangename;;
4) exit 0;;
*) echo "Not A Valid Option"
sleep 1
menu;;
esac
}
airpichangessid(){
clear
echo "SSID for AirPi?"
read ssid
clear
echo "SSID Password?"
read ssidpassword
echo "Change SSID from $airpissid to $ssid ?"
echo "Change SSID Password from $airpissidpassword to $ssidpassword?"
echo -n "Choice(yes/no/quit):"
read option3
case $option3 in
yes) ;;
no)airpichangessid;;
quit)menu;;
*)echo
esac
clear
echo "Changing SSID to $ssid"
sed -i "4s/.*/ssid=\"$ssid\"/" /etc/wpa_supplicant/airpi.conf
sleep 1
echo "Changing SSID Password to $ssidpassword"
sed -i "7s/.*/psk=\"$ssidpassword\"/" /etc/wpa_supplicant/airpi.conf
sleep 1
echo "Bringing Up WLAN0"
ifup --force wlan0
menu
}

airpichangename(){
clear
echo "AirPi Name?"
read name
clear
echo "Change AirPi Name from $airpiname to $name ?"
echo -n "Choice(yes/no/quit):"
read option4
case $option4 in
yes) ;;
no)airpichangename;;
quit)menu;;
*)echo
esac
clear
echo "Changing AirPi Name to $name"
sed -i "22s/.*/DAEMON_ARGS=\"-w \$PIDFILE -a $name\"/" /etc/init.d/shairport
service shairport stop
service shairport start
sleep 1
menu
}

airpiinstall(){
clear
echo "Name Your AirPi?"
read name
clear
echo "SSID for AirPi?"
read ssid
clear
echo "SSID Password?"
read ssidpassword
confirm
}

confirm(){
clear 
echo "You are about to install AirPi with the following configuration," 
echo "AirPi Name: $name"
echo "SSID Name: $ssid"
echo "SSID Password $ssidpassword"
echo "if any of this is incorrect type restart, if you'd like to quit installation type quit, else type next"
read option2
case $option2 in
restart) airpiinstall;;
quit) menu;;
next) continue;;
*)echo "Not a Valid Choice"
sleep 1
confirm;;
esac
}

continue(){
apt-get update
apt-get install -y git
git clone https://github.com/alexraddas/RPi-Airplay /home/pi/AirPi
cd /home/pi/AirPi
apt-get install -y python-dev libcrypt-ssleay-perl wpasupplicant libao-dev libssl-dev libcrypt-openssl-rsa-perl libio-socket-inet6-perl libwww-perl avahi-utils
cd /home/pi/AirPi/perl
perl Build.PL
./Build
./Build test
./Build install
cd /home/pi/AirPi/airplay
make
make install
cp shairport.init.sample /etc/init.d/shairport
chmod a+x /etc/init.d/shairport
update-rc.d shairport defaults
cd /home/pi/AirPi/spidev
python setup.py install
cp /home/pi/AirPi/config/asound.conf /etc
cp /home/pi/AirPi/config/airpi.conf /etc/wpa_supplicant
cp /home/pi/AirPi/config/interfaces /etc/network
mkdir /etc/airpi
cp -r /home/pi/AirPi/scripts /etc/airpi
sed -i "4s/.*/ssid=\"$ssid\"/" /etc/wpa_supplicant/airpi.conf
sed -i "7s/.*/psk=\"$ssidpassword\"/" /etc/wpa_supplicant/airpi.conf
sed -i 's/blacklist spi-bcm2708/#blacklist spi-bcm2708/g' /etc/modprobe.d/raspi-blacklist.conf
sed -i "22s/.*/DAEMON_ARGS=\"-w \$PIDFILE -a $name\"/" /etc/init.d/shairport
typeset -i count
count=$(wc -l /etc/rc.local | awk 'BEGIN {FS=" "}{print $1}')
while [ "$count" -le 101 ]
do
echo " " >> /etc/rc.local
((count++))
done
sed -i "100s%.*%nohup python /etc/airpi/scripts/volume.py 0<&- &>/dev/null &%" /etc/rc.local
sed -i "101s%.*%nohup ./etc/airpi/scripts/wifiup.sh 0<&- &>/dev/null &%" /etc/rc.local  
echo "Your Pi Will Reboot in 60 Seconds"
sleep 60
reboot
}
menu
