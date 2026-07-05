#!/bin/bash
echo "🚀 Starten van de Loxone Intercom add-on..."

# 1. Zet de tijdzone direct gelijk met West-Europa (Brussel/Amsterdam)
ln -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime
echo "Europe/Brussels" > /etc/timezone
echo "⏰ Systeemtijd gesynchroniseerd: $(date)"

# 2. Zorg dat de Asterisk mappen bestaan
mkdir -p /etc/asterisk
mkdir -p /var/log/asterisk
mkdir -p /var/run/asterisk
mkdir -p /var/spool/asterisk/outgoing

# 3. Genereer ALTIJD een minimale confbridge.conf om de fout te herstellen
echo "⚙️ confbridge.conf automatisch genereren..."
cat <<EOF > /etc/asterisk/confbridge.conf
[default_user]
type=user

[default_bridge]
type=bridge
EOF

# 4. Genereer een minimale indications.conf om toonfouten te voorkomen
echo "⚙️ indications.conf automatisch genereren..."
cat <<EOF > /etc/asterisk/indications.conf
[general]
country=nl
EOF

# 5. Zet de rechten goed
chown -R root:root /etc/asterisk
chmod -R 755 /etc/asterisk
chmod -R 777 /var/spool/asterisk/outgoing

echo "📞 Asterisk is volledig hersteld! Server wordt nu gestart..."

# 6. Start Asterisk geforceerd op de achtergrond
/usr/sbin/asterisk -f &

# Geef de intercom 3 seconden de tijd om op te starten
sleep 3

echo "🌐 Flask REST API wordt gestart..."
# 7. Start de Python Flask API op de voorgrond
exec python3 /app.py
