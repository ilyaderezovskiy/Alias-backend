//
//  File.swift
//  
//
//  Created by Ilya Derezovskiy on 28.03.2023.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.get(":id", use: getHandler)
        users.post(use: create)
        users.group(":id") { task in
            task.delete(use: delete)
        }
        users.post("auth", use: authHandler)
    }

    // Получение всех пользователей
    func index(req: Request) async throws -> [User.Public] {
        let users = try await User.query(on: req.db).all()
        let publics = users.map { user in
            user.asPublic()
        }
        return publics
    }

    // Получение пользователя по id
    func getHandler(req: Request) async throws -> User.Public {
        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return user.asPublic()
    }
    
    // Создание нового пользователя
    func create(req: Request) async throws -> User.Public {
        let user = try req.content.decode(User.self)
        user.passwordHash = try Bcrypt.hash(user.passwordHash)
        try await user.save(on: req.db)
        return user.asPublic()
    }

    // Удаление пользователя по id
    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .noContent
    }
    
    // Авторизация пользователя
    func authHandler(req: Request) async throws -> User.Public {
        let userDTO = try req.content.decode(AuthUserDTO.self)
        guard let user = try await User
            .query(on: req.db)
            .filter("username", .equal, userDTO.username)
            .first() else {
            throw Abort(.notFound)
        }
        let isPassEqual = try Bcrypt.verify(userDTO.password, created: user.passwordHash)
        guard isPassEqual else {
            throw Abort(.unauthorized)
        }
        return user.asPublic()
    }
}

struct AuthUserDTO: Content {
    let username: String
    var password: String
}
