FROM alpine:latest

# 1. Installeer Asterisk, Python en Flask
RUN apk add --no-cache asterisk python3 py3-flask bash

# 2. Zorg dat de benodigde Asterisk systeemmappen bestaan en de juiste rechten hebben
RUN mkdir -p /var/spool/asterisk/outgoing /var/run/asterisk /var/log/asterisk /var/lib/asterisk \
    && chown -R asterisk:asterisk /var/spool/asterisk /var/run/asterisk /var/log/asterisk /var/lib/asterisk \
    && chmod -R 777 /var/spool/asterisk

# 3. Kopieer de configuratiebestanden naar de container
COPY run.sh /run.sh
COPY app.py /app.py
COPY sip.conf /etc/asterisk/sip.conf
COPY extensions.conf /etc/asterisk/extensions.conf

# 4. Zorg dat Asterisk eigenaar is van de configuratiebestanden
RUN chown -R asterisk:asterisk /etc/asterisk/ \
    && chmod +x /run.sh

# 5. Start het systeem via run.sh
CMD [ "/run.sh" ]
