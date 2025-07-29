#!/bin/bash

# {{ AURA-X:
# Action: "Added"
# Task_ID: "#55b71a3a-3e2d-4cb0-9d54-1f0b84c5f710"
# Timestamp: "2025-07-28T16:25:46+08:00"
# Authoring_Role: "LD"
# Principle_Applied: "SOLID-S (Single Responsibility Principle)"
# Approval: "inch stop (ID:2025-07-28T16:25:46+08:00)"
#}}

# {{START_MODIFICATIONS}}

#===============================================================================
# DockEase - Docker Container Management Tool
# Version: 1.0.0
# Description: A lightweight, dependency-free Docker management tool
# Author: AURA-X Development Team
# Created: 2025-07-28T16:25:46+08:00
#===============================================================================

set -uo pipefail  # Exit on undefined vars, pipe failures (but not on command errors)

#===============================================================================
# GLOBAL VARIABLES AND CONFIGURATION
#===============================================================================

readonly SCRIPT_NAME="DockEase"
readonly SCRIPT_VERSION="1.0.0"
readonly CONFIG_FILE=".dockease.json"
readonly LOG_FILE=".dockease.log"

#===============================================================================
# COLOR DEFINITIONS AND STYLING
#===============================================================================

# ANSI Color Codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m' # No Color

# Symbols
readonly CHECK_MARK="✅"
readonly CROSS_MARK="❌"
readonly WARNING="⚠️"
readonly INFO="ℹ️"
readonly DOCKER_ICON="🐳"
readonly GEAR_ICON="⚙️"
readonly CLEAN_ICON="🧹"
readonly BUILD_ICON="🔨"

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================

# Print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}" >&2
}

# Print success message
print_success() {
    print_color "$GREEN" "${CHECK_MARK} $1"
}

# Print error message
print_error() {
    print_color "$RED" "${CROSS_MARK} $1"
}

# Print warning message
print_warning() {
    print_color "$YELLOW" "${WARNING} $1"
}

# Print info message
print_info() {
    print_color "$CYAN" "${INFO} $1"
}

# Print header with styling
print_header() {
    local title=$1
    echo
    print_color "$BLUE" "═══════════════════════════════════════════════════════════════"
    print_color "$WHITE" "  ${DOCKER_ICON} ${title}"
    print_color "$BLUE" "═══════════════════════════════════════════════════════════════"
    echo
}

# Print separator
print_separator() {
    print_color "$DIM" "───────────────────────────────────────────────────────────────"
}

#===============================================================================
# LOGGING FUNCTIONS
#===============================================================================

# Log message with timestamp
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Log info
log_info() {
    log_message "INFO" "$1"
}

# Log error
log_error() {
    log_message "ERROR" "$1"
}

# Log warning
log_warning() {
    log_message "WARNING" "$1"
}

#===============================================================================
# SYSTEM CHECK FUNCTIONS
#===============================================================================

# Check if Docker is installed and running
check_docker() {
    print_info "Checking Docker installation..."

    if ! command -v docker &> /dev/null; then
        show_error_help "docker_not_installed"
        log_error "Docker not found in PATH"
        return 1
    fi

    if ! docker info &> /dev/null; then
        show_error_help "docker_not_running"
        log_error "Docker daemon not running"
        return 1
    fi

    print_success "Docker is installed and running"
    log_info "Docker check passed"
    return 0
}

# Check if jq is available for JSON processing
check_jq() {
    if command -v jq &> /dev/null; then
        print_success "jq is available for enhanced JSON processing"
        return 0
    else
        show_error_help "jq_not_available"
        log_warning "jq not available, using fallback parsing"
        return 1
    fi
}

#===============================================================================
# ERROR HANDLING
#===============================================================================

# Error handler
error_handler() {
    local line_number=$1
    print_error "An error occurred on line $line_number"
    log_error "Script error on line $line_number"
    exit 1
}

# Set error trap
trap 'error_handler $LINENO' ERR

#===============================================================================
# MAIN MENU FUNCTIONS
#===============================================================================

# Display main menu
show_main_menu() {
    clear
    print_header "$SCRIPT_NAME v$SCRIPT_VERSION - Docker Management Tool"
    
    print_color "$WHITE" "  ${GEAR_ICON} Container Management:"
    echo "    1) List containers"
    echo "    2) Start containers"
    echo "    3) Stop containers"
    echo "    4) Restart containers"
    echo "    5) Remove containers"
    echo "    6) Quick remove (stop + rm)"
    echo

    print_color "$WHITE" "  ${DOCKER_ICON} Image Management:"
    echo "    7) List images"
    echo "    8) Pull image updates"
    echo "    9) Remove images"
    echo "   10) Clean unused images"
    echo

    print_color "$WHITE" "  ${BUILD_ICON} Build Management:"
    echo "   11) Add build configuration"
    echo "   12) One-click rebuild"
    echo "   13) Manage build configs"
    echo

    print_color "$WHITE" "  ${CLEAN_ICON} System Cleanup:"
    echo "   14) Clean dangling images"
    echo "   15) System prune"
    echo "   16) Full cleanup"
    echo

    print_color "$WHITE" "  ${GEAR_ICON} Settings:"
    echo "   17) View configuration"
    echo "   18) Reset configuration"
    echo "   19) View logs"
    echo

    print_color "$WHITE" "  ${INFO} Help & Info:"
    echo "   20) Show help"
    echo "   21) About DockEase"
    echo

    print_color "$DIM" "   0) Exit"
    echo
    print_separator

    # Show quick tips
    print_color "$DIM" "💡 Quick Tips:"
    print_color "$DIM" "   • Use 'Add build configuration' to save your Docker commands"
    print_color "$DIM" "   • 'One-click rebuild' automates the full update process"
    print_color "$DIM" "   • Regular cleanup helps maintain system performance"
    echo
}



#===============================================================================
# INITIALIZATION AND CLEANUP
#===============================================================================

# Initialize script
initialize() {
    log_info "Starting $SCRIPT_NAME v$SCRIPT_VERSION"
    
    # Check system requirements
    if ! check_docker; then
        exit 1
    fi
    
    check_jq
    
    # Create config file if it doesn't exist
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_info "Creating default configuration file..."
        create_default_config
    fi
    
    print_success "Initialization complete"

    # Show welcome message on first run
    if [[ ! -f ".dockease_welcome_shown" ]]; then
        echo
        echo "🎉 Welcome to DockEase!"
        echo "ℹ️ This appears to be your first time using DockEase."
        echo "ℹ️ Type '20' for help or '21' for more information about DockEase."
        echo
        touch ".dockease_welcome_shown"
        sleep 2
    fi
}

# Cleanup on exit
cleanup() {
    log_info "Exiting $SCRIPT_NAME"
    print_info "Thank you for using $SCRIPT_NAME!"
    exit 0
}

# Set exit trap
trap cleanup EXIT

#===============================================================================
# CONFIGURATION MANAGEMENT FUNCTIONS
#===============================================================================

# {{ AURA-X:
# Action: "Modified"
# Task_ID: "#789e56e7-72bb-4ac3-8c67-243777b20bf2"
# Timestamp: "2025-07-28T16:27:35+08:00"
# Authoring_Role: "LD"
# Principle_Applied: "SOLID-S (Single Responsibility Principle)"
# Approval: "inch stop (ID:2025-07-28T16:27:35+08:00)"
#}}

# Create default configuration file
create_default_config() {
    print_info "Creating default configuration file..."

    local default_config='{
  "containers": {
    "example-app": {
      "image": "nginx:latest",
      "build_cmd": "docker build -t example-app:latest .",
      "run_cmd": "docker run -d --name example-app -p 8080:80 example-app:latest",
      "description": "Example application configuration"
    }
  },
  "settings": {
    "auto_backup": true,
    "log_level": "info",
    "backup_count": 5,
    "created": "'$(date -Iseconds)'"
  },
  "version": "1.0.0"
}'

    if echo "$default_config" > "$CONFIG_FILE"; then
        print_success "Default configuration created: $CONFIG_FILE"
        log_info "Default configuration file created"
    else
        print_error "Failed to create configuration file"
        log_error "Failed to create configuration file"
        return 1
    fi
}

# Backup configuration file
backup_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        local backup_file="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        if cp "$CONFIG_FILE" "$backup_file"; then
            print_success "Configuration backed up to: $backup_file"
            log_info "Configuration backed up to $backup_file"

            # Keep only the last 5 backups
            local backup_count=$(ls -1 "${CONFIG_FILE}.backup."* 2>/dev/null | wc -l)
            if [[ $backup_count -gt 5 ]]; then
                ls -1t "${CONFIG_FILE}.backup."* | tail -n +6 | xargs rm -f
                print_info "Old backups cleaned up"
            fi
        else
            print_warning "Failed to backup configuration"
            log_warning "Failed to backup configuration"
        fi
    fi
}

