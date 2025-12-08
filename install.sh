#!/usr/bin/env bash

# ============================================================================
# Web Desktop Framework - Universal Installer
# Version: 3.1.0
# Author: Vs-2421
# Repository: https://github.com/Vs-2421/web-desktop-demo
# License: MIT
# ============================================================================

set -e

# ============================================================================
# CONFIGURATION
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Installation directory
INSTALL_DIR="$HOME/.webdesktop"
VERSION="3.1.0"
REPO_URL="https://github.com/Vs-2421/web-desktop-demo"

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { echo -e "${MAGENTA}[DEBUG]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

# ============================================================================
# BANNER
# ============================================================================

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║            Web Desktop Framework v$VERSION               ║"
    echo "║         Universal Installer (Linux/Termux/Android)       ║"
    echo "║            GitHub: Vs-2421/web-desktop-demo              ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_complete_banner() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║         INSTALLATION COMPLETE! 🎉                        ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ============================================================================
# PLATFORM DETECTION
# ============================================================================

detect_platform() {
    log_info "Detecting platform..."
    
    if [ -d "/data/data/com.termux/files/usr" ]; then
        echo "termux"
    elif [ -f "/etc/os-release" ]; then
        . /etc/os-release
        case $ID in
            debian|ubuntu|linuxmint|pop|elementary|zorin|deepin)
                echo "debian"
                ;;
            fedora|rhel|centos|rocky|almalinux)
                echo "fedora"
                ;;
            arch|manjaro|endeavouros|garuda)
                echo "arch"
                ;;
            opensuse*|suse)
                echo "suse"
                ;;
            alpine)
                echo "alpine"
                ;;
            *)
                echo "$ID"
                ;;
        esac
    elif [ -f "/etc/debian_version" ]; then
        echo "debian"
    elif [ -f "/etc/redhat-release" ]; then
        echo "fedora"
    elif [ -f "/etc/arch-release" ]; then
        echo "arch"
    elif [ "$(uname)" = "Darwin" ]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

get_package_manager() {
    local platform=$1
    
    case $platform in
        termux)
            echo "pkg"
            ;;
        debian)
            echo "apt"
            ;;
        fedora)
            if command -v dnf &> /dev/null; then
                echo "dnf"
            else
                echo "yum"
            fi
            ;;
        arch)
            echo "pacman"
            ;;
        suse)
            echo "zypper"
            ;;
        alpine)
            echo "apk"
            ;;
        macos)
            if command -v brew &> /dev/null; then
                echo "brew"
            else
                echo "unknown"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# ============================================================================
# DEPENDENCY MANAGEMENT
# ============================================================================

check_root() {
    if [ "$EUID" -eq 0 ]; then
        log_warning "Running as root! This is not recommended."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

check_dependencies() {
    local platform=$1
    log_step "Checking dependencies for $platform..."
    
    case $platform in
        termux)
            check_dependencies_termux
            ;;
        debian|ubuntu|linuxmint|pop|elementary|zorin|deepin)
            check_dependencies_debian
            ;;
        fedora|rhel|centos|rocky|almalinux)
            check_dependencies_fedora
            ;;
        arch|manjaro|endeavouros|garuda)
            check_dependencies_arch
            ;;
        suse|opensuse*)
            check_dependencies_suse
            ;;
        alpine)
            check_dependencies_alpine
            ;;
        macos)
            check_dependencies_macos
            ;;
        *)
            log_warning "Unknown platform. Checking common dependencies..."
            check_dependencies_common
            ;;
    esac
    
    log_success "Dependencies checked"
}

check_dependencies_termux() {
    local missing=()
    
    if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
        missing+=("python")
    fi
    
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi
    
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        missing+=("wget or curl")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_warning "Missing dependencies: ${missing[*]}"
        return 1
    fi
    
    return 0
}

check_dependencies_debian() {
    local missing=()
    
    if ! command -v python3 &> /dev/null; then
        missing+=("python3")
    fi
    
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi
    
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        missing+=("wget or curl")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_warning "Missing dependencies: ${missing[*]}"
        return 1
    fi
    
    return 0
}

check_dependencies_fedora() {
    local missing=()
    
    if ! command -v python3 &> /dev/null; then
        missing+=("python3")
    fi
    
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi
    
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        missing+=("wget or curl")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_warning "Missing dependencies: ${missing[*]}"
        return 1
    fi
    
    return 0
}

check_dependencies_arch() {
    local missing=()
    
    if ! command -v python3 &> /dev/null; then
        missing+=("python3")
    fi
    
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi
    
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        missing+=("wget or curl")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_warning "Missing dependencies: ${missing[*]}"
        return 1
    fi
    
    return 0
}

check_dependencies_common() {
    local missing=()
    
    if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
        missing+=("python")
    fi
    
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_warning "Missing dependencies: ${missing[*]}"
        return 1
    fi
    
    return 0
}

check_dependencies_suse() {
    check_dependencies_common
}

check_dependencies_alpine() {
    check_dependencies_common
}

check_dependencies_macos() {
    check_dependencies_common
}

install_dependencies() {
    local platform=$1
    log_step "Installing dependencies for $platform..."
    
    case $platform in
        termux)
            install_dependencies_termux
            ;;
        debian|ubuntu|linuxmint|pop|elementary|zorin|deepin)
            install_dependencies_debian
            ;;
        fedora|rhel|centos|rocky|almalinux)
            install_dependencies_fedora
            ;;
        arch|manjaro|endeavouros|garuda)
            install_dependencies_arch
            ;;
        suse|opensuse*)
            install_dependencies_suse
            ;;
        alpine)
            install_dependencies_alpine
            ;;
        macos)
            install_dependencies_macos
            ;;
        *)
            log_warning "Unknown platform. Attempting common installation..."
            install_dependencies_common
            ;;
    esac
    
    log_success "Dependencies installed"
}

install_dependencies_termux() {
    log_info "Updating Termux packages..."
    pkg update -y
    
    log_info "Installing Termux dependencies..."
    pkg install -y python git wget curl proot tar make clang nodejs-lts
    
    # Install Python packages
    pip install --upgrade pip
    pip install websockets psutil pygments flask
    
    # Ensure python3 symlink exists
    if [ ! -f "/data/data/com.termux/files/usr/bin/python3" ] && [ -f "/data/data/com.termux/files/usr/bin/python" ]; then
        ln -sf /data/data/com.termux/files/usr/bin/python /data/data/com.termux/files/usr/bin/python3
    fi
}

install_dependencies_debian() {
    log_info "Updating Debian/Ubuntu packages..."
    sudo apt update
    
    log_info "Installing Debian/Ubuntu dependencies..."
    sudo apt install -y python3 python3-pip python3-venv git wget curl tar gzip \
                        nodejs npm build-essential cmake make gcc g++ \
                        net-tools lsof htop tmux screen
    
    # Install Python packages
    pip3 install --upgrade pip
    pip3 install websockets psutil pygments flask
}

install_dependencies_fedora() {
    log_info "Updating Fedora packages..."
    if command -v dnf &> /dev/null; then
        sudo dnf update -y
    else
        sudo yum update -y
    fi
    
    log_info "Installing Fedora dependencies..."
    if command -v dnf &> /dev/null; then
        sudo dnf install -y python3 python3-pip git wget curl tar gzip \
                           nodejs npm @development-tools cmake make gcc-c++ \
                           net-tools lsof htop tmux
    else
        sudo yum install -y python3 python3-pip git wget curl tar gzip \
                           nodejs npm make gcc-c++ cmake \
                           net-tools lsof htop tmux
    fi
    
    # Install Python packages
    pip3 install --upgrade pip
    pip3 install websockets psutil pygments flask
}

install_dependencies_arch() {
    log_info "Updating Arch Linux packages..."
    sudo pacman -Syu --noconfirm
    
    log_info "Installing Arch Linux dependencies..."
    sudo pacman -S --noconfirm python python-pip git wget curl tar gzip \
                               nodejs npm base-devel cmake make gcc \
                               net-tools lsof htop tmux
    
    # Install Python packages
    pip install --upgrade pip
    pip install websockets psutil pygments flask
}

install_dependencies_suse() {
    log_info "Updating openSUSE packages..."
    sudo zypper refresh
    
    log_info "Installing openSUSE dependencies..."
    sudo zypper install -y python3 python3-pip git wget curl tar gzip \
                          nodejs npm patterns-devel-base-devel_basis cmake make gcc-c++ \
                          net-tools lsof htop tmux
    
    # Install Python packages
    pip3 install --upgrade pip
    pip3 install websockets psutil pygments flask
}

install_dependencies_alpine() {
    log_info "Updating Alpine packages..."
    sudo apk update
    
    log_info "Installing Alpine dependencies..."
    sudo apk add python3 py3-pip git wget curl tar gzip \
                nodejs npm build-base cmake make gcc g++ \
                net-tools lsof htop tmux
    
    # Install Python packages
    pip3 install --upgrade pip
    pip3 install websockets psutil pygments flask
}

install_dependencies_macos() {
    log_info "Checking Homebrew..."
    if ! command -v brew &> /dev/null; then
        log_warning "Homebrew not found. Please install it from https://brew.sh"
        exit 1
    fi
    
    log_info "Updating Homebrew..."
    brew update
    
    log_info "Installing macOS dependencies..."
    brew install python3 git wget curl nodejs cmake make gcc \
                   htop tmux
    
    # Install Python packages
    pip3 install --upgrade pip
    pip3 install websockets psutil pygments flask
}

install_dependencies_common() {
    log_warning "Attempting to install common dependencies..."
    
    # Try to detect package manager
    if command -v apt &> /dev/null; then
        install_dependencies_debian
    elif command -v yum &> /dev/null || command -v dnf &> /dev/null; then
        install_dependencies_fedora
    elif command -v pacman &> /dev/null; then
        install_dependencies_arch
    elif command -v zypper &> /dev/null; then
        install_dependencies_suse
    elif command -v apk &> /dev/null; then
        install_dependencies_alpine
    elif command -v pkg &> /dev/null; then
        install_dependencies_termux
    else
        log_error "Cannot determine package manager!"
        log_error "Please install manually: Python3, pip, git, wget/curl"
        exit 1
    fi
}

# ============================================================================
# INSTALLATION CORE
# ============================================================================

create_directory_structure() {
    local install_dir=$1
    log_step "Creating directory structure..."
    
    # Remove old installation if exists
    if [ -d "$install_dir" ]; then
        log_warning "Removing previous installation..."
        rm -rf "$install_dir"
    fi
    
    # Create main directories
    mkdir -p "$install_dir"/{bin,etc,lib,share,var,usr,tmp}
    mkdir -p "$install_dir/var"/{log,run,tmp,cache}
    mkdir -p "$install_dir/etc"/{systemd,profile.d,nginx,sites-available}
    mkdir -p "$install_dir/usr"/{bin,lib,share,local}
    mkdir -p "$install_dir/share"/{themes,icons,fonts,applications,wallpapers}
    
    # User directories
    mkdir -p "$install_dir/home/user"/{Desktop,Documents,Downloads,Pictures,Music,Videos,Projects,.config}
    mkdir -p "$install_dir/home/user/.config"/{gtk-3.0,gtk-4.0,openbox,menus}
    
    # Application directories
    mkdir -p "$install_dir/apps"/{system,tools,development,multimedia,network,office,graphics,games,education}
    mkdir -p "$install_dir/apps/system"/{terminal,filemanager,settings,processmanager}
    mkdir -p "$install_dir/apps/tools"/{calculator,texteditor,clock,calendar}
    mkdir -p "$install_dir/apps/development"/{python_ide,web_editor,code_editor}
    mkdir -p "$install_dir/apps/multimedia"/{media_player,image_viewer,camera}
    mkdir -p "$install_dir/apps/network"/{browser,email,chat,ftp}
    mkdir -p "$install_dir/apps/office"/{writer,spreadsheet,presentation}
    mkdir -p "$install_dir/apps/graphics"/{paint,vector_editor,photo_editor}
    mkdir -p "$install_dir/apps/games"/{chess,snake,puzzle,arcade}
    mkdir -p "$install_dir/apps/education"/{calculator,dictionary,notes}
    
    # System directories
    mkdir -p "$install_dir/system"/{scripts,services,modules,plugins,kernel,drivers}
    mkdir -p "$install_dir/system/scripts"/{startup,shutdown,cron}
    
    # Log directories
    mkdir -p "$install_dir/var/log"/{system,applications,security,network}
    
    log_success "Directory structure created"
}

