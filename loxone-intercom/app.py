import os
import subprocess
import sys
from flask import Flask, jsonify, request

app = Flask(__name__)

# Map waar Asterisk automatisch call files oppikt binnen de container
ASTERISK_OUTGOING = "/var/spool/asterisk/outgoing/"


def log_message(message):
    """Zorgt ervoor dat logs direct zichtbaar zijn in de Home Assistant Add-on logboeken."""
    print(f"[LOXONE-INTERCOM] {message}", file=sys.stderr, flush=True)


def generate_call_file(extension_to_call):
    """Genereert op een veilige manier een Asterisk call file."""
    filename = f"loxone_call_{extension_to_call}.call"
    tmp_filepath = os.path.join("/tmp", filename)
    final_filepath = os.path.join(ASTERISK_OUTGOING, filename)

    # Inhoud van de call file
    # We bellen de actie en verbinden deze direct met de juiste context
    call_file_content = f"""Channel: Local/{extension_to_call}@intercom-context
MaxRetries: 0
RetryTime: 30
WaitTime: 20
Context: intercom-context
Extension: {extension_to_call}
Priority: 1
"""

    try:
        # Schrijf eerst naar de tmp map om corruptie te voorkomen tijdens het lezen door Asterisk
        with open(tmp_filepath, "w") as f:
            f.write(call_file_content)

        # Zet de juiste rechten (Asterisk in Docker draait vaak als root)
        os.chmod(tmp_filepath, 0o777)

        # Verplaats het bestand naar de actieve Asterisk spooler map
        os.rename(tmp_filepath, final_filepath)
        log_message(
            f"Asterisk Call File succesvol gegenereerd voor extensie {extension_to_call}."
        )
    except Exception as e:
        log_message(f"FOUT bij genereren Call File: {str(e)}")
        raise e


@app.route("/api/status", methods=["GET"])
def get_status():
    """Geeft de status van de intercom API weer."""
    log_message("Status opgevraagd door netwerkapparaat.")
    return (
        jsonify(
            {
                "status": "online",
                "system": "Loxone HA SIP Intercom Add-on",
                "version": "1.0.0",
            }
        ),
        200,
    )


@app.route("/api/call/<extension>", methods=["POST"])
def call_tablet(extension):
    """Loxone activeert een oproep naar een specifieke tablet (101-104) of alle tablets (300)."""
    valid_extensions = ["101", "102", "103", "104", "300"]

    if extension not in valid_extensions:
        log_message(
            f"Geweigerd: Ongeldige extensie {extension} aangeroepen door Loxone."
        )
        return (
            jsonify(
                {
                    "error": f"Ongeldige extensie. Kies uit de beschikbare extensies: {valid_extensions}"
                }
            ),
            400,
        )

    log_message(f"Loxone start oproep naar extensie: {extension}")
    try:
        generate_call_file(extension)
        return (
            jsonify({"message": f"Oproep gestart naar extensie {extension}"}),
            200,
        )
    except Exception as e:
        return (
            jsonify(
                {"error": "Kon oproep niet starten", "details": str(e)}
            ),
            500,
        )


@app.route("/api/page", methods=["POST"])
def start_page():
    """Loxone activeert de omroep/paging functie (extensie 400)."""
    log_message("Loxone activeert de omroepfunctie (Paging).")
    try:
        generate_call_file("400")
        return jsonify({"message": "Omroepfunctie (Paging) gestart"}), 200
    except Exception as e:
        return (
            jsonify(
                {
                    "error": "Kon omroepfunctie niet starten",
                    "details": str(e),
                }
            ),
            500,
        )


@app.route("/api/hangup", methods=["POST"])
def hangup_all():
    """Loxone beëindigt onmiddellijk alle actieve gesprekken en rinkelende tablets."""
    log_message("Loxone stuurt HANGUP commando.")
    try:
        # Voer het Asterisk commando uit om alle kanalen direct te verbreken
        result = subprocess.run(
            ["asterisk", "-rx", "channel request hangup all"],
            check=True,
            capture_output=True,
            text=True,
        )
        log_message(f"Asterisk hangup output: {result.stdout.strip()}")
        return (
            jsonify({"message": "Alle actieve oproepen succesvol beëindigd"}),
            200,
        )
    except subprocess.CalledProcessError as e:
        log_message(f"FOUT bij uitvoeren Asterisk hangup: {e.stderr}")
        return (
            jsonify(
                {
                    "error": "Asterisk weigerde op te hangen",
                    "details": e.stderr,
                }
            ),
            500,
        )
    except Exception as e:
        return jsonify({"error": "Systeemfout bij ophangen", "details": str(e)}), 500


if __name__ == "__main__":
    # Start de Flask server op poort 8080 binnen de HA Add-on container
    app.run(host="0.0.0.0", port=8080, debug=False)
