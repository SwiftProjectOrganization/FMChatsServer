#!/bin/bash

# FMChats Server Startup Script

echo "Starting FMChats Server..."

# Navigate to server directory
cd "$(dirname "$0")"

# Check if server is already running
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null ; then
    echo "Server is already running on port 8080"
    echo "To stop it, run: lsof -ti:8080 | xargs kill -9"
    exit 1
fi

# Build if needed
if [ ! -f ".build/debug/FMChatsServer" ]; then
    echo "Building server..."
    swift build
fi

# Start the server
echo "Server starting on http://localhost:8080"
.build/debug/FMChatsServer serve