# Validate JSON configuration file
validate_config() {
    local config_file=${1:-$CONFIG_FILE}

    if [[ ! -f "$config_file" ]]; then
        print_error "Configuration file not found: $config_file"
        return 1
    fi

    # Try to validate with jq if available
    if command -v jq &> /dev/null; then
        if jq empty "$config_file" 2>/dev/null; then
            return 0
        else
            print_error "Invalid JSON format in configuration file"
            log_error "Invalid JSON format in $config_file"
            return 1
        fi
    else
        # Basic validation without jq
        if python3 -c "import json; json.load(open('$config_file'))" 2>/dev/null; then
            return 0
        elif python -c "import json; json.load(open('$config_file'))" 2>/dev/null; then
            return 0
        else
            print_error "Invalid JSON format in configuration file"
            log_error "Invalid JSON format in $config_file (no jq/python available)"
            return 1
        fi
    fi
}

# Read configuration value using jq or fallback
read_config() {
    local key=$1
    local config_file=${2:-$CONFIG_FILE}

    if [[ ! -f "$config_file" ]]; then
        print_error "Configuration file not found: $config_file"
        return 1
    fi

    if ! validate_config "$config_file"; then
        return 1
    fi

    # Use jq if available
    if command -v jq &> /dev/null; then
        jq -r "$key // empty" "$config_file" 2>/dev/null
    else
        # Fallback: simple grep-based extraction for basic keys
        case "$key" in
            ".settings.auto_backup")
                grep -o '"auto_backup"[[:space:]]*:[[:space:]]*[^,}]*' "$config_file" | sed 's/.*:[[:space:]]*//' | tr -d '"'
                ;;
            ".settings.log_level")
                grep -o '"log_level"[[:space:]]*:[[:space:]]*"[^"]*"' "$config_file" | sed 's/.*:[[:space:]]*"//' | sed 's/"$//'
                ;;
            *)
                print_warning "Complex key extraction requires jq: $key"
                return 1
                ;;
        esac
    fi
}

# Write configuration value
write_config() {
    local key=$1
    local value=$2
    local config_file=${3:-$CONFIG_FILE}

    if [[ ! -f "$config_file" ]]; then
        print_error "Configuration file not found: $config_file"
        return 1
    fi

    # Backup before modification
    backup_config

    # Use jq if available
    if command -v jq &> /dev/null; then
        local temp_file=$(mktemp)
        if jq "$key = \"$value\"" "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"; then
            print_success "Configuration updated: $key = $value"
            log_info "Configuration updated: $key = $value"
        else
            print_error "Failed to update configuration"
            log_error "Failed to update configuration: $key = $value"
            rm -f "$temp_file"
            return 1
        fi
    else
        print_warning "Configuration modification requires jq for complex operations"
        return 1
    fi
}

# List all container configurations
list_container_configs() {
    print_header "Container Configurations"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_warning "No configuration file found"
        return 1
    fi

    if ! validate_config; then
        return 1
    fi

    if command -v jq &> /dev/null; then
        local containers=$(jq -r '.containers | keys[]' "$CONFIG_FILE" 2>/dev/null)

        if [[ -z "$containers" ]]; then
            print_info "No container configurations found"
            return 0
        fi

        local count=1
        while IFS= read -r container; do
            local image=$(jq -r ".containers.\"$container\".image" "$CONFIG_FILE")
            local description=$(jq -r ".containers.\"$container\".description // \"No description\"" "$CONFIG_FILE")

            print_color "$WHITE" "  $count) $container"
            print_color "$DIM" "     Image: $image"
            print_color "$DIM" "     Description: $description"
            echo
            ((count++))
        done <<< "$containers"
    else
        print_warning "Listing configurations requires jq"
        return 1
    fi
}

# Add new container configuration
add_container_config() {
    local name=$1
    local image=$2
    local build_cmd=$3
    local run_cmd=$4
    local description=$5

    if [[ -z "$name" || -z "$image" ]]; then
        print_error "Container name and image are required"
        return 1
    fi

    if ! validate_config; then
        return 1
    fi

    # Backup before modification
    backup_config

    if command -v jq &> /dev/null; then
        local temp_file=$(mktemp)

        # Use jq --arg to safely pass variables (avoids JSON escaping issues)
        if jq --arg name "$name" \
              --arg image "$image" \
              --arg build_cmd "${build_cmd:-}" \
              --arg run_cmd "${run_cmd:-}" \
              --arg description "${description:-}" \
              --arg created "$(date -Iseconds)" \
              '.containers[$name] = {
                  "image": $image,
                  "build_cmd": $build_cmd,
                  "run_cmd": $run_cmd,
                  "description": $description,
                  "created": $created
              }' "$CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$CONFIG_FILE"; then
            print_success "Container configuration added: $name"
            log_info "Container configuration added: $name"
        else
            print_error "Failed to add container configuration"
            log_error "Failed to add container configuration: $name"
            rm -f "$temp_file"
            return 1
        fi
    else
        print_warning "Adding configurations requires jq"
        return 1
    fi
}

# Remove container configuration
remove_container_config() {
    local name=$1

    if [[ -z "$name" ]]; then
        print_error "Container name is required"
        return 1
    fi

    if ! validate_config; then
        return 1
    fi

    # Check if container exists
    if command -v jq &> /dev/null; then
        if ! jq -e ".containers.\"$name\"" "$CONFIG_FILE" >/dev/null 2>&1; then
            print_error "Container configuration not found: $name"
            return 1
        fi

        # Backup before modification
        backup_config

        local temp_file=$(mktemp)
        if jq "del(.containers.\"$name\")" "$CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$CONFIG_FILE"; then
            print_success "Container configuration removed: $name"
            log_info "Container configuration removed: $name"
        else
            print_error "Failed to remove container configuration"
            log_error "Failed to remove container configuration: $name"
            rm -f "$temp_file"
            return 1
        fi
    else
        print_warning "Removing configurations requires jq"
        return 1
    fi
}

# Get container configuration
get_container_config() {
    local name=$1
    local field=$2

    if [[ -z "$name" ]]; then
        print_error "Container name is required"
        return 1
    fi

    if ! validate_config; then
        return 1
    fi

    if command -v jq &> /dev/null; then
        if [[ -n "$field" ]]; then
            jq -r ".containers.\"$name\".\"$field\" // empty" "$CONFIG_FILE" 2>/dev/null
        else
            jq -r ".containers.\"$name\" // empty" "$CONFIG_FILE" 2>/dev/null
        fi
    else
        print_warning "Getting configurations requires jq"
        return 1
    fi
}

#===============================================================================
# CONTAINER LIFECYCLE MANAGEMENT FUNCTIONS
#===============================================================================

# {{ AURA-X:
# Action: "Added"
# Task_ID: "#85c49ac9-dba3-4abe-8c13-a7570b492d4a"
# Timestamp: "2025-07-28T16:30:12+08:00"
# Authoring_Role: "LD"
# Principle_Applied: "SOLID-S (Single Responsibility Principle)"
# Approval: "inch stop (ID:2025-07-28T16:30:12+08:00)"
#}}

# List all containers with status
list_containers() {
    local show_all=${1:-false}

    print_header "Docker Containers"

    if ! docker info &>/dev/null; then
        print_error "Docker daemon is not running"
        return 1
    fi

    local docker_cmd="docker ps"
    if [[ "$show_all" == "true" ]]; then
        docker_cmd="docker ps -a"
        print_info "Showing all containers (running and stopped)"
    else
        print_info "Showing running containers only"
    fi

    local containers
    containers=$($docker_cmd --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null)

    if [[ -z "$containers" || "$containers" == *"CONTAINER ID"* && $(echo "$containers" | wc -l) -eq 1 ]]; then
        print_warning "No containers found"
        return 0
    fi

    echo "$containers"
    echo

    # Show container count
    local count=$(echo "$containers" | tail -n +2 | wc -l)
    print_info "Total containers: $count"
}

