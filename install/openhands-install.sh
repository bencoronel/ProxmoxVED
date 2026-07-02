#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Ben Coronel (benjamin-coronel)
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://www.openhands.dev/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y git
msg_ok "Installed Dependencies"

NODE_VERSION="22" setup_nodejs
setup_uv

msg_info "Installing OpenHands (Agent Canvas)"
$STD npm install -g @openhands/agent-canvas
msg_ok "Installed OpenHands (Agent Canvas)"

msg_info "Configuring OpenHands"
mkdir -p /opt/openhands
cat <<EOF >/opt/openhands/agent-canvas.env
LOCAL_BACKEND_API_KEY=$(openssl rand -hex 32)
EOF
chmod 600 /opt/openhands/agent-canvas.env
msg_ok "Configured OpenHands"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/openhands.service
[Unit]
Description=OpenHands Agent Canvas
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/openhands
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
EnvironmentFile=/opt/openhands/agent-canvas.env
ExecStart=agent-canvas --public
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now openhands
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