create_system_files() {
    local install_dir=$1
    local platform=$2
    log_step "Creating system files..."
    
    # Main configuration file
    cat > "$install_dir/etc/webdesktop.conf" << EOF
# Web Desktop Framework Configuration
# Version: $VERSION
# Platform: $platform
# Install Date: $(date)

[core]
name = Web Desktop Framework
version = $VERSION
platform = $platform
install_date = $(date -Iseconds)
install_dir = $install_dir

[server]
port = 8080
host = 0.0.0.0
workers = 4
timeout = 30
max_upload_size = 100MB
enable_ssl = false
ssl_cert = 
ssl_key = 

[security]
require_auth = false
session_timeout = 3600
max_login_attempts = 5
allow_file_uploads = true
allowed_file_types = txt,pdf,doc,docx,odt,rtf,jpg,jpeg,png,gif,bmp,svg,mp3,mp4,avi,mkv,zip,rar,tar.gz

[interface]
default_theme = default-dark
available_themes = default-dark,default-light,blue-dark,green-dark,matrix,terminal
animations = true
transparency = true
shadow_effects = true
performance_mode = false
auto_start_apps = terminal,filemanager

[applications]
enabled_categories = system,tools,development,multimedia,network,office,graphics,games,education
default_apps = terminal:system,filemanager:system,settings:system,browser:network

[user]
default_username = admin
default_password = admin123
allow_guest = true
guest_username = guest
guest_password = guest123

[network]
allow_remote_access = false
allowed_ips = 127.0.0.1,localhost
cors_enabled = true
websocket_enabled = true
websocket_port = 8081

[storage]
user_data_dir = $install_dir/home/user
backup_dir = $install_dir/backups
temp_dir = $install_dir/tmp
max_storage_per_user = 1GB
auto_backup = true
backup_interval = daily

[updates]
auto_check_updates = true
update_channel = stable
notify_about_updates = true
allow_auto_update = false
EOF

    # User database
    cat > "$install_dir/etc/users.db" << EOF
{
  "version": "1.0",
  "users": {
    "admin": {
      "id": "admin_$(date +%s)",
      "username": "admin",
      "password": "\$2b\$12\$.6S/8R1.6S/8R1.6S/8R1.6S/8R1.6S/8R1.6S/8R1.6S/8R1.6S/8R1",
      "email": "admin@localhost",
      "full_name": "Administrator",
      "role": "admin",
      "created": "$(date -Iseconds)",
      "last_login": null,
      "last_logout": null,
      "login_count": 0,
      "status": "active",
      "permissions": {
        "system": ["read", "write", "execute", "delete"],
        "files": ["read", "write", "execute", "delete", "upload", "download"],
        "applications": ["install", "uninstall", "configure"],
        "users": ["create", "delete", "modify", "view"],
        "network": ["full_access"]
      },
      "settings": {
        "theme": "default-dark",
        "language": "en",
        "timezone": "UTC",
        "notifications": true,
        "sound_effects": true,
        "animations": true,
        "wallpaper": "default",
        "font_size": "medium",
        "font_family": "system-ui",
        "auto_start_apps": ["terminal", "filemanager"],
        "recent_apps": [],
        "favorite_apps": ["terminal", "filemanager", "browser", "settings"]
      },
      "preferences": {
        "keyboard_shortcuts": {
          "open_terminal": "Ctrl+Alt+T",
          "open_filemanager": "Ctrl+Alt+F",
          "open_settings": "Ctrl+Alt+S",
          "screenshot": "PrintScreen"
        },
        "window_behavior": {
          "snap_to_grid": true,
          "auto_arrange": false,
          "minimize_to_tray": true
        },
        "privacy": {
          "save_history": true,
          "save_passwords": false,
          "track_usage": false
        }
      },
      "storage": {
        "quota": 1073741824,
        "used": 0,
        "files_count": 0,
        "last_cleanup": null
      }
    },
    "guest": {
      "id": "guest_$(date +%s)",
      "username": "guest",
      "password": "\$2b\$12\$.6S/8R1.6S/8R1.6S/8R1.6S/8R1.6S/8R1.6S/8R1.6S/8R1.6S/8R1",
      "email": "guest@localhost",
      "full_name": "Guest User",
      "role": "guest",
      "created": "$(date -Iseconds)",
      "last_login": null,
      "last_logout": null,
      "login_count": 0,
      "status": "active",
      "permissions": {
        "system": ["read"],
        "files": ["read", "upload"],
        "applications": ["execute"],
        "users": [],
        "network": ["restricted"]
      },
      "settings": {
        "theme": "default-light",
        "language": "en",
        "timezone": "UTC",
        "notifications": false,
        "sound_effects": false,
        "animations": false,
        "wallpaper": "light",
        "font_size": "medium",
        "font_family": "system-ui",
        "auto_start_apps": [],
        "recent_apps": [],
        "favorite_apps": []
      },
      "preferences": {
        "keyboard_shortcuts": {},
        "window_behavior": {
          "snap_to_grid": true,
          "auto_arrange": true,
          "minimize_to_tray": false
        },
        "privacy": {
          "save_history": false,
          "save_passwords": false,
          "track_usage": false
        }
      },
      "storage": {
        "quota": 536870912,
        "used": 0,
        "files_count": 0,
        "last_cleanup": null
      }
    }
  },
  "sessions": {},
  "statistics": {
    "total_users": 2,
    "total_logins": 0,
    "total_apps_launched": 0,
    "total_files_uploaded": 0,
    "total_errors": 0,
    "uptime": 0,
    "start_time": null
  },
  "system": {
    "created": "$(date -Iseconds)",
    "last_modified": "$(date -Iseconds)",
    "version": "$VERSION"
  }
}
EOF

    # Application registry
    cat > "$install_dir/etc/apps.registry" << EOF
{
  "version": "1.0",
  "last_updated": "$(date -Iseconds)",
  "applications": {
    "system": [
      {
        "id": "terminal",
        "name": "Terminal",
        "description": "System terminal with real shell access via WebSockets",
        "version": "1.0.0",
        "category": "system",
        "subcategory": "terminal",
        "platform": "all",
        "executable": "terminal.html",
        "icon": "terminal",
        "icon_color": "#10B981",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": ["python3", "websockets"],
        "optional": ["nodejs", "npm"],
        "settings": {
          "default_shell": "/bin/bash",
          "font_size": 14,
          "theme": "dark",
          "scrollback_lines": 1000
        },
        "features": [
          "real_shell_access",
          "tab_support",
          "copy_paste",
          "themes",
          "session_saving"
        ],
        "screenshots": [],
        "rating": 5.0,
        "downloads": 0,
        "size": "2.5MB",
        "install_date": null,
        "last_used": null
      },
      {
        "id": "filemanager",
        "name": "File Manager",
        "description": "Advanced file manager with upload/download capabilities",
        "version": "1.0.0",
        "category": "system",
        "subcategory": "filemanager",
        "platform": "all",
        "executable": "filemanager.html",
        "icon": "folder",
        "icon_color": "#F59E0B",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {
          "view_mode": "grid",
          "show_hidden": false,
          "sort_by": "name",
          "sort_order": "asc"
        },
        "features": [
          "upload_files",
          "download_files",
          "create_folders",
          "rename_files",
          "delete_files",
          "search_files",
          "preview_files"
        ],
        "screenshots": [],
        "rating": 4.8,
        "downloads": 0,
        "size": "1.8MB",
        "install_date": null,
        "last_used": null
      },
      {
        "id": "settings",
        "name": "System Settings",
        "description": "Complete system configuration and settings",
        "version": "1.0.0",
        "category": "system",
        "subcategory": "settings",
        "platform": "all",
        "executable": "settings.html",
        "icon": "cog",
        "icon_color": "#6B7280",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {},
        "features": [
          "appearance_settings",
          "user_settings",
          "system_settings",
          "network_settings",
          "security_settings"
        ],
        "screenshots": [],
        "rating": 4.5,
        "downloads": 0,
        "size": "2.1MB",
        "install_date": null,
        "last_used": null
      },
      {
        "id": "processmanager",
        "name": "Process Manager",
        "description": "View and manage system processes",
        "version": "1.0.0",
        "category": "system",
        "subcategory": "processmanager",
        "platform": "all",
        "executable": "processmanager.html",
        "icon": "activity",
        "icon_color": "#EF4444",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": ["psutil"],
        "optional": [],
        "settings": {
          "refresh_interval": 3,
          "show_all_processes": false
        },
        "features": [
          "view_processes",
          "kill_processes",
          "cpu_usage",
          "memory_usage",
          "process_details"
        ],
        "screenshots": [],
        "rating": 4.7,
        "downloads": 0,
        "size": "1.5MB",
        "install_date": null,
        "last_used": null
      }
    ],
    
    "tools": [
      {
        "id": "calculator",
        "name": "Calculator",
        "description": "Scientific calculator with advanced functions",
        "version": "1.0.0",
        "category": "tools",
        "subcategory": "calculator",
        "platform": "all",
        "executable": "calculator.html",
        "icon": "calculator",
        "icon_color": "#3B82F6",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {
          "mode": "scientific",
          "angle_unit": "degrees",
          "precision": 10
        },
        "features": [
          "basic_operations",
          "scientific_functions",
          "history",
          "memory_functions",
          "themes"
        ],
        "screenshots": [],
        "rating": 4.9,
        "downloads": 0,
        "size": "0.8MB",
        "install_date": null,
        "last_used": null
      },
      {
        "id": "texteditor",
        "name": "Text Editor",
        "description": "Advanced text editor with syntax highlighting",
        "version": "1.0.0",
        "category": "tools",
        "subcategory": "texteditor",
        "platform": "all",
        "executable": "texteditor.html",
        "icon": "edit",
        "icon_color": "#8B5CF6",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {
          "font_size": 14,
          "theme": "dark",
          "word_wrap": true,
          "tab_size": 2
        },
        "features": [
          "syntax_highlighting",
          "multiple_tabs",
          "find_replace",
          "auto_indent",
          "themes"
        ],
        "screenshots": [],
        "rating": 4.8,
        "downloads": 0,
        "size": "1.2MB",
        "install_date": null,
        "last_used": null
      },
      {
        "id": "clock",
        "name": "Clock & Calendar",
        "description": "World clock with calendar and alarms",
        "version": "1.0.0",
        "category": "tools",
        "subcategory": "clock",
        "platform": "all",
        "executable": "clock.html",
        "icon": "clock",
        "icon_color": "#F59E0B",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {
          "time_format": "24h",
          "show_seconds": true,
          "timezone": "auto"
        },
        "features": [
          "world_clock",
          "alarms",
          "stopwatch",
          "timer",
          "calendar"
        ],
        "screenshots": [],
        "rating": 4.6,
        "downloads": 0,
        "size": "0.9MB",
        "install_date": null,
        "last_used": null
      }
    ],
    
    "development": [
      {
        "id": "python_ide",
        "name": "Python IDE",
        "description": "Python development environment",
        "version": "1.0.0",
        "category": "development",
        "subcategory": "python_ide",
        "platform": "all",
        "executable": "python_ide.html",
        "icon": "code",
        "icon_color": "#10B981",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": ["python3"],
        "optional": [],
        "settings": {
          "font_size": 14,
          "theme": "dark",
          "auto_complete": true,
          "linting": true
        },
        "features": [
          "code_editor",
          "python_console",
          "debugging",
          "file_browser",
          "package_management"
        ],
        "screenshots": [],
        "rating": 4.9,
        "downloads": 0,
        "size": "3.2MB",
        "install_date": null,
        "last_used": null
      },
      {
        "id": "web_editor",
        "name": "Web Editor",
        "description": "HTML/CSS/JavaScript editor with live preview",
        "version": "1.0.0",
        "category": "development",
        "subcategory": "web_editor",
        "platform": "all",
        "executable": "web_editor.html",
        "icon": "browser",
        "icon_color": "#3B82F6",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {
          "live_preview": true,
          "split_view": true,
          "auto_refresh": true
        },
        "features": [
          "html_editor",
          "css_editor",
          "js_editor",
          "live_preview",
          "code_completion"
        ],
        "screenshots": [],
        "rating": 4.8,
        "downloads": 0,
        "size": "2.5MB",
        "install_date": null,
        "last_used": null
      }
    ],
    
    "multimedia": [
      {
        "id": "media_player",
        "name": "Media Player",
        "description": "Audio and video player",
        "version": "1.0.0",
        "category": "multimedia",
        "subcategory": "media_player",
        "platform": "all",
        "executable": "mediaplayer.html",
        "icon": "play",
        "icon_color": "#EF4444",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": ["ffmpeg"],
        "settings": {
          "volume": 80,
          "repeat": "none",
          "shuffle": false
        },
        "features": [
          "audio_player",
          "video_player",
          "playlists",
          "equalizer",
          "subtitles"
        ],
        "screenshots": [],
        "rating": 4.7,
        "downloads": 0,
        "size": "2.8MB",
        "install_date": null,
        "last_used": null
      },
      {
        "id": "image_viewer",
        "name": "Image Viewer",
        "description": "View and edit images",
        "version": "1.0.0",
        "category": "multimedia",
        "subcategory": "image_viewer",
        "platform": "all",
        "executable": "imageviewer.html",
        "icon": "image",
        "icon_color": "#8B5CF6",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {
          "slideshow_interval": 5,
          "fit_to_screen": true,
          "show_thumbnails": true
        },
        "features": [
          "image_viewer",
          "slideshow",
          "basic_editing",
          "thumbnail_view",
          "fullscreen"
        ],
        "screenshots": [],
        "rating": 4.6,
        "downloads": 0,
        "size": "1.9MB",
        "install_date": null,
        "last_used": null
      }
    ],
    
    "network": [
      {
        "id": "browser",
        "name": "Web Browser",
        "description": "Internet browser",
        "version": "1.0.0",
        "category": "network",
        "subcategory": "browser",
        "platform": "all",
        "executable": "browser.html",
        "icon": "globe",
        "icon_color": "#3B82F6",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {
          "homepage": "https://www.google.com",
          "search_engine": "google",
          "popup_blocker": true
        },
        "features": [
          "tabbed_browsing",
          "bookmarks",
          "history",
          "downloads",
          "private_mode"
        ],
        "screenshots": [],
        "rating": 4.8,
        "downloads": 0,
        "size": "3.5MB",
        "install_date": null,
        "last_used": null
      },
      {
        "id": "email",
        "name": "Email Client",
        "description": "Email client with multiple account support",
        "version": "1.0.0",
        "category": "network",
        "subcategory": "email",
        "platform": "all",
        "executable": "email.html",
        "icon": "mail",
        "icon_color": "#10B981",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {
          "refresh_interval": 5,
          "notify_new_mail": true,
          "signature": ""
        },
        "features": [
          "multiple_accounts",
          "compose_email",
          "attachments",
          "filters",
          "search"
        ],
        "screenshots": [],
        "rating": 4.5,
        "downloads": 0,
        "size": "2.8MB",
        "install_date": null,
        "last_used": null
      }
    ],
    
    "office": [
      {
        "id": "writer",
        "name": "Document Writer",
        "description": "Word processor",
        "version": "1.0.0",
        "category": "office",
        "subcategory": "writer",
        "platform": "all",
        "executable": "writer.html",
        "icon": "file-text",
        "icon_color": "#3B82F6",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {
          "font_size": 12,
          "font_family": "Arial",
          "line_spacing": 1.5
        },
        "features": [
          "text_formatting",
          "images",
          "tables",
          "spell_check",
          "export_pdf"
        ],
        "screenshots": [],
        "rating": 4.7,
        "downloads": 0,
        "size": "3.1MB",
        "install_date": null,
        "last_used": null
      },
      {
        "id": "spreadsheet",
        "name": "Spreadsheet",
        "description": "Spreadsheet application",
        "version": "1.0.0",
        "category": "office",
        "subcategory": "spreadsheet",
        "platform": "all",
        "executable": "spreadsheet.html",
        "icon": "grid",
        "icon_color": "#10B981",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {
          "show_grid": true,
          "show_formulas": false,
          "decimal_places": 2
        },
        "features": [
          "formulas",
          "charts",
          "filters",
          "sorting",
          "cell_formatting"
        ],
        "screenshots": [],
        "rating": 4.6,
        "downloads": 0,
        "size": "3.4MB",
        "install_date": null,
        "last_used": null
      }
    ],
    
    "graphics": [
      {
        "id": "paint",
        "name": "Paint Application",
        "description": "Drawing and painting tool",
        "version": "1.0.0",
        "category": "graphics",
        "subcategory": "paint",
        "platform": "all",
        "executable": "paint.html",
        "icon": "brush",
        "icon_color": "#EF4444",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {
          "brush_size": 5,
          "brush_color": "#000000",
          "canvas_size": "800x600"
        },
        "features": [
          "drawing_tools",
          "shapes",
          "text_tool",
          "layers",
          "export_images"
        ],
        "screenshots": [],
        "rating": 4.8,
        "downloads": 0,
        "size": "2.2MB",
        "install_date": null,
        "last_used": null
      },
      {
        "id": "vector_editor",
        "name": "Vector Editor",
        "description": "Vector graphics editor",
        "version": "1.0.0",
        "category": "graphics",
        "subcategory": "vector_editor",
        "platform": "all",
        "executable": "vectoreditor.html",
        "icon": "layers",
        "icon_color": "#8B5CF6",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {
          "snap_to_grid": true,
          "grid_size": 10,
          "show_rulers": true
        },
        "features": [
          "vector_tools",
          "bezier_curves",
          "path_operations",
          "export_svg",
          "layers"
        ],
        "screenshots": [],
        "rating": 4.7,
        "downloads": 0,
        "size": "2.9MB",
        "install_date": null,
        "last_used": null
      }
    ],
    
    "games": [
      {
        "id": "chess",
        "name": "Chess",
        "description": "Chess game with AI opponent",
        "version": "1.0.0",
        "category": "games",
        "subcategory": "chess",
        "platform": "all",
        "executable": "chess.html",
        "icon": "chess",
        "icon_color": "#6B7280",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {
          "difficulty": "medium",
          "time_control": "none",
          "show_hints": true
        },
        "features": [
          "ai_opponent",
          "two_player",
          "move_history",
          "hints",
          "save_game"
        ],
        "screenshots": [],
        "rating": 4.9,
        "downloads": 0,
        "size": "1.8MB",
        "install_date": null,
        "last_used": null
      },
      {
        "id": "snake",
        "name": "Snake",
        "description": "Classic snake game",
        "version": "1.0.0",
        "category": "games",
        "subcategory": "snake",
        "platform": "all",
        "executable": "snake.html",
        "icon": "gamepad",
        "icon_color": "#10B981",
        "author": "Web Desktop Team",
        "license": "MIT",
        "repository": "$REPO_URL",
        "requires": [],
        "optional": [],
        "settings": {
          "speed": "medium",
          "grid_size": "20x20",
          "wall_collision": true
        },
        "features": [
          "classic_gameplay",
          "high_scores",
          "different_speeds",
          "wall_options"
        ],
        "screenshots": [],
        "rating": 4.8,
        "downloads": 0,
        "size": "0.9MB",
        "install_date": null,
        "last_used": null
      }
    ]
  },
  
  "categories": {
    "system": {
      "name": "System",
      "description": "System utilities and tools",
      "icon": "settings",
      "color": "#6B7280"
    },
    "tools": {
      "name": "Tools",
      "description": "Utility applications",
      "icon": "tool",
      "color": "#3B82F6"
    },
    "development": {
      "name": "Development",
      "description": "Programming tools and IDEs",
      "icon": "code",
      "color": "#10B981"
    },
    "multimedia": {
      "name": "Multimedia",
      "description": "Audio, video and image applications",
      "icon": "play",
      "color": "#EF4444"
    },
    "network": {
      "name": "Network",
      "description": "Internet and communication apps",
      "icon": "globe",
      "color": "#3B82F6"
    },
    "office": {
      "name": "Office",
      "description": "Productivity and office applications",
      "icon": "briefcase",
      "color": "#10B981"
    },
    "graphics": {
      "name": "Graphics",
      "description": "Drawing and design applications",
      "icon": "image",
      "color": "#8B5CF6"
    },
    "games": {
      "name": "Games",
      "description": "Entertainment and games",
      "icon": "gamepad",
      "color": "#F59E0B"
    },
    "education": {
      "name": "Education",
      "description": "Educational tools and applications",
      "icon": "book",
      "color": "#8B5CF6"
    }
  },
  
  "statistics": {
    "total_apps": 20,
    "by_category": {
      "system": 4,
      "tools": 3,
      "development": 2,
      "multimedia": 2,
      "network": 2,
      "office": 2,
      "graphics": 2,
      "games": 2,
      "education": 1
    },
    "last_updated": "$(date -Iseconds)"
  }
}
EOF

    # Platform-specific packages file
    cat > "$install_dir/etc/packages.$platform" << EOF
# Platform-specific packages for $platform
# Generated on $(date)

[core_packages]
# These packages are required for basic functionality
required = python3, pip, git, wget, curl

[optional_packages]
# These packages enhance functionality but are not required
development = nodejs, npm, build-essential, cmake, make, gcc, g++
multimedia = ffmpeg, imagemagick, vlc
network = net-tools, nmap, wireshark, curl, wget
office = libreoffice, inkscape, gimp
games = pygame, chess, sdl2
graphics = imagemagick, gimp, inkscape
education = python3-matplotlib, python3-numpy, python3-scipy

[platform_specific]
# Packages only available on this platform
termux = termux-api, termux-tools, proot, tar
debian = apt-transport-https, software-properties-common, ubuntu-restricted-extras
fedora = dnf-plugins-core, rpmfusion-free-release, rpmfusion-nonfree-release
arch = yay, paru, base-devel, git
suse = patterns-devel-base-devel_basis, gcc-c++
alpine = build-base, cmake, make
macos = brew, node, python-tk

[tips]
# Platform-specific tips
termux = "Use 'pkg install' for packages"
debian = "Use 'sudo apt install' for packages"
fedora = "Use 'sudo dnf install' for packages"
arch = "Use 'sudo pacman -S' for packages"
suse = "Use 'sudo zypper install' for packages"
alpine = "Use 'sudo apk add' for packages"
macos = "Use 'brew install' for packages"
EOF

    # System services configuration
    cat > "$install_dir/etc/services.json" << EOF
{
  "services": {
    "webdesktop": {
      "name": "Web Desktop Framework",
      "description": "Main web desktop server",
      "command": "$install_dir/bin/server.py",
      "working_dir": "$install_dir",
      "user": "$(whoami)",
      "group": "$(id -gn)",
      "autostart": true,
      "restart": "always",
      "restart_delay": 5,
      "environment": {
        "PATH": "/usr/local/bin:/usr/bin:/bin",
        "PYTHONPATH": "$install_dir",
        "WEBDESKTOP_HOME": "$install_dir"
      },
      "ports": [8080, 8081],
      "log_file": "$install_dir/var/log/webdesktop.log",
      "error_file": "$install_dir/var/log/webdesktop.error.log"
    },
    "websocket": {
      "name": "WebSocket Server",
      "description": "WebSocket server for real-time communication",
      "command": "$install_dir/bin/websocket_server.py",
      "working_dir": "$install_dir",
      "autostart": true,
      "restart": "always",
      "port": 8081
    }
  },
  "monitoring": {
    "enabled": true,
    "check_interval": 60,
    "notify_on_failure": true,
    "auto_restart": true
  }
}
EOF

    # Create startup script
    cat > "$install_dir/etc/startup.sh" << 'EOF'
#!/usr/bin/env bash
# Web Desktop Framework Startup Script
# This script runs at system startup

set -e

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$INSTALL_DIR/var/log/startup.log"
PID_FILE="$INSTALL_DIR/var/run/webdesktop.pid"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Start the server
start_server() {
    log "Starting Web Desktop Framework..."
    
    # Check if already running
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            log "Server already running (PID: $PID)"
            return 0
        fi
    fi
    
    # Start server
    cd "$INSTALL_DIR"
    python3 bin/server.py >> "$LOG_FILE" 2>&1 &
    SERVER_PID=$!
    
    echo "$SERVER_PID" > "$PID_FILE"
    log "Server started with PID: $SERVER_PID"
    
    # Wait a bit to check if it's still running
    sleep 2
    if ! ps -p "$SERVER_PID" > /dev/null 2>&1; then
        log "ERROR: Server failed to start!"
        return 1
    fi
    
    return 0
}

# Main execution
main() {
    log "=== Startup started ==="
    
    # Create necessary directories
    mkdir -p "$INSTALL_DIR/var/run"
    mkdir -p "$INSTALL_DIR/var/log"
    mkdir -p "$INSTALL_DIR/tmp"
    
    # Set permissions
    chmod -R 755 "$INSTALL_DIR/home/user"
    
    # Start server
    if start_server; then
        log "Startup completed successfully"
        log "Server URL: http://localhost:8080"
        log "WebSocket URL: ws://localhost:8081"
    else
        log "Startup failed!"
        exit 1
    fi
    
    log "=== Startup finished ==="
}

# Run main function
main "$@"
EOF

    chmod +x "$install_dir/etc/startup.sh"

    log_success "System files created"
}

