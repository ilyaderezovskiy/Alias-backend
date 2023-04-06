//
//  CreateRooms.swift
//  
//
//  Created by Ilya Derezovskiy on 06.04.2023.
//

import Fluent
import Vapor

struct CreateRooms: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("rooms")
            .id()
            .field("adminID", .uuid, .required)
            .field("playersID", .array(of: .uuid), .required)
            .field("difficulty", .int64, .required)
            .field("isOpen", .bool, .required)
            .field("code", .int64)
            .field("points", .int64, .required)
            .field("gameTime", .int64, .required)
            .field("teamsCount", .int64, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("rooms").delete()
    }
}

