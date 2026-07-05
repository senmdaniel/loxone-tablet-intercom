#!/bin/bash
echo "🚀 Starten van het Loxone Intercom universele startscript..."

# 1. Zorg dat alle noodzakelijke Asterisk mappen fysiek bestaan
mkdir -p /etc/asterisk
mkdir -p /var/log/asterisk
mkdir -p /var/run/asterisk
mkdir -p /var/spool/asterisk/outgoing
mkdir -p /var/lib/asterisk/astdb

# 2. Genereer een minimale stabiele asterisk.conf als deze ontbreekt
if [ ! -f /etc/asterisk/asterisk.conf ]; then
    echo "⚙️ asterisk.conf ontbreekt. Automatisch genereren..."
    cat <<EOF > /etc/asterisk/asterisk.conf
[options]
verbose = 3
debug = 3
nofork = yes
EOF
fi

# 3. Genereer logger.conf om Asterisk crash-logs te voorkomen
if [ ! -f /etc/asterisk/logger.conf ]; then
    cat <<EOF > /etc/asterisk/logger.conf
[logfiles]
console => notice,warning,error
EOF
fi

# 4. Zet alle rechten keihard op root/asterisk om blokkades te voorkomen
chown -R root:root /etc/asterisk
chmod -R 755 /etc/asterisk
chown -R root:root /var/spool/asterisk
chmod -R 777 /var/spool/asterisk/outgoing

echo "📞 Asterisk configuratie gecontroleerd. Server wordt gestart..."

# 5. Start Asterisk geforceerd op de achtergrond (-f voorkomt afsluiten)
/usr/sbin/asterisk -f &

# Geef de intercom 3 seconden de tijd om op te starten
sleep 3

echo "🌐 Flask REST API wordt gestart..."
# 6. Start de Python Flask API op de voorgrond (houdt de Add-on actief)
exec python3 /app.py
