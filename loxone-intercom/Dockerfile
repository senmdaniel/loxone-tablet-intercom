FROM alpine:latest

# Installeer Asterisk en Python
RUN apk add --no-cache asterisk python3 py3-flask bash

# Kopieer alle bestanden naar de container
COPY run.sh /run.sh
COPY app.py /app.py
COPY sip.conf /etc/asterisk/sip.conf
COPY extensions.conf /etc/asterisk/extensions.conf

RUN chmod +x /run.sh

# Start het systeem via run.sh
CMD [ "/run.sh" ]