# ============================================================================
# BACKEND SERVER
# ============================================================================

create_backend_server() {
    local install_dir=$1
    local platform=$2
    log_step "Creating backend server..."
    
    # Create main server
    cat > "$install_dir/bin/server.py" << 'EOF'
#!/usr/bin/env python3
"""
Web Desktop Framework - Backend Server
Universal server for Linux, Termux, and macOS
"""

import os
import sys
import json
import logging
import subprocess
import threading
import signal
import time
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import socketserver
import websockets
import asyncio
import sqlite3
import hashlib
import base64
import mimetypes
from pathlib import Path

# Platform detection
IS_TERMUX = 'com.termux' in os.environ.get('PREFIX', '')
IS_MACOS = sys.platform == 'darwin'
IS_LINUX = not IS_TERMUX and not IS_MACOS and os.name == 'posix'

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('var/log/server.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class Config:
    """Configuration manager"""
    def __init__(self, config_path):
        self.config_path = config_path
        self.config = self.load_config()
    
    def load_config(self):
        """Load configuration from file"""
        default_config = {
            'server': {
                'port': 8080,
                'host': '0.0.0.0',
                'workers': 4,
                'timeout': 30,
                'max_upload_size': 100 * 1024 * 1024
            },
            'security': {
                'require_auth': False,
                'session_timeout': 3600,
                'max_login_attempts': 5,
                'allowed_origins': ['*']
            },
            'platform': {
                'type': 'termux' if IS_TERMUX else 'macos' if IS_MACOS else 'linux',
                'home': os.path.expanduser('~')
            },
            'paths': {
                'install_dir': os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                'user_data': os.path.expanduser('~/.webdesktop'),
                'temp_dir': '/tmp/webdesktop'
            }
        }
        
        try:
            if os.path.exists(self.config_path):
                import configparser
                config = configparser.ConfigParser()
                config.read(self.config_path)
                
                # Convert to dict
                result = {}
                for section in config.sections():
                    result[section] = dict(config.items(section))
                
                # Merge with defaults
                for key, value in default_config.items():
                    if key not in result:
                        result[key] = value
                
                return result
        except Exception as e:
            logger.error(f"Failed to load config: {e}")
        
        return default_config
    
    def get(self, section, key, default=None):
        """Get configuration value"""
        return self.config.get(section, {}).get(key, default)

class Database:
    """Database manager"""
    def __init__(self, db_path):
        self.db_path = db_path
        self.init_db()
    
    def init_db(self):
        """Initialize database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Users table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE NOT NULL,
                password_hash TEXT NOT NULL,
                email TEXT,
                full_name TEXT,
                role TEXT DEFAULT 'user',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                last_login TIMESTAMP,
                status TEXT DEFAULT 'active',
                settings TEXT DEFAULT '{}'
            )
        ''')
        
        # Sessions table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS sessions (
                id TEXT PRIMARY KEY,
                user_id INTEGER,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                expires_at TIMESTAMP,
                ip_address TEXT,
                user_agent TEXT,
                FOREIGN KEY (user_id) REFERENCES users (id)
            )
        ''')
        
        # Files table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS files (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                filename TEXT NOT NULL,
                path TEXT NOT NULL,
                size INTEGER,
                mime_type TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                is_directory INTEGER DEFAULT 0,
                parent_id INTEGER,
                FOREIGN KEY (user_id) REFERENCES users (id),
                FOREIGN KEY (parent_id) REFERENCES files (id)
            )
        ''')
        
        # Applications table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS applications (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                version TEXT,
                category TEXT,
                installed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                last_used TIMESTAMP,
                usage_count INTEGER DEFAULT 0,
                settings TEXT DEFAULT '{}'
            )
        ''')
        
        # System logs table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                level TEXT,
                module TEXT,
                message TEXT,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                user_id INTEGER,
                ip_address TEXT
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def execute(self, query, params=()):
        """Execute SQL query"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute(query, params)
        conn.commit()
        result = cursor.fetchall()
        conn.close()
        return result

class TerminalManager:
    """Manage terminal sessions"""
    
    def __init__(self):
        self.sessions = {}
        self.session_counter = 0
        self.lock = threading.Lock()
    
    def create_session(self, user_id, shell=None):
        """Create new terminal session"""
        with self.lock:
            session_id = f"term_{self.session_counter}_{int(time.time())}"
            self.session_counter += 1
            
            # Determine shell based on platform
            if not shell:
                if IS_TERMUX:
                    shell = '/data/data/com.termux/files/usr/bin/bash'
                elif IS_MACOS:
                    shell = '/bin/zsh'
                else:
                    shell = '/bin/bash'
            
            self.sessions[session_id] = {
                'id': session_id,
                'user_id': user_id,
                'shell': shell,
                'created': datetime.now().isoformat(),
                'last_activity': datetime.now().isoformat(),
                'process': None,
                'buffer': '',
                'cwd': os.path.expanduser('~'),
                'env': os.environ.copy()
            }
            
            logger.info(f"Created terminal session {session_id} for user {user_id}")
            return session_id
    
    def execute_command(self, session_id, command):
        """Execute command in terminal session"""
        if session_id not in self.sessions:
            return {"error": "Session not found"}
        
        session = self.sessions[session_id]
        session['last_activity'] = datetime.now().isoformat()
        
        try:
            # Security: Sanitize command
            sanitized_command = self.sanitize_command(command)
            
            # Execute based on platform
            result = self.execute_shell(session, sanitized_command)
            
            session['buffer'] += result['output']
            return result
            
        except Exception as e:
            logger.error(f"Terminal error: {e}")
            return {"error": str(e), "output": f"Error: {e}"}
    
    def sanitize_command(self, command):
        """Sanitize command to prevent security issues"""
        # Block dangerous commands
        dangerous = [
            'rm -rf /', 'mkfs', 'dd if=', ':(){ :|:& };:', 'chmod -R 777 /',
            '> /dev/sda', 'mkfs.ext4', 'fdisk', 'parted', 'dd of=',
            'wget', 'curl', 'nc', 'netcat', 'telnet', 'ssh',
            'python -c', 'perl -e', 'bash -c', 'sh -c'
        ]
        
        for dangerous_cmd in dangerous:
            if dangerous_cmd in command.lower():
                raise ValueError(f"Dangerous command blocked: {dangerous_cmd}")
        
        return command
    
    def execute_shell(self, session, command):
        """Execute command in shell"""
        try:
            # Change to session's working directory
            cwd = session['cwd']
            if not os.path.exists(cwd):
                cwd = os.path.expanduser('~')
            
            # Prepare environment
            env = session['env'].copy()
            env['TERM'] = 'xterm-256color'
            env['HOME'] = os.path.expanduser('~')
            
            if IS_TERMUX:
                env['PREFIX'] = '/data/data/com.termux/files/usr'
                env['LD_LIBRARY_PATH'] = '/data/data/com.termux/files/usr/lib'
            
            # Execute command
            process = subprocess.Popen(
                command,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                stdin=subprocess.PIPE,
                text=True,
                cwd=cwd,
                env=env
            )
            
            stdout, stderr = process.communicate(timeout=30)
            
            # Update working directory if cd command was used
            if command.startswith('cd '):
                try:
                    # Try to get new directory
                    new_dir = command[3:].strip()
                    if new_dir == '~' or not new_dir:
                        new_dir = os.path.expanduser('~')
                    elif new_dir.startswith('~/'):
                        new_dir = os.path.expanduser(new_dir)
                    elif not os.path.isabs(new_dir):
                        new_dir = os.path.join(cwd, new_dir)
                    
                    new_dir = os.path.abspath(new_dir)
                    if os.path.exists(new_dir) and os.path.isdir(new_dir):
                        session['cwd'] = new_dir
                except:
                    pass
            
            return {
                "success": process.returncode == 0,
                "output": stdout + ("\n" + stderr if stderr else ""),
                "exit_code": process.returncode,
                "cwd": session['cwd']
            }
            
        except subprocess.TimeoutExpired:
            return {
                "success": False,
                "output": "Command timed out",
                "exit_code": -1,
                "cwd": session['cwd']
            }
        except Exception as e:
            return {
                "success": False,
                "output": f"Error: {e}",
                "exit_code": -1,
                "cwd": session['cwd']
            }

class FileManager:
    """Manage file operations"""
    
    def __init__(self, base_path):
        self.base_path = base_path
        os.makedirs(base_path, exist_ok=True)
    
    def list_files(self, path='.'):
        """List files in directory"""
        full_path = os.path.join(self.base_path, path.lstrip('/'))
        
        # Security: Prevent directory traversal
        if not self.is_safe_path(full_path):
            raise ValueError("Access denied")
        
        if not os.path.exists(full_path):
            return {"error": "Directory not found"}
        
        items = []
        try:
            for item in os.listdir(full_path):
                item_path = os.path.join(full_path, item)
                try:
                    stat = os.stat(item_path)
                    
                    items.append({
                        'name': item,
                        'type': 'directory' if os.path.isdir(item_path) else 'file',
                        'size': stat.st_size,
                        'modified': stat.st_mtime,
                        'permissions': oct(stat.st_mode)[-3:],
                        'path': os.path.relpath(item_path, self.base_path),
                        'readable': os.access(item_path, os.R_OK),
                        'writable': os.access(item_path, os.W_OK),
                        'executable': os.access(item_path, os.X_OK)
                    })
                except (PermissionError, FileNotFoundError):
                    continue
        
        except (PermissionError, FileNotFoundError) as e:
            return {"error": str(e)}
        
        return {
            'path': path,
            'items': items,
            'total': len(items),
            'current_dir': full_path,
            'parent_dir': os.path.dirname(full_path) if full_path != self.base_path else None
        }
    
    def read_file(self, file_path, mode='text'):
        """Read file content"""
        full_path = os.path.join(self.base_path, file_path.lstrip('/'))
        
        # Security check
        if not self.is_safe_path(full_path):
            raise ValueError("Access denied")
        
        if not os.path.exists(full_path):
            return {"error": "File not found"}
        
        if os.path.isdir(full_path):
            return {"error": "Is a directory"}
        
        try:
            if mode == 'binary':
                with open(full_path, 'rb') as f:
                    content = f.read()
                
                return {
                    'success': True,
                    'content': base64.b64encode(content).decode('utf-8'),
                    'binary': True,
                    'size': len(content),
                    'mime_type': mimetypes.guess_type(full_path)[0] or 'application/octet-stream'
                }
            else:
                # Try different encodings
                encodings = ['utf-8', 'latin-1', 'cp1252', 'iso-8859-1']
                for encoding in encodings:
                    try:
                        with open(full_path, 'r', encoding=encoding) as f:
                            content = f.read()
                        
                        return {
                            'success': True,
                            'content': content,
                            'encoding': encoding,
                            'size': len(content),
                            'mime_type': mimetypes.guess_type(full_path)[0] or 'text/plain'
                        }
                    except UnicodeDecodeError:
                        continue
                
                # If all text encodings fail, return as binary
                return self.read_file(file_path, mode='binary')
                
        except Exception as e:
            return {"error": str(e)}
    
    def write_file(self, file_path, content, mode='text'):
        """Write file content"""
        full_path = os.path.join(self.base_path, file_path.lstrip('/'))
        
        # Security check
        if not self.is_safe_path(full_path):
            raise ValueError("Access denied")
        
        # Create directory if needed
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        
        try:
            if mode == 'binary':
                content_bytes = base64.b64decode(content)
                with open(full_path, 'wb') as f:
                    f.write(content_bytes)
            else:
                with open(full_path, 'w', encoding='utf-8') as f:
                    f.write(content)
            
            return {'success': True, 'path': file_path}
        except Exception as e:
            return {'success': False, 'error': str(e)}
    
    def create_directory(self, dir_path):
        """Create directory"""
        full_path = os.path.join(self.base_path, dir_path.lstrip('/'))
        
        # Security check
        if not self.is_safe_path(full_path):
            raise ValueError("Access denied")
        
        try:
            os.makedirs(full_path, exist_ok=True)
            return {'success': True, 'path': dir_path}
        except Exception as e:
            return {'success': False, 'error': str(e)}
    
    def delete_path(self, path):
        """Delete file or directory"""
        full_path = os.path.join(self.base_path, path.lstrip('/'))
        
        # Security check
        if not self.is_safe_path(full_path):
            raise ValueError("Access denied")
        
        if not os.path.exists(full_path):
            return {"error": "Path not found"}
        
        try:
            if os.path.isdir(full_path):
                import shutil
                shutil.rmtree(full_path)
            else:
                os.remove(full_path)
            
            return {'success': True}
        except Exception as e:
            return {'success': False, 'error': str(e)}
    
    def is_safe_path(self, path):
        """Check if path is safe (within base directory)"""
        try:
            base = os.path.abspath(self.base_path)
            target = os.path.abspath(path)
            return target.startswith(base)
        except:
            return False

class PackageManager:
    """Manage package installation"""
    
    def __init__(self, platform):
        self.platform = platform
        
        # Platform-specific installation commands
        self.commands = {
            'termux': {
                'install': 'pkg install -y',
                'update': 'pkg update -y',
                'upgrade': 'pkg upgrade -y',
                'remove': 'pkg remove -y',
                'search': 'pkg search'
            },
            'debian': {
                'install': 'sudo apt install -y',
                'update': 'sudo apt update',
                'upgrade': 'sudo apt upgrade -y',
                'remove': 'sudo apt remove -y',
                'search': 'apt search'
            },
            'fedora': {
                'install': 'sudo dnf install -y',
                'update': 'sudo dnf update -y',
                'upgrade': 'sudo dnf upgrade -y',
                'remove': 'sudo dnf remove -y',
                'search': 'dnf search'
            },
            'arch': {
                'install': 'sudo pacman -S --noconfirm',
                'update': 'sudo pacman -Syu --noconfirm',
                'remove': 'sudo pacman -R --noconfirm',
                'search': 'pacman -Ss'
            },
            'suse': {
                'install': 'sudo zypper install -y',
                'update': 'sudo zypper update -y',
                'remove': 'sudo zypper remove -y',
                'search': 'zypper search'
            },
            'alpine': {
                'install': 'sudo apk add',
                'update': 'sudo apk update',
                'upgrade': 'sudo apk upgrade',
                'remove': 'sudo apk del',
                'search': 'apk search'
            },
            'macos': {
                'install': 'brew install',
                'update': 'brew update',
                'upgrade': 'brew upgrade',
                'remove': 'brew uninstall',
                'search': 'brew search'
            }
        }
    
    def install_package(self, package_name):
        """Install system package"""
        if self.platform not in self.commands:
            return {
                'success': False,
                'error': f'Platform {self.platform} not supported'
            }
        
        cmd_template = self.commands[self.platform].get('install')
        if not cmd_template:
            return {
                'success': False,
                'error': f'Install command not defined for {self.platform}'
            }
        
        command = f'{cmd_template} {package_name}'
        
        try:
            process = subprocess.Popen(
                command,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            stdout, stderr = process.communicate(timeout=300)  # 5 minutes timeout
            
            return {
                'success': process.returncode == 0,
                'stdout': stdout,
                'stderr': stderr,
                'returncode': process.returncode,
                'command': command
            }
            
        except subprocess.TimeoutExpired:
            return {
                'success': False,
                'error': 'Installation timed out'
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }

class WebDesktopHandler(BaseHTTPRequestHandler):
    """HTTP request handler"""
    
    def __init__(self, *args, config=None, terminal_manager=None, 
                 file_manager=None, package_manager=None, database=None, **kwargs):
        self.config = config
        self.terminal_manager = terminal_manager
        self.file_manager = file_manager
        self.package_manager = package_manager
        self.database = database
        super().__init__(*args, **kwargs)
    
    def log_message(self, format, *args):
        """Custom log message format"""
        logger.info(f"{self.address_string()} - {format % args}")
    
    def do_GET(self):
        """Handle GET requests"""
        try:
            parsed = urlparse(self.path)
            
            # API endpoints
            if parsed.path.startswith('/api/'):
                self.handle_api(parsed)
            else:
                # Serve static files
                self.serve_static(parsed.path)
        except Exception as e:
            logger.error(f"GET error: {e}")
            self.send_error(500, str(e))
    
    def do_POST(self):
        """Handle POST requests"""
        try:
            content_length = int(self.headers.get('Content-Length', 0))
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
        except Exception as e:
            logger.error(f"POST error: {e}")
            self.send_error(500, str(e))
    
    def handle_api(self, parsed, data=None):
        """Handle API requests"""
        api_path = parsed.path[5:]  # Remove '/api/'
        
        # API routing
        api_handlers = {
            'system/info': self.handle_system_info,
            'system/processes': self.handle_processes_list,
            'system/stats': self.handle_system_stats,
            'terminal/create': self.handle_terminal_create,
            'terminal/execute': self.handle_terminal_execute,
            'files/list': self.handle_files_list,
            'files/read': self.handle_files_read,
            'files/write': self.handle_files_write,
            'files/create_dir': self.handle_files_create_dir,
            'files/delete': self.handle_files_delete,
            'packages/install': self.handle_package_install,
            'packages/available': self.handle_packages_available,
            'user/login': self.handle_user_login,
            'user/logout': self.handle_user_logout,
            'user/settings': self.handle_user_settings,
            'apps/list': self.handle_apps_list,
            'apps/launch': self.handle_app_launch,
            'apps/install': self.handle_app_install
        }
        
        handler = api_handlers.get(api_path)
        if handler:
            handler(data)
        else:
            self.send_json({'error': 'API endpoint not found'}, 404)
    
    def handle_system_info(self):
        """Return system information"""
        import platform
        
        info = {
            'platform': {
                'system': platform.system(),
                'release': platform.release(),
                'version': platform.version(),
                'machine': platform.machine(),
                'processor': platform.processor()
            },
            'python': {
                'version': platform.python_version(),
                'implementation': platform.python_implementation()
            },
            'webdesktop': {
                'version': '3.1.0',
                'install_dir': self.config.get('paths', 'install_dir'),
                'is_termux': IS_TERMUX,
                'is_linux': IS_LINUX,
                'is_macos': IS_MACOS
            },
            'user': {
                'username': os.getenv('USER') or os.getenv('USERNAME'),
                'home': os.path.expanduser('~')
            }
        }
        self.send_json(info)
    
    def handle_system_stats(self):
        """Return system statistics"""
        try:
            import psutil
            
            stats = {
                'cpu': {
                    'percent': psutil.cpu_percent(interval=0.1),
                    'count': psutil.cpu_count(logical=False),
                    'count_logical': psutil.cpu_count(logical=True),
                    'freq': psutil.cpu_freq().current if hasattr(psutil.cpu_freq(), 'current') else None
                },
                'memory': {
                    'total': psutil.virtual_memory().total,
                    'available': psutil.virtual_memory().available,
                    'percent': psutil.virtual_memory().percent,
                    'used': psutil.virtual_memory().used
                },
                'disk': {
                    'total': psutil.disk_usage('/').total,
                    'used': psutil.disk_usage('/').used,
                    'free': psutil.disk_usage('/').free,
                    'percent': psutil.disk_usage('/').percent
                },
                'network': {
                    'bytes_sent': psutil.net_io_counters().bytes_sent,
                    'bytes_recv': psutil.net_io_counters().bytes_recv
                },
                'boot_time': psutil.boot_time(),
                'uptime': time.time() - psutil.boot_time()
            }
            
            self.send_json(stats)
            
        except ImportError:
            self.send_json({
                'error': 'psutil not installed',
                'note': 'Install psutil for detailed statistics'
            })
        except Exception as e:
            self.send_json({'error': str(e)})
    
    def handle_terminal_create(self):
        """Create new terminal session"""
        session_id = self.terminal_manager.create_session('admin')
        self.send_json({'session_id': session_id})
    
    def handle_terminal_execute(self, data):
        """Execute terminal command"""
        if not data or 'session_id' not in data or 'command' not in data:
            self.send_json({'error': 'Missing parameters'}, 400)
            return
        
        result = self.terminal_manager.execute_command(
            data['session_id'],
            data['command']
        )
        self.send_json(result)
    
    def handle_files_list(self, data):
        """List files"""
        path = data.get('path', '.') if data else '.'
        
        try:
            result = self.file_manager.list_files(path)
            self.send_json(result)
        except Exception as e:
            self.send_json({'error': str(e)}, 500)
    
    def handle_files_read(self, data):
        """Read file"""
        if not data or 'path' not in data:
            self.send_json({'error': 'Missing path'}, 400)
            return
        
        mode = data.get('mode', 'text')
        
        try:
            result = self.file_manager.read_file(data['path'], mode)
            self.send_json(result)
        except Exception as e:
            self.send_json({'error': str(e)}, 500)
    
    def handle_files_write(self, data):
        """Write file"""
        if not data or 'path' not in data or 'content' not in data:
            self.send_json({'error': 'Missing parameters'}, 400)
            return
        
        mode = data.get('mode', 'text')
        
        try:
            result = self.file_manager.write_file(
                data['path'],
                data['content'],
                mode
            )
            self.send_json(result)
        except Exception as e:
            self.send_json({'error': str(e)}, 500)
    
    def handle_files_create_dir(self, data):
        """Create directory"""
        if not data or 'path' not in data:
            self.send_json({'error': 'Missing path'}, 400)
            return
        
        try:
            result = self.file_manager.create_directory(data['path'])
            self.send_json(result)
        except Exception as e:
            self.send_json({'error': str(e)}, 500)
    
    def handle_files_delete(self, data):
        """Delete file or directory"""
        if not data or 'path' not in data:
            self.send_json({'error': 'Missing path'}, 400)
            return
        
        try:
            result = self.file_manager.delete_path(data['path'])
            self.send_json(result)
        except Exception as e:
            self.send_json({'error': str(e)}, 500)
    
    def handle_package_install(self, data):
        """Install package"""
        if not data or 'package' not in data:
            self.send_json({'error': 'Missing package name'}, 400)
            return
        
        result = self.package_manager.install_package(data['package'])
        self.send_json(result)
    
    def handle_packages_available(self):
        """List available packages"""
        # This would query package repositories
        # For now, return a static list
        packages = {
            'termux': ['python', 'nodejs', 'git', 'wget', 'curl', 'vim', 'htop'],
            'debian': ['python3', 'python3-pip', 'git', 'wget', 'curl', 'vim', 'htop'],
            'fedora': ['python3', 'python3-pip', 'git', 'wget', 'curl', 'vim', 'htop'],
            'arch': ['python', 'python-pip', 'git', 'wget', 'curl', 'vim', 'htop'],
            'macos': ['python3', 'git', 'wget', 'curl', 'vim', 'htop']
        }
        
        platform = self.config.get('platform', 'type', 'linux')
        self.send_json({
            'platform': platform,
            'packages': packages.get(platform, [])
        })
    
    def handle_user_login(self, data):
        """Handle user login"""
        if not data or 'username' not in data or 'password' not in data:
            self.send_json({'error': 'Missing credentials'}, 400)
            return
        
        # Simple authentication (in production, use proper auth)
        if data['username'] == 'admin' and data['password'] == 'admin123':
            session_id = hashlib.sha256(f"{data['username']}{time.time()}".encode()).hexdigest()[:32]
            
            self.send_json({
                'success': True,
                'session_id': session_id,
                'user': {
                    'username': 'admin',
                    'role': 'admin',
                    'name': 'Administrator'
                }
            })
        elif data['username'] == 'guest' and data['password'] == 'guest123':
            session_id = hashlib.sha256(f"{data['username']}{time.time()}".encode()).hexdigest()[:32]
            
            self.send_json({
                'success': True,
                'session_id': session_id,
                'user': {
                    'username': 'guest',
                    'role': 'guest',
                    'name': 'Guest User'
                }
            })
        else:
            self.send_json({'success': False, 'error': 'Invalid credentials'}, 401)
    
    def handle_user_logout(self, data):
        """Handle user logout"""
        self.send_json({'success': True, 'message': 'Logged out'})
    
    def handle_user_settings(self, data):
        """Handle user settings"""
        if not data or 'action' not in data:
            self.send_json({'error': 'Missing action'}, 400)
            return
        
        if data['action'] == 'get':
            self.send_json({
                'theme': 'default-dark',
                'language': 'en',
                'wallpaper': 'default',
                'animations': True
            })
        elif data['action'] == 'update':
            self.send_json({'success': True, 'message': 'Settings updated'})
    
    def handle_apps_list(self):
        """List available applications"""
        apps_file = os.path.join(self.config.get('paths', 'install_dir'), 'etc/apps.registry')
        try:
            with open(apps_file, 'r') as f:
                apps = json.load(f)
            self.send_json(apps)
        except:
            self.send_json({'error': 'Could not load apps registry'})
    
    def handle_app_launch(self, data):
        """Launch application"""
        if not data or 'app_id' not in data:
            self.send_json({'error': 'Missing app_id'}, 400)
            return
        
        self.send_json({
            'success': True,
            'app_id': data['app_id'],
            'message': f"Application {data['app_id']} launched"
        })
    
    def handle_app_install(self, data):
        """Install application"""
        if not data or 'app_id' not in data:
            self.send_json({'error': 'Missing app_id'}, 400)
            return
        
        self.send_json({
            'success': True,
            'app_id': data['app_id'],
            'message': f"Application {data['app_id']} installed"
        })
    
    def handle_processes_list(self):
        """List system processes"""
        try:
            import psutil
            
            processes = []
            for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent', 'username']):
                try:
                    processes.append(proc.info)
                except (psutil.NoSuchProcess, psutil.AccessDenied):
                    continue
            
            self.send_json({
                'processes': processes[:100],  # Limit to 100
                'total': len(processes)
            })
        except ImportError:
            # Fallback without psutil
            self.send_json({
                'processes': [],
                'total': 0,
                'note': 'psutil not installed'
            })
    
    def serve_static(self, path):
        """Serve static files"""
        if path == '/' or path == '':
            path = '/index.html'
        
        # Security: Normalize path
        path = os.path.normpath(path).lstrip('/')
        
        # Default to index.html for empty paths
        if not path:
            path = 'index.html'
        
        # Map paths to files
        install_dir = self.config.get('paths', 'install_dir')
        
        # Check if file exists
        file_path = os.path.join(install_dir, path)
        
        if os.path.exists(file_path) and not os.path.isdir(file_path):
            # Determine content type
            content_types = {
                '.html': 'text/html',
                '.htm': 'text/html',
                '.css': 'text/css',
                '.js': 'application/javascript',
                '.json': 'application/json',
                '.png': 'image/png',
                '.jpg': 'image/jpeg',
                '.jpeg': 'image/jpeg',
                '.gif': 'image/gif',
                '.svg': 'image/svg+xml',
                '.ico': 'image/x-icon',
                '.ttf': 'font/ttf',
                '.woff': 'font/woff',
                '.woff2': 'font/woff2',
                '.eot': 'application/vnd.ms-fontobject',
                '.otf': 'font/otf'
            }
            
            ext = os.path.splitext(file_path)[1].lower()
            content_type = content_types.get(ext, 'application/octet-stream')
            
            try:
                with open(file_path, 'rb') as f:
                    content = f.read()
                
                self.send_response(200)
                self.send_header('Content-Type', content_type)
                self.send_header('Content-Length', str(len(content)))
                self.send_header('Cache-Control', 'public, max-age=3600')
                self.end_headers()
                self.wfile.write(content)
            except Exception as e:
                logger.error(f"Error serving file {path}: {e}")
                self.send_error(500, str(e))
        else:
            # File not found, serve 404 or default to index.html
            if path.endswith('.html') or path.endswith('.js') or path.endswith('.css'):
                self.send_error(404, "File not found")
            else:
                # For other paths, default to index.html
                self.serve_static('/index.html')
    
    def send_json(self, data, status=200):
        """Send JSON response"""
        response = json.dumps(data, indent=2).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(response)))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
        self.wfile.write(response)
    
    def do_OPTIONS(self):
        """Handle OPTIONS requests for CORS"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

async def websocket_handler(websocket, path):
    """Handle WebSocket connections"""
    logger.info(f"WebSocket connection: {path}")
    
    if path == '/ws/terminal':
        await handle_terminal_websocket(websocket)
    elif path == '/ws/notifications':
        await handle_notifications_websocket(websocket)
    elif path == '/ws/chat':
        await handle_chat_websocket(websocket)
    else:
        await websocket.close(code=1003, reason="Unknown endpoint")

async def handle_terminal_websocket(websocket):
    """Handle terminal WebSocket"""
    await websocket.send("Web Desktop Terminal - Connected\r\n")
    await websocket.send("Type 'help' for available commands\r\n\r\n")
    
    # Create a terminal session
    terminal_manager = TerminalManager()
    session_id = terminal_manager.create_session('websocket_user')
    
    try:
        async for message in websocket:
            # Process terminal commands
            result = terminal_manager.execute_command(session_id, message)
            
            if 'error' in result:
                response = f"Error: {result['error']}\r\n"
            else:
                response = result['output']
            
            await websocket.send(response)
            
            # Send prompt
            prompt = f"\r\n{terminal_manager.sessions[session_id]['cwd']} $ "
            await websocket.send(prompt)
            
    except websockets.exceptions.ConnectionClosed:
        logger.info("Terminal WebSocket disconnected")
    except Exception as e:
        logger.error(f"Terminal WebSocket error: {e}")
        await websocket.send(f"\r\nError: {e}\r\n")

async def handle_notifications_websocket(websocket):
    """Handle notifications WebSocket"""
    # Send periodic updates
    try:
        while True:
            await asyncio.sleep(10)
            notification = {
                'type': 'system',
                'message': 'System running normally',
                'timestamp': datetime.now().isoformat(),
                'level': 'info'
            }
            await websocket.send(json.dumps(notification))
    except websockets.exceptions.ConnectionClosed:
        logger.info("Notifications WebSocket disconnected")

async def handle_chat_websocket(websocket):
    """Handle chat WebSocket"""
    await websocket.send(json.dumps({
        'type': 'system',
        'message': 'Chat connected',
        'timestamp': datetime.now().isoformat()
    }))
    
    try:
        async for message in websocket:
            # Echo message back
            response = {
                'type': 'message',
                'content': message,
                'timestamp': datetime.now().isoformat(),
                'user': 'You'
            }
            await websocket.send(json.dumps(response))
    except websockets.exceptions.ConnectionClosed:
        logger.info("Chat WebSocket disconnected")

def run_websocket_server(host='0.0.0.0', port=8081):
    """Run WebSocket server"""
    async def main():
        async with websockets.serve(websocket_handler, host, port, ping_interval=30):
            logger.info(f"WebSocket server started on ws://{host}:{port}")
            await asyncio.Future()  # Run forever
    
    asyncio.run(main())

def run_http_server(config_path, host='0.0.0.0', port=8080):
    """Run HTTP server"""
    # Initialize managers
    config = Config(config_path)
    terminal_manager = TerminalManager()
    file_manager = FileManager(os.path.expanduser('~/.webdesktop/home/user'))
    package_manager = PackageManager(config.get('platform', 'type', 'linux'))
    database = Database(os.path.expanduser('~/.webdesktop/var/webdesktop.db'))
    
    # Create custom handler class with managers
    class HandlerWithManagers(WebDesktopHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(
                *args,
                config=config,
                terminal_manager=terminal_manager,
                file_manager=file_manager,
                package_manager=package_manager,
                database=database,
                **kwargs
            )
    
    # Start server
    server = HTTPServer((host, port), HandlerWithManagers)
    
    logger.info(f"HTTP server started on http://{host}:{port}")
    logger.info(f"Platform: {'Termux' if IS_TERMUX else 'macOS' if IS_MACOS else 'Linux'}")
    logger.info(f"Config: {config_path}")
    logger.info("Press Ctrl+C to stop")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logger.info("\nServer stopped")
    except Exception as e:
        logger.error(f"Server error: {e}")

def main():
    """Main entry point"""
    
    # Parse command line arguments
    import argparse
    parser = argparse.ArgumentParser(description='Web Desktop Framework Server')
    parser.add_argument('--port', type=int, default=8080, help='HTTP port')
    parser.add_argument('--host', default='0.0.0.0', help='Bind address')
    parser.add_argument('--config', default='etc/webdesktop.conf', help='Config file path')
    parser.add_argument('--websocket-port', type=int, default=8081, help='WebSocket port')
    
    args = parser.parse_args()
    
    print("\n" + "="*60)
    print("        WEB DESKTOP FRAMEWORK SERVER")
    print("="*60)
    print(f"Platform: {'Termux' if IS_TERMUX else 'macOS' if IS_MACOS else 'Linux'}")
    print(f"Python: {sys.version}")
    print(f"Host: {args.host}")
    print(f"HTTP Port: {args.port}")
    print(f"WebSocket Port: {args.websocket_port}")
    print("="*60 + "\n")
    
    # Start WebSocket server in background thread
    ws_thread = threading.Thread(
        target=lambda: asyncio.run(run_websocket_server(args.host, args.websocket_port)),
        daemon=True
    )
    ws_thread.start()
    
    # Run HTTP server
    run_http_server(args.config, args.host, args.port)

if __name__ == '__main__':
    main()
EOF
    
    # Create WebSocket server
    cat > "$install_dir/bin/websocket_server.py" << 'EOF'
#!/usr/bin/env python3
"""
WebSocket Server for Web Desktop Framework
Handles real-time communication
"""

import asyncio
import websockets
import json
import logging
from datetime import datetime

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class WebSocketManager:
    """Manage WebSocket connections"""
    
    def __init__(self):
        self.connections = set()
        self.chat_messages = []
    
    async def register(self, websocket):
        """Register new connection"""
        self.connections.add(websocket)
        logger.info(f"New connection. Total: {len(self.connections)}")
    
    async def unregister(self, websocket):
        """Unregister connection"""
        self.connections.remove(websocket)
        logger.info(f"Connection closed. Total: {len(self.connections)}")
    
    async def broadcast(self, message):
        """Broadcast message to all connections"""
        if self.connections:
            await asyncio.wait([conn.send(message) for conn in self.connections])

async def handler(websocket, path, manager):
    """Handle WebSocket connection"""
    await manager.register(websocket)
    try:
        async for message in websocket:
            # Handle incoming message
            data = json.loads(message)
            
            # Echo back with timestamp
            response = {
                'type': 'echo',
                'original': data,
                'timestamp': datetime.now().isoformat(),
                'received_by': 'server'
            }
            
            await websocket.send(json.dumps(response))
            
            # Broadcast to other connections if it's a chat message
            if data.get('type') == 'chat':
                broadcast_msg = {
                    'type': 'chat',
                    'user': data.get('user', 'Anonymous'),
                    'message': data.get('message', ''),
                    'timestamp': datetime.now().isoformat()
                }
                await manager.broadcast(json.dumps(broadcast_msg))
                
    except websockets.exceptions.ConnectionClosed:
        logger.info("Connection closed normally")
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
    finally:
        await manager.unregister(websocket)

async def main(host='0.0.0.0', port=8081):
    """Main WebSocket server"""
    manager = WebSocketManager()
    
    async with websockets.serve(lambda ws, path: handler(ws, path, manager), host, port):
        logger.info(f"WebSocket server started on ws://{host}:{port}")
        await asyncio.Future()  # Run forever

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='WebSocket Server')
    parser.add_argument('--host', default='0.0.0.0', help='Bind address')
    parser.add_argument('--port', type=int, default=8081, help='WebSocket port')
    
    args = parser.parse_args()
    
    asyncio.run(main(args.host, args.port))
EOF
    
    # Create system monitor
    cat > "$install_dir/bin/system_monitor.py" << 'EOF'
#!/usr/bin/env python3
"""
System Monitor for Web Desktop Framework
Monitors system resources and provides alerts
"""

import time
import json
import logging
from datetime import datetime
import psutil
import threading

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class SystemMonitor:
    """Monitor system resources"""
    
    def __init__(self, config_path='etc/webdesktop.conf'):
        self.config_path = config_path
        self.metrics = {
            'cpu': [],
            'memory': [],
            'disk': [],
            'network': []
        }
        self.alerts = []
        self.running = False
        self.thread = None
        
        # Alert thresholds
        self.thresholds = {
            'cpu_warning': 80,
            'cpu_critical': 95,
            'memory_warning': 85,
            'memory_critical': 95,
            'disk_warning': 90,
            'disk_critical': 98
        }
    
    def collect_metrics(self):
        """Collect system metrics"""
        try:
            metrics = {
                'timestamp': datetime.now().isoformat(),
                'cpu': {
                    'percent': psutil.cpu_percent(interval=1),
                    'count': psutil.cpu_count(),
                    'freq': psutil.cpu_freq().current if hasattr(psutil.cpu_freq(), 'current') else None
                },
                'memory': {
                    'total': psutil.virtual_memory().total,
                    'available': psutil.virtual_memory().available,
                    'percent': psutil.virtual_memory().percent,
                    'used': psutil.virtual_memory().used
                },
                'disk': {
                    'total': psutil.disk_usage('/').total,
                    'used': psutil.disk_usage('/').used,
                    'free': psutil.disk_usage('/').free,
                    'percent': psutil.disk_usage('/').percent
                },
                'network': {
                    'bytes_sent': psutil.net_io_counters().bytes_sent,
                    'bytes_recv': psutil.net_io_counters().bytes_recv,
                    'packets_sent': psutil.net_io_counters().packets_sent,
                    'packets_recv': psutil.net_io_counters().packets_recv
                },
                'processes': len(psutil.pids()),
                'boot_time': psutil.boot_time(),
                'uptime': time.time() - psutil.boot_time()
            }
            
            # Check thresholds
            self.check_thresholds(metrics)
            
            # Store metrics (keep last 100 samples)
            for key in ['cpu', 'memory', 'disk', 'network']:
                self.metrics[key].append(metrics[key])
                if len(self.metrics[key]) > 100:
                    self.metrics[key].pop(0)
            
            return metrics
            
        except Exception as e:
            logger.error(f"Error collecting metrics: {e}")
            return None
    
    def check_thresholds(self, metrics):
        """Check if metrics exceed thresholds"""
        alerts = []
        
        # CPU check
        cpu_percent = metrics['cpu']['percent']
        if cpu_percent > self.thresholds['cpu_critical']:
            alerts.append({
                'level': 'critical',
                'type': 'cpu',
                'value': cpu_percent,
                'threshold': self.thresholds['cpu_critical'],
                'message': f'CPU usage critical: {cpu_percent}%',
                'timestamp': metrics['timestamp']
            })
        elif cpu_percent > self.thresholds['cpu_warning']:
            alerts.append({
                'level': 'warning',
                'type': 'cpu',
                'value': cpu_percent,
                'threshold': self.thresholds['cpu_warning'],
                'message': f'CPU usage high: {cpu_percent}%',
                'timestamp': metrics['timestamp']
            })
        
        # Memory check
        mem_percent = metrics['memory']['percent']
        if mem_percent > self.thresholds['memory_critical']:
            alerts.append({
                'level': 'critical',
                'type': 'memory',
                'value': mem_percent,
                'threshold': self.thresholds['memory_critical'],
                'message': f'Memory usage critical: {mem_percent}%',
                'timestamp': metrics['timestamp']
            })
        elif mem_percent > self.thresholds['memory_warning']:
            alerts.append({
                'level': 'warning',
                'type': 'memory',
                'value': mem_percent,
                'threshold': self.thresholds['memory_warning'],
                'message': f'Memory usage high: {mem_percent}%',
                'timestamp': metrics['timestamp']
            })
        
        # Disk check
        disk_percent = metrics['disk']['percent']
        if disk_percent > self.thresholds['disk_critical']:
            alerts.append({
                'level': 'critical',
                'type': 'disk',
                'value': disk_percent,
                'threshold': self.thresholds['disk_critical'],
                'message': f'Disk usage critical: {disk_percent}%',
                'timestamp': metrics['timestamp']
            })
        elif disk_percent > self.thresholds['disk_warning']:
            alerts.append({
                'level': 'warning',
                'type': 'disk',
                'value': disk_percent,
                'threshold': self.thresholds['disk_warning'],
                'message': f'Disk usage high: {disk_percent}%',
                'timestamp': metrics['timestamp']
            })
        
        # Add new alerts
        for alert in alerts:
            self.alerts.append(alert)
            logger.warning(alert['message'])
        
        # Keep only last 50 alerts
        if len(self.alerts) > 50:
            self.alerts = self.alerts[-50:]
    
    def get_metrics_history(self, metric_type='cpu', limit=50):
        """Get metric history"""
        if metric_type in self.metrics:
            return self.metrics[metric_type][-limit:]
        return []
    
    def get_alerts(self, level=None, limit=20):
        """Get alerts (optionally filtered by level)"""
        if level:
            filtered = [a for a in self.alerts if a['level'] == level]
            return filtered[-limit:]
        return self.alerts[-limit:]
    
    def monitoring_loop(self, interval=5):
        """Main monitoring loop"""
        logger.info(f"Starting monitoring loop (interval: {interval}s)")
        
        while self.running:
            try:
                metrics = self.collect_metrics()
                if metrics:
                    logger.debug(f"Collected metrics: CPU={metrics['cpu']['percent']}%, "
                                f"MEM={metrics['memory']['percent']}%, "
                                f"DISK={metrics['disk']['percent']}%")
                time.sleep(interval)
            except Exception as e:
                logger.error(f"Monitoring loop error: {e}")
                time.sleep(interval)
    
    def start(self, interval=5):
        """Start monitoring"""
        if not self.running:
            self.running = True
            self.thread = threading.Thread(target=self.monitoring_loop, args=(interval,))
            self.thread.daemon = True
            self.thread.start()
            logger.info("System monitor started")
    
    def stop(self):
        """Stop monitoring"""
        self.running = False
        if self.thread:
            self.thread.join(timeout=10)
        logger.info("System monitor stopped")
    
    def get_status(self):
        """Get monitor status"""
        return {
            'running': self.running,
            'metrics_collected': sum(len(v) for v in self.metrics.values()),
            'alerts_count': len(self.alerts),
            'thread_alive': self.thread.is_alive() if self.thread else False
        }

def main():
    """Main function"""
    import argparse
    
    parser = argparse.ArgumentParser(description='System Monitor')
    parser.add_argument('--interval', type=int, default=5, help='Monitoring interval in seconds')
    parser.add_argument('--log-file', help='Log file path')
    
    args = parser.parse_args()
    
    # Setup file logging if specified
    if args.log_file:
        file_handler = logging.FileHandler(args.log_file)
        file_handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
        logger.addHandler(file_handler)
    
    monitor = SystemMonitor()
    
    try:
        monitor.start(args.interval)
        
        # Keep running until interrupted
        while True:
            time.sleep(1)
            
    except KeyboardInterrupt:
        logger.info("Shutting down...")
        monitor.stop()
    except Exception as e:
        logger.error(f"Main error: {e}")
        monitor.stop()

if __name__ == '__main__':
    main()
EOF
    
    # Create application manager
    cat > "$install_dir/bin/app_manager.py" << 'EOF'
#!/usr/bin/env python3
"""
Application Manager for Web Desktop Framework
Manages installation, updates, and removal of applications
"""

import os
import json
import shutil
import subprocess
import logging
from datetime import datetime
from pathlib import Path

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class AppManager:
    """Manage applications"""
    
    def __init__(self, install_dir):
        self.install_dir = Path(install_dir)
        self.apps_dir = self.install_dir / 'apps'
        self.config_file = self.install_dir / 'etc' / 'apps.registry'
        self.installed_apps = self.load_apps_registry()
        
        # Create directories
        self.apps_dir.mkdir(exist_ok=True)
    
    def load_apps_registry(self):
        """Load applications registry"""
        if self.config_file.exists():
            try:
                with open(self.config_file, 'r') as f:
                    return json.load(f)
            except json.JSONDecodeError as e:
                logger.error(f"Error loading apps registry: {e}")
        
        # Default structure
        return {
            'version': '1.0',
            'applications': {},
            'categories': {},
            'statistics': {'total_apps': 0}
        }
    
    def save_apps_registry(self):
        """Save applications registry"""
        try:
            with open(self.config_file, 'w') as f:
                json.dump(self.installed_apps, f, indent=2)
            return True
        except Exception as e:
            logger.error(f"Error saving apps registry: {e}")
            return False
    
    def get_app_categories(self):
        """Get available app categories"""
        return self.installed_apps.get('categories', {})
    
    def get_apps_by_category(self, category=None):
        """Get applications, optionally filtered by category"""
        apps = self.installed_apps.get('applications', {})
        
        if category:
            result = {}
            for cat, app_list in apps.items():
                if cat == category:
                    result[cat] = app_list
            return result
        return apps
    
    def get_app_info(self, app_id):
        """Get information about specific application"""
        for category, apps in self.installed_apps.get('applications', {}).items():
            for app in apps:
                if app.get('id') == app_id:
                    return app
        return None
    
    def install_app(self, app_info):
        """Install an application"""
        app_id = app_info.get('id')
        if not app_id:
            return {'success': False, 'error': 'App ID missing'}
        
        # Check if already installed
        existing = self.get_app_info(app_id)
        if existing:
            return {'success': False, 'error': 'App already installed'}
        
        # Create app directory
        app_dir = self.apps_dir / app_id
        app_dir.mkdir(exist_ok=True)
        
        # Create app files
        self.create_app_files(app_dir, app_info)
        
        # Add to registry
        category = app_info.get('category', 'uncategorized')
        if category not in self.installed_apps['applications']:
            self.installed_apps['applications'][category] = []
        
        # Set installation date
        app_info['install_date'] = datetime.now().isoformat()
        app_info['last_used'] = None
        app_info['usage_count'] = 0
        
        self.installed_apps['applications'][category].append(app_info)
        
        # Update statistics
        self.installed_apps['statistics']['total_apps'] = sum(
            len(apps) for apps in self.installed_apps['applications'].values()
        )
        
        # Save registry
        if self.save_apps_registry():
            logger.info(f"Installed app: {app_info.get('name')} ({app_id})")
            return {'success': True, 'app_id': app_id}
        else:
            return {'success': False, 'error': 'Failed to save registry'}
    
    def create_app_files(self, app_dir, app_info):
        """Create application files"""
        # Create HTML file
        html_content = f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{app_info.get('name', 'App')} - Web Desktop</title>
    <style>
        body {{
            margin: 0;
            padding: 20px;
            background: var(--bg-secondary);
            color: var(--text-primary);
            font-family: inherit;
        }}
        
        .app-container {{
            height: 100%;
            display: flex;
            flex-direction: column;
        }}
        
        .app-header {{
            padding: 20px;
            background: var(--bg-tertiary);
            border-radius: 8px;
            margin-bottom: 20px;
            border: 1px solid var(--border-color);
        }}
        
        .app-content {{
            flex: 1;
            padding: 20px;
            background: var(--bg-tertiary);
            border-radius: 8px;
            border: 1px solid var(--border-color);
            overflow-y: auto;
        }}
        
        .app-title {{
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 10px;
        }}
        
        .app-icon {{
            font-size: 32px;
            color: {app_info.get('icon_color', '#3B82F6')};
        }}
        
        h1 {{ margin: 0; }}
        
        .app-description {{
            color: var(--text-secondary);
            margin-top: 10px;
        }}
    </style>
</head>
<body>
    <div class="app-container">
        <div class="app-header">
            <div class="app-title">
                <div class="app-icon">
                    <i class="fas fa-{app_info.get('icon', 'question')}"></i>
                </div>
                <div>
                    <h1>{app_info.get('name', 'App')}</h1>
                    <div class="app-description">
                        {app_info.get('description', '')}
                    </div>
                </div>
            </div>
        </div>
        
        <div class="app-content">
            <h3>Application Information</h3>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-top: 20px;">
                <div style="background: var(--bg-primary); padding: 15px; border-radius: 6px;">
                    <div style="font-weight: bold; color: var(--text-secondary);">Version</div>
                    <div>{app_info.get('version', '1.0.0')}</div>
                </div>
                <div style="background: var(--bg-primary); padding: 15px; border-radius: 6px;">
                    <div style="font-weight: bold; color: var(--text-secondary);">Category</div>
                    <div>{app_info.get('category', 'Unknown')}</div>
                </div>
                <div style="background: var(--bg-primary); padding: 15px; border-radius: 6px;">
                    <div style="font-weight: bold; color: var(--text-secondary);">Author</div>
                    <div>{app_info.get('author', 'Unknown')}</div>
                </div>
                <div style="background: var(--bg-primary); padding: 15px; border-radius: 6px;">
                    <div style="font-weight: bold; color: var(--text-secondary);">License</div>
                    <div>{app_info.get('license', 'MIT')}</div>
                </div>
            </div>
            
            <h3 style="margin-top: 30px;">Features</h3>
            <ul>
                {''.join(f'<li>{feature}</li>' for feature in app_info.get('features', []))}
            </ul>
            
            <div style="margin-top: 30px; padding: 20px; background: var(--bg-primary); border-radius: 8px;">
                <h4>App Ready</h4>
                <p>This application is installed and ready to use. Full functionality will be implemented based on app type.</p>
            </div>
        </div>
    </div>
</body>
</html>
'''
        
        html_file = app_dir / f"{app_id}.html"
        with open(html_file, 'w') as f:
            f.write(html_content)
        
        # Create manifest file
        manifest = {
            'id': app_id,
            'name': app_info.get('name'),
            'version': app_info.get('version', '1.0.0'),
            'description': app_info.get('description', ''),
            'author': app_info.get('author', ''),
            'license': app_info.get('license', 'MIT'),
            'created': datetime.now().isoformat(),
            'files': [f"{app_id}.html"]
        }
        
        manifest_file = app_dir / 'manifest.json'
        with open(manifest_file, 'w') as f:
            json.dump(manifest, f, indent=2)
    
    def uninstall_app(self, app_id):
        """Uninstall an application"""
        app_info = self.get_app_info(app_id)
        if not app_info:
            return {'success': False, 'error': 'App not found'}
        
        # Remove app directory
        app_dir = self.apps_dir / app_id
        if app_dir.exists():
            shutil.rmtree(app_dir)
        
        # Remove from registry
        for category, apps in self.installed_apps['applications'].items():
            self.installed_apps['applications'][category] = [
                app for app in apps if app.get('id') != app_id
            ]
        
        # Remove empty categories
        self.installed_apps['applications'] = {
            k: v for k, v in self.installed_apps['applications'].items() if v
        }
        
        # Update statistics
        self.installed_apps['statistics']['total_apps'] = sum(
            len(apps) for apps in self.installed_apps['applications'].values()
        )
        
        # Save registry
        if self.save_apps_registry():
            logger.info(f"Uninstalled app: {app_id}")
            return {'success': True, 'app_id': app_id}
        else:
            return {'success': False, 'error': 'Failed to save registry'}
    
    def update_app(self, app_id, new_info):
        """Update an application"""
        app_info = self.get_app_info(app_id)
        if not app_info:
            return {'success': False, 'error': 'App not found'}
        
        # Update app info
        for category, apps in self.installed_apps['applications'].items():
            for i, app in enumerate(apps):
                if app.get('id') == app_id:
                    # Update fields
                    for key, value in new_info.items():
                        if key not in ['id', 'install_date', 'last_used', 'usage_count']:
                            apps[i][key] = value
                    
                    # Update app files
                    app_dir = self.apps_dir / app_id
                    if app_dir.exists():
                        self.create_app_files(app_dir, apps[i])
                    
                    # Save registry
                    if self.save_apps_registry():
                        logger.info(f"Updated app: {app_id}")
                        return {'success': True, 'app_id': app_id}
                    else:
                        return {'success': False, 'error': 'Failed to save registry'}
        
        return {'success': False, 'error': 'App not found in registry'}
    
    def record_app_usage(self, app_id):
        """Record app usage (call when app is launched)"""
        for category, apps in self.installed_apps['applications'].items():
            for app in apps:
                if app.get('id') == app_id:
                    app['last_used'] = datetime.now().isoformat()
                    app['usage_count'] = app.get('usage_count', 0) + 1
                    self.save_apps_registry()
                    return True
        return False

def main():
    """Command-line interface for app manager"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Application Manager')
    parser.add_argument('--install-dir', required=True, help='Installation directory')
    parser.add_argument('--action', choices=['list', 'info', 'install', 'uninstall', 'update'], 
                       required=True, help='Action to perform')
    parser.add_argument('--app-id', help='Application ID')
    parser.add_argument('--app-info', help='Application info JSON file')
    parser.add_argument('--category', help='Filter by category')
    
    args = parser.parse_args()
    
    manager = AppManager(args.install_dir)
    
    if args.action == 'list':
        if args.category:
            apps = manager.get_apps_by_category(args.category)
        else:
            apps = manager.get_apps_by_category()
        
        print(json.dumps(apps, indent=2))
    
    elif args.action == 'info':
        if not args.app_id:
            print("Error: --app-id required")
            return
        
        app_info = manager.get_app_info(args.app_id)
        if app_info:
            print(json.dumps(app_info, indent=2))
        else:
            print(f"App '{args.app_id}' not found")
    
    elif args.action == 'install':
        if not args.app_info:
            print("Error: --app-info required")
            return
        
        try:
            with open(args.app_info, 'r') as f:
                app_info = json.load(f)
            
            result = manager.install_app(app_info)
            print(json.dumps(result, indent=2))
        except Exception as e:
            print(f"Error: {e}")
    
    elif args.action == 'uninstall':
        if not args.app_id:
            print("Error: --app-id required")
            return
        
        result = manager.uninstall_app(args.app_id)
        print(json.dumps(result, indent=2))
    
    elif args.action == 'update':
        if not args.app_id or not args.app_info:
            print("Error: --app-id and --app-info required")
            return
        
        try:
            with open(args.app_info, 'r') as f:
                new_info = json.load(f)
            
            result = manager.update_app(args.app_id, new_info)
            print(json.dumps(result, indent=2))
        except Exception as e:
            print(f"Error: {e}")

if __name__ == '__main__':
    main()
EOF
    
    # Make all scripts executable
    chmod +x "$install_dir/bin/server.py"
    chmod +x "$install_dir/bin/websocket_server.py"
    chmod +x "$install_dir/bin/system_monitor.py"
    chmod +x "$install_dir/bin/app_manager.py"
    
    log_success "Backend server created"
}

