import os
import re
import json

from conf import OVP

VAULT_PATH = OVP

def parse_markdown_links(content):
    return re.findall(r'\[\[([^\]]+)\]\]', content)

def build_graph(vault_path):
    graph = {"nodes": [], "edges": []}
    nodes = {}
    
    for file in os.listdir(vault_path):
        if file.endswith(".md"):
            note_name = file[:-3]
            file_path = os.path.join(vault_path, file)
            
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
            
            links = parse_markdown_links(content)
            nodes[note_name] = links

    for node in nodes:
        graph["nodes"].append({"id": node, "label": node})
        for link in nodes[node]:
            if link in nodes: 
                graph["edges"].append({"from": node, "to": link})

    return graph

def main():
    graph = build_graph(VAULT_PATH)
    with open("graph.json", "w", encoding="utf-8") as f:
        json.dump(graph, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    main()