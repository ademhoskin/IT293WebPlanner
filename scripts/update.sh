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

# Create backup before update
create_backup() {
    print_status "Creating backup before update..."
    ./scripts/backup.sh
    if [ $? -ne 0 ]; then
        print_error "Backup failed, aborting update"
        exit 1
    fi
}

# Update application
update_application() {
    print_status "Updating application..."

    # Pull latest changes
    print_status "Pulling latest changes..."
    git pull origin main
    if [ $? -ne 0 ]; then
        print_error "Failed to pull latest changes"
        exit 1
    fi

    # Install/update dependencies
    print_status "Updating dependencies..."
    
    # Backend dependencies
    cd backend
    npm install
    if [ $? -ne 0 ]; then
        print_error "Failed to update backend dependencies"
        exit 1
    fi
    cd ..

    # Frontend dependencies
    cd frontend
    npm install
    if [ $? -ne 0 ]; then
        print_error "Failed to update frontend dependencies"
        exit 1
    fi
    cd ..

    # Rebuild containers
    print_status "Rebuilding containers..."
    docker-compose build
    if [ $? -ne 0 ]; then
        print_error "Failed to rebuild containers"
        exit 1
    fi
}

# Run tests
run_tests() {
    print_status "Running tests..."

    # Backend tests
    print_status "Running backend tests..."
    cd backend
    npm test
    if [ $? -ne 0 ]; then
        print_error "Backend tests failed"
        exit 1
    fi
    cd ..

    # Frontend tests
    print_status "Running frontend tests..."
    cd frontend
    npm test
    if [ $? -ne 0 ]; then
        print_error "Frontend tests failed"
        exit 1
    fi
    cd ..
}

# Restart services
restart_services() {
    print_status "Restarting services..."
    docker-compose down
    docker-compose up -d
    if [ $? -ne 0 ]; then
        print_error "Failed to restart services"
        exit 1
    fi
}

# Check health after update
check_health() {
    print_status "Checking service health after update..."
    ./scripts/health_check.sh
}

# Main update process
echo "Starting update process..."
echo "======================"

# Create backup
create_backup

# Update application
update_application

# Run tests
run_tests

# Restart services
restart_services

# Check health
check_health

echo "======================"
print_status "Update completed successfully!" 