#!/bin/bash

# Deploy script for Internet Billing System

echo "🚀 Starting deployment..."

# Pull latest changes
git pull origin main

# Install dependencies
npm install --production

# Build application
npm run build

# Stop existing PM2 process
pm2 stop internet-billing || true

# Start with PM2
pm2 start pm2.config.js --env production

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup ubuntu -u $USER

echo "✅ Deployment completed!"
echo "📊 Check status: pm2 status"
echo "📝 View logs: pm2 logs internet-billing"