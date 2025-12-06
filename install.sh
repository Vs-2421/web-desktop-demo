#!/usr/bin/env bash

# aburOS - Universal Web Desktop Environment
# Version: 2.0.0
# License: MIT
# Repository: https://github.com/Vs-2421/web-desktop-demo
#It was originally abur**, but due to GitHub restrictions it's now a web-desktop-demo.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect platform
detect_platform() {
    if [ -d "/data/data/com.termux/files/usr" ]; then
        echo "termux"
    elif [ -f "/etc/os-release" ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Check dependencies
check_dependencies() {
    local platform=$1
    
    print_info "Checking dependencies..."
    
    if [ "$platform" = "termux" ]; then
        if ! command -v python &> /dev/null && ! command -v python3 &> /dev/null; then
            print_warning "Python not found. Installing..."
            pkg update -y
            pkg install -y python
        fi
        
        if ! command -v git &> /dev/null; then
            pkg install -y git
        fi
        
        if ! command -v wget &> /dev/null; then
            pkg install -y wget
        fi
        
        # Ensure proper paths
        if [ ! -f "/data/data/com.termux/files/usr/bin/python3" ] && [ -f "/data/data/com.termux/files/usr/bin/python" ]; then
            ln -sf /data/data/com.termux/files/usr/bin/python /data/data/com.termux/files/usr/bin/python3 2>/dev/null || true
        fi
        
    else
        # For Linux distributions
        if ! command -v python3 &> /dev/null; then
            print_warning "Python3 not found. Attempting to install..."
            
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y python3 python3-pip git wget
            elif command -v yum &> /dev/null; then
                sudo yum install -y python3 python3-pip git wget
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y python3 python3-pip git wget
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm python python-pip git wget
            elif command -v zypper &> /dev/null; then
                sudo zypper install -y python3 python3-pip git wget
            else
                print_error "Cannot install Python3 automatically. Please install it manually."
                exit 1
            fi
        fi
        
        # Check for Node.js (optional for some features)
        if ! command -v node &> /dev/null; then
            print_info "Node.js is not installed (optional for extended features)"
        fi
    fi
    
    print_success "Dependencies checked"
}

# Install aburOS
install_aburos() {
    local platform=$1
    local install_dir="$HOME/.aburos"
    local version="2.0.0"
    
    print_info "Installing aburOS v$version..."
    
    # Remove old installation if exists
    if [ -d "$install_dir" ]; then
        print_warning "Previous installation found. Removing..."
        rm -rf "$install_dir"
    fi
    
    # Create directory structure
    mkdir -p "$install_dir"/{system,apps,data,config,logs,home,tmp,bin,lib}
    mkdir -p "$install_dir/home/user"/{Desktop,Documents,Downloads,Pictures,Music,Videos,Projects}
    
    # Create system files
    create_system_files "$install_dir" "$platform"
    
    # Create main HTML interface
    create_web_interface "$install_dir"
    
    # Create launchers
    create_launchers "$install_dir" "$platform"
    
    # Create update manager
    create_update_manager "$install_dir"
    
    # Create uninstaller
    create_uninstaller "$install_dir"
    
    # Set permissions
    chmod -R 755 "$install_dir"
    chmod +x "$install_dir"/bin/* "$install_dir"/*.sh 2>/dev/null
    
    print_success "aburOS installed to $install_dir"
}

# Create system configuration files
create_system_files() {
    local install_dir=$1
    local platform=$2
    
    # Create user database
    cat > "$install_dir/system/users.db" << EOF
{
  "users": {
    "admin": {
      "password": "$(echo -n "admin123" | base64)",
      "name": "Administrator",
      "role": "admin",
      "created": "$(date -Iseconds)",
      "theme": "default",
      "wallpaper": "default"
    },
    "guest": {
      "password": "$(echo -n "guest123" | base64)",
      "name": "Guest User",
      "role": "user",
      "created": "$(date -Iseconds)",
      "theme": "light",
      "wallpaper": "light"
    }
  },
  "system": {
    "version": "2.0.0",
    "install_date": "$(date -Iseconds)",
    "platform": "$platform",
    "last_update": null
  }
}
EOF

    # Create apps database
    cat > "$install_dir/system/apps.db" << EOF
{
  "installed": [
    {
      "id": "terminal",
      "name": "Terminal",
      "version": "1.0.0",
      "description": "System terminal with real shell access",
      "category": "system",
      "executable": "/bin/bash"
    },
    {
      "id": "filemanager",
      "name": "File Manager",
      "version": "1.0.0",
      "description": "File browser and manager",
      "category": "utilities"
    },
    {
      "id": "browser",
      "name": "Web Browser",
      "version": "1.0.0",
      "description": "Internet browser",
      "category": "internet"
    },
    {
      "id": "calculator",
      "name": "Calculator",
      "version": "1.0.0",
      "description": "Scientific calculator",
      "category": "utilities"
    },
    {
      "id": "texteditor",
      "name": "Text Editor",
      "version": "1.0.0",
      "description": "Code and text editor",
      "category": "development"
    },
    {
      "id": "settings",
      "name": "System Settings",
      "version": "1.0.0",
      "description": "System configuration",
      "category": "system"
    },
    {
      "id": "processmanager",
      "name": "Process Manager",
      "version": "1.0.0",
      "description": "View and manage system processes",
      "category": "system"
    },
    {
      "id": "networkmanager",
      "name": "Network Manager",
      "version": "1.0.0",
      "description": "Network tools and monitor",
      "category": "internet"
    },
    {
      "id": "packagemanager",
      "name": "Package Manager",
      "version": "1.0.0",
      "description": "Install and manage software",
      "category": "system"
    },
    {
      "id": "paint",
      "name": "aburPaint",
      "version": "1.0.0",
      "description": "Drawing application",
      "category": "graphics"
    },
    {
      "id": "office",
      "name": "aburOffice",
      "version": "1.0.0",
      "description": "Office suite (text, spreadsheet)",
      "category": "office"
    },
    {
      "id": "mediaplayer",
      "name": "Media Player",
      "version": "1.0.0",
      "description": "Audio and video player",
      "category": "multimedia"
    }
  ],
  "available": [
    {
      "id": "python",
      "name": "Python IDE",
      "description": "Python development environment",
      "category": "development",
      "install_cmd": "install_python_ide"
    },
    {
      "id": "wireshark",
      "name": "Wireshark",
      "description": "Network protocol analyzer",
      "category": "internet",
      "install_cmd": "install_wireshark"
    },
    {
      "id": "gimp",
      "name": "GIMP",
      "description": "Image manipulation program",
      "category": "graphics",
      "install_cmd": "install_gimp"
    },
    {
      "id": "libreoffice",
      "name": "LibreOffice",
      "description": "Complete office suite",
      "category": "office",
      "install_cmd": "install_libreoffice"
    }
  ]
}
EOF

    # Create system configuration
    cat > "$install_dir/system/config.json" << EOF
{
  "server": {
    "port": 8080,
    "host": "0.0.0.0",
    "enable_ssl": false
  },
  "security": {
    "require_auth": true,
    "session_timeout": 3600,
    "max_login_attempts": 5
  },
  "interface": {
    "default_theme": "default",
    "animations": true,
    "transparency": true,
    "performance_mode": false
  },
  "storage": {
    "max_file_size": 104857600,
    "backup_enabled": true,
    "backup_interval": 86400
  }
}
EOF
}

# Create the main web interface
create_web_interface() {
    local install_dir=$1
    
    print_info "Creating web interface..."
    
    # This would be a very large HTML/JS/CSS file
    # For GitHub, we'll create a template and download the full version
    # Here's the basic structure:
    
    cat > "$install_dir/index.html" << 'HTML_BASE'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>aburOS - Loading...</title>
    <style>
        .loading-screen {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            z-index: 9999;
        }
        
        .loading-logo {
            font-size: 3rem;
            color: #4cc9f0;
            margin-bottom: 2rem;
            text-align: center;
        }
        
        .loading-progress {
            width: 300px;
            height: 4px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 2px;
            overflow: hidden;
        }
        
        .loading-bar {
            height: 100%;
            background: linear-gradient(90deg, #4cc9f0, #4361ee);
            width: 0%;
            transition: width 0.3s ease;
        }
        
        .loading-text {
            color: rgba(255, 255, 255, 0.7);
            margin-top: 1rem;
            font-family: monospace;
        }
        
        .performance-option {
            margin-top: 2rem;
            padding: 1rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 8px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .performance-option:hover {
            background: rgba(255, 255, 255, 0.2);
        }
    </style>
</head>
<body>
    <div class="loading-screen" id="loadingScreen">
        <div class="loading-logo">
            <div style="font-size: 4rem; margin-bottom: 1rem;">⚡</div>
            aburOS
            <div style="font-size: 1rem; margin-top: 0.5rem; color: rgba(255, 255, 255, 0.5);">
                Universal Web Desktop Environment
            </div>
        </div>
        
        <div class="loading-progress">
            <div class="loading-bar" id="loadingBar"></div>
        </div>
        
        <div class="loading-text" id="loadingText">Initializing system...</div>
        
        <div class="performance-option" id="performanceOption" onclick="togglePerformanceMode()">
            <div style="font-weight: bold; color: #4cc9f0;">⚡ Performance Mode Available</div>
            <div style="font-size: 0.9rem; margin-top: 0.5rem; color: rgba(255, 255, 255, 0.7);">
                Click to enable lightweight mode (reduces CPU/GPU usage)
            </div>
        </div>
    </div>

    <script>
        // This is a minimal loader. The full interface will be loaded dynamically
        let performanceMode = localStorage.getItem('aburos_performance_mode') === 'true';
        
        function updateProgress(percent, text) {
            document.getElementById('loadingBar').style.width = percent + '%';
            document.getElementById('loadingText').textContent = text;
        }
        
        function togglePerformanceMode() {
            performanceMode = !performanceMode;
            localStorage.setItem('aburos_performance_mode', performanceMode);
            document.getElementById('performanceOption').innerHTML = performanceMode ?
                '<div style="font-weight: bold; color: #10b981;">✓ Performance Mode Enabled</div>' +
                '<div style="font-size: 0.9rem; margin-top: 0.5rem; color: rgba(255, 255, 255, 0.7);">' +
                'Lightweight interface will load</div>' :
                '<div style="font-weight: bold; color: #4cc9f0;">⚡ Performance Mode Available</div>' +
                '<div style="font-size: 0.9rem; margin-top: 0.5rem; color: rgba(255, 255, 255, 0.7);">' +
                'Click to enable lightweight mode</div>';
            
            // Reload with new mode
            setTimeout(() => {
                window.location.reload();
            }, 500);
        }
        
        // Load the appropriate interface
        window.addEventListener('DOMContentLoaded', async () => {
            updateProgress(10, 'Checking system...');
            
            try {
                // Load configuration
                const response = await fetch('/api/system/config');
                const config = await response.json();
                
                updateProgress(30, 'Loading interface...');
                
                // Load the appropriate interface file
                const interfaceFile = performanceMode ? 'interface-lite.html' : 'interface-full.html';
                const interfaceResponse = await fetch(interfaceFile);
                const interfaceHTML = await interfaceResponse.text();
                
                updateProgress(70, 'Initializing applications...');
                
                // Replace body with loaded interface
                document.body.innerHTML = interfaceHTML;
                
                updateProgress(100, 'System ready!');
                
                // Initialize the loaded interface
                if (window.initAburOS) {
                    window.initAburOS(config, performanceMode);
                }
                
            } catch (error) {
                console.error('Failed to load interface:', error);
                document.getElementById('loadingText').textContent = 
                    'Error loading interface. Please check console.';
                document.getElementById('loadingText').style.color = '#ef4444';
            }
        });
    </script>
</body>
</html>
HTML_BASE

    # Create minimal lite interface
    cat > "$install_dir/interface-lite.html" << 'LITE_HTML'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>aburOS Lite</title>
    <style>
        :root {
            --primary: #2563eb;
            --bg: #0f172a;
            --surface: #1e293b;
            --text: #f8fafc;
        }
        
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background: var(--bg); color: var(--text); font-family: sans-serif; }
        
        .desktop { height: 100vh; display: flex; flex-direction: column; }
        
        .taskbar {
            background: var(--surface);
            padding: 0.5rem;
            border-top: 1px solid rgba(255,255,255,0.1);
            display: flex;
            justify-content: space-between;
        }
        
        .window {
            background: var(--surface);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 4px;
            margin: 1rem;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .window-header {
            background: rgba(var(--primary), 0.2);
            padding: 0.5rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        
        .terminal-output {
            background: #000;
            flex: 1;
            padding: 1rem;
            font-family: monospace;
            overflow-y: auto;
            white-space: pre-wrap;
        }
        
        .terminal-input {
            background: #111;
            border: none;
            color: #0f0;
            padding: 0.5rem;
            font-family: monospace;
            width: 100%;
        }
        
        .app-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(80px, 1fr));
            gap: 1rem;
            padding: 1rem;
        }
        
        .app-icon {
            background: var(--surface);
            padding: 1rem;
            border-radius: 4px;
            text-align: center;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="desktop" id="desktop">
        <div class="app-grid" id="appGrid"></div>
        
        <div class="window" id="terminalWindow" style="display: none;">
            <div class="window-header">
                Terminal <button onclick="closeWindow('terminalWindow')" style="float:right;">✕</button>
            </div>
            <div class="terminal-output" id="terminalOutput"></div>
            <input class="terminal-input" id="terminalInput" 
                   placeholder="Enter command..." onkeydown="handleTerminalKey(event)">
        </div>
        
        <div class="taskbar">
            <button onclick="showAppGrid()">Apps</button>
            <div id="clock">00:00:00</div>
            <div id="systemStatus">CPU: --% | RAM: --%</div>
        </div>
    </div>

    <script>
        // Real terminal communication
        let terminalSocket = null;
        let currentUser = 'admin';
        
        async function initAburOS(config, performanceMode) {
            // Initialize clock
            setInterval(() => {
                document.getElementById('clock').textContent = 
                    new Date().toLocaleTimeString();
            }, 1000);
            
            // Load apps
            const apps = [
                {id: 'terminal', name: 'Terminal', icon: '💻'},
                {id: 'files', name: 'Files', icon: '📁'},
                {id: 'browser', name: 'Browser', icon: '🌐'},
                {id: 'settings', name: 'Settings', icon: '⚙️'},
                {id: 'calculator', name: 'Calculator', icon: '🧮'},
                {id: 'editor', name: 'Editor', icon: '📝'},
                {id: 'paint', name: 'Paint', icon: '🎨'},
                {id: 'office', name: 'Office', icon: '📊'}
            ];
            
            const appGrid = document.getElementById('appGrid');
            apps.forEach(app => {
                const appIcon = document.createElement('div');
                appIcon.className = 'app-icon';
                appIcon.innerHTML = `${app.icon}<br><small>${app.name}</small>`;
                appIcon.onclick = () => openApp(app.id);
                appGrid.appendChild(appIcon);
            });
            
            // Connect to real terminal backend
            connectTerminal();
            
            // Load user settings
            loadUserSettings();
        }
        
        function openApp(appId) {
            if (appId === 'terminal') {
                document.getElementById('terminalWindow').style.display = 'flex';
                document.getElementById('terminalInput').focus();
                showNotification('Terminal opened with real shell access');
            } else {
                fetch(`/api/apps/${appId}/open`, {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'}
                }).then(response => response.json())
                  .then(data => {
                      if (data.success) {
                          showNotification(`${appId} application opened`);
                      }
                  });
            }
        }
        
        function connectTerminal() {
            // WebSocket connection to real terminal
            const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            terminalSocket = new WebSocket(`${protocol}//${window.location.host}/ws/terminal`);
            
            terminalSocket.onopen = () => {
                console.log('Terminal WebSocket connected');
                document.getElementById('terminalOutput').innerHTML += 
                    '<div style="color:#0f0">Connected to real system terminal</div>';
            };
            
            terminalSocket.onmessage = (event) => {
                const output = document.getElementById('terminalOutput');
                output.innerHTML += `<div>${escapeHtml(event.data)}</div>`;
                output.scrollTop = output.scrollHeight;
            };
            
            terminalSocket.onclose = () => {
                console.log('Terminal WebSocket disconnected');
                document.getElementById('terminalOutput').innerHTML += 
                    '<div style="color:#f00">Terminal disconnected</div>';
            };
        }
        
        function handleTerminalKey(event) {
            if (event.key === 'Enter') {
                const input = document.getElementById('terminalInput');
                const command = input.value.trim();
                
                if (command) {
                    const output = document.getElementById('terminalOutput');
                    output.innerHTML += `<div style="color:#4cc9f0">$ ${command}</div>`;
                    
                    // Send to real terminal
                    if (terminalSocket && terminalSocket.readyState === WebSocket.OPEN) {
                        terminalSocket.send(command);
                    } else {
                        output.innerHTML += '<div style="color:#f00">Terminal not connected</div>';
                    }
                    
                    input.value = '';
                }
                
                event.preventDefault();
            }
        }
        
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
        
        function showNotification(message) {
            // Simple notification
            const notification = document.createElement('div');
            notification.style.cssText = `
                position: fixed; top: 20px; right: 20px;
                background: var(--surface); padding: 1rem;
                border-left: 4px solid var(--primary);
                border-radius: 4px;
                z-index: 1000;
            `;
            notification.textContent = message;
            document.body.appendChild(notification);
            
            setTimeout(() => notification.remove(), 3000);
        }
        
        function closeWindow(windowId) {
            document.getElementById(windowId).style.display = 'none';
        }
        
        function showAppGrid() {
            const appGrid = document.getElementById('appGrid');
            appGrid.style.display = appGrid.style.display === 'none' ? 'grid' : 'none';
        }
        
        async function loadUserSettings() {
            try {
                const response = await fetch('/api/user/settings');
                const settings = await response.json();
                
                // Apply user preferences
                if (settings.theme) {
                    document.documentElement.style.setProperty('--primary', settings.theme.primary);
                }
            } catch (error) {
                console.error('Failed to load user settings:', error);
            }
        }
        
        // Initialize when loaded
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => {
                initAburOS({}, true);
            });
        } else {
            initAburOS({}, true);
        }
        
        window.initAburOS = initAburOS;
        window.openApp = openApp;
    </script>
</body>
</html>
LITE_HTML

    # For the full interface, we'll create a placeholder that will be replaced
    # with the actual full interface from GitHub
    cat > "$install_dir/interface-full.html" << 'FULL_PLACEHOLDER'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>aburOS Full Interface - Loading</title>
</head>
<body>
    <div style="padding: 2rem; text-align: center;">
        <h1>Full Interface</h1>
        <p>The full interface will be loaded from the repository.</p>
        <p>For now, using lite mode.</p>
        <button onclick="window.location.reload()">Switch to Lite Mode</button>
    </div>
    
    <script>
        // Try to load the full interface from CDN/GitHub
        fetch('https://raw.githubusercontent.com/[your-username]/aburOS/main/full-interface.html')
            .then(response => response.text())
            .then(html => {
                document.open();
                document.write(html);
                document.close();
            })
            .catch(error => {
                console.error('Failed to load full interface:', error);
                document.body.innerHTML += `
                    <div style="color: #f00; padding: 1rem;">
                        Failed to load full interface. Using lite mode.
                    </div>
                `;
            });
    </script>
</body>
</html>
FULL_PLACEHOLDER

    # Create backend Python server that handles real terminal access
    create_backend_server "$install_dir"
}

# Create backend server for real terminal access
create_backend_server() {
    local install_dir=$1
    
    cat > "$install_dir/server.py" << 'PYTHON_SERVER'
#!/usr/bin/env python3
"""
aburOS Backend Server
Handles real terminal access, file operations, and system integration
"""

import os
import sys
import json
import shlex
import subprocess
import threading
import websockets
import asyncio
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import sqlite3
from datetime import datetime
import signal
import pty
import select
import termios
import tty
import fcntl
import struct

class AburOSHandler(BaseHTTPRequestHandler):
    """HTTP handler for aburOS API"""
    
    def __init__(self, *args, **kwargs):
        self.install_dir = kwargs.pop('install_dir')
        super().__init__(*args, **kwargs)
    
    def do_GET(self):
        """Handle GET requests"""
        parsed = urlparse(self.path)
        
        if parsed.path == '/':
            # Serve main interface
            self.serve_file('index.html')
        elif parsed.path == '/interface-lite.html':
            self.serve_file('interface-lite.html')
        elif parsed.path == '/interface-full.html':
            self.serve_file('interface-full.html')
        elif parsed.path.startswith('/api/'):
            self.handle_api(parsed)
        elif os.path.exists(os.path.join(self.install_dir, parsed.path[1:])):
            self.serve_file(parsed.path[1:])
        else:
            self.send_error(404, "File not found")
    
    def do_POST(self):
        """Handle POST requests"""
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode('utf-8')
        
        parsed = urlparse(self.path)
        
        if parsed.path.startswith('/api/'):
            try:
                data = json.loads(post_data) if post_data else {}
                self.handle_api(parsed, data)
            except json.JSONDecodeError:
                self.send_error(400, "Invalid JSON")
        else:
            self.send_error(404)
    
    def serve_file(self, filename):
        """Serve static files"""
        filepath = os.path.join(self.install_dir, filename)
        
        if not os.path.exists(filepath):
            self.send_error(404)
            return
        
        # Determine content type
        content_types = {
            '.html': 'text/html',
            '.css': 'text/css',
            '.js': 'application/javascript',
            '.json': 'application/json',
            '.png': 'image/png',
            '.jpg': 'image/jpeg',
            '.svg': 'image/svg+xml',
        }
        
        ext = os.path.splitext(filename)[1].lower()
        content_type = content_types.get(ext, 'application/octet-stream')
        
        try:
            with open(filepath, 'rb') as f:
                content = f.read()
            
            self.send_response(200)
            self.send_header('Content-Type', content_type)
            self.send_header('Content-Length', str(len(content)))
            self.send_header('Cache-Control', 'no-cache')
            self.end_headers()
            self.wfile.write(content)
        except Exception as e:
            print(f"Error serving file {filename}: {e}")
            self.send_error(500)
    
    def handle_api(self, parsed, data=None):
        """Handle API requests"""
        api_path = parsed.path[5:]  # Remove '/api/'
        
        if api_path == 'system/config':
            self.handle_config()
        elif api_path == 'user/settings':
            self.handle_user_settings(data)
        elif api_path.startswith('apps/'):
            app_id = api_path[5:].split('/')[0]
            self.handle_app_request(app_id, data)
        elif api_path == 'terminal/execute':
            self.handle_terminal_execute(data)
        elif api_path == 'files/list':
            self.handle_files_list(data)
        elif api_path == 'files/read':
            self.handle_files_read(data)
        elif api_path == 'files/write':
            self.handle_files_write(data)
        elif api_path == 'system/processes':
            self.handle_system_processes()
        elif api_path == 'system/info':
            self.handle_system_info()
        elif api_path == 'packages/install':
            self.handle_package_install(data)
        else:
            self.send_error(404, "API endpoint not found")
    
    def handle_config(self):
        """Return system configuration"""
        config_path = os.path.join(self.install_dir, 'system/config.json')
        try:
            with open(config_path, 'r') as f:
                config = json.load(f)
            
            # Add runtime info
            config['runtime'] = {
                'platform': sys.platform,
                'python_version': sys.version,
                'server_time': datetime.now().isoformat()
            }
            
            self.send_json(config)
        except Exception as e:
            self.send_error(500, str(e))
    
    def handle_user_settings(self, data):
        """Handle user settings"""
        users_db = os.path.join(self.install_dir, 'system/users.db')
        try:
            with open(users_db, 'r') as f:
                users = json.load(f)
            
            if data and 'action' in data:
                if data['action'] == 'get':
                    username = data.get('username', 'admin')
                    if username in users['users']:
                        user_data = users['users'][username].copy()
                        # Don't send password
                        if 'password' in user_data:
                            del user_data['password']
                        self.send_json(user_data)
                    else:
                        self.send_error(404, "User not found")
                elif data['action'] == 'update':
                    # Update user settings
                    username = data.get('username', 'admin')
                    if username in users['users']:
                        for key, value in data.get('settings', {}).items():
                            if key != 'password' and key in users['users'][username]:
                                users['users'][username][key] = value
                        
                        # Handle password change
                        if 'new_password' in data:
                            import base64
                            users['users'][username]['password'] = base64.b64encode(
                                data['new_password'].encode()
                            ).decode()
                        
                        with open(users_db, 'w') as f:
                            json.dump(users, f, indent=2)
                        
                        self.send_json({'success': True})
                    else:
                        self.send_error(404, "User not found")
            else:
                self.send_error(400, "Invalid request")
        except Exception as e:
            self.send_error(500, str(e))
    
    def handle_terminal_execute(self, data):
        """Execute command in real terminal"""
        if not data or 'command' not in data:
            self.send_error(400, "No command provided")
            return
        
        command = data['command']
        cwd = data.get('cwd', self.install_dir)
        
        # Security: Prevent escaping from aburOS directory
        if '..' in cwd or cwd.startswith('/') and not cwd.startswith(self.install_dir):
            cwd = self.install_dir
        
        try:
            # Execute command
            env = os.environ.copy()
            env['ABUROS_HOME'] = self.install_dir
            env['ABUROS_USER'] = data.get('user', 'admin')
            
            process = subprocess.Popen(
                command,
                shell=True,
                cwd=cwd,
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                stdin=subprocess.PIPE if data.get('input') else None,
                text=True
            )
            
            if data.get('input'):
                process.stdin.write(data['input'])
                process.stdin.close()
            
            stdout, stderr = process.communicate(timeout=30)
            
            result = {
                'success': process.returncode == 0,
                'exit_code': process.returncode,
                'stdout': stdout,
                'stderr': stderr,
                'command': command
            }
            
            self.send_json(result)
            
        except subprocess.TimeoutExpired:
            process.kill()
            self.send_error(408, "Command timed out")
        except Exception as e:
            self.send_error(500, str(e))
    
    def handle_files_list(self, data):
        """List files in directory"""
        path = data.get('path', '')
        full_path = os.path.join(self.install_dir, 'home/user', path.lstrip('/'))
        
        # Security check
        if not full_path.startswith(self.install_dir):
            full_path = os.path.join(self.install_dir, 'home/user')
        
        try:
            items = []
            for item in os.listdir(full_path):
                item_path = os.path.join(full_path, item)
                stat = os.stat(item_path)
                
                items.append({
                    'name': item,
                    'type': 'directory' if os.path.isdir(item_path) else 'file',
                    'size': stat.st_size,
                    'modified': stat.st_mtime,
                    'permissions': oct(stat.st_mode)[-3:]
                })
            
            self.send_json({
                'path': path,
                'items': items,
                'total': len(items)
            })
        except Exception as e:
            self.send_error(500, str(e))
    
    def handle_files_read(self, data):
        """Read file content"""
        if 'file' not in data:
            self.send_error(400, "No file specified")
            return
        
        file_path = os.path.join(self.install_dir, 'home/user', data['file'].lstrip('/'))
        
        # Security check
        if not file_path.startswith(os.path.join(self.install_dir, 'home/user')):
            self.send_error(403, "Access denied")
            return
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            self.send_json({
                'success': True,
                'content': content,
                'size': len(content)
            })
        except UnicodeDecodeError:
            # Try binary read
            try:
                with open(file_path, 'rb') as f:
                    content = f.read()
                
                self.send_json({
                    'success': True,
                    'content': content.hex(),
                    'binary': True,
                    'size': len(content)
                })
            except Exception as e:
                self.send_error(500, str(e))
        except Exception as e:
            self.send_error(500, str(e))
    
    def handle_files_write(self, data):
        """Write file content"""
        if 'file' not in data or 'content' not in data:
            self.send_error(400, "Missing parameters")
            return
        
        file_path = os.path.join(self.install_dir, 'home/user', data['file'].lstrip('/'))
        
        # Security check
        if not file_path.startswith(os.path.join(self.install_dir, 'home/user')):
            self.send_error(403, "Access denied")
            return
        
        # Create directory if needed
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        
        try:
            if data.get('binary'):
                # Binary write
                content = bytes.fromhex(data['content'])
                with open(file_path, 'wb') as f:
                    f.write(content)
            else:
                # Text write
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(data['content'])
            
            self.send_json({'success': True})
        except Exception as e:
            self.send_error(500, str(e))
    
    def handle_system_processes(self):
        """Get system processes"""
        try:
            import psutil
            processes = []
            
            for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent']):
                try:
                    processes.append(proc.info)
                except (psutil.NoSuchProcess, psutil.AccessDenied):
                    continue
            
            self.send_json({
                'processes': processes[:50],  # Limit to 50
                'total': len(processes)
            })
        except ImportError:
            # Fallback to ps command
            try:
                result = subprocess.run(
                    ['ps', 'aux'],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                
                lines = result.stdout.strip().split('\n')
                headers = lines[0].split()
                processes = []
                
                for line in lines[1:21]:  # First 20 processes
                    parts = line.split(maxsplit=len(headers)-1)
                    if len(parts) >= len(headers):
                        processes.append(dict(zip(headers, parts)))
                
                self.send_json({
                    'processes': processes,
                    'total': len(lines) - 1
                })
            except Exception as e:
                self.send_error(500, f"Failed to get processes: {e}")
    
    def handle_system_info(self):
        """Get system information"""
        try:
            import psutil
            
            info = {
                'cpu': {
                    'percent': psutil.cpu_percent(interval=0.1),
                    'count': psutil.cpu_count(),
                    'frequency': psutil.cpu_freq().current if hasattr(psutil.cpu_freq(), 'current') else None
                },
                'memory': {
                    'total': psutil.virtual_memory().total,
                    'available': psutil.virtual_memory().available,
                    'percent': psutil.virtual_memory().percent
                },
                'disk': {
                    'total': psutil.disk_usage('/').total,
                    'used': psutil.disk_usage('/').used,
                    'free': psutil.disk_usage('/').free,
                    'percent': psutil.disk_usage('/').percent
                },
                'platform': {
                    'system': sys.platform,
                    'node': os.uname().nodename if hasattr(os, 'uname') else 'Unknown',
                    'release': os.uname().release if hasattr(os, 'uname') else 'Unknown'
                }
            }
            
            self.send_json(info)
        except ImportError:
            # Basic info without psutil
            info = {
                'cpu': {'percent': 0, 'count': 1},
                'memory': {'total': 0, 'available': 0, 'percent': 0},
                'disk': {'total': 0, 'used': 0, 'free': 0, 'percent': 0},
                'platform': {
                    'system': sys.platform,
                    'node': 'Unknown',
                    'release': 'Unknown'
                }
            }
            self.send_json(info)
    
    def handle_package_install(self, data):
        """Install system package"""
        if 'package' not in data:
            self.send_error(400, "No package specified")
            return
        
        package = data['package']
        
        # Security: Only allow specific packages
        allowed_packages = ['python', 'wireshark', 'gimp', 'libreoffice', 'vim', 'htop']
        if package not in allowed_packages:
            self.send_error(403, f"Package {package} not allowed")
            return
        
        try:
            # Determine package manager
            import shutil
            
            install_cmd = None
            if shutil.which('apt'):
                install_cmd = ['sudo', 'apt', 'install', '-y', package]
            elif shutil.which('yum'):
                install_cmd = ['sudo', 'yum', 'install', '-y', package]
            elif shutil.which('dnf'):
                install_cmd = ['sudo', 'dnf', 'install', '-y', package]
            elif shutil.which('pacman'):
                install_cmd = ['sudo', 'pacman', '-S', '--noconfirm', package]
            elif shutil.which('pkg'):
                install_cmd = ['pkg', 'install', '-y', package]
            
            if install_cmd:
                result = subprocess.run(
                    install_cmd,
                    capture_output=True,
                    text=True,
                    timeout=300  # 5 minutes timeout
                )
                
                self.send_json({
                    'success': result.returncode == 0,
                    'stdout': result.stdout,
                    'stderr': result.stderr,
                    'returncode': result.returncode
                })
            else:
                self.send_error(500, "No package manager found")
                
        except subprocess.TimeoutExpired:
            self.send_error(408, "Installation timed out")
        except Exception as e:
            self.send_error(500, str(e))
    
    def handle_app_request(self, app_id, data):
        """Handle application-specific requests"""
        # This would handle app-specific API calls
        # For now, just return basic info
        self.send_json({
            'app': app_id,
            'status': 'available',
            'message': 'App endpoint'
        })
    
    def send_json(self, data):
        """Send JSON response"""
        response = json.dumps(data, indent=2).encode('utf-8')
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(response)))
        self.send_header('Cache-Control', 'no-cache')
        self.end_headers()
        self.wfile.write(response)
    
    def log_message(self, format, *args):
        """Custom log message format"""
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {format % args}")

async def websocket_handler(websocket, path):
    """Handle WebSocket connections for real terminal"""
    print(f"WebSocket connection: {path}")
    
    if path == '/ws/terminal':
        await handle_terminal_websocket(websocket)
    else:
        await websocket.close(code=1003, reason="Unknown endpoint")

async def handle_terminal_websocket(websocket):
    """Handle terminal WebSocket with PTY"""
    # Create PTY for real terminal
    pid, fd = pty.fork()
    
    if pid == 0:
        # Child process - run shell
        os.environ['TERM'] = 'xterm-256color'
        os.environ['HOME'] = os.path.expanduser('~')
        os.execlp('bash', 'bash')
    else:
        # Parent process - handle WebSocket communication
        old_tty_settings = termios.tcgetattr(fd)
        tty.setraw(fd)
        
        try:
            # Set non-blocking
            fl = fcntl.fcntl(fd, fcntl.F_GETFL)
            fcntl.fcntl(fd, fcntl.F_SETFL, fl | os.O_NONBLOCK)
            
            # Send initial message
            await websocket.send("aburOS Terminal - Connected to real shell\r\n")
            await websocket.send(f"$ ")
            
            while True:
                try:
                    # Wait for data from WebSocket or PTY
                    ready_to_read, ready_to_write, _ = select.select(
                        [websocket, fd], [], [], 0.1
                    )
                    
                    for ready in ready_to_read:
                        if ready is websocket:
                            # Data from WebSocket to PTY
                            try:
                                data = await asyncio.wait_for(websocket.recv(), timeout=0.1)
                                if data:
                                    os.write(fd, data.encode())
                            except asyncio.TimeoutError:
                                pass
                            except websockets.exceptions.ConnectionClosed:
                                return
                        
                        elif ready is fd:
                            # Data from PTY to WebSocket
                            try:
                                data = os.read(fd, 1024)
                                if data:
                                    await websocket.send(data.decode())
                            except OSError:
                                pass
                    
                    # Check if process is still alive
                    try:
                        os.waitpid(pid, os.WNOHANG)
                    except ChildProcessError:
                        await websocket.send("\r\nProcess terminated\r\n")
                        break
                        
                except Exception as e:
                    print(f"Terminal error: {e}")
                    break
                    
        finally:
            # Restore terminal settings and clean up
            termios.tcsetattr(fd, termios.TCSADRAIN, old_tty_settings)
            os.close(fd)
            try:
                os.kill(pid, signal.SIGTERM)
            except ProcessLookupError:
                pass

def run_server(install_dir, port=8080, host='0.0.0.0'):
    """Run the combined HTTP/WebSocket server"""
    
    # Custom handler with install_dir
    handler_class = type('AburOSHandlerWithDir', (AburOSHandler,), {
        '__init__': lambda self, *args, **kwargs: AburOSHandler.__init__(
            self, *args, install_dir=install_dir, **kwargs
        )
    })
    
    # Start HTTP server in thread
    http_server = HTTPServer((host, port), handler_class)
    http_thread = threading.Thread(target=http_server.serve_forever)
    http_thread.daemon = True
    http_thread.start()
    
    print(f"HTTP server started on http://{host}:{port}")
    
    # Start WebSocket server
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    
    start_server = websockets.serve(websocket_handler, host, port + 1)
    loop.run_until_complete(start_server)
    print(f"WebSocket server started on ws://{host}:{port + 1}")
    
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        print("\nShutting down servers...")
    finally:
        http_server.shutdown()
        loop.stop()
        loop.close()

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='aburOS Backend Server')
    parser.add_argument('--port', type=int, default=8080, help='HTTP port')
    parser.add_argument('--host', default='0.0.0.0', help='Bind address')
    parser.add_argument('--install-dir', required=True, help='aburOS installation directory')
    
    args = parser.parse_args()
    
    print(f"Starting aburOS server v2.0.0")
    print(f"Install directory: {args.install_dir}")
    print(f"Server: http://{args.host}:{args.port}")
    print(f"Terminal: ws://{args.host}:{args.port + 1}")
    print("Press Ctrl+C to stop")
    
    run_server(args.install_dir, args.port, args.host)
PYTHON_SERVER

    chmod +x "$install_dir/server.py"
}

# Create launcher scripts
create_launchers() {
    local install_dir=$1
    local platform=$2
    
    # Main launcher
    cat > "$install_dir/start.sh" << 'LAUNCHER'
#!/usr/bin/env bash

ABUROS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT="${1:-8080}"
HOST="${2:-0.0.0.0}"

echo "========================================"
echo "        aburOS v2.0.0                   "
echo "========================================"
echo "Directory: $ABUROS_DIR"
echo "Server: http://$HOST:$PORT"
echo "WebSocket: ws://$HOST:$((PORT + 1))"
echo ""

# Check if server is already running
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Port $PORT is already in use!"
    echo "   Either stop the other process or use a different port:"
    echo "   ./start.sh 9090"
    exit 1
fi

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON=python3
elif command -v python &> /dev/null; then
    PYTHON=python
else
    echo "❌ Python not found!"
    exit 1
fi

echo "🚀 Starting aburOS server..."
echo ""

# Run the server
cd "$ABUROS_DIR"
exec "$PYTHON" server.py --port "$PORT" --host "$HOST" --install-dir "$ABUROS_DIR"
LAUNCHER

    # Termux-specific launcher
    if [ "$platform" = "termux" ]; then
        cat > "$install_dir/start-termux.sh" << 'TERMUX_LAUNCHER'
#!/data/data/com.termux/files/usr/bin/bash

ABUROS_DIR="$HOME/.aburos"
PORT=8080

echo "Starting aburOS in Termux..."
echo ""

# Start in background
cd "$ABUROS_DIR"
./start.sh "$PORT" 127.0.0.1 &
SERVER_PID=$!

sleep 2

# Open in Termux browser
if command -v termux-open-url &> /dev/null; then
    echo "Opening browser..."
    termux-open-url "http://localhost:$PORT"
else
    echo "Please open browser manually:"
    echo "http://localhost:$PORT"
fi

echo ""
echo "✅ aburOS started!"
echo "📁 Directory: $ABUROS_DIR"
echo "🌐 URL: http://localhost:$PORT"
echo "🆔 PID: $SERVER_PID"
echo ""
echo "To stop: kill $SERVER_PID"
echo "Or: pkill -f 'server.py'"
echo ""
echo "Press Enter to return to shell (server runs in background)"
read

wait $SERVER_PID
TERMUX_LAUNCHER

        chmod +x "$install_dir/start-termux.sh"
    fi

    # Desktop launcher for Linux
    if [ "$platform" != "termux" ]; then
        cat > "$install_dir/start-desktop.sh" << 'DESKTOP_LAUNCHER'
#!/usr/bin/env bash

ABUROS_DIR="$HOME/.aburos"
PORT=8080

# Create desktop entry if needed
if [ ! -f "$HOME/.local/share/applications/aburos.desktop" ]; then
    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/aburos.desktop" << EOF
[Desktop Entry]
Name=aburOS
Comment=Universal Web Desktop Environment
Exec=$ABUROS_DIR/start-desktop.sh
Icon=$ABUROS_DIR/system/icon.png
Terminal=false
Type=Application
Categories=System;
StartupNotify=true
EOF
    echo "Desktop entry created"
fi

echo "Starting aburOS Desktop..."
echo ""

cd "$ABUROS_DIR"
./start.sh "$PORT"
DESKTOP_LAUNCHER

        chmod +x "$install_dir/start-desktop.sh"
    fi

    chmod +x "$install_dir/start.sh"
}

# Create update manager
create_update_manager() {
    local install_dir=$1
    
    cat > "$install_dir/update-manager" << 'UPDATE_MANAGER'
#!/usr/bin/env bash

ABUROS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL="https://github.com/[your-username]/aburOS"
VERSION_FILE="$ABUROS_DIR/system/version.json"
BACKUP_DIR="$ABUROS_DIR/backups"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[UPDATE]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_update() {
    log "Checking for updates..."
    
    # Get current version
    if [ -f "$VERSION_FILE" ]; then
        CURRENT_VERSION=$(jq -r '.version' "$VERSION_FILE" 2>/dev/null || echo "1.0.0")
    else
        CURRENT_VERSION="1.0.0"
    fi
    
    # Try to get latest version from GitHub
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/[your-username]/aburOS/releases/latest" | 
                     grep '"tag_name"' | 
                     sed -E 's/.*"v([^"]+)".*/\1/' 2>/dev/null || echo "")
    
    if [ -z "$LATEST_VERSION" ]; then
        error "Could not fetch latest version"
        return 1
    fi
    
    log "Current version: $CURRENT_VERSION"
    log "Latest version: $LATEST_VERSION"
    
    if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
        success "aburOS is up to date!"
        return 0
    else
        warning "Update available: $CURRENT_VERSION → $LATEST_VERSION"
        return 2
    fi
}

create_backup() {
    log "Creating backup..."
    
    mkdir -p "$BACKUP_DIR"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/aburos_backup_$TIMESTAMP.tar.gz"
    
    # Backup user data and config
    tar -czf "$BACKUP_FILE" \
        -C "$ABUROS_DIR" \
        home/ \
        system/users.db \
        system/config.json \
        system/apps.db 2>/dev/null
    
    if [ $? -eq 0 ]; then
        success "Backup created: $(basename "$BACKUP_FILE")"
        echo "$BACKUP_FILE"
    else
        error "Backup failed"
        return 1
    fi
}

restore_backup() {
    local backup_file=$1
    
    if [ ! -f "$backup_file" ]; then
        error "Backup file not found: $backup_file"
        return 1
    fi
    
    log "Restoring from backup..."
    
    # Stop server if running
    pkill -f "server.py.*$ABUROS_DIR" 2>/dev/null && sleep 2
    
    # Extract backup
    tar -xzf "$backup_file" -C "$ABUROS_DIR"
    
    if [ $? -eq 0 ]; then
        success "Backup restored"
        return 0
    else
        error "Restore failed"
        return 1
    fi
}

perform_update() {
    log "Starting update process..."
    
    # Create backup
    BACKUP_FILE=$(create_backup)
    if [ $? -ne 0 ]; then
        error "Cannot proceed without backup"
        return 1
    fi
    
    # Stop server
    log "Stopping aburOS server..."
    pkill -f "server.py.*$ABUROS_DIR" 2>/dev/null
    sleep 2
    
    # Download update script
    log "Downloading update..."
    UPDATE_SCRIPT=$(mktemp)
    
    if curl -L "$REPO_URL/raw/main/update.sh" -o "$UPDATE_SCRIPT" 2>/dev/null; then
        chmod +x "$UPDATE_SCRIPT"
        
        # Run update script
        log "Running update..."
        if "$UPDATE_SCRIPT" "$ABUROS_DIR" "$BACKUP_FILE"; then
            success "Update completed successfully!"
            
            # Update version file
            cat > "$VERSION_FILE" << EOF
{
  "version": "$LATEST_VERSION",
  "update_date": "$(date -Iseconds)",
  "previous_version": "$CURRENT_VERSION",
  "backup_file": "$BACKUP_FILE"
}
EOF
            
            log "You can now start aburOS with: ./start.sh"
            return 0
        else
            error "Update script failed"
            # Restore from backup
            warning "Attempting to restore from backup..."
            restore_backup "$BACKUP_FILE"
            return 1
        fi
    else
        error "Failed to download update"
        return 1
    fi
}

list_backups() {
    if [ -d "$BACKUP_DIR" ] && [ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        log "Available backups:"
        ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null | awk '{print $6, $7, $8, $9}'
    else
        log "No backups found"
    fi
}

show_help() {
    echo "aburOS Update Manager"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  check      Check for updates"
    echo "  update     Perform update"
    echo "  backup     Create backup only"
    echo "  restore    Restore from backup"
    echo "  list       List available backups"
    echo "  help       Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 check"
    echo "  $0 update"
    echo "  $0 restore /path/to/backup.tar.gz"
}

main() {
    case "$1" in
        check)
            check_update
            ;;
        update)
            check_update
            if [ $? -eq 2 ]; then
                echo ""
                read -p "Do you want to update? (y/N): " -n 1 -r
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    perform_update
                else
                    log "Update cancelled"
                fi
            fi
            ;;
        backup)
            create_backup
            ;;
        restore)
            if [ -n "$2" ]; then
                restore_backup "$2"
            else
                error "Please specify backup file"
                echo "Usage: $0 restore /path/to/backup.tar.gz"
                exit 1
            fi
            ;;
        list)
            list_backups
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

