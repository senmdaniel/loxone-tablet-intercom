FROM debian:bookworm-slim

# 1. Installeer Asterisk, Python en Flask
RUN apt-get update && apt-get install -y \
    asterisk \
    python3 \
    python3-flask \
    bash \
    curl \
    tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Kopieer alle configuratiebestanden rechtstreeks naar de container
COPY run.sh /run.sh
COPY app.py /app.py
COPY sip.conf /etc/asterisk/sip.conf
COPY extensions.conf /etc/asterisk/extensions.conf
COPY modules.conf /etc/asterisk/modules.conf
COPY asterisk.conf /etc/asterisk/asterisk.conf
COPY confbridge.conf /etc/asterisk/confbridge.conf
COPY logger.conf /etc/asterisk/logger.conf

# 3. Maak het startscript uitvoerbaar
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
