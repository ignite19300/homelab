# HA Dashboard — LLM Recovery Cards

## Add to your dashboard (YAML editor):

```yaml
- type: vertical-stack
  title: "LLM Recovery"
  cards:
    - type: action
      name: "Start Llama 27B"
      icon: mdi:robot-happy
      action: perform-action
      action_name: shell_command.llama_27b_start
      description: "Starts the 27B text model on port 9931"

    - type: action
      name: "Start OpenWebUI"
      icon: mdi:web
      action: perform-action
      action_name: shell_command.owui_start
      description: "Starts the OpenWebUI docker container"

    - type: action
      name: "Start Router"
      icon: mdi:router
      action: perform-action
      action_name: shell_command.router_start
      description: "Starts the model router on port 8900"

    - type: action
      name: "Check Llama Status"
      icon: mdi:stethoscope
      action: perform-action
      action_name: shell_command.llama_status

    - type: action
      name: "Check OWUI Status"
      icon: mdi:stethoscope
      action: perform-action
      action_name: shell_command.owui_status
```

## Optional: REST Sensor for Llama status

```yaml
sensor:
  - platform: command_line
    name: "LLMA Status"
    command: /usr/bin/ssh -i /config/ssh/ha_access -o StrictHostKeyChecking=no user@192.168.1.8 "ss -tln | grep -c 9931"
    scan_interval: 60
```
