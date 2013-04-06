apt-get update
apt-get -y upgrade
apt-get install git
git clone https://github.com/alexraddas/RPi-Airplay /home/pi/AirPi
cd /home/pi/AirPi
apt-get -y install libcrypt-ssleay-perl wpasupplicant libao-dev libssl-dev libcrypt-openssl-rsa-perl libio-socket-inet6-perl libwww-perl avahi-utils
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
cp /home/pi/AirPi/config/asound.conf /etc
cp /home/pi/AirPi/config/wpa_supplicant.conf /etc/wpa-supplicant
cp /home/pi/AirPi/config/interfaces /etc/network
