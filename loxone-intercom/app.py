import os
import subprocess
import sys
from flask import Flask, jsonify

app = Flask(__name__)
ASTERISK_OUTGOING = "/var/spool/asterisk/outgoing/"

def log_message(message):
    print(f"[LOXONE-INTERCOM] {message}", file=sys.stderr, flush=True)

def generate_call_file(extension_to_call):
    filename = f"loxone_call_{extension_to_call}.call"
    tmp_filepath = os.path.join("/tmp", filename)
    final_filepath = os.path.join(ASTERISK_OUTGOING, filename)

    call_file_content = f"""Channel: Local/{extension_to_call}@intercom-context
MaxRetries: 0
RetryTime: 30
WaitTime: 20
Context: intercom-context
Extension: {extension_to_call}
Priority: 1
"""
    try:
        with open(tmp_filepath, "w", newline='\n') as f:
            f.write(call_file_content)
        os.chmod(tmp_filepath, 0o777)
        os.rename(tmp_filepath, final_filepath)
        log_message(f"Call File gegenereerd voor {extension_to_call}.")
    except Exception as e:
        log_message(f"FOUT bij Call File: {str(e)}")
        raise e

@app.route("/api/status", methods=["GET"])
def get_status():
    return jsonify({"status": "online", "system": "Loxone Intercom"}), 200

@app.route("/api/call/<extension>", methods=["POST"])
def call_tablet(extension):
    if extension not in ["101", "102", "103", "104", "300"]:
        return jsonify({"error": "Slechte extensie"}), 400
    try:
        generate_call_file(extension)
        return jsonify({"message": "Oproep gestart"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/page", methods=["POST"])
def start_page():
    try:
        generate_call_file("400")
        return jsonify({"message": "Paging gestart"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/hangup", methods=["POST"])
def hangup_all():
    try:
        subprocess.run(["asterisk", "-rx", "channel request hangup all"], check=True)
        return jsonify({"message": "Opgehangen"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
