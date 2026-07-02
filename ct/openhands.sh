#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVED/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: Ben Coronel (benjamin-coronel)
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://www.openhands.dev/

APP="OpenHands"
var_tags="${var_tags:-ai;dev-tools}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/openhands ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Checking for Updates"
  CURRENT="$(agent-canvas --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)"
  LATEST="$(npm view @openhands/agent-canvas version 2>/dev/null || true)"
  msg_ok "Checked for Updates"

  if [[ -z "$LATEST" ]]; then
    msg_error "Could not determine the latest version"
    exit
  fi

  if [[ "$CURRENT" == "$LATEST" ]]; then
    msg_ok "No update required. ${APP} is already at ${CURRENT}"
    exit
  fi

  msg_info "Stopping Service"
  systemctl stop openhands
  msg_ok "Stopped Service"

  msg_info "Updating ${APP} to ${LATEST}"
  $STD npm install -g @openhands/agent-canvas@latest
  msg_ok "Updated ${APP} to ${LATEST}"

  msg_info "Starting Service"
  systemctl start openhands
  msg_ok "Started Service"
  msg_ok "Updated successfully!"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8000${CL}"
echo -e "${INFO}${YW} Backend API key (enter it in the browser):${CL}"
echo -e "${TAB}${GATEWAY}${BGN}cat /opt/openhands/agent-canvas.env${CL}"
