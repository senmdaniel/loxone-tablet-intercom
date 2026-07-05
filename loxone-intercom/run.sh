#!/bin/bash
echo "🚀 Starten van het Loxone Intercom startscript..."

# 1. Zorg dat de Asterisk mappen bestaan
mkdir -p /etc/asterisk
mkdir -p /var/log/asterisk
mkdir -p /var/run/asterisk
mkdir -p /var/spool/asterisk/outgoing

# 2. Genereer ALTIJD een werkende modules.conf om de crash te stoppen
echo "⚙️ modules.conf automatisch genereren..."
cat <<EOF > /etc/asterisk/modules.conf
[modules]
autoload=yes
load => chan_sip.so
load => app_dial.so
load => app_confbridge.so
load => app_page.so
load => codec_ulaw.so
load => codec_alaw.so
noload => chan_pjsip.so
EOF

# 3. Genereer een stabiele asterisk.conf als deze ontbreekt
if [ ! -f /etc/asterisk/asterisk.conf ]; then
    cat <<EOF > /etc/asterisk/asterisk.conf
[options]
verbose = 3
debug = 3
nofork = yes
EOF
fi

# 4. Zet de rechten goed
chown -R root:root /etc/asterisk
chmod -R 755 /etc/asterisk
chmod -R 777 /var/spool/asterisk/outgoing

echo "📞 Asterisk is hersteld! Server wordt nu gestart..."

# 5. Start Asterisk geforceerd op de achtergrond
/usr/sbin/asterisk -f &

# Geef de intercom 3 seconden de tijd om op te starten
sleep 3

echo "🌐 Flask REST API wordt gestart..."
# 6. Start de Python Flask API op de voorgrond
exec python3 /app.py
