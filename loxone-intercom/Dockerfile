FROM alpine:latest

# Installeer Asterisk, Python, Flask en handige netwerktools
RUN apk add --no-cache asterisk python3 py3-flask bash curl

# Kopieer de bestanden naar de container
COPY run.sh /run.sh
COPY app.py /app.py
COPY sip.conf /etc/asterisk/sip.conf
COPY extensions.conf /etc/asterisk/extensions.conf
COPY modules.conf /etc/asterisk/modules.conf

# Maak het startscript uitvoerbaar
RUN chmod +x /run.sh

# Start het universele script
CMD [ "/run.sh" ]