main "$@"
UPDATE_MANAGER

    chmod +x "$install_dir/update-manager"
}

# Create uninstaller
create_uninstaller() {
    local install_dir=$1
    
    cat > "$install_dir/uninstall.sh" << 'UNINSTALLER'
#!/usr/bin/env bash

ABUROS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_OPTION=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}========================================${NC}"
echo -e "${RED}        aburOS Uninstaller              ${NC}"
echo -e "${RED}========================================${NC}"
echo ""
echo "This will completely remove aburOS from your system."
echo ""

# Check if running
if pgrep -f "server.py.*$ABUROS_DIR" > /dev/null; then
    echo -e "${YELLOW}⚠️  aburOS is currently running!${NC}"
    read -p "Stop it before uninstalling? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Stopping aburOS..."
        pkill -f "server.py.*$ABUROS_DIR"
        sleep 2
    else
        echo "Cannot uninstall while running."
        exit 1
    fi
fi

# Ask about backup
read -p "Create backup of user data before uninstalling? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    BACKUP_OPTION=true
fi

# Confirm
echo -e "${RED}WARNING: This action cannot be undone!${NC}"
read -p "Are you sure you want to uninstall aburOS? (type 'YES' to confirm): " -r
echo ""

if [ "$REPLY" != "YES" ]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Create backup if requested
if [ "$BACKUP_OPTION" = true ]; then
    echo "Creating backup..."
    BACKUP_FILE="$HOME/aburos_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    if tar -czf "$BACKUP_FILE" -C "$ABUROS_DIR" home/ system/users.db system/config.json 2>/dev/null; then
        echo -e "${GREEN}✓ Backup created: $BACKUP_FILE${NC}"
    else
        echo -e "${YELLOW}⚠️  Backup creation failed, continuing anyway...${NC}"
    fi
