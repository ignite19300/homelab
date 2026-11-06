# HA Dashboard — LLM Recovery Buttons

Add these Mushroom cards to your dashboard. They trigger the shell_commands above.

## Card 1: Start Llama 27B
```
- type: mushroom-template-card
  template: llama_start
  variables:
    name: "Start Llama 27B"
    icon: mdi:robot
    action: llama_27b_start
```

## Card 2: Start OpenWebUI
```
- type: mushroom-template-card
  template: owui_start
  variables:
    name: "Start OpenWebUI"
    icon: mdi:web
    action: owui_start
```

## Simpler: Use action cards (no template needed)

### Start Llama 27B
```
- type: action
  name: "Start Llama 27B"
  icon: mdi:robot
  action: perform-action
  action_name: shell_command.llama_27b_start
```

### Start OpenWebUI
```
- type: action
  name: "Start OpenWebUI"
  icon: mdi:web
  action: perform-action
  action_name: shell_command.owui_start
```

## Status check (optional sensor)
Add a REST sensor or use the shell_command to check status:
```
sensor:
  - platform: command_line
    name: "LLMA Status"
    command: /usr/bin/ssh -o StrictHostKeyChecking=no user@192.168.1.8 "ss -tln | grep -c 9931"
    unit_of_measurement: "ports"
```
