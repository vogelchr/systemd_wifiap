Run wlan access point under systemd control, once a Wi-Fi capable
network interface has been connected (e.g. a Wi-Fi USB stick).

Usage
-----

[root@a20lime2 systemd_wifiap]# ./install.sh 
**
** Creating hostapd config using ...
**
** SSID        a20lime2_5636
** Passphrase  Aejeesoos8Ie
**


Dependencies
------------

hostapd
dnsmasq
pwgen (to generate the random passphrase)

Currently the ip address is hardcoded to 172.18.3.1, dhcp-range .224..254.