# Select containers interactively
select_containers() {
    local show_all=${1:-false}
    local prompt=${2:-"Select containers"}

    if ! docker info &>/dev/null; then
        print_error "Docker daemon is not running"
        return 1
    fi

    local docker_cmd="docker ps"
    if [[ "$show_all" == "true" ]]; then
        docker_cmd="docker ps -a"
    fi

    local containers
    containers=$($docker_cmd --format "{{.ID}}:{{.Names}}:{{.Image}}:{{.Status}}" 2>/dev/null)

    if [[ -z "$containers" ]]; then
        print_warning "No containers found"
        return 1
    fi

    print_header "$prompt"

    local -a container_array
    local count=1

    while IFS=':' read -r id name image status; do
        # Skip empty lines or invalid entries
        if [[ -n "$id" && "$id" != "" ]]; then
            container_array+=("$id:$name")
            echo "  $count) $name ($id)" >&2
            echo "     Image: $image" >&2
            echo "     Status: $status" >&2
            echo >&2
            ((count++))
        fi
    done <<< "$containers"

    echo "  0) Cancel" >&2
    echo >&2
    echo "───────────────────────────────────────────────────────────────" >&2

    local selected_containers=()

    while true; do
        echo -n "Enter container numbers (space-separated) or 'all' for all containers: " >&2
        read -r selection

        if [[ "$selection" == "0" ]]; then
            print_info "Operation cancelled"
            return 1
        elif [[ "$selection" == "all" ]]; then
            for container in "${container_array[@]}"; do
                selected_containers+=("$container")
            done
            break
        else
            selected_containers=()
            for num in $selection; do
                if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -ge 1 ]] && [[ $num -le ${#container_array[@]} ]]; then
                    selected_containers+=("${container_array[$((num-1))]}")
                else
                    print_error "Invalid selection: $num"
                    continue 2
                fi
            done
            break
        fi
    done

    # Return selected container IDs
    for container in "${selected_containers[@]}"; do
        local id="${container%%:*}"
        # Only return non-empty IDs
        if [[ -n "$id" ]]; then
            echo "$id"
        fi
    done
}

# Stop containers
stop_containers() {
    print_header "Stop Containers"



    local container_ids
    container_ids=$(select_containers false "Select containers to stop")

    if [[ $? -ne 0 || -z "$container_ids" ]]; then
        return 1
    fi

    print_warning "About to stop the following containers:"
    while IFS= read -r id; do
        # Skip empty IDs
        if [[ -n "$id" && "$id" != "" ]]; then
            local name=$(docker inspect --format '{{.Name}}' "$id" 2>/dev/null | sed 's/^\/*//')
            if [[ -n "$name" ]]; then
                echo "  - $name ($id)"
            else
                echo "  - Container ID: $id"
            fi
        fi
    done <<< "$container_ids"

    echo
    echo -n "Are you sure? (y/N): "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled"
        return 0
    fi

    local success_count=0
    local total_count=0

    while IFS= read -r id; do
        # Skip empty IDs
        if [[ -n "$id" && "$id" != "" ]]; then
            ((total_count++))
            local name=$(docker inspect --format '{{.Name}}' "$id" 2>/dev/null | sed 's/^\/*//')

            if [[ -n "$name" ]]; then
                print_info "Stopping container: $name ($id)"
            else
                print_info "Stopping container: $id"
            fi

            if docker stop "$id" &>/dev/null; then
                if [[ -n "$name" ]]; then
                    print_success "Stopped: $name"
                    log_info "Container stopped: $name ($id)"
                else
                    print_success "Stopped: $id"
                    log_info "Container stopped: $id"
                fi
                ((success_count++))
            else
                if [[ -n "$name" ]]; then
                    print_error "Failed to stop: $name"
                    log_error "Failed to stop container: $name ($id)"
                else
                    print_error "Failed to stop: $id"
                    log_error "Failed to stop container: $id"
                fi
            fi
        fi
    done <<< "$container_ids"

    print_separator
    print_info "Operation completed: $success_count/$total_count containers stopped"
}

# Remove containers
remove_containers() {
    print_header "Remove Containers"

    local container_ids
    container_ids=$(select_containers true "Select containers to remove")

    if [[ $? -ne 0 || -z "$container_ids" ]]; then
        return 1
    fi

    print_warning "About to PERMANENTLY REMOVE the following containers:"
    while IFS= read -r id; do
        # Skip empty IDs
        if [[ -n "$id" && "$id" != "" ]]; then
            local name=$(docker inspect --format '{{.Name}}' "$id" 2>/dev/null | sed 's/^\/*//')
            if [[ -n "$name" ]]; then
                echo "  - $name ($id)"
            else
                echo "  - Container ID: $id"
            fi
        fi
    done <<< "$container_ids"

    echo
    print_warning "This action cannot be undone!"
    echo -n "Are you sure? (y/N): "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled"
        return 0
    fi

    local success_count=0
    local total_count=0

    while IFS= read -r id; do
        # Skip empty IDs
        if [[ -n "$id" && "$id" != "" ]]; then
            ((total_count++))
            local name=$(docker inspect --format '{{.Name}}' "$id" 2>/dev/null | sed 's/^\/*//')

            if [[ -n "$name" ]]; then
                print_info "Removing container: $name ($id)"
            else
                print_info "Removing container: $id"
            fi

            if docker rm "$id" &>/dev/null; then
                if [[ -n "$name" ]]; then
                    print_success "Removed: $name"
                    log_info "Container removed: $name ($id)"
                else
                    print_success "Removed: $id"
                    log_info "Container removed: $id"
                fi
                ((success_count++))
            else
                if [[ -n "$name" ]]; then
                    print_error "Failed to remove: $name"
                    log_error "Failed to remove container: $name ($id)"
                else
                    print_error "Failed to remove: $id"
                    log_error "Failed to remove container: $id"
                fi
            fi
        fi
    done <<< "$container_ids"

    print_separator
    print_info "Operation completed: $success_count/$total_count containers removed"
}

# Quick remove containers (stop + remove)
quick_remove_containers() {
    print_header "Quick Remove Containers (Stop + Remove)"

    local container_ids
    container_ids=$(select_containers false "Select running containers to stop and remove")

    if [[ $? -ne 0 || -z "$container_ids" ]]; then
        return 1
    fi

    print_warning "About to STOP and PERMANENTLY REMOVE the following containers:"
    while IFS= read -r id; do
        # Skip empty IDs
        if [[ -n "$id" && "$id" != "" ]]; then
            local name=$(docker inspect --format '{{.Name}}' "$id" 2>/dev/null | sed 's/^\/*//')
            if [[ -n "$name" ]]; then
                echo "  - $name ($id)"
            else
                echo "  - Container ID: $id"
            fi
        fi
    done <<< "$container_ids"

    echo
    print_warning "This action cannot be undone!"
    echo -n "Are you sure? (y/N): "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled"
        return 0
    fi

    local success_count=0
    local total_count=0

    while IFS= read -r id; do
        # Skip empty IDs
        if [[ -n "$id" && "$id" != "" ]]; then
            ((total_count++))
            local name=$(docker inspect --format '{{.Name}}' "$id" 2>/dev/null | sed 's/^\/*//')

            if [[ -n "$name" ]]; then
                print_info "Quick removing container: $name ($id)"
            else
                print_info "Quick removing container: $id"
            fi

            # Stop first, then remove
            if docker stop "$id" &>/dev/null && docker rm "$id" &>/dev/null; then
                if [[ -n "$name" ]]; then
                    print_success "Quick removed: $name"
                    log_info "Container quick removed: $name ($id)"
                else
                    print_success "Quick removed: $id"
                    log_info "Container quick removed: $id"
                fi
                ((success_count++))
            else
                if [[ -n "$name" ]]; then
                    print_error "Failed to quick remove: $name"
                    log_error "Failed to quick remove container: $name ($id)"
                else
                    print_error "Failed to quick remove: $id"
                    log_error "Failed to quick remove container: $id"
                fi
            fi
        fi
    done <<< "$container_ids"

    print_separator
    print_info "Operation completed: $success_count/$total_count containers quick removed"
}

# Restart containers
restart_containers() {
    print_header "Restart Containers"

    local container_ids
    container_ids=$(select_containers false "Select running containers to restart")

    if [[ $? -ne 0 || -z "$container_ids" ]]; then
        return 1
    fi

    print_info "About to restart the following containers:"
    while IFS= read -r id; do
        # Skip empty IDs
        if [[ -n "$id" && "$id" != "" ]]; then
            local name=$(docker inspect --format '{{.Name}}' "$id" 2>/dev/null | sed 's/^\/*//')
            if [[ -n "$name" ]]; then
                echo "  - $name ($id)"
            else
                echo "  - Container ID: $id"
            fi
        fi
    done <<< "$container_ids"

    echo
    echo -n "Are you sure? (y/N): "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled"
        return 0
    fi

    local success_count=0
    local total_count=0

    while IFS= read -r id; do
        # Skip empty IDs
        if [[ -n "$id" && "$id" != "" ]]; then
            ((total_count++))
            local name=$(docker inspect --format '{{.Name}}' "$id" 2>/dev/null | sed 's/^\/*//')

            if [[ -n "$name" ]]; then
                print_info "Restarting container: $name ($id)"
            else
                print_info "Restarting container: $id"
            fi

            if docker restart "$id" &>/dev/null; then
                if [[ -n "$name" ]]; then
                    print_success "Restarted: $name"
                    log_info "Container restarted: $name ($id)"
                else
                    print_success "Restarted: $id"
                    log_info "Container restarted: $id"
                fi
                ((success_count++))
            else
                if [[ -n "$name" ]]; then
                    print_error "Failed to restart: $name"
                    log_error "Failed to restart container: $name ($id)"
                else
                    print_error "Failed to restart: $id"
                    log_error "Failed to restart container: $id"
                fi
            fi
        fi
    done <<< "$container_ids"

    print_separator
    print_info "Operation completed: $success_count/$total_count containers restarted"
}

# Start stopped containers
start_containers() {
    print_header "Start Containers"

    # Get only stopped containers
    local stopped_containers
    stopped_containers=$(docker ps -a --filter "status=exited" --format "{{.ID}}:{{.Names}}:{{.Image}}:{{.Status}}" 2>/dev/null)

    if [[ -z "$stopped_containers" ]]; then
        print_warning "No stopped containers found"
        return 0
    fi

    print_info "Select stopped containers to start:"

    local -a container_array
    local count=1

    while IFS=':' read -r id name image status; do
        container_array+=("$id:$name")
        echo "  $count) $name ($id)"
        echo "     Image: $image"
        echo "     Status: $status"
        echo
        ((count++))
    done <<< "$stopped_containers"

    echo "  0) Cancel"
    echo
    echo "───────────────────────────────────────────────────────────────"

    local selected_containers=()

    while true; do
        echo -n "Enter container numbers (space-separated) or 'all' for all containers: "
        read -r selection

        if [[ "$selection" == "0" ]]; then
            print_info "Operation cancelled"
            return 1
        elif [[ "$selection" == "all" ]]; then
            for container in "${container_array[@]}"; do
                selected_containers+=("${container%%:*}")
            done
            break
        else
            selected_containers=()
            for num in $selection; do
                if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -ge 1 ]] && [[ $num -le ${#container_array[@]} ]]; then
                    selected_containers+=("${container_array[$((num-1))]%%:*}")
                else
                    print_error "Invalid selection: $num"
                    continue 2
                fi
            done
            break
        fi
    done

    local success_count=0
    local total_count=${#selected_containers[@]}

    for id in "${selected_containers[@]}"; do
        local name=$(docker inspect --format '{{.Name}}' "$id" 2>/dev/null | sed 's/^\/*//')

        print_info "Starting container: $name ($id)"

        if docker start "$id" &>/dev/null; then
            print_success "Started: $name"
            log_info "Container started: $name ($id)"
            ((success_count++))
        else
            print_error "Failed to start: $name"
            log_error "Failed to start container: $name ($id)"
        fi
    done

    print_separator
    print_info "Operation completed: $success_count/$total_count containers started"
}

#===============================================================================
# IMAGE MANAGEMENT FUNCTIONS
#===============================================================================

# {{ AURA-X:
# Action: "Added"
# Task_ID: "#4121b25c-0324-427a-b2a1-5b6f5793f1c2"
# Timestamp: "2025-07-28T16:38:00+08:00"
# Authoring_Role: "LD"
# Principle_Applied: "SOLID-S (Single Responsibility Principle)"
# Approval: "inch stop (ID:2025-07-28T16:38:00+08:00)"
#}}

# List all Docker images with detailed information
list_images() {
    print_header "Docker Images"

    if ! docker info &>/dev/null; then
        print_error "Docker daemon is not running"
        return 1
    fi

    local images
    images=$(docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}" 2>/dev/null)

    if [[ -z "$images" || "$images" == *"REPOSITORY"* && $(echo "$images" | wc -l) -eq 1 ]]; then
        print_warning "No images found"
        return 0
    fi

    echo "$images"
    echo

    # Show image statistics
    local total_images=$(docker images -q | wc -l)
    local total_size=$(docker images --format "{{.Size}}" | grep -o '[0-9.]*[KMGT]*B' | head -1)
    local dangling_images=$(docker images -f "dangling=true" -q | wc -l)

    print_info "Total images: $total_images"
    print_info "Dangling images: $dangling_images"

    # Calculate total disk usage
    local disk_usage=$(docker system df --format "{{.Type}}\t{{.TotalCount}}\t{{.Size}}" | grep "Images" | awk '{print $3}')
    if [[ -n "$disk_usage" ]]; then
        print_info "Total disk usage: $disk_usage"
    fi
}

# Select images interactively
select_images() {
    local filter=${1:-""}
    local prompt=${2:-"Select images"}

    if ! docker info &>/dev/null; then
        print_error "Docker daemon is not running"
        return 1
    fi

    local docker_cmd="docker images"
    if [[ "$filter" == "dangling" ]]; then
        docker_cmd="docker images -f dangling=true"
        prompt="Select dangling images"
    fi

    local images
    images=$($docker_cmd --format "{{.Repository}}:{{.Tag}}:{{.ID}}:{{.CreatedSince}}:{{.Size}}" 2>/dev/null)

    if [[ -z "$images" ]]; then
        print_warning "No images found"
        return 1
    fi

    print_header "$prompt"

    local -a image_array
    local count=1

    while IFS=':' read -r repo tag id created size; do
        if [[ "$repo" == "<none>" && "$tag" == "<none>" ]]; then
            image_array+=("$id")
            echo "  $count) <dangling> ($id)" >&2
        else
            image_array+=("$id")
            echo "  $count) $repo:$tag ($id)" >&2
        fi
        echo "     Created: $created" >&2
        echo "     Size: $size" >&2
        echo >&2
        ((count++))
    done <<< "$images"

    echo "  0) Cancel" >&2
    echo >&2
    echo "───────────────────────────────────────────────────────────────" >&2

    local selected_images=()

    while true; do
        echo -n "Enter image numbers (space-separated) or 'all' for all images: " >&2
        read -r selection

        if [[ "$selection" == "0" ]]; then
            print_info "Operation cancelled"
            return 1
        elif [[ "$selection" == "all" ]]; then
            for image in "${image_array[@]}"; do
                selected_images+=("$image")
            done
            break
        else
            selected_images=()
            for num in $selection; do
                if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -ge 1 ]] && [[ $num -le ${#image_array[@]} ]]; then
                    selected_images+=("${image_array[$((num-1))]}")
                else
                    print_error "Invalid selection: $num"
                    continue 2
                fi
            done
            break
        fi
    done

    # Return selected image IDs
    for image in "${selected_images[@]}"; do
        echo "$image"
    done
}

# Pull image updates
pull_images() {
    print_header "Pull Image Updates"

    print_info "Enter image names to pull (one per line, empty line to finish):"
    print_color "$DIM" "Examples: nginx:latest, ubuntu:20.04, node:16"
    echo

    local images_to_pull=()

    while true; do
        echo -n "$(print_color "$CYAN" "Image name: ")"
        read -r image_name

        if [[ -z "$image_name" ]]; then
            break
        fi

        images_to_pull+=("$image_name")
        print_success "Added: $image_name"
    done

    if [[ ${#images_to_pull[@]} -eq 0 ]]; then
        print_warning "No images specified"
        return 0
    fi

    print_separator
    print_info "About to pull the following images:"
    for image in "${images_to_pull[@]}"; do
        echo "  - $image"
    done

    echo
    echo -n "Continue? (y/N): "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled"
        return 0
    fi

    local success_count=0
    local total_count=${#images_to_pull[@]}

    for image in "${images_to_pull[@]}"; do
        print_info "Pulling image: $image"

        if docker pull "$image" 2>/dev/null; then
            print_success "Pulled: $image"
            log_info "Image pulled: $image"
            ((success_count++))
        else
            print_error "Failed to pull: $image"
            log_error "Failed to pull image: $image"
        fi
    done

    print_separator
    print_info "Operation completed: $success_count/$total_count images pulled"
}

# Remove selected images
remove_images() {
    print_header "Remove Images"

    local image_ids
    image_ids=$(select_images "" "Select images to remove")

    if [[ $? -ne 0 || -z "$image_ids" ]]; then
        return 1
    fi

    print_warning "About to PERMANENTLY REMOVE the following images:"
    while IFS= read -r id; do
        echo "  - Image ID: $id"
    done <<< "$image_ids"

    echo
    print_warning "This action cannot be undone!"
    echo -n "Are you sure? (y/N): "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled"
        return 0
    fi

    local success_count=0
    local total_count=0

    while IFS= read -r id; do
        ((total_count++))

        print_info "Removing image: $id"

        if docker rmi "$id" &>/dev/null; then
            print_success "Removed: $id"
            log_info "Image removed: $id"
            ((success_count++))
        else
            print_error "Failed to remove: $id"
            log_error "Failed to remove image: $id"
        fi
    done <<< "$image_ids"

    print_separator
    print_info "Operation completed: $success_count/$total_count images removed"
}

# Clean dangling images
clean_dangling_images() {
    print_header "Clean Dangling Images"

    # Get dangling images count and size before cleanup
    local dangling_count=$(docker images -f "dangling=true" -q | wc -l)

    if [[ $dangling_count -eq 0 ]]; then
        print_success "No dangling images found"
        return 0
    fi

    print_info "Found $dangling_count dangling image(s)"

    # Show dangling images
    print_info "Dangling images:"
    docker images -f "dangling=true" --format "table {{.ID}}\t{{.CreatedSince}}\t{{.Size}}"
    echo

    echo -n "Remove all dangling images? (y/N): "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled"
        return 0
    fi

    print_info "Cleaning dangling images..."

    local cleanup_output
    cleanup_output=$(docker image prune -f 2>&1)

    if [[ $? -eq 0 ]]; then
        print_success "Dangling images cleaned"

        # Extract reclaimed space from output
        local reclaimed_space=$(echo "$cleanup_output" | grep -o 'reclaimed [^[:space:]]*' | awk '{print $2}')
        if [[ -n "$reclaimed_space" ]]; then
            print_info "Space reclaimed: $reclaimed_space"
        fi

        log_info "Dangling images cleaned, space reclaimed: ${reclaimed_space:-unknown}"
    else
        print_error "Failed to clean dangling images"
        log_error "Failed to clean dangling images: $cleanup_output"
    fi
}

# Clean unused images
clean_unused_images() {
    print_header "Clean Unused Images"

    echo "Choose cleanup method:"
    echo "  1) Remove all unused images (automatic)"
    echo "  2) Select specific unused images to remove"
    echo "  0) Cancel"
    echo
    echo -n "Enter your choice [0-2]: "
    read -r cleanup_choice

    case $cleanup_choice in
        0)
            print_info "Operation cancelled"
            return 0
            ;;
        1)
            # Original automatic cleanup
            print_warning "This will remove all images not used by any container"
            print_info "Getting unused images information..."

            # Get current disk usage
            local before_usage=$(docker system df --format "{{.Type}}\t{{.Size}}" | grep "Images" | awk '{print $2}')

            echo
            echo -n "Remove all unused images? (y/N): "
            read -r confirm

            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                print_info "Operation cancelled"
                return 0
            fi
            ;;
        2)
            # Select specific images to remove
            local image_ids
            image_ids=$(select_images "" "Select unused images to remove")

            if [[ $? -ne 0 || -z "$image_ids" ]]; then
                return 1
            fi

            print_warning "About to remove the selected images:"
            while IFS= read -r id; do
                local repo_tag=$(docker images --format "{{.Repository}}:{{.Tag}}" --filter "id=$id" | head -1)
                echo "  - $repo_tag ($id)"
            done <<< "$image_ids"

            echo
            echo -n "Remove selected images? (y/N): "
            read -r confirm

            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                print_info "Operation cancelled"
                return 0
            fi

            # Remove selected images
            local success_count=0
            local total_count=0

            while IFS= read -r id; do
                ((total_count++))
                local repo_tag=$(docker images --format "{{.Repository}}:{{.Tag}}" --filter "id=$id" | head -1)

                print_info "Removing image: $repo_tag ($id)"

                if docker rmi "$id" &>/dev/null; then
                    print_success "Removed: $repo_tag"
                    log_info "Image removed: $repo_tag ($id)"
                    ((success_count++))
                else
                    print_error "Failed to remove: $repo_tag"
                    log_error "Failed to remove image: $repo_tag ($id)"
                fi
            done <<< "$image_ids"

            print_separator
            print_info "Operation completed: $success_count/$total_count images removed"
            return 0
            ;;
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac

    print_info "Cleaning unused images..."

    local cleanup_output
    cleanup_output=$(docker image prune -a -f 2>&1)

    if [[ $? -eq 0 ]]; then
        print_success "Unused images cleaned"

        # Extract reclaimed space from output
        local reclaimed_space=$(echo "$cleanup_output" | grep -o 'reclaimed [^[:space:]]*' | awk '{print $2}')
        if [[ -n "$reclaimed_space" ]]; then
            print_info "Space reclaimed: $reclaimed_space"
        fi

        # Get current disk usage after cleanup
        local after_usage=$(docker system df --format "{{.Type}}\t{{.Size}}" | grep "Images" | awk '{print $2}')

        print_separator
        print_info "Cleanup Summary:"
        print_info "  Before: ${before_usage:-unknown}"
        print_info "  After: ${after_usage:-unknown}"
        print_info "  Reclaimed: ${reclaimed_space:-unknown}"

        log_info "Unused images cleaned, space reclaimed: ${reclaimed_space:-unknown}"
    else
        print_error "Failed to clean unused images"
        log_error "Failed to clean unused images: $cleanup_output"
    fi
}

# System-wide Docker cleanup
system_cleanup() {
    print_header "System Cleanup"

    print_warning "This will remove:"
    print_color "$YELLOW" "  - All stopped containers"
    print_color "$YELLOW" "  - All networks not used by at least one container"
    print_color "$YELLOW" "  - All dangling images"
    print_color "$YELLOW" "  - All dangling build cache"
    echo

    # Get current system usage
    print_info "Current system usage:"
    docker system df
    echo

    echo -n "Proceed with system cleanup? (y/N): "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled"
        return 0
    fi

    print_info "Performing system cleanup..."

    local cleanup_output
    cleanup_output=$(docker system prune -f 2>&1)

    if [[ $? -eq 0 ]]; then
        print_success "System cleanup completed"

        # Extract reclaimed space from output
        local reclaimed_space=$(echo "$cleanup_output" | grep -o 'reclaimed [^[:space:]]*' | awk '{print $2}')
        if [[ -n "$reclaimed_space" ]]; then
            print_info "Space reclaimed: $reclaimed_space"
        fi

        echo
        print_info "System usage after cleanup:"
        docker system df

        log_info "System cleanup completed, space reclaimed: ${reclaimed_space:-unknown}"
    else
        print_error "Failed to perform system cleanup"
        log_error "Failed to perform system cleanup: $cleanup_output"
    fi
}

#===============================================================================
# BUILD MANAGEMENT FUNCTIONS
#===============================================================================

# {{ AURA-X:
# Action: "Added"
# Task_ID: "#b5b32690-7bcf-4f79-9f92-5a61e3a659b3"
# Timestamp: "2025-07-28T16:43:07+08:00"
# Authoring_Role: "LD"
# Principle_Applied: "SOLID-S (Single Responsibility Principle)"
# Approval: "inch stop (ID:2025-07-28T16:43:07+08:00)"
#}}

# Add new container configuration
add_build_config() {
    print_header "Add Container Configuration"

    local container_name image_name run_cmd description

    # Get container name
    echo -n "Container name: "
    read -r container_name

    if [[ -z "$container_name" ]]; then
        print_error "Container name is required"
        return 1
    fi

    # Check if container already exists in config
    if command -v jq &> /dev/null && [[ -f "$CONFIG_FILE" ]]; then
        if jq -e ".containers.\"$container_name\"" "$CONFIG_FILE" >/dev/null 2>&1; then
            print_warning "Container configuration already exists: $container_name"
            echo -n "Overwrite existing configuration? (y/N): "
            read -r confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                print_info "Operation cancelled"
                return 0
            fi
        fi
    fi

    # Get image name
    echo -n "Image name (e.g., dockerpull.lucky619.me/gys619/docs-system:latest): "
    read -r image_name

    if [[ -z "$image_name" ]]; then
        print_error "Image name is required"
        return 1
    fi

    # Get run command
    echo
    echo "Enter the complete docker run command:"
    echo "Example: docker run -d -p 3000:3000 --name docs dockerpull.lucky619.me/gys619/docs-system:latest"
    echo
    echo "You can paste multi-line commands directly. Press Ctrl+D when finished."
    echo
    echo "Run command:"

    # Use cat to read multi-line input until EOF (Ctrl+D)
    run_cmd=$(cat | tr '\n' ' ' | sed 's/\\[[:space:]]*/ /g' | sed 's/[[:space:]]\+/ /g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

    if [[ -z "$run_cmd" ]]; then
        print_error "Run command is required"
        return 1
    fi

    # Get description
    echo -n "Description (optional): "
    read -r description

    # Show summary
    echo
    echo "───────────────────────────────────────────────────────────────"
    echo "Configuration Summary:"
    echo "  Container: $container_name"
    echo "  Image: $image_name"
    echo "  Description: ${description:-None}"
    echo
    echo "  Run Command:"
    # Format long command for better readability
    if [[ ${#run_cmd} -gt 80 ]]; then
        echo "    $(echo "$run_cmd" | fold -w 76 -s | sed '2,$s/^/    /')"
    else
        echo "    $run_cmd"
    fi
    echo

    echo -n "Save this configuration? (y/N): "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Configuration not saved"
        return 0
    fi

    # Save configuration (use empty build_cmd since we're focusing on run commands)
    if add_container_config "$container_name" "$image_name" "" "$run_cmd" "$description"; then
        print_success "Container configuration saved: $container_name"
        log_info "Container configuration added: $container_name"
    else
        print_error "Failed to save container configuration"
        return 1
    fi
}

# List build configurations
list_build_configs() {
    print_header "Build Configurations"

    if ! list_container_configs; then
        return 1
    fi

    echo
    print_info "Use 'Manage build configs' to edit or remove configurations"
}

# Edit build configuration
edit_build_config() {
    print_header "Edit Build Configuration"

    if [[ ! -f "$CONFIG_FILE" ]] || ! validate_config; then
        print_error "No valid configuration file found"
        return 1
    fi

    # List available configurations
    if ! command -v jq &> /dev/null; then
        print_error "jq is required for editing configurations"
        return 1
    fi

    local containers
    containers=$(jq -r '.containers | keys[]' "$CONFIG_FILE" 2>/dev/null)

    if [[ -z "$containers" ]]; then
        print_warning "No container configurations found"
        return 0
    fi

    print_info "Available configurations:"
    local -a config_array
    local count=1

    while IFS= read -r container; do
        config_array+=("$container")
        local image=$(jq -r ".containers.\"$container\".image" "$CONFIG_FILE")
        local description=$(jq -r ".containers.\"$container\".description // \"No description\"" "$CONFIG_FILE")

        print_color "$WHITE" "  $count) $container"
        print_color "$DIM" "     Image: $image"
        print_color "$DIM" "     Description: $description"
        echo
        ((count++))
    done <<< "$containers"

    print_color "$DIM" "  0) Cancel"
    echo

    echo -n "$(print_color "$CYAN" "Select configuration to edit [0-$((count-1))]: ")"
    read -r selection

    if [[ "$selection" == "0" ]]; then
        print_info "Operation cancelled"
        return 0
    fi

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt ${#config_array[@]} ]]; then
        print_error "Invalid selection"
        return 1
    fi

    local selected_container="${config_array[$((selection-1))]}"

    # Get current configuration
    local current_image=$(jq -r ".containers.\"$selected_container\".image" "$CONFIG_FILE")
    local current_build=$(jq -r ".containers.\"$selected_container\".build_cmd" "$CONFIG_FILE")
    local current_run=$(jq -r ".containers.\"$selected_container\".run_cmd" "$CONFIG_FILE")
    local current_desc=$(jq -r ".containers.\"$selected_container\".description // \"\"" "$CONFIG_FILE")

    print_separator
    print_info "Current configuration for: $selected_container"
    print_color "$DIM" "  Image: $current_image"
    print_color "$DIM" "  Build: $current_build"
    print_color "$DIM" "  Run: $current_run"
    print_color "$DIM" "  Description: $current_desc"
    echo

    # Edit configuration (reuse add_build_config logic)
    print_info "Enter new values (press Enter to keep current value):"

    local new_image new_build new_run new_desc

    echo -n "$(print_color "$CYAN" "Image [$current_image]: ")"
    read -r new_image
    new_image=${new_image:-$current_image}

    echo -n "$(print_color "$CYAN" "Build command [$current_build]: ")"
    read -r new_build
    new_build=${new_build:-$current_build}

    echo -n "$(print_color "$CYAN" "Run command [$current_run]: ")"
    read -r new_run
    new_run=${new_run:-$current_run}

    echo -n "$(print_color "$CYAN" "Description [$current_desc]: ")"
    read -r new_desc
    new_desc=${new_desc:-$current_desc}

    # Save updated configuration
    if add_container_config "$selected_container" "$new_image" "$new_build" "$new_run" "$new_desc"; then
        print_success "Configuration updated: $selected_container"
        log_info "Build configuration updated: $selected_container"
    else
        print_error "Failed to update configuration"
        return 1
    fi
}

# One-click update container
one_click_rebuild() {
    print_header "One-Click Update Container"

    if [[ ! -f "$CONFIG_FILE" ]] || ! validate_config; then
        print_error "No valid configuration file found"
        return 1
    fi

    if ! command -v jq &> /dev/null; then
        print_error "jq is required for update functionality"
        return 1
    fi

    # List available configurations
    local containers
    containers=$(jq -r '.containers | keys[]' "$CONFIG_FILE" 2>/dev/null)

    if [[ -z "$containers" ]]; then
        print_warning "No container configurations found"
        print_info "Use 'Add container configuration' to create configurations first"
        return 0
    fi

    echo "Available configurations:"
    local -a config_array
    local count=1

    while IFS= read -r container; do
        config_array+=("$container")
        local image=$(jq -r ".containers.\"$container\".image" "$CONFIG_FILE")
        local description=$(jq -r ".containers.\"$container\".description // \"No description\"" "$CONFIG_FILE")

        echo "  $count) $container"
        echo "     Image: $image"
        echo "     Description: $description"
        echo
        ((count++))
    done <<< "$containers"

    echo "  0) Cancel"
    echo

    echo -n "Select configuration to update [0-$((count-1))]: "
    read -r selection

    if [[ "$selection" == "0" ]]; then
        print_info "Operation cancelled"
        return 0
    fi

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt ${#config_array[@]} ]]; then
        print_error "Invalid selection"
        return 1
    fi

    local selected_container="${config_array[$((selection-1))]}"

    # Get configuration details
    local image=$(jq -r ".containers.\"$selected_container\".image" "$CONFIG_FILE")
    local run_cmd=$(jq -r ".containers.\"$selected_container\".run_cmd" "$CONFIG_FILE")

    if [[ -z "$run_cmd" || "$run_cmd" == "null" ]]; then
        print_error "No run command configured for: $selected_container"
        return 1
    fi

    # Show update plan
    echo
    echo "───────────────────────────────────────────────────────────────"
    echo "Update Plan for: $selected_container"
    echo "  1. Pull latest image: $image"
    echo "  2. Stop existing container"
    echo "  3. Remove existing container"
    echo "  4. Start new container"
    echo
    echo "Run command: $run_cmd"
    echo

    echo -n "Proceed with update? (y/N): "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Update cancelled"
        return 0
    fi

    # Start update process
    echo
    echo "───────────────────────────────────────────────────────────────"
    echo "Starting update process for: $selected_container"
    log_info "Starting update process for: $selected_container"

    local update_success=true
    local step=1

    # Step 1: Pull latest image
    echo "[$step/4] Pulling latest image: $image"
    if docker pull "$image"; then
        print_success "Image pulled successfully: $image"
        log_info "Image pulled: $image"
    else
        print_error "Failed to pull image: $image"
        log_error "Failed to pull image: $image"
        update_success=false
    fi
    ((step++))

    # Step 2: Stop existing container
    echo "[$step/4] Stopping existing container..."
    if docker ps -q -f "name=^${selected_container}$" | grep -q .; then
        if docker stop "$selected_container" &>/dev/null; then
            print_success "Container stopped: $selected_container"
        else
            print_warning "Failed to stop container: $selected_container (continuing anyway)"
        fi
    else
        echo "No running container found: $selected_container"
    fi
    ((step++))

    # Step 3: Remove existing container
    echo "[$step/4] Removing existing container..."
    if docker ps -a -q -f "name=^${selected_container}$" | grep -q .; then
        if docker rm "$selected_container" &>/dev/null; then
            print_success "Container removed: $selected_container"
        else
            print_error "Failed to remove container: $selected_container"
            update_success=false
        fi
    else
        echo "No existing container found: $selected_container"
    fi
    ((step++))

    # Step 4: Start new container
    if [[ "$update_success" == "true" ]]; then
        echo "[$step/4] Starting new container..."
        echo "Command: $run_cmd"

        if eval "$run_cmd"; then
            print_success "Container started successfully: $selected_container"
            log_info "Container started: $selected_container"
        else
            print_error "Failed to start container: $selected_container"
            log_error "Failed to start container: $selected_container - command: $run_cmd"
            update_success=false
        fi
    else
        echo "[$step/4] Skipping container start due to previous errors"
    fi

    # Final result
    echo
    echo "───────────────────────────────────────────────────────────────"
    if [[ "$update_success" == "true" ]]; then
        print_success "Update completed successfully: $selected_container"
        log_info "Update completed successfully for: $selected_container"

        # Show container info if running
        if docker ps -q -f "name=^${selected_container}$" | grep -q .; then
            echo
            echo "Container information:"
            docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" -f "name=^${selected_container}$"
        fi
    else
        print_error "Update failed: $selected_container"
        echo "Check logs for details: tail -f $LOG_FILE"
    fi
}

# Manage build configurations
manage_build_configs() {
    print_header "Manage Build Configurations"

    while true; do
        echo
        print_color "$WHITE" "Configuration Management:"
        echo "  1) List configurations"
        echo "  2) Add new configuration"
        echo "  3) Edit configuration"
        echo "  4) Remove configuration"
        echo "  5) Export configurations"
        echo "  6) Import configurations"
        echo
        print_color "$DIM" "  0) Back to main menu"
        echo
        print_separator

        echo -n "$(print_color "$CYAN" "Enter your choice [0-6]: ")"
        read -r choice

        case $choice in
            0)
                break
                ;;
            1)
                clear
                list_build_configs
                read -p "Press Enter to continue..."
                ;;
            2)
                clear
                add_build_config
                read -p "Press Enter to continue..."
                ;;
            3)
                clear
                edit_build_config
                read -p "Press Enter to continue..."
                ;;
            4)
                clear
                remove_build_config
                read -p "Press Enter to continue..."
                ;;
            5)
                clear
                export_build_configs
                read -p "Press Enter to continue..."
                ;;
            6)
                clear
                import_build_configs
                read -p "Press Enter to continue..."
                ;;
            *)
                print_error "Invalid choice. Please select 0-6."
                read -p "Press Enter to continue..."
                ;;
        esac
        clear
    done
}

# Remove build configuration
remove_build_config() {
    print_header "Remove Build Configuration"

    if [[ ! -f "$CONFIG_FILE" ]] || ! validate_config; then
        print_error "No valid configuration file found"
        return 1
    fi

    if ! command -v jq &> /dev/null; then
        print_error "jq is required for removing configurations"
        return 1
    fi

    # List available configurations
    local containers
    containers=$(jq -r '.containers | keys[]' "$CONFIG_FILE" 2>/dev/null)

    if [[ -z "$containers" ]]; then
        print_warning "No container configurations found"
        return 0
    fi

    print_info "Available configurations:"
    local -a config_array
    local count=1

    while IFS= read -r container; do
        config_array+=("$container")
        local image=$(jq -r ".containers.\"$container\".image" "$CONFIG_FILE")
        local description=$(jq -r ".containers.\"$container\".description // \"No description\"" "$CONFIG_FILE")

        print_color "$WHITE" "  $count) $container"
        print_color "$DIM" "     Image: $image"
        print_color "$DIM" "     Description: $description"
        echo
        ((count++))
    done <<< "$containers"

    print_color "$DIM" "  0) Cancel"
    echo

    echo -n "$(print_color "$CYAN" "Select configuration to remove [0-$((count-1))]: ")"
    read -r selection

    if [[ "$selection" == "0" ]]; then
        print_info "Operation cancelled"
        return 0
    fi

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt ${#config_array[@]} ]]; then
        print_error "Invalid selection"
        return 1
    fi

    local selected_container="${config_array[$((selection-1))]}"

    print_warning "About to remove configuration: $selected_container"
    echo -n "Are you sure? (y/N): "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled"
        return 0
    fi

    if remove_container_config "$selected_container"; then
        print_success "Configuration removed: $selected_container"
    else
        print_error "Failed to remove configuration"
        return 1
    fi
}

# Export build configurations
export_build_configs() {
    print_header "Export Build Configurations"

    if [[ ! -f "$CONFIG_FILE" ]] || ! validate_config; then
        print_error "No valid configuration file found"
        return 1
    fi

    local export_file="dockease_export_$(date +%Y%m%d_%H%M%S).json"

    echo -n "$(print_color "$CYAN" "Export file name [$export_file]: ")"
    read -r user_filename
    export_file=${user_filename:-$export_file}

    if cp "$CONFIG_FILE" "$export_file"; then
        print_success "Configurations exported to: $export_file"
        log_info "Configurations exported to: $export_file"
    else
        print_error "Failed to export configurations"
        return 1
    fi
}

# Import build configurations
import_build_configs() {
    print_header "Import Build Configurations"

    echo -n "$(print_color "$CYAN" "Import file path: ")"
    read -r import_file

    if [[ -z "$import_file" ]]; then
        print_error "Import file path is required"
        return 1
    fi

    if [[ ! -f "$import_file" ]]; then
        print_error "Import file not found: $import_file"
        return 1
    fi

    # Validate import file
    if ! validate_config "$import_file"; then
        print_error "Invalid configuration file format"
        return 1
    fi

    print_warning "This will merge configurations from the import file"
    print_info "Existing configurations with the same name will be overwritten"
    echo -n "Continue? (y/N): "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Import cancelled"
        return 0
    fi

    # Backup current config
    backup_config

    # Merge configurations
    if command -v jq &> /dev/null; then
        local temp_file=$(mktemp)
        if jq -s '.[0] * .[1]' "$CONFIG_FILE" "$import_file" > "$temp_file" && mv "$temp_file" "$CONFIG_FILE"; then
            print_success "Configurations imported successfully"
            log_info "Configurations imported from: $import_file"
        else
            print_error "Failed to import configurations"
            rm -f "$temp_file"
            return 1
        fi
    else
        print_error "jq is required for importing configurations"
        return 1
    fi
}

#===============================================================================
# HELP AND INFORMATION FUNCTIONS
#===============================================================================

# {{ AURA-X:
# Action: "Added"
# Task_ID: "#5f0ead50-d786-4540-913c-c5c750d01759"
# Timestamp: "2025-07-28T16:48:15+08:00"
# Authoring_Role: "LD"
# Principle_Applied: "SOLID-S (Single Responsibility Principle)"
# Approval: "inch stop (ID:2025-07-28T16:48:15+08:00)"
#}}

# Show comprehensive help information
show_help() {
    clear
    print_header "DockEase Help & User Guide"

    print_color "$WHITE" "📖 OVERVIEW"
    echo "DockEase is a lightweight, dependency-free Docker management tool that simplifies"
    echo "container and image management through an intuitive command-line interface."
    echo

    print_color "$WHITE" "🚀 QUICK START"
    echo "1. Run the script: ./dockease.sh"
    echo "2. Use 'Add build configuration' to save your Docker commands"
    echo "3. Use 'One-click rebuild' to automate container updates"
    echo "4. Regular cleanup helps maintain system performance"
    echo

    print_color "$WHITE" "📋 MAIN FEATURES"
    echo
    print_color "$CYAN" "Container Management (1-6):"
    echo "  • List all containers with detailed status information"
    echo "  • Start, stop, restart containers individually or in batches"
    echo "  • Remove containers with safety confirmations"
    echo "  • Quick remove: stop and remove in one operation"
    echo

    print_color "$CYAN" "Image Management (7-10):"
    echo "  • List all images with size and creation information"
    echo "  • Pull latest image updates from registries"
    echo "  • Remove unused or specific images"
    echo "  • Clean unused images to free disk space"
    echo

    print_color "$CYAN" "Build Management (11-13):"
    echo "  • Save build configurations for easy reuse"
    echo "  • One-click rebuild: automated pull→stop→rm→build→run process"
    echo "  • Manage configurations: edit, remove, import/export"
    echo

    print_color "$CYAN" "System Cleanup (14-16):"
    echo "  • Clean dangling images (untagged images)"
    echo "  • System prune: remove stopped containers, unused networks"
    echo "  • Full cleanup: comprehensive system cleaning"
    echo

    print_color "$CYAN" "Settings & Configuration (17-19):"
    echo "  • View current configuration in JSON format"
    echo "  • Reset configuration to defaults"
    echo "  • View recent operation logs"
    echo

    print_color "$WHITE" "⚙️ CONFIGURATION FILE"
    echo "DockEase uses a JSON configuration file (.dockease.json) to store:"
    echo "  • Container build and run commands"
    echo "  • Application settings and preferences"
    echo "  • Automatic backups are created before modifications"
    echo

    print_color "$WHITE" "🔧 REQUIREMENTS"
    echo "  • Docker installed and running"
    echo "  • Bash shell (version 4.0 or later)"
    echo "  • jq (optional, for enhanced JSON processing)"
    echo "  • Basic Unix utilities (grep, awk, sed)"
    echo

    print_color "$WHITE" "💡 TIPS & BEST PRACTICES"
    echo "  • Always test build commands manually before saving them"
    echo "  • Use descriptive names for container configurations"
    echo "  • Regular cleanup prevents disk space issues"
    echo "  • Export configurations before major changes"
    echo "  • Check logs if operations fail unexpectedly"
    echo

    print_color "$WHITE" "🚨 SAFETY FEATURES"
    echo "  • Confirmation prompts for destructive operations"
    echo "  • Automatic configuration backups"
    echo "  • Detailed operation logging"
    echo "  • Step-by-step rebuild process with rollback capability"
    echo

    print_color "$WHITE" "📁 FILES CREATED"
    echo "  • .dockease.json - Main configuration file"
    echo "  • .dockease.log - Operation logs"
    echo "  • .dockease.json.backup.* - Configuration backups"
    echo

    print_separator
    print_info "For more information, visit the project repository or check the logs."
}

# Show about information
show_about() {
    clear
    print_header "About DockEase"

    # ASCII Art Logo
    print_color "$BLUE" "    ____             __   ______                "
    print_color "$BLUE" "   / __ \\____  _____/ /__/ ____/___ __________ "
    print_color "$BLUE" "  / / / / __ \\/ ___/ //_/ __/ / __ \`/ ___/ _ \\  "
    print_color "$BLUE" " / /_/ / /_/ / /__/ ,< / /___/ /_/ (__  )  __/   "
    print_color "$BLUE" "/_____/\\____/\\___/_/|_|\\____/\\__,_/____/\\___/   "
    echo

    print_color "$WHITE" "🐳 DockEase - Docker Management Made Simple"
    echo

    print_color "$CYAN" "Version Information:"
    echo "  • Version: $SCRIPT_VERSION"
    echo "  • Build Date: 2025-07-28"
    echo "  • Architecture: Single-file Shell Script"
    echo "  • License: Open Source"
    echo

    print_color "$CYAN" "Development Team:"
    echo "  • Developed by: AURA-X Development Team"
    echo "  • Architecture: LD (Lead Developer)"
    echo "  • Project Management: PM (Project Manager)"
    echo "  • Product Design: PDM (Product Manager)"
    echo

    print_color "$CYAN" "Technical Specifications:"
    echo "  • Language: Bash Shell Script"
    echo "  • Dependencies: None (jq optional)"
    echo "  • Platform: Cross-platform (Linux, macOS, WSL)"
    echo "  • Size: Single file, lightweight"
    echo

    print_color "$CYAN" "Core Principles:"
    echo "  • 🚀 Zero Dependencies - Works out of the box"
    echo "  • 🎯 User-Friendly - Intuitive interface design"
    echo "  • 🔒 Safety First - Confirmations and backups"
    echo "  • 📝 Comprehensive Logging - Full operation tracking"
    echo "  • ⚡ Efficient - Fast and responsive operations"
    echo

    print_color "$CYAN" "System Information:"
    echo "  • Docker Version: $(docker --version 2>/dev/null || echo 'Not detected')"
    echo "  • Shell: $SHELL"
    echo "  • OS: $(uname -s) $(uname -r)"
    echo "  • jq Available: $(command -v jq &>/dev/null && echo 'Yes' || echo 'No')"
    echo

    print_color "$CYAN" "Statistics:"
    if [[ -f "$CONFIG_FILE" ]] && command -v jq &>/dev/null; then
        local container_count=$(jq '.containers | length' "$CONFIG_FILE" 2>/dev/null || echo "0")
        echo "  • Configured Containers: $container_count"
    fi

    if [[ -f "$LOG_FILE" ]]; then
        local log_lines=$(wc -l < "$LOG_FILE" 2>/dev/null || echo "0")
        echo "  • Log Entries: $log_lines"
    fi

    local docker_containers=$(docker ps -a --format "{{.Names}}" 2>/dev/null | wc -l || echo "0")
    local docker_images=$(docker images -q 2>/dev/null | wc -l || echo "0")
    echo "  • Docker Containers: $docker_containers"
    echo "  • Docker Images: $docker_images"
    echo

    print_color "$WHITE" "🙏 Acknowledgments"
    echo "Special thanks to the Docker community and all open-source contributors"
    echo "who make tools like this possible."
    echo

    print_separator
    print_color "$GREEN" "Thank you for using DockEase! 🐳✨"
}

# Show keyboard shortcuts and navigation help
show_navigation_help() {
    print_color "$WHITE" "⌨️  Navigation Help:"
    echo "  • Enter number + Enter to select menu option"
    echo "  • Type 'all' to select all items in lists"
    echo "  • Use Ctrl+C to cancel current operation"
    echo "  • Press Enter to keep current values when editing"
    echo "  • Type '0' to go back or cancel in submenus"
    echo
}

# Enhanced error display with suggestions
show_error_help() {
    local error_type=$1

    case "$error_type" in
        "docker_not_running")
            print_error "Docker daemon is not running"
            print_info "Try: sudo systemctl start docker"
            print_info "Or: sudo service docker start"
            ;;
        "docker_not_installed")
            print_error "Docker is not installed"
            print_info "Install Docker: https://docs.docker.com/get-docker/"
            ;;
        "jq_not_available")
            print_warning "jq is not available"
            print_info "Install jq for enhanced JSON processing:"
            print_info "  • Ubuntu/Debian: sudo apt-get install jq"
            print_info "  • CentOS/RHEL: sudo yum install jq"
            print_info "  • macOS: brew install jq"
            ;;
        *)
            print_error "Unknown error occurred"
            print_info "Check logs: tail -f $LOG_FILE"
            ;;
    esac
}

# Main execution loop
main() {
    initialize
    
    while true; do
        show_main_menu

        # Get user input directly
        echo
        echo "════════════════════════════════════════════════════════════════"
        echo "  Please enter your choice (0-21):"
        echo "════════════════════════════════════════════════════════════════"
        echo -n "  ► Enter number: "
        read choice
        echo

        # Clean the choice
        choice=$(echo "$choice" | tr -d '[:space:]')

        case $choice in
            0)
                cleanup
                ;;
            1)
                # List containers
                clear
                list_containers true
                read -p "Press Enter to continue..."
                ;;
            2)
                # Start containers
                clear
                start_containers
                echo
                read -p "Press Enter to continue..."
                ;;
            3)
                # Stop containers
                clear
                stop_containers
                read -p "Press Enter to continue..."
                ;;
            4)
                # Restart containers
                clear
                restart_containers
                read -p "Press Enter to continue..."
                ;;
            5)
                # Remove containers
                clear
                remove_containers
                read -p "Press Enter to continue..."
                ;;
            6)
                # Quick remove (stop + rm)
                clear
                quick_remove_containers
                read -p "Press Enter to continue..."
                ;;
            7)
                # List images
                clear
                list_images
                read -p "Press Enter to continue..."
                ;;
            8)
                # Pull image updates
                clear
                pull_images
                read -p "Press Enter to continue..."
                ;;
            9)
                # Remove images
                clear
                remove_images
                read -p "Press Enter to continue..."
                ;;
            10)
                # Clean unused images
                clear
                clean_unused_images
                read -p "Press Enter to continue..."
                ;;
            11)
                # Add build configuration
                clear
                add_build_config
                read -p "Press Enter to continue..."
                ;;
            12)
                # One-click rebuild
                clear
                one_click_rebuild
                read -p "Press Enter to continue..."
                ;;
            13)
                # Manage build configs
                clear
                manage_build_configs
                ;;
            14)
                # Clean dangling images
                clear
                clean_dangling_images
                read -p "Press Enter to continue..."
                ;;
            15)
                # System prune
                clear
                system_cleanup
                read -p "Press Enter to continue..."
                ;;
            16)
                # Full cleanup
                clear
                print_header "Full Cleanup"
                print_warning "This will perform a comprehensive cleanup:"
                print_color "$YELLOW" "  1. Clean dangling images"
                print_color "$YELLOW" "  2. Clean unused images"
                print_color "$YELLOW" "  3. System prune"
                echo
                echo -n "Proceed with full cleanup? (y/N): "
                read -r confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    clean_dangling_images
                    echo
                    clean_unused_images
                    echo
                    system_cleanup
                    print_success "Full cleanup completed"
                else
                    print_info "Full cleanup cancelled"
                fi
                read -p "Press Enter to continue..."
                ;;
            17)
                # View configuration
                clear
                print_header "Current Configuration"
                if [[ -f "$CONFIG_FILE" ]]; then
                    if command -v jq &> /dev/null; then
                        jq '.' "$CONFIG_FILE" 2>/dev/null || cat "$CONFIG_FILE"
                    else
                        cat "$CONFIG_FILE"
                    fi
                else
                    print_warning "No configuration file found"
                fi
                echo
                read -p "Press Enter to continue..."
                ;;
            18)
                # Reset configuration
                clear
                print_header "Reset Configuration"
                print_warning "This will reset all configuration to defaults!"
                echo -n "Are you sure? (y/N): "
                read -r confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    backup_config
                    create_default_config
                    print_success "Configuration reset to defaults"
                else
                    print_info "Reset cancelled"
                fi
                read -p "Press Enter to continue..."
                ;;
            19)
                # View logs
                clear
                print_header "Recent Logs"
                if [[ -f "$LOG_FILE" ]]; then
                    tail -n 20 "$LOG_FILE"
                else
                    print_warning "No log file found"
                fi
                echo
                read -p "Press Enter to continue..."
                ;;
            20)
                # Show help
                show_help
                read -p "Press Enter to continue..."
                ;;
            21)
                # About DockEase
                show_about
                read -p "Press Enter to continue..."
                ;;
            *)
                print_error "Invalid choice. Please select 0-21."
                show_navigation_help
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

#===============================================================================
# SCRIPT ENTRY POINT
#===============================================================================

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# {{END_MODIFICATIONS}}
