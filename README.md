# FMChats Server

A Vapor-based REST API server for syncing chats with the FMChats iOS/macOS application.

## Features

- RESTful API for chat synchronization
- In-memory storage (easily replaceable with database)
- CORS support for web clients
- ISO8601 date encoding for cross-platform compatibility
- Comprehensive logging

## Requirements

- Swift 6.0+
- macOS 14.0+
- Vapor 4.99.0+

## Installation

1. Clone or navigate to this directory:
```bash
cd /Users/rob/Projects/Swift/FMChatsServer
```

2. Resolve dependencies:
```bash
swift package resolve
```

3. Build the project:
```bash
swift build
```

## Running the Server

### Development Mode

Run the server directly:
```bash
swift run
```

The server will start on `http://localhost:8080`

### Production Mode

Build for release:
```bash
swift build -c release
```

Run the release binary:
```bash
.build/release/FMChatsServer
```

## API Endpoints

### Health Check
```bash
GET /health
```
Returns server health status.

**Response:**
```json
{
  "status": "ok",
  "service": "FMChatsServer",
  "timestamp": "2024-02-10T12:00:00Z"
}
```

### Get All Chats
```bash
GET /chats
```
Returns all chats sorted by timestamp (newest first).

**Response:**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Sample Chat",
    "timestamp": "2024-02-10T12:00:00Z",
    "questions": [...]
  }
]
```

### Upload Chat
```bash
POST /chats
Content-Type: application/json
```

**Request Body:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "New Chat",
  "timestamp": "2024-02-10T12:00:00Z",
  "questions": [
    {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "questionText": "What is Swift?",
      "answerText": "Swift is a programming language...",
      "timestamp": "2024-02-10T12:01:00Z"
    }
  ]
}
```

**Response:**
Returns the uploaded chat (same format as request).

### Get Specific Chat
```bash
GET /chats/:chatId
```

**Response:**
Returns the requested chat or 404 if not found.

### Delete Chat
```bash
DELETE /chats/:chatId
```

**Response:**
Returns 204 No Content on success.

## Testing with curl

```bash
# Health check
curl http://localhost:8080/health

# Get all chats
curl http://localhost:8080/chats

# Upload a chat
curl -X POST http://localhost:8080/chats \
  -H "Content-Type: application/json" \
  -d '{
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Test Chat",
    "timestamp": "2024-02-10T12:00:00Z",
    "questions": []
  }'

# Get specific chat
curl http://localhost:8080/chats/550e8400-e29b-41d4-a716-446655440000

# Delete chat
curl -X DELETE http://localhost:8080/chats/550e8400-e29b-41d4-a716-446655440000
```

## Project Structure

```
FMChatsServer/
├── Package.swift
├── README.md
├── Sources/
│   └── FMChatsServer/
│       ├── FMChatsServer.swift      # Main entry point
│       ├── configure.swift           # App configuration
│       ├── Models/
│       │   └── ChatDTO.swift        # Data models
│       └── Controllers/
│           └── ChatController.swift # API endpoints
```

## Configuration

### Port
The server runs on port 8080 by default. To change it, modify `configure.swift`:
```swift
app.http.server.configuration.port = 8080
```

### CORS
CORS is configured to allow all origins. For production, modify `configure.swift`:
```swift
let corsConfiguration = CORSMiddleware.Configuration(
    allowedOrigin: .custom("https://yourdomain.com"),
    allowedMethods: [.GET, .POST, .PUT, .DELETE],
    allowedHeaders: [.accept, .authorization, .contentType, .origin]
)
```

## Production Deployment

### Database Integration

Replace in-memory storage with a database:

1. Add Fluent dependency to `Package.swift`:
```swift
.package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
.package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
```

2. Create database models and migrations
3. Update `ChatController` to use database queries

### Security

- Add authentication middleware (JWT or session-based)
- Use HTTPS with SSL/TLS certificates
- Implement rate limiting
- Add input validation
- Set up environment variables for secrets

### Deployment Options

- **Vapor Cloud**: Official Vapor hosting platform
- **Heroku**: Easy deployment with buildpacks
- **AWS**: EC2, ECS, or Lambda
- **Docker**: Containerize for any cloud provider

## Development

### Adding New Endpoints

1. Create a new controller in `Controllers/`
2. Register it in `configure.swift`:
```swift
try app.register(collection: YourController())
```

### Logging

The server uses Vapor's built-in logging:
```swift
req.logger.info("Your message")
req.logger.warning("Warning message")
req.logger.error("Error message")
```

## Troubleshooting

### Port Already in Use
```bash
lsof -ti:8080 | xargs kill -9
```

### Build Errors
```bash
swift package clean
swift package resolve
swift build
```

### Connection Refused from iOS App
- Ensure server is running
- Check firewall settings
- Verify iOS app is using correct URL (http://localhost:8080)
- For iOS simulator, localhost should work
- For physical device, use your Mac's IP address

## License

This project is part of the FMChats application.
