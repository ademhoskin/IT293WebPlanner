#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print status messages
print_status() {
    echo -e "${GREEN}[✓] $1${NC}"
}

print_error() {
    echo -e "${RED}[✗] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

# Check if backup file exists
if [ -z "$1" ]; then
    print_error "Please provide a backup file path"
    echo "Usage: $0 <backup_file.tar.gz>"
    exit 1
fi

BACKUP_FILE=$1
if [ ! -f "$BACKUP_FILE" ]; then
    print_error "Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Create temporary directory for restoration
TEMP_DIR=$(mktemp -d)
print_status "Created temporary directory: $TEMP_DIR"

# Extract backup
print_status "Extracting backup..."
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"
if [ $? -ne 0 ]; then
    print_error "Failed to extract backup"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Find the backup directory
BACKUP_DIR=$(find "$TEMP_DIR" -type d -name "backup_*" | head -n 1)
if [ -z "$BACKUP_DIR" ]; then
    print_error "Invalid backup format"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Restore database
restore_database() {
    print_status "Restoring database..."
    if [ -f "$BACKUP_DIR/database.sql" ]; then
        docker-compose exec -T mysql mysql -u root -proot degree_planner < "$BACKUP_DIR/database.sql"
        if [ $? -eq 0 ]; then
            print_status "Database restored successfully"
        else
            print_error "Database restoration failed"
            exit 1
        fi
    else
        print_error "Database backup not found in archive"
        exit 1
    fi
}

# Restore configurations
restore_configs() {
    print_status "Restoring configuration files..."
    if [ -d "$BACKUP_DIR/configs" ]; then
        cp "$BACKUP_DIR/configs/"* .
        print_status "Configuration files restored"
    else
        print_warning "No configuration files found in backup"
    fi
}

# Main restore process
print_warning "This will overwrite current data. Are you sure? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # Stop containers
    print_status "Stopping containers..."
    docker-compose down

    # Restore database
    restore_database

    # Restore configurations
    restore_configs

    # Start containers
    print_status "Starting containers..."
    docker-compose up -d

    print_status "Restore completed successfully!"
else
    print_status "Restore cancelled"
fi

# Cleanup
rm -rf "$TEMP_DIR" 