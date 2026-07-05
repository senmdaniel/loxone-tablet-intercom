#!/bin/bash
echo "🚀 Starten van de Loxone Intercom add-on..."

# Zet de tijdzone direct gelijk met West-Europa
ln -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime
echo "Europe/Brussels" > /etc/timezone
echo "⏰ Systeemtijd gesynchroniseerd: $(date)"

# Maak live de benodigde spool-map aan voor Loxone call-files
mkdir -p /var/spool/asterisk/outgoing
chmod -R 777 /var/spool/asterisk/outgoing

echo "📞 Asterisk SIP server wordt gestart..."
# Start Asterisk gewoon op de achtergrond
/usr/sbin/asterisk -f &

# Geef Asterisk 3 seconden de tijd om rustig op te starten
sleep 3

echo "🌐 Flask REST API wordt gestart..."
# Start de Python API op de voorgrond
exec python3 /app.py
