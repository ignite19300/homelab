#!/bin/bash
# HA MCP helper — sends a JSON-RPC request to the ha-mcp stdio server
# Usage: ha-mcp.sh '<jsonrpc_request>'

HA_URL="http://192.168.1.5:8123"
HA_TOKEN="REDACTED_HA_TOKEN"

REQUEST="$1"

# Build the full message sequence: initialize + initialized + request
printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"owui","version":"1.0"}}}' \
  '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
  "$REQUEST" \
  | HA_MCP_URL="$HA_URL" HA_MCP_TOKEN="$HA_TOKEN" \
    timeout 15 node home/user/ha-mcp/node_modules/ha-mcp/dist/stdio.js 2>/dev/null
