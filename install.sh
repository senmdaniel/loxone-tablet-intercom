#!/bin/bash

# Zorg dat het script stopt bij fouten
set -e

echo "🚀 Start installatie van Loxone Tablet Intercom..."

# 1. Update het systeem
sudo apt update && sudo apt upgrade -y

# 2. Installeer Asterisk en Python benodigdheden
sudo apt install asterisk python3 python3-pip python3-flask python3-werkzeug -y

# 3. Stop Asterisk tijdelijk voor configuratie
sudo systemctl stop asterisk

# 4. Haal de configuratiebestanden op uit de lopende map (GitHub kloon)
echo "⚙️ Configureren van Asterisk en API..."
sudo cp server/sip.conf /etc/asterisk/sip.conf
sudo cp server/extensions.conf /etc/asterisk/extensions.conf

# Zorg voor de juiste rechten op Asterisk bestanden
sudo chown -R asterisk:asterisk /etc/asterisk/

# 5. Maak een achtergrondservice voor de Python REST API
echo "🖥️ API Service aanmaken..."
SCRIPT_DIR=$(pwd)

sudo bash -c "cat <<EOF > /etc/systemd/system/loxone-intercom-api.service
[Unit]
Description=Loxone Intercom REST API
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$SCRIPT_DIR/server
ExecStart=/usr/bin/python3 app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF"

# 6. Start en activeer alle services
sudo systemctl daemon-reload
sudo systemctl enable asterisk
sudo systemctl start asterisk
sudo systemctl enable loxone-intercom-api
sudo systemctl start loxone-intercom-api

# 7. Controleer status
echo "📊 Status controleren..."
sudo systemctl status asterisk --no-pager
sudo systemctl status loxone-intercom-api --no-pager

echo "✅ INSTALLATIE SUCCESVOL VOLTOOID!"
echo "👉 De REST API luistert nu op poort 8080."
echo "👉 Je kunt Asterisk SIP bereiken op poort 5060."
