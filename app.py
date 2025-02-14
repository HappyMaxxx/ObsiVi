from flask import Flask, jsonify, send_from_directory, render_template
from flask_cors import CORS
import os
import json
import time
from main import main

from main import build_graph
from conf import SD, OVP

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
    graph_path = "graph.json"
    
    if os.path.exists(graph_path):
        with open(graph_path, "r", encoding="utf-8") as f:
            saved_graph = json.load(f)
    else:
        saved_graph = None
    
    current_graph = build_graph(OVP)

    if (
        saved_graph is None or 
        len(saved_graph["nodes"]) != len(current_graph["nodes"]) or 
        len(saved_graph["edges"]) != len(current_graph["edges"]) or
        {node["id"] for node in saved_graph["nodes"]} != {node["id"] for node in current_graph["nodes"]}
    ):
        with open(graph_path, "w", encoding="utf-8") as f:
            json.dump(current_graph, f, ensure_ascii=False, indent=4)
        return jsonify({"status": "updated", "graph": current_graph})
    
    return jsonify(saved_graph)

@app.route("/libs/<path:filename>")
def serve_libs(filename):
    return send_from_directory("libs", filename)

if __name__ == "__main__":
    try:
        app.run(debug=True, port=5001)
    except OSError:
        with open(os.path.join(SD, "flask.log"), "r") as f:
            f.write(f"Error: port 5001 is alredy in use\n")
