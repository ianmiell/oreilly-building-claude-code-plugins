#!/usr/bin/env python3
"""adr-search: a tiny MCP server that searches a project's ADRs.

Standard library only. Speaks JSON-RPC 2.0 over stdin and stdout, one message
per line, as MCP's stdio transport requires. Anything else goes to stderr.
"""
import json
import os
import re
import sys
from pathlib import Path

SERVER = {"name": "adr-search", "version": "0.3.0"}

TOOL = {
    "name": "search_adrs",
    "description": (
        "Search this project's Architecture Decision Records. Returns each matching ADR's "
        "number, title, status and file, and the lines that matched. Use it before making "
        "a technical choice, to find decisions that already cover it."
    ),
    "inputSchema": {
        "type": "object",
        "properties": {
            "query": {"type": "string", "description": "Words to look for. Empty matches every ADR."},
            "status": {"type": "string", "description": "Only ADRs whose status starts with this, such as 'accepted'."},
        },
    },
}


def adr_dir():
    configured = os.environ.get("ADR_DIR", "")
    if not configured or configured.startswith("${"):
        configured = "docs/adr"
    project = os.environ.get("ADR_PROJECT_DIR", "")
    if not project or project.startswith("${"):
        project = os.getcwd()
    return Path(project) / configured


def read_adr(path):
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    title = next((l[2:].strip() for l in lines if l.startswith("# ")), path.stem)
    title = re.sub(r"^\d+\.\s*", "", title)
    status = ""
    for i, line in enumerate(lines):
        if line.lower().startswith("status:"):
            status = line.split(":", 1)[1].strip().strip('"')
            break
        if line.startswith("## Status"):
            status = next((l.strip() for l in lines[i + 1:] if l.strip()), "")
            break
    return {"number": path.name[:4], "title": title, "status": status, "file": str(path), "lines": lines}


def search(query="", status=""):
    directory = adr_dir()
    if not directory.is_dir():
        return f"No ADR directory at {directory}."
    words = [w.lower() for w in query.split()]
    results = []
    for path in sorted(directory.glob("[0-9][0-9][0-9][0-9]-*.md")):
        adr = read_adr(path)
        if status and not adr["status"].lower().startswith(status.lower()):
            continue
        matched = [l.strip() for l in adr["lines"] if l.strip() and any(w in l.lower() for w in words)]
        if words and not matched:
            continue
        entry = f"ADR {adr['number']}: {adr['title']} [{adr['status'] or 'no status'}]\n  {adr['file']}"
        for line in matched[:5]:
            entry += f"\n  > {line}"
        results.append(entry)
    if not results:
        return "No ADRs matched."
    return "\n\n".join(results)


def respond(request_id, result=None, error=None):
    message = {"jsonrpc": "2.0", "id": request_id}
    if error:
        message["error"] = error
    else:
        message["result"] = result
    sys.stdout.write(json.dumps(message) + "\n")
    sys.stdout.flush()


def handle(message):
    method = message.get("method")
    request_id = message.get("id")
    params = message.get("params") or {}
    if request_id is None:
        return  # a notification, such as notifications/initialized: no reply
    if method == "initialize":
        respond(request_id, {
            "protocolVersion": params.get("protocolVersion", "2025-06-18"),
            "capabilities": {"tools": {}},
            "serverInfo": SERVER,
        })
    elif method == "tools/list":
        respond(request_id, {"tools": [TOOL]})
    elif method == "tools/call" and params.get("name") == TOOL["name"]:
        args = params.get("arguments") or {}
        text = search(args.get("query", ""), args.get("status", ""))
        respond(request_id, {"content": [{"type": "text", "text": text}]})
    elif method == "ping":
        respond(request_id, {})
    else:
        respond(request_id, error={"code": -32601, "message": f"Unknown method: {method}"})


def main():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            handle(json.loads(line))
        except Exception as exc:  # keep serving; report on stderr
            print(f"adr-search: {exc}", file=sys.stderr)


if __name__ == "__main__":
    main()
