# HA MCP Server (KUbuntu 103)

MCP server for Home Assistant, running on KUbuntu (192.168.1.8).

## Setup
- **Package:** `ha-mcp` v0.1.6 (by jgracey) — Node.js stdio MCP server
- **Location:** `home/user/ha-mcp/`
- **Helper script:** `home/user/ha-mcp/ha-mcp.sh`
- **HA URL:** `http://192.168.1.5:8123`
- **Token:** Long-lived access token (stored in OpenWebUI memory, path `context/home-assistant`)

## Usage

The MCP server is **stdio-based** — it initializes on each call. The helper script handles the initialize handshake automatically.

```bash
home/user/ha-mcp/ha-mcp.sh '<jsonrpc_request>'
```

### Examples

**Get entity state:**
```bash
home/user/ha-mcp/ha-mcp.sh '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"HomeAssistant","arguments":{"action":"get_state","entity_id":"climate.heating_living_room"}}}'
```

**List entities (lights only):**
```bash
home/user/ha-mcp/ha-mcp.sh '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"HomeAssistant","arguments":{"action":"list_entities","listFilters":{"domain":"light"}}}}'
```

**Turn on a light:**
```bash
home/user/ha-mcp/ha-mcp.sh '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"HomeAssistant","arguments":{"action":"call_service","domain":"light","service":"turn_on","entity_id":"light.living_room"}}}'
```

**List all services:**
```bash
home/user/ha-mcp/ha-mcp.sh '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"HomeAssistant","arguments":{"action":"list_services"}}}'
```

## Available Actions

| Action | Description |
|--------|-------------|
| `list_entities` | List entities with optional filters (domain, device_class, q, limit) |
| `list_services` | List all available HA services |
| `get_states` | Get all entity states |
| `get_state` | Get a specific entity's state |
| `call_service` | Call an HA service (turn_on, turn_off, set_temperature, etc.) |
| `fire_event` | Fire a custom HA event |

## Helper Script

See `ha-mcp.sh` in this directory. It:
1. Sets `HA_MCP_URL` and `HA_MCP_TOKEN` env vars
2. Sends initialize + initialized + your request to the stdio server
3. Returns the JSON-RPC response
4. Has a 15-second timeout

## SSH to HA (for direct access)

```bash
ssh -i home/user/.ssh/ha_access root@192.168.1.5
```

Key was added to HA's `/root/.ssh/authorized_keys` on 2026-11-06.
