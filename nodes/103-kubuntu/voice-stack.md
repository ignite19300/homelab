# Voice Stack (STT + TTS) — Kubuntu 103

Fully local speech-to-text (STT) and text-to-speech (TTS) stack running in Docker
on Kubuntu (192.168.1.8). No cloud APIs — everything stays on the LAN. Feeds both
**Open WebUI** (chat mic + read-aloud) and **Home Assistant** (via Wyoming bridge).

> Built 2026-11-02. All four languages fully local.

## Architecture

```
                 ┌──────────────────────────────┐
  Open WebUI ───▶│  speaches  (STT + TTS) :8000 │  ◀──┐
  (chat mic/TTS) └──────────────┬───────────────┘     │
                                 │  OpenAI-compat API  │
                                 ▼                     │
                    ┌────────────────────────┐         │
                    │ wyoming_openai :10300  │◀────────┘
                    └───────────┬───────────┘  (same backend)
                                 ▼
                        Home Assistant
                     (Wyoming protocol)
```

- **speaches** — the actual STT/TTS engine. Exposes an OpenAI-compatible API.
- **wyoming_openai** — a thin bridge that re-exposes the same backend over the
  Wyoming protocol so Home Assistant can use it natively.
- Both live on the **`voice_default`** Docker network.

## Containers

| Container | Image | Port | Role |
|-----------|-------|------|------|
| `speaches` | `ghcr.io/speaches-ai/speaches:0.9.0-rc.3-cpu` | 8000 | STT (Whisper) + TTS (Kokoro + Piper) |
| `wyoming_openai` | `ghcr.io/roryeckel/wyoming_openai:latest` | 10300 | Wyoming bridge for HA |

Compose file: `/opt/voice/docker-compose.yml`
Shared HF model cache volume: `huggingface-hub` (named volume, mounted at
`/home/ubuntu/.cache/huggingface/hub` inside speaches).

## Languages & Voices (all female)

| Language | STT (local) | TTS voice | TTS engine |
|----------|-------------|-----------|------------|
| English | Whisper large-v3 | `af_heart`, `af_bella`, `af_sky`, `af_nicole` | Kokoro 82M |
| German  | Whisper large-v3 | `de_DE-kerstin-low` | Piper |
| Greek   | Whisper large-v3 | `el_GR-rapunzelina-low` | Piper |
| Italian | Whisper large-v3 | `it_IT-paola-medium` | Piper |

STT model (all languages): `Systran/faster-distil-whisper-large-v3` (int8).

### Models preloaded on speaches startup
`preload_models` in the compose file lists all five so they're ready at boot:
- `Systran/faster-distil-whisper-large-v3`
- `speaches-ai/Kokoro-82M-v1.0-ONNX`
- `speaches-ai/piper-de_DE-kerstin-low`
- `speaches-ai/piper-el_GR-rapunzelina-low`
- `speaches-ai/piper-it_IT-paola-medium`

> ⚠️ A TTS model that is NOT in `preload_models` returns **404 "not installed
> locally"** on first request. If you add a voice, add it here and recreate speaches.

## Why NOT Edge TTS

The `travisvn/openai-edge-tts` container (free Microsoft neural voices) was tried
first but Microsoft **403-blocks datacenter/cloud IPs** at the WebSocket handshake
(`speech.platform.bing.com`). Since this box is behind a datacenter-style tunnel
IP, Edge TTS is unusable here. Pivoted to fully local Piper voices, which also have
Greek coverage (Piper `el_GR-rapunzelina-low`). Container + image were removed.

## Open WebUI Integration

Open WebUI talks to `speaches` directly over its OpenAI-compatible API.

**Networking gotcha (fixed 2026-11-02):** the `open-webui` container was on the
`bridge` network and `speaches` is on `voice_default`, so `speaches:8000` was
unreachable (hostname resolved to the mesh VPN IP instead). Fix:

```bash
docker network connect voice_default open-webui
```

This is persistent across restarts but is **lost if the open-webui container is
deleted and recreated** — re-run the command after any recreation.

**Open WebUI audio settings** (stored in its SQLite `config` table, visible under
Admin → Settings → Audio and user Settings → Audio):

| Setting | Value |
|---------|-------|
| `audio.stt.engine` | `openai` (OpenAI-compatible) |
| `audio.stt.openai.api_base_url` | `http://speaches:8000/v1` |
| `audio.stt.openai.api_key` | `sk-no-key-required` |
| `audio.stt.model` | `Systran/faster-distil-whisper-large-v3` |
| `audio.tts.engine` | `openai` (OpenAI-compatible) |
| `audio.tts.openai.api_base_url` | `http://speaches:8000/v1` |
| `audio.tts.openai.api_key` | `sk-no-key-required` |
| `audio.tts.model` | `speaches-ai/Kokoro-82M-v1.0-ONNX` |
| `audio.tts.voice` | `af_heart` |

User chat permissions for `stt`, `tts`, `call` are all `true`, so the mic button
and the user Audio tab are visible.

## Home Assistant Integration (PENDING)

Wire HA to the Wyoming bridge:
Settings → Devices & Services → Add Integration → **Wyoming Protocol** →
URI: `tcp://192.168.1.8:10300`

## OpenWakeWord (PENDING)

To be installed for wake-word detection with multiple phrase options.

## Operations

```bash
cd /opt/voice

# status
docker ps --filter name=speaches --filter name=wyoming_openai

# logs
docker logs -f speaches
docker logs -f wyoming_openai

# update (pull newer images, recreate)
docker compose pull && docker compose up -d

# if open-webui was recreated, re-attach the network
docker network connect voice_default open-webui
```

## Quick tests

```bash
# TTS (English)
curl -fsS http://localhost:8000/v1/audio/speech -H 'Content-Type: application/json' \
  -d '{"model":"speaches-ai/Kokoro-82M-v1.0-ONNX","input":"Hello!","voice":"af_heart","response_format":"wav"}' \
  --output /tmp/t.wav

# STT
curl -fsS http://localhost:8000/v1/audio/transcriptions \
  -F 'file=@/tmp/t.wav' -F 'model=Systran/faster-distil-whisper-large-v3' -F 'language=en'
```

> Note: transcribing **synthetic Piper/Kokoro TTS output** with Whisper is
> unreliable (Whisper sometimes mishears robotic voices, worse for non-English).
> Accuracy with real human speech is excellent. Don't judge STT quality on TTS
> round-trips.
