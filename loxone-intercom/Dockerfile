FROM alpine:3.18

# 1. Installeer Asterisk EN alle noodzakelijke netwerk/SIP/audio modules
RUN apk add --no-cache \
    asterisk \
    asterisk-sip \
    asterisk-confbridge \
    asterisk-sounds-en \
    python3 \
    py3-flask \
    bash \
    curl \
    tzdata

# 2. Maak de benodigde mappen aan
RUN mkdir -p /etc/asterisk /var/spool/asterisk/outgoing /var/run/asterisk /var/log/asterisk

# 3. Kopieer jouw eigen configuratiebestanden
COPY run.sh /run.sh
COPY app.py /app.py
COPY sip.conf /etc/asterisk/sip.conf
COPY extensions.conf /etc/asterisk/extensions.conf
COPY modules.conf /etc/asterisk/modules.conf

# 4. Genereer direct de missende master-bestanden die Asterisk eist
RUN echo -e "[options]\nverbose = 3\ndebug = 3\nnofork = yes" > /etc/asterisk/asterisk.conf \
    && echo -e "[default_user]\ntype=user\n\n[default_bridge]\ntype=bridge" > /etc/asterisk/confbridge.conf \
    && echo -e "[general]\ncountry=nl" > /etc/asterisk/indications.conf \
    && echo -e "[logfiles]\nconsole => notice,warning,error" > /etc/asterisk/logger.conf

# 5. Zet alle rechten correct voor de Asterisk gebruiker
RUN chown -R asterisk:asterisk /etc/asterisk /var/spool/asterisk /var/run/asterisk /var/log/asterisk \
    && chmod -R 755 /etc/asterisk \
    && chmod -R 777 /var/spool/asterisk/outgoing \
    && chmod +x /run.sh

# 6. Start de container
CMD [ "/run.sh" ]
