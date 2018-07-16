#!/bin/bash
#TODO install rise automatically + clamav sigs
pacman -Syyu thunar file-roller libconfig gconf xorg xorg-xinit xorg-apps xorg-server xorg-xclock xorg-twm xterm xfce4-terminal packer openbox obmenu obconf chromium base-devel git wget openssh xf86-video-fbdev clamav ntp nano qt5-base --needed --noconfirm &
wait $PID

timedatectl set-ntp true
ln -sf /usr/share/zoneinfo/America/Chicago > /etc/localtime
#hwclock --systohc
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo 'enter device location: '
read dlocation
echo $dlocation > /etc/hostname

echo 'select a new root password'
passwd
echo 'create the signage user'
read duser
useradd -g users -G video,audio,power,storage,wheel -m $duser
echo 'set the signage user password'
passwd $duser

echo -e '%wheel ALL=(ALL) ALL\nDefaults rootpw\n' >> /etc/sudoers

if [ ! -e /home/$duser/.config ]
then
	mkdir /home/$duser/.config
fi

if [ ! -e /home/$duser/.config/openbox ]
then
	mkdir /home/$duser/.config/openbox
fi

if [ -e /home/$duser/.config/openbox/autostart ]
then
	echo -e "xset s off\nxset s noblank\nxset -dpms\nsetxkbmap -option terminate:ctrl_alt_bksp" > /home/$duser/.config/openbox/autostart
else
	touch /home/$duser/.config/openbox/autostart
	echo -e "xset s off\nxset s noblank\nxset -dpms\nsetxkbmap -option terminate:ctrl_alt_bksp" > /home/$duser/.config/openbox/autostart
	mv menu.xml /home/$duser/.config/openbox
fi

if [ -e /home/$duser/.xinitrc ]
then
	echo "exec openbox-session" > /home/$duser/.xinitrc
else
	touch /home/$duser/.xinitrc
	echo "exec openbox-session" > /home/$duser/.xinitrc
fi

if [ -e /home/$duser/.bash_profile ]
then
	#echo "[[ -z $DISPLAY && XDG_VTNR -eq 1 ]] && startx -- -nocursor" > /home/$duser/.bash_profile
	echo "startx -- -nocursor" > /home/$duser/.bash_profile
else
	touch /home/$duser/.bash_profile
	#echo "[[ -z $DISPLAY && XDG_VTNR -eq 1 ]] && startx -- -nocursor" > /home/$duser/.bash_profile
	echo "startx -- -nocursor" > /home/$duser/.bash_profile
fi

#add auto-install commands into user's .bash_profile and then just rewrite it
#for what is actually needed


cd /home/$duser
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

echo -e "                       _       _       _                     " > /etc/motd
echo -e "     /\               | |     | |     (_)                    " >> /etc/motd
echo -e "    /  \    _ __  ___ | |__   | |      _  _ __   _   _ __  __" >> /etc/motd
echo -e "   / /\ \  | '__|/ __|| '_ \  | |     | || '_ \ | | | |\ \/ /" >> /etc/motd
echo -e "  / ____ \ | |  | (__ | | | | | |____ | || | | || |_| | >  < " >> /etc/motd
echo -e " /_/    \_\|_|   \___||_| |_| |______||_||_| |_| \__,_|/_/\_\ " >> /etc/motd

if [ ! -e /etc/systemd/system/getty\@tty1.service.d]
then
	mkdir /etc/systemd/system/getty\@tty1.service.d
fi

if [ ! -e /etc/systemd/system/getty\@tty1/service.d/override.conf]
	touch /etc/systemd/system/getty@tty1.service.d/override.conf
fi
echo -e '[Service]\nExecStart=\nExecStart=-/sbin/agetty -a '$duser' --noclear %I $TERM' > /etc/systemd/system/getty@tty1.service.d/override.conf

chown -R $duser:users /home/$duser
touch /var/lib/clamav/clamd.sock
chown clamav:clamav /var/lib/clamav/clamd.sock
sed -i 's/LocalSocket \/run\/clamav\/clamd.ctl/LocalSocket \/etc\/clamav\/clamd.sock/' /etc/clamav/clamd.conf
freshclam &
wait $PID
systemctl enable clamav-freshclam.service
systemctl enable clamav-daemon.service

touch /etc/clamav/detected.sh
mv /root/detected.sh /etc/clamav/
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