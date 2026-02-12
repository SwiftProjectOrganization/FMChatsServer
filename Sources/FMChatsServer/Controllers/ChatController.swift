//
//  ChatController.swift
//  FMChatsServer
//
//  Created by Robert Goedman on 2/10/26.
//

import Vapor

/// Controller handling chat-related API endpoints
struct ChatController: RouteCollection {
    // File-based storage in ~/Documents/FMChats
    private actor ChatStorage {
        private let storageDirectory: URL
        private let fileManager = FileManager.default
        
        init() {
            // Set up storage directory at ~/Documents/FMChats
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            self.storageDirectory = documentsURL.appendingPathComponent("FMChats")
            
            // Create directory if it doesn't exist
            try? fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        }
        
        /// Sanitizes the chat title to create a safe filename
        private func sanitizeFilename(_ title: String) -> String {
            // Replace invalid characters with underscores
            let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
            return title.components(separatedBy: invalidCharacters).joined(separator: "_")
        }
        
        /// Generates file URL for a chat
        private func fileURL(for chat: ChatDTO) -> URL {
            let sanitizedTitle = sanitizeFilename(chat.title)
            let filename = "\(sanitizedTitle).json"
            return storageDirectory.appendingPathComponent(filename)
        }
        
        /// Generates file URL from filename
        private func fileURL(filename: String) -> URL {
            storageDirectory.appendingPathComponent(filename)
        }

        func getAll() -> [ChatDTO] {
            guard let fileURLs = try? fileManager.contentsOfDirectory(
                at: storageDirectory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ).filter({ $0.pathExtension == "json" }) else {
                return []
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let chats: [ChatDTO] = fileURLs.compactMap { url in
                guard let data = try? Data(contentsOf: url),
                      let chat = try? decoder.decode(ChatDTO.self, from: data) else {
                    return nil
                }
                return chat
            }
            
            return chats.sorted { $0.timestamp > $1.timestamp }
        }

        func get(_ id: UUID) -> ChatDTO? {
            guard let fileURLs = try? fileManager.contentsOfDirectory(
                at: storageDirectory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ).filter({ $0.pathExtension == "json" }) else {
                return nil
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            for url in fileURLs {
                guard let data = try? Data(contentsOf: url),
                      let chat = try? decoder.decode(ChatDTO.self, from: data),
                      chat.id == id else {
                    continue
                }
                return chat
            }
            
            return nil
        }

        func set(_ chat: ChatDTO) {
            let fileURL = fileURL(for: chat)
            
            // Encode with pretty printing
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            
            guard let data = try? encoder.encode(chat) else {
                return
            }
            
            try? data.write(to: fileURL, options: .atomic)
        }

        func delete(_ id: UUID) {
            // Find the chat file and delete it
            guard let chat = get(id) else { return }
            let fileURL = fileURL(for: chat)
            try? fileManager.removeItem(at: fileURL)
        }
    }

    private static let storage = ChatStorage()

    func boot(routes: RoutesBuilder) throws {
        let chatsRoute = routes.grouped("chats")

        // GET /chats - Get all chats
        chatsRoute.get(use: getAllChats)

        // POST /chats - Upload a new chat
        chatsRoute.post(use: uploadChat)

        // GET /chats/:chatId - Get a specific chat
        chatsRoute.get(":chatId", use: getChat)

        // DELETE /chats/:chatId - Delete a specific chat (optional)
        chatsRoute.delete(":chatId", use: deleteChat)
    }

    /// GET /chats - Returns all chats sorted by timestamp
    func getAllChats(req: Request) async throws -> [ChatDTO] {
        req.logger.info("Fetching all chats")
        return await ChatController.storage.getAll()
    }

    /// POST /chats - Upload a new chat
    func uploadChat(req: Request) async throws -> ChatDTO {
        let chat = try req.content.decode(ChatDTO.self)
        req.logger.info("Uploading chat: \(chat.title) (ID: \(chat.id))")

        await ChatController.storage.set(chat)
        return chat
    }

    /// GET /chats/:chatId - Get a specific chat by ID
    func getChat(req: Request) async throws -> ChatDTO {
        guard let chatIdString = req.parameters.get("chatId"),
              let chatId = UUID(uuidString: chatIdString) else {
            req.logger.warning("Invalid chat ID format")
            throw Abort(.badRequest, reason: "Invalid chat ID format")
        }

        guard let chat = await ChatController.storage.get(chatId) else {
            req.logger.warning("Chat not found: \(chatId)")
            throw Abort(.notFound, reason: "Chat not found")
        }

        req.logger.info("Fetching chat: \(chat.title) (ID: \(chat.id))")
        return chat
    }

    /// DELETE /chats/:chatId - Delete a specific chat
    func deleteChat(req: Request) async throws -> HTTPStatus {
        guard let chatIdString = req.parameters.get("chatId"),
              let chatId = UUID(uuidString: chatIdString) else {
            req.logger.warning("Invalid chat ID format")
            throw Abort(.badRequest, reason: "Invalid chat ID format")
        }

        await ChatController.storage.delete(chatId)
        req.logger.info("Deleted chat: \(chatId)")
        return .noContent
    }
}
