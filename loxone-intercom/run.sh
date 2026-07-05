#!/bin/bash
echo "🚀 Loxone Tablet Intercom Add-on wordt gestart..."

# Maak de ontbrekende asterisk.conf aan als deze niet bestaat
if [ ! -f /etc/asterisk/asterisk.conf ]; then
    touch /etc/asterisk/asterisk.conf
fi

# Start Asterisk op de achtergrond
asterisk -f &

# Geef Asterisk 2 seconden om op te starten
sleep 2

# Start de Python API op de voorgrond
python3 /app.py
