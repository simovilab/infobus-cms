#!/bin/bash

# Docker Development Script for Strapi
# This script provides easy commands for Docker development

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Function to create .env.docker.local if it doesn't exist
create_env_file() {
    if [ ! -f .env.docker.local ]; then
        print_warning ".env.docker.local not found. Creating from template..."
        cp .env.docker .env.docker.local
        print_status "Please edit .env.docker.local with your configuration"
    fi
}

# Main script logic
case "${1}" in
    "build")
        print_status "Building Docker image..."
        check_docker
        docker-compose build --no-cache
        ;;
    "up")
        print_status "Starting development environment..."
        check_docker
        create_env_file
        docker-compose --env-file .env.docker.local up -d
        print_status "Strapi is running at http://localhost:1337"
        ;;
    "down")
        print_status "Stopping development environment..."
        check_docker
        docker-compose down
        ;;
    "restart")
        print_status "Restarting development environment..."
        check_docker
        docker-compose restart
        ;;
    "logs")
        print_status "Showing logs..."
        check_docker
        docker-compose logs -f
        ;;
    "shell")
        print_status "Opening shell in container..."
        check_docker
        docker-compose exec strapi-dev sh
        ;;
    "clean")
        print_status "Cleaning up Docker resources..."
        check_docker
        docker-compose down -v
        docker system prune -f
        ;;
    *)
        echo "Usage: $0 {build|up|down|restart|logs|shell|clean}"
        echo ""
        echo "Commands:"
        echo "  build    - Build Docker image"
        echo "  up       - Start development environment"
        echo "  down     - Stop development environment"
        echo "  restart  - Restart development environment"
        echo "  logs     - Show container logs"
        echo "  shell    - Open shell in container"
        echo "  clean    - Clean up Docker resources"
        exit 1
        ;;
esac