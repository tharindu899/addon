# Termux VPS Deployment Tool

Deploy web applications to VPS directly from Termux

## Installation
```bash
pkg update -y && pkg install -y wget openssh && \
wget https://github.com/tharindu899/addon/raw/refs/heads/main/termux/termux-deploy_V3.1.deb -O termux-deploy.deb && \
dpkg -i termux-deploy.deb && \
rm termux-deploy.deb
```

## Usage
```bash
deploy-vps
```

## Features
- Connect to VPS via SSH
- Deploy multiple repositories
- Docker container management
- SSL certificate setup
- Nginx reverse proxy configuration
- GitHub private repo support
```

## Uninstallation
```bash
dpkg -r termux-deploy
```
