DEBIAN_FRONTEND=noninteractive apt install -y clamav gufw xorg xserver-xorg xserver-xorg-video-fbdev openbox openbox-menu openbox-themes obconf-qt xfce4-terminal chromium-browser &
wait $PID
if [ ! -e /home/pi/.config ]
then
	mkdir /home/pi/.config
fi

if [ ! -e /home/pi/.config/openbox ]
then
	mkdir /home/pi/.config/openbox
fi

mv menu.xml /home/pi/.config/openbox

if [ ! -e /home/pi/.config/openbox/autostart ]
then
	touch /home/pi/.config/openbox/autostart
else
	echo -e "xset s off\nxset s noblank\nxset -dpms\nsetxkbmap -option terminate:ctrl_alt_bksp" > /home/pi/.config/openbox/autostart
fi

if [ ! -e /home/pi/.xinitrc ]
then
	touch /home/pi/.xinitrc
else
	echo -e "exec openbox-session" > /home/pi/.xinitrc
fi

if [ ! -e /home/pi/.bash_profile ]
then
	touch /home/pi/.bash_profile
else
	echo "startx -- -nocursor" > /home/pi/.bash_profile
fi

cd /home/pi
git clone https://aur.archlinux.org/package-query.git
git clone https://aur.archlinux.org/yaourt.git
wget install-versions.risevision.com/installer-lnx-armv7l.sh
chmod +x installer-lnx-armv7l.sh

echo -e "  _______     _         _  _          " > /etc/issue
echo -e " |__   __|   (_)       (_)| |         " >> /etc/issue
echo -e "    | | _ __  _  _ __   _ | |_  _   _ " >> /etc/issue
echo -e "    | || '__|| || '_ \ | || __|| | | |" >> /etc/issue
echo -e "    | || |   | || | | || || |_ | |_| |" >> /etc/issue
echo -e "    |_||_|   |_||_| |_||_| \__| \__, |" >> /etc/issue
echo -e "                                 __/ |" >> /etc/issue
echo -e "                                |___/ " >> /etc/issue

echo -e "______ ___________ _____  ___   _   _ " > /etc/issue
echo -e "|  _  \  ___| ___ \_   _|/ _ \ | \ | |" >> /etc/issue
echo -e "| | | | |__ | |_/ / | | / /_\ \|  \| |" >> /etc/issue
echo -e "| | | |  __|| ___ \ | | |  _  || . \ |" >> /etc/issue
echo -e "| |/ /| |___| |_/ /_| |_| | | || |\  |" >> /etc/issue
echo -e "|___/ \____/\____/ \___/\_| |_/\_| \_/" >> /etc/issue

                                      

if [ ! -e /etc/systemd/system/getty\@tty1.service.d ]
then
	mkdir /etc/systemd/system/getty\@tty1.service.d
fi

if [ ! -e /etc/systemd/system/getty\@tty1/service.d/override.conf ]
then
	touch /etc/systemd/system/getty\@tty1.service.d/override.conf
fi
echo -e '[Service]\nExecStart=\nExecStart=-/sbin/agetty -a pi --noclear %I $TERM' > /etc/systemd/system/getty@tty1.service.d/override.conf

chown -R pi:users /home/pi
touch /var/lib/clamav/clamd.sock
chown clamav:clamav /var/lib/clamav/clamd.sock
sed -i 's/LocalSocket \/run\/clamav\/clamd.ctl/LocalSocket \/etc\/clamav\/clamd.sock/' /etc/clamav/clamd.conf
systemctl stop clamav-daemon.service
freshclam &
wait $PID
systemctl enable clamav-freshclam.service
systemctl enable clamav-daemon.service

mv detected.sh /etc/clamav/
sed -i '/ScanOnAccess yes/s/^#//' /etc/clamav/clamd.conf
sed -i '/OnAccessMountPath \//s/^#//' /etc/clamav/clamd.conf
sed -i '/OnAcessPrevention yes/s/^#//' /etc/clamav/clamd.conf
sed -i '/OnAcessExtraScanning yes/s/^#//' /etc/clamav/clamd.conf
sed -i 's/User clamav/User root/' /etc/clamav/clamd.conf
echo -e "VirusEvent /etc/clamav/detected.sh" >> /etc/clamav/clamd.conf

sed -i 's/#Port 22/Port 13337/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
sed -i 's/#MaxSessions 10/MaxSessions 2/' /etc/ssh/sshd_config

sed -i 's/gpu_mem=64/gpu_mem=256/' /boot/config.txt
sed -i 's/disable_overscan=1/#disable_overscan=1' /boot/config.txt
systemctl enable sshd
systemctl start sshd