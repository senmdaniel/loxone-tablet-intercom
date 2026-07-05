#!/bin/bash
echo "🚀 Loxone Tablet Intercom Add-on wordt gestart..."

# Start Asterisk op de achtergrond
asterisk -g

# Start de Python API op de voorgrond
python3 /app.py
