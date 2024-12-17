# Stage 1: Build the React app
FROM node:latest AS build

# Set the working directory for the app
WORKDIR /app

# Copy only package.json and package-lock.json (to utilize Docker cache for dependencies)
COPY package*.json ./

# Clear npm cache and install only production dependencies (for production mode)
RUN rm -rf /root/.npm && npm install --legacy-peer-deps --production

# Copy the rest of the application code
COPY . .

# Build the React app for production
RUN npm run build

# Stage 2: Serve the app with Nginx
FROM nginx:alpine

# Remove the default Nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy the built React app from the previous stage to the Nginx web directory
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 3000 (instead of the default port 80)
EXPOSE 3000

# Update the Nginx configuration to listen on port 3000
RUN echo 'server { listen 3000; server_name localhost; location / { root /usr/share/nginx/html; try_files $uri /index.html; } }' > /etc/nginx/conf.d/default.conf

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
