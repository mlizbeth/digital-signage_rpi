apt update
DEBIAN_FRONTEND=noninteractive apt install -y file-roller thunar gvfs clamav gufw xorg xserver-xorg xserver-xorg-video-fbdev openbox openbox-menu openbox-themes obconf-qt xfce4-terminal chromium-browser &
wait $PID
if [ ! -e /home/pi/.config ]
then
	mkdir /home/pi/.config
fi

if [ ! -e /home/pi/.config/openbox ]
then
	mkdir /home/pi/.config/openbox
fi

sed -i 's/chromium/chromium-browser/' menu.xml
mv menu.xml /home/pi/.config/openbox

if [ ! -e /home/pi/.config/openbox/autostart ]
then
	touch /home/pi/.config/openbox/autostart
fi
echo "xset s off\nxset s noblank\nxset -dpms\nsetxkbmap -option terminate:ctrl_alt_bksp" > /home/pi/.config/openbox/autostart


if [ ! -e /home/pi/.xinitrc ]
then
	touch /home/pi/.xinitrc
fi
echo "exec openbox-session" > /home/pi/.xinitrc


if [ ! -e /home/pi/.bash_profile ]
then
	touch /home/pi/.bash_profile
fi
echo "startx -- -nocursor" > /home/pi/.bash_profile


cd /home/pi
wget install-versions.risevision.com/installer-lnx-armv7l.sh
chmod +x installer-lnx-armv7l.sh

echo "  _______     _         _  _          " > /etc/issue
echo " |__   __|   (_)       (_)| |         " >> /etc/issue
echo "    | | _ __  _  _ __   _ | |_  _   _ " >> /etc/issue
echo "    | || '__|| || '_ \ | || __|| | | |" >> /etc/issue
echo "    | || |   | || | | || || |_ | |_| |" >> /etc/issue
echo "    |_||_|   |_||_| |_||_| \__| \__, |" >> /etc/issue
echo "                                 __/ |" >> /etc/issue
echo "                                |___/ " >> /etc/issue

echo "______ ___________ _____  ___   _   _ " > /etc/motd
echo "|  _  \  ___| ___ \_   _|/ _ \ | \ | |" >> /etc/motd
echo "| | | | |__ | |_/ / | | / /_\ \|  \| |" >> /etc/motd
echo "| | | |  __|| ___ \ | | |  _  || . \ |" >> /etc/motd
echo "| |/ /| |___| |_/ /_| |_| | | || |\  |" >> /etc/motd
echo "|___/ \____/\____/ \___/\_| |_/\_| \_/" >> /etc/motd

                                      

if [ ! -e /etc/systemd/system/getty\@tty1.service.d ]
then
	mkdir /etc/systemd/system/getty\@tty1.service.d
fi

if [ ! -e /etc/systemd/system/getty\@tty1/service.d/override.conf ]
then
	touch /etc/systemd/system/getty\@tty1.service.d/override.conf
fi
echo '[Service]\nExecStart=\nExecStart=-/sbin/agetty -a pi --noclear %I $TERM' > /etc/systemd/system/getty@tty1.service.d/override.conf

chown -R pi:users /home/pi
#touch /var/lib/clamav/clamd.sock
#chown clamav:clamav /var/lib/clamav/clamd.sock
#systemctl stop clamav-daemon.service
freshclam &
wait $PID
#systemctl enable clamav-freshclam.service
#systemctl enable clamav-daemon.service

#mv detected.sh /etc/clamav/
#sed -i '/ScanOnAccess yes/s/^#//' /etc/clamav/clamd.conf
#sed -i '/OnAccessMountPath \//s/^#//' /etc/clamav/clamd.conf
#sed -i '/OnAcessPrevention yes/s/^#//' /etc/clamav/clamd.conf
#sed -i '/OnAcessExtraScanning yes/s/^#//' /etc/clamav/clamd.conf
#sed -i 's/User clamav/User root/' /etc/clamav/clamd.conf
#echo -e "VirusEvent /etc/clamav/detected.sh" >> /etc/clamav/clamd.conf

sed -i 's/#Port 22/Port 13337/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
sed -i 's/#MaxSessions 10/MaxSessions 2/' /etc/ssh/sshd_config

sed -i 's/gpu_mem=64/gpu_mem=256/' /boot/config.txt
sed -i 's/disable_overscan=1/#disable_overscan=1' /boot/config.txt
systemctl enable sshd
systemctl start sshd
