#!/bin/bash
# Pre-write check for xavs-ansible-collection
# Safety gates for collection files

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Warn if editing galaxy.yml — collection metadata
if [[ "$FILE_PATH" == *galaxy.yml ]]; then
  cat <<EOF
{
  "additionalContext": "NOTE: galaxy.yml defines collection metadata (namespace: xavs, name: images, version: 1.0.0). After changes, rebuild with: ansible-galaxy collection build --force"
}
EOF
fi

# Warn if editing baremetal role — orchestrator
if [[ "$FILE_PATH" == *roles/baremetal/* ]]; then
  cat <<EOF
{
  "additionalContext": "NOTE: The baremetal role is the orchestrator that calls all other roles in sequence. Execution order: etc_hosts → pre-install → packages → docker/podman → xavs_user → sdk → apparmor → ceph."
}
EOF
fi

# Warn if editing docker daemon.json composition
if [[ "$FILE_PATH" == *roles/docker/tasks/* ]]; then
  cat <<EOF
{
  "additionalContext": "NOTE: Docker daemon.json is built from 11 layers of config composition. docker_custom_config is always applied LAST (user overrides). Don't change the merge order."
}
EOF
fi

exit 0
