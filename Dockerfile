# --- STAGE 1: BUILDER ---
# Use a full Node image for building dependencies (npm ci is faster and locks versions)
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /usr/src/app

# Copy package files and install dependencies
# We use npm ci to ensure immutable dependency installation (faster and safer than npm install)
COPY package*.json ./
RUN npm ci --only=production 

# --- STAGE 2: PRODUCTION ---
# Use a small, production-optimized base image (node:20-slim or alpine are common)
FROM node:20-alpine AS production

# Set the working directory
WORKDIR /usr/src/app

# Copy only the compiled code and production dependencies from the builder stage
# This ensures no dev dependencies or build tools are in the final image
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY . .

# Set the environment variable required for production Node performance
ENV NODE_ENV production
ENV PORT 3000

# Expose the application port
EXPOSE 3000

# Start the application
CMD [ "node", "index.js" ]