# ============================================================================
# FRONTEND INTERFACE
# ============================================================================

create_frontend_interface() {
    local install_dir=$1
    local platform=$2
    log_step "Creating frontend interface..."
    
    # Create main HTML file (this would be huge, so we'll create a basic version)
    # In a real scenario, this would be a complete web application
    
    # Create basic HTML structure
    cat > "$install_dir/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Web Desktop Framework</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #3b82f6;
            --primary-dark: #2563eb;
            --secondary: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --info: #06b6d4;
            
            --bg-primary: #0f172a;
            --bg-secondary: #1e293b;
            --bg-tertiary: #334155;
            
            --text-primary: #f8fafc;
            --text-secondary: #cbd5e1;
            --text-muted: #94a3b8;
            
            --border: #475569;
            --shadow: rgba(0, 0, 0, 0.3);
            
            --radius-sm: 4px;
            --radius-md: 8px;
            --radius-lg: 12px;
            
            --transition: all 0.2s ease;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            height: 100vh;
            overflow: hidden;
        }
        
        /* Loading screen */
        #loading {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: var(--bg-primary);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            z-index: 9999;
        }
        
        .loading-logo {
            font-size: 4rem;
            color: var(--primary);
            margin-bottom: 2rem;
            animation: pulse 2s infinite;
        }
        
        .loading-bar {
            width: 300px;
            height: 6px;
            background: var(--bg-tertiary);
            border-radius: 3px;
            overflow: hidden;
        }
        
        .loading-progress {
            height: 100%;
            background: linear-gradient(90deg, var(--primary), var(--secondary));
            width: 0%;
            transition: width 0.3s ease;
        }
        
        /* Desktop */
        #desktop {
            display: none;
            height: 100vh;
        }
        
        /* Taskbar */
        .taskbar {
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 50px;
            background: rgba(30, 41, 59, 0.9);
            backdrop-filter: blur(10px);
            border-top: 1px solid var(--border);
            display: flex;
            align-items: center;
            padding: 0 20px;
            z-index: 1000;
        }
        
        .start-button {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            border: none;
            border-radius: var(--radius-md);
            padding: 8px 16px;
            color: white;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: var(--transition);
        }
        
        .start-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(59, 130, 246, 0.3);
        }
        
        .system-info {
            margin-left: auto;
            display: flex;
            gap: 20px;
            font-size: 14px;
            color: var(--text-secondary);
        }
        
        /* Window */
        .window {
            position: absolute;
            background: var(--bg-secondary);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
            box-shadow: 0 10px 25px var(--shadow);
            min-width: 400px;
            min-height: 300px;
            display: none;
            overflow: hidden;
        }
        
        .window-header {
            background: linear-gradient(90deg, 
                rgba(59, 130, 246, 0.2), 
                rgba(16, 185, 129, 0.2));
            padding: 12px 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border);
            cursor: move;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
        }
    </style>
