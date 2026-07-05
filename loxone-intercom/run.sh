#!/bin/bash
echo "🚀 Starten van de Loxone Intercom add-on..."

# Zet de tijdzone direct gelijk met West-Europa
ln -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime
echo "Europe/Brussels" > /etc/timezone
echo "⏰ Systeemtijd gesynchroniseerd: $(date)"

echo "📞 Asterisk SIP server wordt gestart..."
# Start Asterisk onder de juiste v20/v18 gebruiker op Debian
/usr/sbin/asterisk -U asterisk -f &

# Wacht tot Asterisk is opgestart
sleep 3

echo "🌐 Flask REST API wordt gestart..."
# Start de Python API op de voorgrond
exec python3 /app.py
