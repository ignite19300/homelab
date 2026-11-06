#!/bin/bash
# Docker helper — quick status/checks for KUbuntu Docker
# Usage: docker-helper.sh <command>
# Commands: status, logs <name>, disk, images, inspect <name>

case "$1" in
  status)
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
    ;;
  logs)
    docker logs --tail 50 "$2" 2>&1
    ;;
  disk)
    docker system df
    ;;
  images)
    docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'
    ;;
  inspect)
    docker inspect --format '{{.Name}} | State: {{.State.Status}} | Started: {{.State.StartedAt}} | RestartCount: {{.RestartCount}}' "$2" 2>&1
    ;;
  *)
    echo "Usage: $0 {status|logs <name>|disk|images|inspect <name>}"
    ;;
esac
