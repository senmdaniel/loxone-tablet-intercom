#!/bin/bash
# Automatisch installatiescript voor Loxone Tablet Intercom

echo "🚀 Start installatie van Loxone Tablet Intercom..."

# Systeem updaten
sudo apt update && sudo apt upgrade -y

# Asterisk en Python installeren
sudo apt install asterisk python3 python3-pip python3-flask -y

# Configureer Asterisk (Basis SIP configuratie)
echo "⚙️ Asterisk configureren..."
# [Hier komt later de automatische kopieerslag van sip.conf en extensions.conf]

# Start services
sudo systemctl enable asterisk
sudo systemctl start asterisk

echo "✅ Installatie voltooid! De intercom is actief."
