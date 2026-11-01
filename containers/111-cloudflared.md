# 111 Cloudflared (LXC)
- Debian 12, 1c/512M, 192.168.10.11. Runs `cloudflared tunnel run --token`.
- Also postfix :25 + sshd :22 + cloudflared local :20241.
- Tunnel ingress is defined in the Cloudflare dashboard (token mode), NOT in
  this CT. To change what a hostname points at: repoint-tunnel.md runbook.
- Uptime since Jul 26 2026 — do not reboot casually.
