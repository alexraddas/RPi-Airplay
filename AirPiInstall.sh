apt-get update -y
apt-get -y upgrade
apt-get install git
git clone https://github.com/alexraddas/RPi-Airplay /home/pi/AirPi
cd /home/pi/AirPi
apt-get install wpa-supplicant libao-dev libssl-dev libcrypt-openssl-rsa-perl libio-socket-inet6-perl libwww-perl avahi-utils$
perl /home/pi/RPi-Airplay/perl-net-sdp/Build.PL
sudo ./home/pi/RPi-Airplay/perl-net-sdp/Build
sudo ./home/pi/RPi-Airplay/perl-net-sdp/Build test
sudo ./home/pi/RPi-Airplay/perl-net-sdp/Build install
make /home/pi/RPi-Airplay/shairport
make /home/pi/RPi-Airplay/shairport/install
chmod a+x /etc/init.d/shairport
update-rc.d shairport defaults
cp /home/pi/RPi-Airplay/config/asound.conf /etc
cp /home/pi/RPi-Airplay/config/wpa-supplicant.conf /etc/wpa-supplicant
