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

# Check if services are running
check_services() {
    print_status "Checking service status..."
    
    # Check MySQL
    if docker-compose ps mysql | grep -q "Up"; then
        print_status "MySQL is running"
    else
        print_error "MySQL is not running"
    fi

    # Check GraphQL server
    if docker-compose ps graphql | grep -q "Up"; then
        print_status "GraphQL server is running"
    else
        print_error "GraphQL server is not running"
    fi

    # Check Apache
    if docker-compose ps apache | grep -q "Up"; then
        print_status "Apache is running"
    else
        print_error "Apache is not running"
    fi
}

# Check service health
check_health() {
    print_status "Checking service health..."

    # Check MySQL connection
    if docker-compose exec -T mysql mysqladmin ping -h localhost -u root -proot > /dev/null 2>&1; then
        print_status "MySQL is healthy"
    else
        print_error "MySQL is not responding"
    fi

    # Check GraphQL server
    if curl -s http://localhost:4000/graphql -X POST -H "Content-Type: application/json" \
        -d '{"query": "{ __schema { types { name } } }"}' > /dev/null 2>&1; then
        print_status "GraphQL server is healthy"
    else
        print_error "GraphQL server is not responding"
    fi

    # Check Apache
    if curl -s http://localhost:80 > /dev/null 2>&1; then
        print_status "Apache is healthy"
    else
        print_error "Apache is not responding"
    fi
}

# Check resource usage
check_resources() {
    print_status "Checking resource usage..."

    # Get container stats
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# Check logs for errors
check_logs() {
    print_status "Checking service logs for errors..."

    # Check MySQL logs
    print_warning "MySQL logs:"
    docker-compose logs mysql | grep -i "error" | tail -n 5

    # Check GraphQL logs
    print_warning "GraphQL logs:"
    docker-compose logs graphql | grep -i "error" | tail -n 5

    # Check Apache logs
    print_warning "Apache logs:"
    docker-compose logs apache | grep -i "error" | tail -n 5
}

# Main health check process
echo "Starting health check..."
echo "======================"

check_services
echo "----------------------"
check_health
echo "----------------------"
check_resources
echo "----------------------"
check_logs

echo "======================"
print_status "Health check completed" 