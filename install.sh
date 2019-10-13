#!/bin/bash

set -e

# ssid is hostname, or hostname with 4 random hex
# chars appended

if ! [ -f /etc/hostapd/wifiap_hostapd.conf ] ; then

        ssid="`hostname`"
        if [ -e /proc/sys/kernel/random/uuid ] ; then
                read randhex </proc/sys/kernel/random/uuid
                ssid="${ssid}_${randhex:0:4}"
        fi

        if [ -x "/usr/bin/pwgen" ] ; then
                wpa_passphrase="`pwgen 12 1`"
        else
                echo ""
                echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                echo "!!! CANNOT FIND pwgen, please change your                !!!"
                echo "!!! wpa_passphrase in /etc/hostapd/wifiap_hostapd.conf   !!!"
                echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                echo ""
                wpa_passphrase="changeme!"
        fi

        echo "**"
        echo "** Creating hostapd config using ..."
        echo "**"
        echo "** SSID        $ssid"
        echo "** Passphrase  $wpa_passphrase"
        echo "**"

        # add ssid and passphrase to hostapd config
        tmp_config=`mktemp`
        cat wifiap_hostapd.conf >>$tmp_config
        echo "" >>$tmp_config
        echo "ssid=$ssid" >>$tmp_config
        echo "wpa_passphrase=$wpa_passphrase" >>$tmp_config

        echo "... installing /etc/hostapd/wifiap_hostapd.conf"
        [ -d /etc/hostapd ] || mkdir /etc/hostapd
        install -m600 $tmp_config /etc/hostapd/wifiap_hostapd.conf
        rm -f "$tmp_config"
else
        echo "... NOT overwriting /etc/hostapd/wifiap_hostapd.conf"
fi

echo "... installing /usr/local/sbin/wifiap_dnsmasq.sh"
[ -d /usr/local/sbin ] || mkdir -p /usr/local/sbin
install -m755 wifiap_dnsmasq.sh /usr/local/sbin

echo "... installing /etc/systemd/system/wifiap_dnsmasq@.service"
install -m644 wifiap_dnsmasq@.service /etc/systemd/system

echo "... installing /etc/systemd/system/wifiap_hostapd@.service"
install -m644 wifiap_hostapd@.service /etc/systemd/system

echo "... installing /etc/udev/rules.d/99-wifiap_autostart.rules"
install -m644 99-wifiap_autostart.rules /etc/udev/rules.d

systemctl daemon-reload
udevadm control --reload-rules