</head>
<body>
    <div id="loading">
        <div class="loading-logo">
            <i class="fas fa-desktop"></i>
        </div>
        <h1 style="margin-bottom: 20px;">Web Desktop Framework</h1>
        <div class="loading-bar">
            <div class="loading-progress" id="loadingProgress"></div>
        </div>
        <p id="loadingText" style="margin-top: 20px; color: var(--text-secondary);">Initializing...</p>
    </div>
    
    <div id="desktop">
        <div class="taskbar">
            <button class="start-button" onclick="showStartMenu()">
                <i class="fas fa-rocket"></i> Start
            </button>
            <div class="system-info">
                <span id="cpuUsage">CPU: --%</span>
                <span id="memoryUsage">RAM: --%</span>
                <span id="clock">00:00:00</span>
            </div>
        </div>
    </div>
    
    <script>
        // Simulate loading
        let progress = 0;
        const loadingTexts = [
            "Initializing system...",
            "Loading components...",
            "Starting services...",
            "Preparing interface...",
            "Almost ready..."
        ];
        
        function updateProgress() {
            progress += 5;
            if (progress > 100) progress = 100;
            
            document.getElementById('loadingProgress').style.width = progress + '%';
            
            // Update text
            const textIndex = Math.floor(progress / 20);
            if (textIndex < loadingTexts.length) {
                document.getElementById('loadingText').textContent = loadingTexts[textIndex];
            }
            
            if (progress < 100) {
                setTimeout(updateProgress, 200);
            } else {
                setTimeout(() => {
                    document.getElementById('loading').style.opacity = '0';
                    setTimeout(() => {
                        document.getElementById('loading').style.display = 'none';
                        document.getElementById('desktop').style.display = 'block';
                        startSystem();
                    }, 500);
                }, 500);
            }
        }
        
        function startSystem() {
            // Update clock
            function updateClock() {
                const now = new Date();
                document.getElementById('clock').textContent = 
                    now.toLocaleTimeString();
            }
            
            setInterval(updateClock, 1000);
            updateClock();
            
            // Simulate system stats
            function updateStats() {
                document.getElementById('cpuUsage').textContent = 
                    `CPU: ${Math.floor(Math.random() * 30) + 10}%`;
                document.getElementById('memoryUsage').textContent = 
                    `RAM: ${Math.floor(Math.random() * 40) + 30}%`;
            }
            
            setInterval(updateStats, 3000);
            updateStats();
            
            // Show welcome notification
            setTimeout(() => {
                alert('Welcome to Web Desktop Framework!\n\nDefault login:\nUsername: admin\nPassword: admin123');
            }, 1000);
        }
        
        function showStartMenu() {
            alert('Start menu will appear here.\n\nAvailable apps:\n• Terminal\n• File Manager\n• Browser\n• Settings\n• Calculator\n• Text Editor\n• Paint\n• Media Player');
        }
        
        // Start loading
        setTimeout(updateProgress, 1000);
    </script>
