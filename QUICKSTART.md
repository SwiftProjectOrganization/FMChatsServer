# FMChats Server - Quick Start Guide

## What You Just Built

A fully functional Vapor REST API server for syncing chats with your FMChats iOS/macOS app.

## Server Status

✅ **Server is currently running on http://localhost:8080**

## Quick Commands

### Start the Server
```bash
cd /Users/rob/Projects/Swift/FMChatsServer
./start-server.sh
```

Or manually:
```bash
swift run
```

### Stop the Server
```bash
lsof -ti:8080 | xargs kill -9
```

### Test the Server

Health check:
```bash
curl http://localhost:8080/health
```

Welcome page:
```bash
curl http://localhost:8080/
```

Get all chats:
```bash
curl http://localhost:8080/chats
```

## Using with FMChats App

1. **Make sure the server is running** on http://localhost:8080
2. **Open your FMChats app** (iOS or macOS)
3. **Create some chats** in the app
4. **Tap the Sync button** (🔄) in the toolbar
5. **Select "Upload to Server"**
6. **Select chats to upload** and tap "Upload"
7. Chats are now stored on the server AND saved as JSON files in `~/Documents/FMChats/`

### Downloading Chats

1. **Tap the Sync button** (🔄) in the toolbar
2. **Select "Download from Server"**
3. **Browse available chats** from the server
4. **Select chats to download** and tap "Download"
5. Chats are imported into your app

## What's Stored Where

### Server (In-Memory)
The server currently stores chats in memory. They will be lost when the server restarts.

### Local JSON Files
All uploaded chats are saved to:
```
~/Documents/FMChats/{uuid}.json
```

These files persist even if the server restarts or the app is closed.

## Current Test Data

The server currently has 1 test chat:
- **Title**: "Test Chat from Server"
- **ID**: 550E8400-E29B-41D4-A716-446655440000
- **Questions**: 1 question about Vapor

You can download this in your app to test the download functionality.

## Next Steps

### For Development

1. **Test Upload**:
   - Create a chat in your FMChats app
   - Upload it to the server
   - Check `~/Documents/FMChats/` for the JSON file

2. **Test Download**:
   - Download the test chat from the server
   - Verify it appears in your app

3. **Test Round-Trip**:
   - Create a chat on device A
   - Upload to server
   - Download to device B (or delete and re-download on same device)

### For Production

To make this production-ready:

1. **Add Database Storage** (replace in-memory storage)
   - PostgreSQL (recommended)
   - MongoDB
   - SQLite

2. **Add Authentication**
   - JWT tokens
   - User accounts
   - Secure endpoints

3. **Deploy to Cloud**
   - Vapor Cloud
   - Heroku
   - AWS
   - Digital Ocean

4. **Add Features**
   - Conflict resolution
   - Real-time sync with WebSockets
   - Multi-user support
   - Chat sharing

## Project Structure

```
FMChatsServer/
├── Package.swift                           # Dependencies
├── README.md                              # Full documentation
├── QUICKSTART.md                          # This file
├── start-server.sh                        # Startup script
└── Sources/
    └── FMChatsServer/
        ├── FMChatsServer.swift            # Main entry point
        ├── configure.swift                # Server configuration
        ├── Models/
        │   └── ChatDTO.swift             # Data models
        └── Controllers/
            └── ChatController.swift       # API endpoints
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/` | Welcome message |
| GET | `/chats` | Get all chats |
| POST | `/chats` | Upload a chat |
| GET | `/chats/:id` | Get specific chat |
| DELETE | `/chats/:id` | Delete a chat |

## Troubleshooting

### Port 8080 Already in Use
```bash
lsof -ti:8080 | xargs kill -9
```

### Server Won't Start
```bash
cd /Users/rob/Projects/Swift/FMChatsServer
swift package clean
swift build
./start-server.sh
```

### Can't Connect from iOS App
- Ensure server is running: `curl http://localhost:8080/health`
- Check firewall settings
- For iOS simulator: use `http://localhost:8080`
- For physical device: use your Mac's IP address (e.g., `http://192.168.1.100:8080`)

### JSON Files Not Created
Check the app's Documents directory:
```bash
ls -la ~/Documents/FMChats/
```

## Support

For more detailed information, see the full README.md in this directory.
