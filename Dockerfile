# Multi-stage build for Strapi TypeScript application
FROM node:18-alpine as base

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create app directory
WORKDIR /opt/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Development stage
FROM base as dev

# Install all dependencies including dev dependencies
RUN npm ci && npm cache clean --force

# Copy source code
COPY . .

# Expose port
EXPOSE 1337

# Start development server
CMD ["dumb-init", "npm", "run", "develop"]

# Build stage
FROM base as build

# Install all dependencies for building
RUN npm ci && npm cache clean --force

# Copy source code
COPY . .

# Set NODE_ENV to production for build
ENV NODE_ENV=production

# Build the application
RUN npm run build

# Production stage
FROM base as production

# Set NODE_ENV to production
ENV NODE_ENV=production

# Copy built application from build stage
COPY --from=build /opt/app/dist ./dist
COPY --from=build /opt/app/config ./config
COPY --from=build /opt/app/database ./database
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/favicon.png ./favicon.png

# Create non-root user
RUN addgroup -g 1001 -S strapi && \
    adduser -S strapi -u 1001

# Change ownership of app directory
RUN chown -R strapi:strapi /opt/app
USER strapi

# Expose port
EXPOSE 1337

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:1337/_health || exit 1

# Start production server
CMD ["dumb-init", "npm", "start"]