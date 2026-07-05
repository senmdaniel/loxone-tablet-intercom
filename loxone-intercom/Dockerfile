FROM alpine:latest

# 1. Installeer Asterisk, Python, Flask en Bash
RUN apk add --no-cache asterisk python3 py3-flask bash curl

# 2. Maak de configuratiemap aan
RUN mkdir -p /etc/asterisk

# 3. Kopieer alle bestanden rechtstreeks naar de container
COPY run.sh /run.sh
COPY app.py /app.py
COPY sip.conf /etc/asterisk/sip.conf
COPY extensions.conf /etc/asterisk/extensions.conf
COPY modules.conf /etc/asterisk/modules.conf

# 4. Genereer tijdens de bouw direct een harde master asterisk.conf om fouten te voorkomen
RUN echo -e "[options]\nverbose = 3\ndebug = 3\nnofork = yes" > /etc/asterisk/asterisk.conf

# 5. Maak het startscript uitvoerbaar
RUN chmod +x /run.sh

# 6. Start het universele script
CMD [ "/run.sh" ]