fi

# Remove desktop entry
if [ -f "$HOME/.local/share/applications/aburos.desktop" ]; then
    rm "$HOME/.local/share/applications/aburos.desktop"
    echo "Removed desktop entry"
fi

# Remove from PATH (if added)
if [ -f "$HOME/.bashrc" ]; then
    sed -i '/aburOS/d' "$HOME/.bashrc" 2>/dev/null
fi

if [ -f "$HOME/.zshrc" ]; then
    sed -i '/aburOS/d' "$HOME/.zshrc" 2>/dev/null
fi

# Remove installation directory
echo "Removing aburOS files..."
if rm -rf "$ABUROS_DIR"; then
    echo -e "${GREEN}✓ aburOS successfully uninstalled${NC}"
    echo ""
    echo "If you want to reinstall, run:"
    echo "  curl -L https://github.com/[your-username]/aburOS/raw/main/install.sh | bash"
else
    echo -e "${RED}✗ Failed to remove some files${NC}"
    echo "You may need to remove manually:"
    echo "  rm -rf $ABUROS_DIR"
fi
UNINSTALLER

    chmod +x "$install_dir/uninstall.sh"
}

# Main installation process
main() {
    print_info "Starting aburOS installation..."
    
    # Detect platform
    PLATFORM=$(detect_platform)
    print_info "Platform detected: $PLATFORM"
    
    # Check dependencies
    check_dependencies "$PLATFORM"
    
    # Install aburOS
    install_aburos "$PLATFORM"
    
    # Installation complete
    print_success "Installation complete!"
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "  🚀 aburOS v2.0.0 successfully installed!"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "📂 Installation directory: ~/.aburos"
    echo ""
    echo "🚀 To start aburOS:"
    echo "    cd ~/.aburos"
    
    if [ "$PLATFORM" = "termux" ]; then
        echo "    ./start-termux.sh"
    else
        echo "    ./start.sh"
        echo "    # or for desktop integration:"
        echo "    ./start-desktop.sh"
    fi
    
    echo ""
    echo "🌐 Access from browser:"
    echo "    http://localhost:8080"
    echo ""
    echo "🔧 Default login:"
    echo "    Username: admin"
    echo "    Password: admin123"
    echo ""
    echo "🔄 Update management:"
    echo "    cd ~/.aburos && ./update-manager check"
    echo ""
    echo "🗑️  To uninstall:"
    echo "    cd ~/.aburos && ./uninstall.sh"
    echo ""
    echo "📖 Documentation: https://github.com/[your-username]/aburOS"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    
    # Ask to start now
    read -p "Start aburOS now? (Y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        cd "$HOME/.aburos"
        if [ "$PLATFORM" = "termux" ]; then
            ./start-termux.sh
        else
            ./start.sh
        fi
    fi
}

# Run main function
main "$@"
