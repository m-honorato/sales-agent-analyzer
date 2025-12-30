#!/bin/bash

echo "🐳 Starting n8n Docker Container..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "❌ Docker is not running!"
  echo ""
  echo "Please:"
  echo "1. Open Docker Desktop (search in Spotlight)"
  echo "2. Wait for whale icon in menu bar to be steady"
  echo "3. Run this script again"
  exit 1
fi

echo "✅ Docker is running"

# Remove old n8n container if it exists
echo "🧹 Cleaning up old containers..."
docker rm -f n8n 2>/dev/null

# Start fresh n8n container
echo "🚀 Starting n8n..."
docker run -d \
  --name n8n \
  --restart unless-stopped \
  -p 5678:5678 \
  -e N8N_SECURE_COOKIE=false \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n:latest

# Wait for n8n to start
echo "⏳ Waiting for n8n to initialize (30 seconds)..."
sleep 30

# Check if running
if docker ps | grep -q n8n; then
  echo ""
  echo "✅ SUCCESS! n8n is running!"
  echo ""
  echo "🌐 Access at: http://localhost:5678"
  echo ""
  echo "🔐 First time? You'll need to create an admin account."
  echo ""
  
  # Open in browser
  open http://localhost:5678
else
  echo ""
  echo "❌ n8n failed to start. Logs:"
  docker logs n8n --tail 50
fi