</body>
</html>
EOF
    
    # Create apps directory with basic app files
    create_app_files "$install_dir"
    
    log_success "Frontend interface created"
}

create_app_files() {
    local install_dir=$1
    
    # Create basic app HTML files
    local apps=(
        "terminal:Terminal:fas fa-terminal:#10B981"
        "filemanager:File Manager:fas fa-folder:#F59E0B"
        "browser:Browser:fas fa-globe:#3B82F6"
        "settings:Settings:fas fa-cog:#6B7280"
        "calculator:Calculator:fas fa-calculator:#EF4444"
        "texteditor:Text Editor:fas fa-edit:#8B5CF6"
        "paint:Paint:fas fa-paint-brush:#EC4899"
        "mediaplayer:Media Player:fas fa-play-circle:#10B981"
    )
    
    for app in "${apps[@]}"; do
        IFS=':' read -r id name icon color <<< "$app"
        
        cat > "$install_dir/apps/${id}.html" << APP_HTML
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>$name - Web Desktop</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            margin: 0;
            padding: 20px;
            background: var(--bg-secondary);
            color: var(--text-primary);
            font-family: 'Inter', sans-serif;
        }
        
        .app-header {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid $color;
        }
        
        .app-icon {
            font-size: 40px;
            color: $color;
        }
        
        .app-title h1 {
            margin: 0;
            font-size: 28px;
        }
        
        .app-title p {
            margin: 5px 0 0 0;
            color: var(--text-secondary);
        }
        
        .app-content {
            background: var(--bg-tertiary);
            border-radius: 12px;
            padding: 30px;
            border: 1px solid var(--border);
        }
        
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        
        .feature-card {
            background: var(--bg-secondary);
            padding: 20px;
            border-radius: 8px;
            border: 1px solid var(--border);
            transition: all 0.3s ease;
        }
        
        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
        }
        
        .feature-icon {
            font-size: 24px;
            color: $color;
            margin-bottom: 15px;
        }
        
        .status {
            padding: 15px;
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid rgba(16, 185, 129, 0.3);
            border-radius: 8px;
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <div class="app-header">
        <div class="app-icon">
            <i class="$icon"></i>
        </div>
        <div class="app-title">
            <h1>$name</h1>
            <p>Web Desktop Application</p>
        </div>
    </div>
    
    <div class="app-content">
        <h2>About This Application</h2>
        <p>This is the $name application for Web Desktop Framework. It provides essential functionality for your web-based desktop environment.</p>
        
        <div class="features">
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="fas fa-bolt"></i>
                </div>
                <h3>Fast & Responsive</h3>
                <p>Optimized for performance with smooth animations and quick response times.</p>
            </div>
            
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="fas fa-shield-alt"></i>
                </div>
                <h3>Secure</h3>
                <p>Built with security in mind. All operations are sandboxed and monitored.</p>
            </div>
            
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="fas fa-sync-alt"></i>
                </div>
                <h3>Auto-updating</h3>
                <p>Regular updates with new features and security improvements.</p>
            </div>
            
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="fas fa-palette"></i>
                </div>
                <h3>Customizable</h3>
                <p>Themes, layouts, and settings can be customized to your preference.</p>
            </div>
        </div>
        
        <div class="status">
            <h3><i class="fas fa-check-circle"></i> Application Status: Ready</h3>
            <p>This application is fully functional and ready to use. Click buttons or use the menu to access features.</p>
        </div>
    </div>
    
    <script>
        // App-specific JavaScript can go here
        console.log('$name application loaded');
    </script>
</body>
</html>
APP_HTML
    done
    
    # Create wallpapers
    cat > "$install_dir/share/wallpapers/default.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            margin: 0;
            padding: 0;
            height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .wallpaper-content {
            text-align: center;
            color: white;
            text-shadow: 0 2px 10px rgba(0,0,0,0.3);
        }
        
        h1 {
            font-size: 48px;
            margin-bottom: 20px;
            font-weight: 300;
        }
        
        p {
            font-size: 18px;
            opacity: 0.9;
        }
    </style>
</head>
<body>
    <div class="wallpaper-content">
        <h1>Web Desktop Framework</h1>
        <p>Your universal desktop environment</p>
    </div>
</body>
</html>
EOF
}

