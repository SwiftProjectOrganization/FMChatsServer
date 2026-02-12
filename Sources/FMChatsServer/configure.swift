//
//  configure.swift
//  FMChatsServer
//
//  Created by Robert Goedman on 2/10/26.
//

import Vapor

/// Configures the Vapor application
public func configure(_ app: Application) async throws {
    // Configure server hostname and port
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8082

    // Configure JSON encoding/decoding
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    ContentConfiguration.global.use(encoder: encoder, for: .json)

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    ContentConfiguration.global.use(decoder: decoder, for: .json)

    // Configure CORS to allow requests from any origin (adjust for production)
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors)

    // Register routes
    try routes(app)

    // Log server start
    app.logger.info("FMChats server configured and ready")
    app.logger.info("Server listening on http://localhost:\(app.http.server.configuration.port)")
}

/// Registers all routes
func routes(_ app: Application) throws {
    // Health check endpoint
    app.get("health") { req async -> [String: String] in
        req.logger.info("Health check requested")
        return [
            "status": "ok",
            "service": "FMChatsServer",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
    }

    // Welcome endpoint
    app.get { req async -> String in
        """
        Welcome to FMChats Server!

        Available endpoints:
        - GET  /health            - Health check
        - GET  /chats             - Get all chats
        - POST /chats             - Upload a chat
        - GET  /chats/:id         - Get specific chat
        - DELETE /chats/:id       - Delete specific chat

        Server is running on port \(app.http.server.configuration.port)
        """
    }

    // Register chat routes
    try app.register(collection: ChatController())
}
