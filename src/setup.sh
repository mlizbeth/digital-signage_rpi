#Rise doesn't disable the cursor.
#!/bin/bash
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen &
wait $PID
passwd
echo "Enter the location for this device"
read loc
echo $loc > /etc/hostname
mv keyboard /etc/default/keyboard
mv wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
sed -i 's/gpu_mem=64/gpu_mem=256/' /boot/config.txt
apt update & 
wait $PID
DEBIAN_FRONTEND=noninteractive apt install -y gufw realvnc-vnc-server unclutter xscreensaver clamav raspberrypi-ui-mods rpi-chromium-mods file-roller xorg xserver-xorg xserver-xorg-video-fbdev & 
wait $PID
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
#if [ ! -e /home/pi/.bash_profile ]
#then
#	touch /home/pi/.bash_profile
#fi
#echo "startx #-- -nocursor" > /home/pi/.bash_profile
#In testing this didn't seem to work with the above packages.
# if [ ! -e /etc/systemd/system/getty\@tty1.service.d ]
# then
# 	mkdir /etc/systemd/system/getty\@tty1.service.d
# fi
# if [ ! -e /etc/systemd/system/getty\@tty1/service.d/override.conf ]
# then
# 	touch /etc/systemd/system/getty\@tty1.service.d/override.conf
# fi
# echo '[Service]\nExecStart=\nExecStart=-/sbin/agetty -a pi --noclear %I $TERM' > /etc/systemd/system/getty@tty1.service.d/override.conf
chown -R pi:users /home/pi
sed -i 's/#Port 22/Port 13337/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
sed -i 's/#MaxSessions 10/MaxSessions 2/' /etc/ssh/sshd_config
sed -i 's/gpu_mem=64/gpu_mem=256/' /boot/config.txt
sed -i 's/disable_overscan=1/#disable_overscan=1/' /boot/config.txt
systemctl enable ssh
systemctl start ssh
systemctl enable vncserver-x11-serviced
systemctl start vncserver-x11-serviced
