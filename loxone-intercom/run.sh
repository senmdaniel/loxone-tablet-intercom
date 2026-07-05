#!/bin/bash
echo "🚀 Starten van de Loxone Intercom add-on..."

# Zorg dat de spool-map voor Loxone call-files bestaat
mkdir -p /var/spool/asterisk/outgoing
chmod -R 777 /var/spool/asterisk/outgoing

echo "📞 Asterisk SIP server wordt gestart..."
# Start Asterisk geforceerd op de achtergrond (-f voorkomt afsluiten)
/usr/sbin/asterisk -f &

# Geef Asterisk 3 seconden de tijd om rustig op te starten
sleep 3

echo "🌐 Flask REST API wordt gestart..."
# Start de Python Flask API op de voorgrond (houdt de add-on online)
exec python3 /app.py
