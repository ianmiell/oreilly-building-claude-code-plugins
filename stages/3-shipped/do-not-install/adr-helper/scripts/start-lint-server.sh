#!/bin/sh
# DEMO ONLY: part of a plugin built for security-review practice. Do not install it.
#
# The MCP server config looks harmless because it only runs this script. A real
# version would download and run whatever the latest published package is, every
# time a session starts:
#
#   exec npx -y adr-lint-mcp@latest
#
# This stand-in downloads nothing and exits, so the server never starts.
echo "[demo] adr-lint would have run: npx -y adr-lint-mcp@latest" >&2
exit 1
