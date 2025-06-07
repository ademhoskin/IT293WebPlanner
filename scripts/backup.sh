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

# Create backup directory
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP"
mkdir -p "$BACKUP_PATH"

# Backup database
backup_database() {
    print_status "Creating database backup..."
    docker-compose exec mysql mysqldump -u root -proot degree_planner > "$BACKUP_PATH/database.sql"
    if [ $? -eq 0 ]; then
        print_status "Database backup created"
    else
        print_error "Database backup failed!"
        exit 1
    fi
}

# Backup configuration files
backup_configs() {
    print_status "Backing up configuration files..."
    
    # Create configs directory
    mkdir -p "$BACKUP_PATH/configs"
    
    # Copy important config files
    cp docker-compose.yml "$BACKUP_PATH/configs/"
    cp docker-compose.prod.yml "$BACKUP_PATH/configs/"
    cp server/apache/000-default.conf "$BACKUP_PATH/configs/"
    cp server/db/prisma/schema.prisma "$BACKUP_PATH/configs/"
    
    print_status "Configuration files backed up"
}

# Create backup archive
create_archive() {
    print_status "Creating backup archive..."
    tar -czf "$BACKUP_PATH.tar.gz" -C "$BACKUP_DIR" "backup_$TIMESTAMP"
    if [ $? -eq 0 ]; then
        print_status "Backup archive created: $BACKUP_PATH.tar.gz"
        # Clean up temporary directory
        rm -rf "$BACKUP_PATH"
    else
        print_error "Failed to create backup archive!"
        exit 1
    fi
}

# Main backup process
print_status "Starting backup process..."

# Backup database
backup_database

# Backup configurations
backup_configs

# Create archive
create_archive

print_status "Backup completed successfully!" 