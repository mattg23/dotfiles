#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/lib.sh"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Level 3: backup installation ==${NC}"

install_apt restic
install_apt rclone
install_apt wl-clipboard

echo -e "${BLUE}Creating secure config directory...${NC}"
mkdir -p "$HOME/.config/restic"
if [ ! -f "$HOME/.config/restic/env.sh" ]; then
    touch "$HOME/.config/restic/env.sh"
    chmod 600 "$HOME/.config/restic/env.sh"
    echo -e "${YELLOW}Created empty $HOME/.config/restic/env.sh${NC}"
else
    echo -e "${BLUE}Config file already exists, skipping creation.${NC}"
fi

echo -e "${BLUE}Generating Systemd units...${NC}"
mkdir -p "$HOME/.config/systemd/user/"

# --- Create Service File ---
cat << 'EOF' > "$HOME/.config/systemd/user/restic-backup.service"
[Unit]
Description=Restic Backup (Company Files)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
# %h is home directory
ExecStart=%h/.local/share/chezmoi/scripts/tasks_backup.sh
CPUSchedulingPolicy=idle
IOSchedulingClass=idle
EOF

# --- Create Timer File ---
cat << 'EOF' > "$HOME/.config/systemd/user/restic-backup.timer"
[Unit]
Description=Run Restic Backup Daily 

[Timer]
# Run every day at 16:12 
OnCalendar=*-*-* 16:12:00

Persistent=true

[Install]
WantedBy=timers.target
EOF

echo -e "${GREEN}=== Setup Complete ===${NC}"
echo -e "${YELLOW}ACTION REQUIRED:${NC}"
echo -e "1. Edit credentials:  ${BLUE}~/.config/restic/env.sh${NC} -- HINT: SecNote: 'RESTIC ENV'"
echo -e "2. Initialize Repo:   ${BLUE}source ~/.config/restic/env.sh && restic init${NC}"
echo -e "3. Enable Timer:      ${BLUE}systemctl --user enable --now restic-backup.timer${NC}"
