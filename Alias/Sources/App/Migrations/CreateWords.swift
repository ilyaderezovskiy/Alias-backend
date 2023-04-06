//
//  CreateWords.swift
//  
//
//  Created by Ilya Derezovskiy on 07.04.2023.
//

import Fluent
import Vapor

struct CreateWords: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("words")
            .id()
            .field("word", .string, .required)
            .unique(on: "word")
            .field("difficulty", .int64, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("words").delete()
    }
}
