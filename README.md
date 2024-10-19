# Story Protocol Node Management Tools

This repository contains a comprehensive tool to help you manage your Story Protocol node. The main script provides a menu-driven interface that simplifies the process of installing, updating, and maintaining your node.

## Quick Start

To get started, run the main installer script:

```bash
bash <(curl -s https://raw.githubusercontent.com/CroutonDigital/story-protocol-tools/main/scripts/story_protocol_installer.sh)
```

This will present you with a menu of options to manage your Story Protocol node.

## Available Options

When you run the script, you'll see a menu with the following options:

1. Install Story Protocol Node
2. Download snapshot
3. Start Node
4. Stop Node
5. Delete Node
6. View Logs
7. Exit

### 1. Install Story Protocol Node

This option sets up a new Story Protocol node on your system. It performs the following actions:

- Updates your system
- Installs necessary packages
- Installs Go
- Installs Geth and Story
- Sets up systemd services for Geth and Story

### 2. Download snapshot

This option helps you download and apply the latest snapshot for your Story Protocol node. It:

- Stops running services
- Backs up validator state
- Downloads and applies snapshots for both Geth and Story
- Restores validator state
- Restarts services

### 3. Start Node

Starts the Story Protocol node services (both Geth and Story).

### 4. Stop Node

Stops the running Story Protocol node services.

### 5. Delete Node

Completely removes the Story Protocol node from your system. Use with caution!

### 6. View Logs

This option allows you to view the logs for your Story Protocol node. When selected, you'll see a submenu with the following options:

- View Geth logs
- View Story logs
- Exit

This feature uses `journalctl` to display real-time logs for the selected service.

### 7. Exit

Exits the management tool.

## Notes

- Always ensure you have recent backups before performing major operations like updating or deleting your node.
- This script requires sudo access to perform system-level operations.
- If you encounter any issues, please check the logs or reach out to the Story Protocol community for support.

