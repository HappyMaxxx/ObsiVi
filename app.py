from flask import Flask, jsonify, send_from_directory, render_template
from flask_cors import CORS
import os
import json
import time
from main import main

app = Flask(__name__)
CORS(app)

@app.route("/")
def index():
    return render_template("loading.html")

@app.route("/main")
def main_route():
    main()
    return render_template("index.html")

@app.route("/graph")
def get_graph():
    if os.path.exists("graph.json"):
        with open("graph.json", "r", encoding="utf-8") as f:
            return jsonify(json.load(f))
    return jsonify({"error": "Graph not found"}), 404

@app.route("/libs/<path:filename>")
def serve_libs(filename):
    return send_from_directory("libs", filename)

if __name__ == "__main__":
    app.run(debug=True, port=5001)
