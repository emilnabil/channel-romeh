#!/bin/sh
# ###########################################
# SCRIPT : DOWNLOAD AND INSTALL Channel
# ###########################################
# Command: wget https://raw.githubusercontent.com/emilnabil/channel-romeh/main/installer.sh -qO - | /bin/sh

TMPDIR='/tmp'
PACKAGE='astra-sm'
MY_URL='https://raw.githubusercontent.com/emilnabil/channel-romeh/main'

VERSION=$(wget $MY_URL/version -qO- | cut -d "=" -f2-)

BINPATH=/usr/bin
ETCPATH=/etc
ASTRAPATH=${ETCPATH}/astra

BBCPMT=${BINPATH}/bbc_pmt_starter.sh
BBCPY=${BINPATH}/bbc_pmt_v6.py
BBCENIGMA=${BINPATH}/enigma2_pre_start.sh

SYSCONF=${ETCPATH}/sysctl.conf
ASTRACONF=${ASTRAPATH}/astra.conf
ABERTISBIN=${ASTRAPATH}/scripts/abertis

CONFIGpmttmp=${TMPDIR}/bbc_pmt_v6/bbc_pmt_starter.sh
CONFIGpytmp=${TMPDIR}/bbc_pmt_v6/bbc_pmt_v6.py
CONFIGentmp=${TMPDIR}/bbc_pmt_v6/enigma2_pre_start.sh
CONFIGsysctltmp=${TMPDIR}/${PACKAGE}/sysctl.conf
CONFIGastratmp=${TMPDIR}/${PACKAGE}/astra.conf
CONFIGabertistmp=${TMPDIR}/${PACKAGE}/abertis

if [ -f /etc/opkg/opkg.conf ]; then
    STATUS='/var/lib/opkg/status'
    OSTYPE='Opensource'
    OPKG='opkg update'
    OPKGINSTAL='opkg install'
fi

rm -rf /etc/enigma2/lamedb /etc/enigma2/*list /etc/enigma2/*.tv /etc/enigma2/*.radio

install() {
    if ! grep -qs "Package: $1" $STATUS; then
        $OPKG >/dev/null 2>&1
        echo "   >>>>   Installing package: $1   <<<<"
        $OPKGINSTAL "$1" >/dev/null 2>&1
        sleep 1
    fi
}

if [ "$OSTYPE" = "Opensource" ]; then
    for i in dvbsnoop $PACKAGE; do
        install $i
    done
fi

case $(uname -m) in
    armv7l*) plarform="arm" ;;
    mips*) plarform="mips" ;;
esac

rm -rf ${ASTRACONF} ${SYSCONF}
rm -rf ${TMPDIR}/channels_backup_by_"${VERSION}"* astra-* bbc_pmt_v6*

echo
set -e
echo ">>> Downloading and installing channel, please wait..."
wget $MY_URL/channels_backup_by-romeh.tar.gz -qP $TMPDIR
tar -zxf $TMPDIR/channels_backup_by-romeh.tar.gz -C /
sleep 5
set +e

if [ -f $BBCPMT ] && [ -f $BBCPY ] && [ -f $BBCENIGMA ]; then
    echo ">>> All BBC config files already exist"
    sleep 2
else
    set -e
    echo ">>> Downloading BBC config files..."
    wget $MY_URL/bbc_pmt_v6.tar.gz -qP $TMPDIR
    tar -xzf $TMPDIR/bbc_pmt_v6.tar.gz -C $TMPDIR
    set +e
    [ ! -f $BBCPMT ] && cp -f $CONFIGpmttmp $BINPATH && chmod 755 $BBCPMT && echo "[bbc_pmt_starter.sh copied]"
    [ ! -f $BBCPY ] && cp -f $CONFIGpytmp $BINPATH && chmod 755 $BBCPY && echo "[bbc_pmt_v6.py copied]"
    [ ! -f $BBCENIGMA ] && cp -f $CONFIGentmp $BINPATH && chmod 755 $BBCENIGMA && echo "[enigma2_pre_start.sh copied]"
fi

if [ "$OSTYPE" = "Opensource" ]; then
    if [ -f $ASTRACONF ] && [ -f $ABERTISBIN ] && [ -f $SYSCONF ]; then
        echo ">>> All $PACKAGE config files already exist"
        sleep 2
    else
        set -e
        echo ">>> Downloading $PACKAGE config files..."
        wget $MY_URL/astra-"${plarform}".tar.gz -qP $TMPDIR
        tar -xzf $TMPDIR/astra-"${plarform}".tar.gz -C $TMPDIR
        mv $TMPDIR/astra-"${plarform}" $TMPDIR/${PACKAGE}
        set +e
        [ ! -f $SYSCONF ] && cp -f $CONFIGsysctltmp $ETCPATH && chmod 644 $SYSCONF && echo "[sysctl.conf copied]"
        [ ! -f $ASTRACONF ] && cp -f $CONFIGastratmp $ASTRAPATH && chmod 644 $ASTRACONF && echo "[astra.conf copied]"
        [ ! -f $ABERTISBIN ] && cp -f $CONFIGabertistmp $ASTRAPATH/scripts && chmod 755 $ABERTISBIN && echo "[abertis script copied]"
    fi
fi

rm -rf ${TMPDIR}/channels_backup_by-romeh.tar.gz ${TMPDIR}/*astra-* ${TMPDIR}/*bbc_pmt_v6*
sync

echo ""
echo "*********************************************************"
echo "#       Channel and config INSTALLED SUCCESSFULLY       #"
echo "   UPLOADED BY  >>>>   EMIL_NABIL"
echo "*********************************************************"
echo "#                    ${VERSION}                         #"
echo "*********************************************************"
echo "#           Your device will RESTART now                #"
echo "*********************************************************"
sleep 4

if [ "$OSTYPE" = "Opensource" ]; then
    killall -9 enigma2
else
    systemctl restart enigma2
fi

exit 0


