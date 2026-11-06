# Home Assistant (VMID 101, 192.168.1.5)

## Current State (2026-11-06)
- **HA 2026.11.0** · 566 states · 50 config entries
- RAM: 2 GB (increase skipped by user)
- Disk: 50 GB

## 2026-11-06 Cleanup (Deep Audit)
### Config entries removed (58 → 50)
- `zha` — Sonoff Zigbee 3.0 USB Dongle Plus (replaced by Z2M)
- `hue` — no entities, dead integration
- `cast` — no entities, dead integration
- `upnp` — NBG7510, no entities
- `dlna_dms` — Lyrion Music Server, no entities
- `dlna_dmr` — Squeezebox Radio (redundant with native `squeezebox`)
- `kodi` × 2 — redundant entries (192.168.1.10 + fedora). Kept `osmc`.

### Entity registry changes (1342 → 1339)
**Deleted:**
- `media_player.marantz_nr1604_4` (stale duplicate)
- `sensor.marantz_nr1604_next_alarm_2` (dead)
- `switch.marantz_nr1604_alarms_enabled_2` (dead)

**Disabled (user):**
- `media_player.browser_mod_e85761f1_62f5ad51` (ghost)
- `media_player.browser_mod_ba01b471_bef2c277` (ghost)
- 9× `sensor.beatrices_iphone_*` (stale fitness sensors)

### Configuration.yaml changes
- Recorder `exclude` expanded: added `sensor.browser_mod_*`, `binary_sensor.browser_mod_*`, `light.browser_mod_*`, `media_player.browser_mod_*`, `update`
- Removed 3× `homeassistant.*: debug` log level lines
- `kubuntu_power_off` shell command: kept at `192.168.1.10` (correct IP)

### TTS cache
- Cleared `/homeassistant/tts/`: 1313 files / 159.8 MB → 0 / 148 KB

### Kept (user's choice)
- `person.mqtt_user` — not deleted
- RAM stays at 2 GB

### WS API Limitation
- `config_entries`, `entity_registry`, `device_registry` WS commands all return `Unknown command`
- Must edit `/config/.storage/core.config_entries` and `core.entity_registry` JSON directly
- Then `ha core restart` to apply
- Backups: `*.bak-20261106` in `/config/.storage/`

## Integration Summary (post-cleanup)
Key integrations: esphome, mqtt, proxmoxve, kodi (osmc), squeezebox (native),
denonavr, philips_airpurifier_coap, mobile_app, hacs, music_assistant,
llm/mcp, polyvoice/wyoming/assist, go2rtc, powercalc, ffmpeg, zigbee2mqtt

## Access
- SSH: root@192.168.1.5 (key: ~/.ssh/ha_access from KUbuntu)
- HA token: long-lived openwebui token (REST /api/states works, WS registry commands do not)
- Supervisor CLI: `ha core restart` from host SSH
