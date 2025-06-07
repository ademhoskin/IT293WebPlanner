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

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
}

# Backup database
backup_database() {
    print_status "Creating database backup..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="./backups"
    mkdir -p $BACKUP_DIR
    
    docker-compose exec mysql mysqldump -u root -proot degree_planner > "$BACKUP_DIR/backup_$TIMESTAMP.sql"
    if [ $? -eq 0 ]; then
        print_status "Backup created: $BACKUP_DIR/backup_$TIMESTAMP.sql"
    else
        print_error "Backup failed!"
        exit 1
    fi
}

# Deploy function
deploy() {
    local ENV=$1
    
    print_status "Starting deployment for $ENV environment..."
    
    # Check Docker installation
    check_docker
    
    # Backup database if it exists
    if [ "$ENV" = "prod" ]; then
        backup_database
    fi
    
    # Pull latest changes if in git repository
    if [ -d .git ]; then
        print_status "Pulling latest changes..."
        git pull
    fi
    
    # Build and start containers
    print_status "Building and starting containers..."
    if [ "$ENV" = "prod" ]; then
        docker-compose -f docker-compose.prod.yml build
        docker-compose -f docker-compose.prod.yml up -d
    else
        docker-compose build
        docker-compose up -d
    fi
    
    # Wait for services to be ready
    print_status "Waiting for services to be ready..."
    sleep 10
    
    # Check if services are running
    print_status "Checking service health..."
    if curl -f http://localhost:80 > /dev/null 2>&1; then
        print_status "Apache is running"
    else
        print_error "Apache is not responding"
        exit 1
    fi
    
    if curl -f http://localhost:4000/graphql > /dev/null 2>&1; then
        print_status "GraphQL API is running"
    else
        print_error "GraphQL API is not responding"
        exit 1
    fi
    
    print_status "Deployment completed successfully!"
}

# Main script
case "$1" in
    "dev")
        deploy "dev"
        ;;
    "prod")
        deploy "prod"
        ;;
    *)
        echo "Usage: $0 {dev|prod}"
        exit 1
        ;;
esac 