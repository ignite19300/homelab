#!/bin/bash
# HA MCP helper — sends a JSON-RPC request to the ha-mcp stdio server
# Usage: ha-mcp.sh '<jsonrpc_request>'
#
# Requires HA_TOKEN env var to be set (long-lived HA access token).
# Set it in ~/.bashrc or export it before running.

HA_URL="http://192.168.1.5:8123"

if [ -z "$HA_TOKEN" ]; then
  echo "ERROR: HA_TOKEN env var not set. Export your HA long-lived token first." >&2
  exit 1
fi

REQUEST="$1"

# Build the full message sequence: initialize + initialized + request
printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"owui","version":"1.0"}}}' \
  '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
  "$REQUEST" \
  | HA_MCP_URL="$HA_URL" HA_MCP_TOKEN="$HA_TOKEN" \
    timeout 15 node /home/user/ha-mcp/node_modules/ha-mcp/dist/stdio.js 2>/dev/null
