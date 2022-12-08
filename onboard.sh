#!/bin/bash
systemUsers=("tierpointadmin" "hspatch")

sudo adduser ${systemUsers[1]}
sudo usermod -aG wheel ${systemUsers[1]}

#user management
for i in ${systemUsers[@]}; do
        sudo mkdir /home/$i/.ssh
        sudo wget -O /home/$i/.ssh/authorized_keys https://raw.githubusercontent.com/cronflakes/super-waddle/main/id_ed25519-$i\.pub
        sudo chmod 400 /home/$i/.ssh/authorized_keys
        sudo chmod 700 /home/$i/.ssh
        sudo chown -R $i:$i /home/$i/.ssh
        sudo chage -I -1 -m 0 -M 99999 -E -1 $i
done

#snmpd
if systemctl is-active --quiet snmpd; then
        retVal=$(sudo grep 10.156.128.220 /etc/snmp/snmpd.conf)
        if [ "$retVal" -ne 0 ]; then
                sudo bash -c 'echo "com2sec public 10.156.128.220 <community string>" >> /etc/snmp/snmpd.conf'
                sudo systemctl restart snmpd
        fi
fi

#firewalld
if systemctl is-active --quiet firewalld; then
        sudo firewall-cmd --ipset=monitoring_tierpoint --add-entry=10.156.128.220 --permanent
        sudo firewall-cmd --ipset=jump_boxes_tierpoint --add-entry=10.156.129.29 --permanent
        sudo firewall-cmd --reload
fi