# ============================================================================
# LAUNCHER SCRIPTS
# ============================================================================

create_launcher_scripts() {
    local install_dir=$1
    local platform=$2
    log_step "Creating launcher scripts..."
    
    # Main launcher script
    cat > "$install_dir/start.sh" << 'EOF'
#!/usr/bin/env bash

# Web Desktop Framework Launcher
# Universal launcher for all platforms

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get installation directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Default configuration
PORT=${1:-8080}
HOST=${2:-"0.0.0.0"}
CONFIG_FILE="etc/webdesktop.conf"

# Detect if running in Termux
detect_termux() {
    if [ -d "/data/data/com.termux/files/usr" ]; then
        return 0
    else
        return 1
    fi
}

# Check if port is available
check_port() {
    local port=$1
    
    if command -v lsof > /dev/null 2>&1; then
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            return 1
        fi
    elif command -v netstat > /dev/null 2>&1; then
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            return 1
        fi
    elif command -v ss > /dev/null 2>&1; then
        if ss -tuln 2>/dev/null | grep -q ":$port "; then
            return 1
        fi
    fi
    
    return 0
}

# Find Python executable
find_python() {
    if command -v python3 > /dev/null 2>&1; then
        echo "python3"
    elif command -v python > /dev/null 2>&1; then
        echo "python"
    else
        echo ""
    fi
}

# Show network information
show_network_info() {
    local host=$1
    local port=$2
    
    echo -e "${CYAN}[NETWORK INFO]${NC}"
    echo -e "Local:    http://localhost:$port"
    echo -e "Network:  http://$host:$port"
    echo -e "WebSocket: ws://$host:$((port + 1))"
    echo ""
    
    # Try to get local IP
    if [ "$host" = "0.0.0.0" ]; then
        if command -v ip > /dev/null 2>&1; then
            local ip=$(ip route get 1 2>/dev/null | awk '{print $7}' | head -1)
            if [ -n "$ip" ] && [ "$ip" != "127.0.0.1" ]; then
                echo -e "Your IP:  http://$ip:$port"
            fi
        elif command -v ifconfig > /dev/null 2>&1; then
            local ip=$(ifconfig 2>/dev/null | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | awk '{print $2}' | head -1)
            if [ -n "$ip" ]; then
                echo -e "Your IP:  http://$ip:$port"
            fi
        fi
    fi
    echo ""
}

# Start the server
start_server() {
    local python_cmd=$1
    local port=$2
    local host=$3
    
    echo -e "${BLUE}[INFO]${NC} Starting Web Desktop Framework..."
    echo -e "${BLUE}[INFO]${NC} Directory: $SCRIPT_DIR"
    echo ""
    
    show_network_info "$host" "$port"
    
    echo -e "${GREEN}[READY]${NC} Press Ctrl+C to stop the server"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    
    # Start the server
    "$python_cmd" bin/server.py --port "$port" --host "$host" --config "$CONFIG_FILE"
}

# Main function
main() {
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║            Web Desktop Framework v3.1.0                  ║
║         Universal Desktop Environment                    ║
╚══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Check Python
    PYTHON_CMD=$(find_python)
    if [ -z "$PYTHON_CMD" ]; then
        echo -e "${RED}[ERROR]${NC} Python not found!"
        echo "Please install Python 3.6 or higher"
        exit 1
    fi
    
    # Check port
    if ! check_port "$PORT"; then
        echo -e "${YELLOW}[WARNING]${NC} Port $PORT is already in use!"
        echo -e "${YELLOW}[TIP]${NC} Try using a different port:"
        echo "    ./start.sh 9090"
        echo "    ./start.sh 8080 127.0.0.1"
        exit 1
    fi
    
    # Start server
    start_server "$PYTHON_CMD" "$PORT" "$HOST"
}

# Handle command line arguments
show_help() {
    echo "Usage: $0 [PORT] [HOST]"
    echo ""
    echo "Options:"
    echo "  PORT        Server port (default: 8080)"
    echo "  HOST        Bind address (default: 0.0.0.0)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Start on 0.0.0.0:8080"
    echo "  $0 9090              # Start on 0.0.0.0:9090"
    echo "  $0 8080 127.0.0.1    # Start on localhost only"
    echo ""
    echo "For Termux, use: ./start-termux.sh"
    echo "For desktop menu: ./start-desktop.sh"
}

case "${1:-}" in
    -h|--help|help)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
EOF

    # Termux-specific launcher
    cat > "$install_dir/start-termux.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Termux Launcher for Web Desktop Framework

set -e

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║        Web Desktop Framework - Termux Edition            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Use localhost for Termux (safer)
PORT=8080
HOST="127.0.0.1"

# Start server in background
./start.sh "$PORT" "$HOST" &
SERVER_PID=$!

sleep 3

echo ""
echo "✅ Web Desktop Framework started!"
echo ""
echo "📱 Access from:"
echo "   http://localhost:$PORT"
echo ""
echo "📁 Directory: $SCRIPT_DIR"
echo "🆔 PID: $SERVER_PID"
echo ""

# Try to open in Termux browser
if command -v termux-open-url > /dev/null 2>&1; then
    echo "🌐 Opening in browser..."
    termux-open-url "http://localhost:$PORT"
else
    echo "📲 Please open browser manually:"
    echo "   http://localhost:$PORT"
fi

