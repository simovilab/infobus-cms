# Docker Configuration for Infobus CMS

This repository includes Docker configuration for running the Strapi TypeScript application in both development and production environments.

## Files Added

- `Dockerfile` - Multi-stage Dockerfile with dev, build, and production targets
- `docker-compose.yml` - Development environment configuration
- `docker-compose.prod.yml` - Production environment configuration
- `.dockerignore` - Files to exclude from Docker context
- `.env.docker` - Environment variables template
- `scripts/docker-dev.sh` - Helper script for development commands

## Quick Start

### Development Environment

1. Copy the environment template:
   ```bash
   cp .env.docker .env.docker.local
   ```

2. Edit `.env.docker.local` with your configuration values

3. Start the development environment:
   ```bash
   # Using the helper script
   ./scripts/docker-dev.sh up
   
   # Or directly with docker-compose
   docker-compose --env-file .env.docker.local up -d
   ```

4. Access your Strapi application at `http://localhost:1337`

### Production Environment

1. Set up your production environment variables in `.env.docker.local`

2. Build and run the production container:
   ```bash
   docker-compose -f docker-compose.prod.yml --env-file .env.docker.local up -d
   ```

## Development Helper Script

The `scripts/docker-dev.sh` script provides convenient commands:

```bash
./scripts/docker-dev.sh build    # Build Docker image
./scripts/docker-dev.sh up       # Start development environment
./scripts/docker-dev.sh down     # Stop development environment
./scripts/docker-dev.sh restart  # Restart services
./scripts/docker-dev.sh logs     # Show container logs
./scripts/docker-dev.sh shell    # Open shell in container
./scripts/docker-dev.sh clean    # Clean up Docker resources
```

## Environment Variables

Required environment variables (set in `.env.docker.local`):

- `APP_KEYS` - Comma-separated list of keys for session encryption
- `API_TOKEN_SALT` - Salt for API tokens
- `ADMIN_JWT_SECRET` - Secret for admin JWT tokens
- `TRANSFER_TOKEN_SALT` - Salt for transfer tokens
- `JWT_SECRET` - Secret for JWT tokens
- `DATABASE_CLIENT` - Database client (default: better-sqlite3)
- `DATABASE_FILENAME` - Database file path (for SQLite)

## Docker Features

### Multi-stage Build
- **Development**: Live reloading with source code mounted
- **Build**: Compiles TypeScript and builds the application
- **Production**: Optimized image with only necessary files

### Security
- Non-root user for production
- Health checks included
- Proper signal handling with dumb-init

### Persistence
- Database files are persisted via volumes
- Uploaded files are preserved
- Development dependencies are cached

## Database Options

### SQLite (Default)
The configuration uses better-sqlite3 by default with data persisted in the `./data` directory.

### PostgreSQL (Optional)
To use PostgreSQL instead, update your `.env.docker.local`:

```env
DATABASE_CLIENT=postgres
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_NAME=strapi
DATABASE_USERNAME=strapi
DATABASE_PASSWORD=your-password
DATABASE_SSL=false
```

And add a PostgreSQL service to your docker-compose files.

## Production Deployment

For production deployment:

1. Use `docker-compose.prod.yml`
2. Set strong, unique values for all secrets
3. Consider using Docker Secrets or external secret management
4. Use proper SSL/TLS certificates
5. Set up monitoring and logging

## Troubleshooting

### Container won't start
- Check logs: `docker-compose logs strapi-dev`
- Verify environment variables in `.env.docker.local`
- Ensure Docker has enough resources allocated

### Permission issues
- Ensure the `data` and `database` directories exist and are writable
- Check file ownership if mounting local directories

### Performance issues
- Allocate more memory to Docker
- Use volume mounts instead of bind mounts for better performance on macOS/Windows

## Commands Reference

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Remove everything including volumes
docker-compose down -v

# Execute commands in container
docker-compose exec strapi-dev npm run build

# Open shell
docker-compose exec strapi-dev sh
```