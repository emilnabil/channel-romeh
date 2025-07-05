#!/bin/sh
#
# Command:
# wget https://raw.githubusercontent.com/emilnabil/channel-romeh/main/installer.sh -qO - | /bin/sh
#
# ###########################################################

MY_URL="https://raw.githubusercontent.com/emilnabil/channel-romeh/main"

echo "******************************************************************************************************************"
echo "        DOWNLOAD AND INSTALL CHANNEL"
echo "=================================================================================================================="
echo "        REMOVE OLD CHANNELS..."

rm -rf /etc/enigma2/lamedb
rm -rf /etc/enigma2/*list
rm -rf /etc/enigma2/*.tv
rm -rf /etc/enigma2/*.radio

#####################################################################################
echo "        INSTALLING NEW CHANNELS..."
cd /tmp
set -e
wget -q "${MY_URL}/channels_backup_by-romeh.tar.gz"
tar -xzf channels_backup_by-romeh.tar.gz -C /
cd ..
set +e
rm -f /tmp/channels_backup_by-romeh.tar.gz
sleep 2

echo ""
echo "        INSTALLING ASTRA-SM PATCH"
opkg install astra-sm -y >/dev/null 2>&1
sleep 1
echo ""
echo ""
echo "****************************************************************************************************************************"
echo "#       CHANNEL INSTALLED SUCCESSFULLY       #"
echo "*********************************************************"
echo "********************************************************************************"
echo "   UPLOADED BY >>>> EMIL_NABIL"
sleep 4
echo "========================================================================================================================="
echo "        >>>> RESTARTING <<<<"
echo "**********************************************************************************"

killall -9 enigma2
exit 0