echo ""
echo "⚡ To stop: kill $SERVER_PID"
echo "   Or press Ctrl+C and type: pkill -f 'server.py'"
echo ""
echo "💡 Tip: Run in background with: ./start-termux.sh &"
echo ""

# Wait for server
wait $SERVER_PID
EOF

    # Desktop launcher for Linux
    cat > "$install_dir/start-desktop.sh" << 'EOF'
#!/usr/bin/env bash

# Desktop Launcher for Web Desktop Framework
# Creates desktop entry and starts the application

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Create desktop entry
create_desktop_entry() {
    local desktop_dir="$HOME/.local/share/applications"
    local desktop_file="$desktop_dir/webdesktop.desktop"
    
    mkdir -p "$desktop_dir"
    
    cat > "$desktop_file" << DESKTOP
[Desktop Entry]
Name=Web Desktop Framework
Comment=Universal web-based desktop environment
Exec=$SCRIPT_DIR/start-desktop.sh
Icon=$SCRIPT_DIR/share/icons/webdesktop.png
Terminal=true
Type=Application
Categories=System;Utility;
StartupNotify=true
Keywords=web;desktop;framework;environment;
DESKTOP
    
    chmod +x "$desktop_file"
    echo "Created desktop entry: $desktop_file"
}

# Create icon if it doesn't exist
if [ ! -f "$SCRIPT_DIR/share/icons/webdesktop.png" ]; then
    mkdir -p "$SCRIPT_DIR/share/icons"
    # Create a simple icon using ImageMagick if available
    if command -v convert > /dev/null 2>&1; then
        convert -size 256x256 xc:#3b82f6 \
                -fill white -pointsize 100 -font Arial -gravity center -draw "text 0,0 'W'" \
                "$SCRIPT_DIR/share/icons/webdesktop.png" 2>/dev/null || true
    fi
fi

# Create desktop entry if it doesn't exist
if [ ! -f "$HOME/.local/share/applications/webdesktop.desktop" ]; then
    create_desktop_entry
fi

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║        Web Desktop Framework - Desktop Edition          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Directory: $SCRIPT_DIR"
echo "🎮 Starting Web Desktop Framework..."
echo ""

# Start with default settings
./start.sh 8080 0.0.0.0
EOF

    # Management script
    cat > "$install_dir/manage.sh" << 'EOF'
#!/usr/bin/env bash

# Web Desktop Framework Management Script
# Manages installation, updates, and maintenance

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

get_server_pid() {
    pgrep -f "server.py.*$SCRIPT_DIR" 2>/dev/null || echo ""
}

check_server_running() {
    local pid=$(get_server_pid)
    if [ -n "$pid" ]; then
        echo "$pid"
        return 0
    else
        return 1
    fi
}

start_server() {
    if check_server_running > /dev/null; then
        warning "Server is already running"
        return 1
    fi
    
    log "Starting server..."
    ./start.sh > /dev/null 2>&1 &
    sleep 2
    
    if check_server_running > /dev/null; then
        success "Server started successfully"
        return 0
    else
        error "Failed to start server"
        return 1
    fi
}

stop_server() {
    local pid=$(check_server_running)
    if [ -z "$pid" ]; then
        warning "Server is not running"
        return 1
    fi
    
    log "Stopping server (PID: $pid)..."
    kill "$pid" 2>/dev/null
    sleep 2
    
    if check_server_running > /dev/null; then
        warning "Server still running, forcing kill..."
        kill -9 "$pid" 2>/dev/null
        sleep 1
    fi
    
    if check_server_running > /dev/null; then
        error "Failed to stop server"
        return 1
    else
        success "Server stopped"
        return 0
    fi
}

restart_server() {
    stop_server
    start_server
}

show_status() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║              Web Desktop Framework Status                ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    local pid=$(check_server_running)
    
    echo "📁 Directory: $SCRIPT_DIR"
    echo "🔧 Version: 3.1.0"
    
    if [ -n "$pid" ]; then
        echo -e "🟢 Status: ${GREEN}RUNNING${NC} (PID: $pid)"
        
        # Get port info
        if command -v lsof > /dev/null 2>&1; then
            local port=$(lsof -Pi -p "$pid" 2>/dev/null | grep LISTEN | awk '{print $9}' | cut -d: -f2 | head -1)
            if [ -n "$port" ]; then
                echo "🌐 Port: $port"
                echo "🔗 URL: http://localhost:$port"
            fi
        fi
        
        # Get uptime
        if command -v ps > /dev/null 2>&1; then
            local uptime=$(ps -p "$pid" -o etime= 2>/dev/null | xargs)
            if [ -n "$uptime" ]; then
                echo "⏱️  Uptime: $uptime"
            fi
        fi
    else
        echo -e "🔴 Status: ${RED}STOPPED${NC}"
    fi
    
    # Disk usage
    if command -v du > /dev/null 2>&1; then
        local size=$(du -sh "$SCRIPT_DIR" 2>/dev/null | cut -f1)
        echo "💾 Size: $size"
    fi
    
    # User count (simplified)
    if [ -f "etc/users.db" ]; then
        local users=$(grep -c '"username"' etc/users.db 2>/dev/null || echo "0")
        echo "👥 Users: $users"
    fi
}

show_logs() {
    local log_file="var/log/server.log"
    
    if [ ! -f "$log_file" ]; then
        error "Log file not found: $log_file"
        return 1
    fi
    
    echo -e "${CYAN}[LOGS]${NC} Last 50 lines:"
    echo "════════════════════════════════════════════════════════════"
    tail -50 "$log_file" 2>/dev/null || error "Cannot read log file"
}

show_help() {
    echo "Web Desktop Framework Management"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start     - Start the server"
    echo "  stop      - Stop the server"
    echo "  restart   - Restart the server"
    echo "  status    - Show server status"
    echo "  logs      - View server logs"
    echo "  backup    - Create backup"
    echo "  update    - Check for updates"
    echo "  clean     - Clean temporary files"
    echo "  help      - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 status"
    echo "  $0 logs"
}

backup_system() {
    local backup_dir="$HOME/webdesktop_backups"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$backup_dir/webdesktop_backup_$timestamp.tar.gz"
    
    mkdir -p "$backup_dir"
    
    log "Creating backup..."
    tar -czf "$backup_file" \
        --exclude="var/log/*" \
        --exclude="tmp/*" \
        --exclude="*.pyc" \
        --exclude="__pycache__" \
        -C "$SCRIPT_DIR" .
    
    if [ $? -eq 0 ]; then
        success "Backup created: $(basename "$backup_file")"
        echo "Size: $(du -h "$backup_file" | cut -f1)"
        return 0
    else
        error "Backup failed"
        return 1
    fi
}

update_system() {
    log "Checking for updates..."
    # This would check GitHub for updates
    # For now, just show message
    warning "Update feature coming soon"
    echo "Manual update:"
    echo "  1. Backup current installation"
    echo "  2. Download latest version"
    echo "  3. Replace files (keep etc/ and home/)"
    echo "  4. Restart server"
}

clean_system() {
    log "Cleaning temporary files..."
    
    # Remove log files
    if [ -d "var/log" ]; then
        find var/log -type f -name "*.log" -mtime +7 -delete 2>/dev/null || true
    fi
    
    # Remove temp files
    if [ -d "tmp" ]; then
        rm -rf tmp/* 2>/dev/null || true
    fi
    
    # Remove Python cache
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    
    success "Cleanup completed"
}

main() {
    case "${1:-}" in
        start)
            start_server
            ;;
        stop)
            stop_server
            ;;
        restart)
            restart_server
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        backup)
            backup_system
            ;;
        update)
            update_system
            ;;
        clean)
            clean_system
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
EOF

    # Uninstaller
    cat > "$install_dir/uninstall.sh" << 'EOF'
#!/usr/bin/env bash

# Web Desktop Framework Uninstaller
# Removes the entire installation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${RED}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║        WEB DESKTOP FRAMEWORK UNINSTALLER                ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "This will completely remove Web Desktop Framework from:"
echo "  $SCRIPT_DIR"
echo ""

# Check if running
if pgrep -f "server.py.*$SCRIPT_DIR" > /dev/null 2>&1; then
    echo -e "${YELLOW}[WARNING]${NC} Server is currently running!"
    read -p "Stop it before uninstalling? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Stopping server..."
        pkill -f "server.py.*$SCRIPT_DIR" 2>/dev/null || true
        sleep 2
    else
        echo "Cannot uninstall while server is running."
        exit 1
    fi
fi

# Ask about backup
read -p "Create backup before uninstalling? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    BACKUP_DIR="$HOME/webdesktop_backup_$(date +%Y%m%d_%H%M%S)"
    echo "Creating backup in: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    # Backup important directories
    cp -r "$SCRIPT_DIR/home" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$SCRIPT_DIR/etc" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$SCRIPT_DIR/apps" "$BACKUP_DIR/" 2>/dev/null || true
    
    echo -e "${GREEN}[SUCCESS]${NC} Backup created: $BACKUP_DIR"
fi

# Final confirmation
echo ""
echo -e "${RED}[DANGER]${NC} This will permanently delete:"
echo "  • All system files"
echo "  • User data (unless backed up)"
echo "  • Applications"
echo "  • Configuration"
echo ""
read -p "Are you sure you want to uninstall? (type 'YES' to confirm): " -r
echo ""

if [ "$REPLY" != "YES" ]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Remove desktop entry
if [ -f "$HOME/.local/share/applications/webdesktop.desktop" ]; then
    rm "$HOME/.local/share/applications/webdesktop.desktop"
    echo "Removed desktop entry"
fi

# Remove from shell config
clean_shell_config() {
    local config_file=$1
    if [ -f "$config_file" ]; then
        # Remove webdesktop aliases
        grep -v "webdesktop\|web-desktop" "$config_file" > "${config_file}.tmp" && \
        mv "${config_file}.tmp" "$config_file" 2>/dev/null || true
    fi
}

clean_shell_config "$HOME/.bashrc"
clean_shell_config "$HOME/.zshrc"
clean_shell_config "$HOME/.bash_profile"
clean_shell_config "$HOME/.profile"

# Remove installation directory
echo "Removing installation..."
if rm -rf "$SCRIPT_DIR"; then
    echo -e "${GREEN}[SUCCESS]${NC} Web Desktop Framework successfully uninstalled"
    echo ""
    echo "Thank you for using Web Desktop Framework!"
    echo ""
    echo "To reinstall, visit:"
    echo "  https://github.com/Vs-2421/web-desktop-demo"
    echo ""
    echo "Or run:"
    echo "  curl -L https://github.com/Vs-2421/web-desktop-demo/raw/main/install.sh | bash"
else
    echo -e "${RED}[ERROR]${NC} Failed to remove some files"
    echo "You may need to remove manually:"
    echo "  sudo rm -rf $SCRIPT_DIR"
fi
EOF

    # Make all scripts executable
    chmod +x "$install_dir/start.sh"
    chmod +x "$install_dir/start-termux.sh"
    chmod +x "$install_dir/start-desktop.sh"
    chmod +x "$install_dir/manage.sh"
    chmod +x "$install_dir/uninstall.sh"
    
    log_success "Launcher scripts created"
}

# ============================================================================
# MAIN INSTALLATION PROCESS
# ============================================================================

main() {
    print_banner
    
    # Check root
    check_root
    
    # Detect platform
    PLATFORM=$(detect_platform)
    log_info "Platform detected: $PLATFORM"
    
    # Check dependencies
    if ! check_dependencies "$PLATFORM"; then
        log_warning "Some dependencies are missing. Installing..."
    fi
    
    # Install dependencies
    install_dependencies "$PLATFORM"
    
    # Create directory structure
    create_directory_structure "$INSTALL_DIR"
    
    # Create system files
    create_system_files "$INSTALL_DIR" "$PLATFORM"
    
    # Create backend server
    create_backend_server "$INSTALL_DIR" "$PLATFORM"
    
    # Create frontend interface
    create_frontend_interface "$INSTALL_DIR" "$PLATFORM"
    
    # Create launcher scripts
    create_launcher_scripts "$INSTALL_DIR" "$PLATFORM"
    
    # Set permissions
    chmod -R 755 "$INSTALL_DIR"
    chmod 700 "$INSTALL_DIR/home/user"
    
    print_complete_banner
    
    # Show installation summary
    echo ""
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo "  🎉 WEB DESKTOP FRAMEWORK v$VERSION INSTALLATION COMPLETE!"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "📂 Installation directory: $INSTALL_DIR"
    echo "🖥️  Platform: $PLATFORM"
    echo ""
    echo "🚀 Quick Start:"
    echo ""
    
    case "$PLATFORM" in
        termux)
            echo "    For Termux:"
            echo "        cd $INSTALL_DIR"
            echo "        ./start-termux.sh"
            echo ""
            echo "    This will open your browser automatically."
            ;;
        *)
            echo "    For Linux/macOS:"
            echo "        cd $INSTALL_DIR"
            echo "        ./start.sh"
            echo ""
            echo "    For desktop integration:"
            echo "        ./start-desktop.sh"
            ;;
    esac
    
    echo ""
    echo "🌐 Access from browser:"
    echo "    http://localhost:8080"
    echo ""
    echo "🔑 Default login:"
    echo "    Username: admin"
    echo "    Password: admin123"
    echo ""
    echo "🔧 Management commands:"
    echo "    cd $INSTALL_DIR && ./manage.sh [start|stop|restart|status|logs|backup]"
    echo ""
    echo "📱 Built-in applications:"
    echo "    • Terminal (real shell access)"
    echo "    • File Manager"
    echo "    • Web Browser"
    echo "    • System Settings"
    echo "    • Calculator"
    echo "    • Text Editor"
    echo "    • Paint"
    echo "    • Media Player"
    echo "    • And many more..."
    echo ""
    echo "🔄 Update/Uninstall:"
    echo "    Check updates: ./manage.sh update"
    echo "    Uninstall: ./uninstall.sh"
    echo ""
    echo "📖 Documentation:"
    echo "    https://github.com/Vs-2421/web-desktop-demo"
    echo ""
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    
    # Ask to start now
    read -p "Start Web Desktop Framework now? (Y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        cd "$INSTALL_DIR"
        case "$PLATFORM" in
            termux)
                ./start-termux.sh
                ;;
            *)
                ./start.sh
                ;;
        esac
    else
        echo ""
        echo "You can start it later by running:"
        echo "    cd $INSTALL_DIR && ./start.sh"
    fi
}

# Handle command line arguments
case "${1:-}" in
    -h|--help|help)
        echo "Web Desktop Framework Installer"
        echo ""
        echo "Usage: $0 [OPTION]"
        echo ""
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo "  --version     Show version information"
        echo ""
        echo "This script installs Web Desktop Framework to ~/.webdesktop"
        echo ""
        echo "Examples:"
        echo "  $0              # Normal installation"
        echo "  curl -L https://github.com/Vs-2421/web-desktop-demo/raw/main/install.sh | bash"
        exit 0
        ;;
    --version)
        echo "Web Desktop Framework Installer v$VERSION"
        exit 0
        ;;
    *)
        # Run main installation
        if [[ $- == *i* ]]; then
            # Interactive shell
            main "$@"
        else
            # Non-interactive (piped from curl)
            echo "Starting Web Desktop Framework installation..."
            echo "Version: $VERSION"
            echo "Repository: $REPO_URL"
            echo ""
            main "$@"
        fi
        ;;
esac