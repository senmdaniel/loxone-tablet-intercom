import os
import subprocess
from flask import Flask, jsonify, request

app = Flask(__name__)

# Map waar Asterisk automatisch call files oppikt
ASTERISK_OUTGOING = "/var/spool/asterisk/outgoing/"


def generate_call_file(extension_to_call):
    """Genereert een Asterisk call file om een actie te starten."""
    filename = f"loxone_call_{extension_to_call}.call"
    filepath = os.path.join("/tmp", filename)

    # Inhoud van de call file
    # We bellen extensie 200 (conferentie) of 300/400 en verbinden dit met de tablets
    call_file_content = f"""Channel: Local/{extension_to_call}@intercom-context
MaxRetries: 0
RetryTime: 30
WaitTime: 20
Context: intercom-context
Extension: {extension_to_call}
Priority: 1
"""

    with open(filepath, "w") as f:
        f.write(call_file_content)

    # Verplaats naar de Asterisk spooler map met de juiste rechten
    final_path = os.path.join(ASTERISK_OUTGOING, filename)
    os.system(f"mv {filepath} {final_path}")
    os.system(f"chmod 777 {final_path}")
    os.system(f"chown asterisk:asterisk {final_path}")


@app.route("/api/status", methods=["GET"])
def get_status():
    """Geeft de status van de API weer."""
    return jsonify({"status": "online", "system": "Loxone SIP Intercom"}), 200


@app.route("/api/call/<extension>", methods=["POST"])
def call_tablet(extension):
    """Loxone activeert een oproep naar een specifieke tablet (101-104) of alle (300)."""
    valid_extensions = ["101", "102", "103", "104", "300"]
    if extension not in valid_extensions:
        return (
            jsonify({"error": f"Ongeldige extensie. Kies uit {valid_extensions}"}),
            400,
        )

    generate_call_file(extension)
    return (
        jsonify({"message": f"Oproep gestart naar extensie {extension}"}),
        200,
    )


@app.route("/api/page", methods=["POST"])
def start_page():
    """Loxone activeert de omroep/paging functie (extensie 400)."""
    generate_call_file("400")
    return jsonify({"message": "Omroepfunctie (Paging) gestart"}), 200


@app.route("/api/hangup", methods=["POST"])
def hangup_all():
    """Loxone hangt alle actieve gesprekken op."""
    try:
        subprocess.run(
            ["asterisk", "-rx", "channel request hangup all"], check=True
        )
        return jsonify({"message": "Alle actieve oproepen beëindigd"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    # Start de webserver op poort 8080, bereikbaar voor de Loxone Miniserver
    app.run(host="0.0.0.0", port=8080)
