//
//  RoomController.swift
//  
//
//  Created by Ilya Derezovskiy on 06.04.2023.
//

import Fluent
import Vapor
import Foundation

struct RoomController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let rooms = routes.grouped("rooms")
        rooms.get(use: index)
        rooms.get(":roomID", use: getHandler)
        
        rooms.post(use: create)
        rooms.delete(":roomID", use: delete)
        rooms.put(":roomID", ":adminID", use: updateAdmin)
        rooms.put(":roomID", "updatepoints", ":newPoints", use: updatePoints)
        rooms.put(":roomID", use: addPlayer)
        rooms.delete(":roomID", ":playerID", use: removePlayer)
        
//        let basicMW = User.authenticator()
//        let guardMW = User.guardMiddleware()
//        let protected = rooms.grouped(basicMW, guardMW)
//        protected.post(use: create)
//        protected.delete(":roomID", use: delete)
//        protected.put(":roomID", use: update)
    }

    // Получение всех комнат
    func index(req: Request) async throws -> [Room] {
        try await Room.query(on: req.db).all()
    }
    
    // Получение комнат по id админа
//    func getUserHandler(req: Request) async throws -> [Room] {
//        var rooms = try await Room.query(on: req.db).all()
//        return rooms.filter({$0.adminID == req.parameters.get("adminID")})
//    }

    // Получение комнаты по id комнаты
    func getHandler(req: Request) async throws -> Room {
        guard let room = try await Room.find(req.parameters.get("roomID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return room
    }
    
    // Создание комнаты
    func create(req: Request) async throws -> Room {
        let room = try req.content.decode(Room.self)
        try await room.save(on: req.db)
        return room
    }
    
    // Изменение админа по id комнаты
    // http://127.0.0.1:8080/rooms/{roomID}/{newAdminID}
    func updateAdmin(req: Request) async throws -> Room {
        guard let room = try await Room.find(req.parameters.get("roomID"), on: req.db) else {
            throw Abort(.notFound)
        }

        room.adminID = req.parameters.get("adminID")
        
        try await room.save(on: req.db)
        
        return room
    }
    
    // Изменение значения баллов, получаемых за верный ответ, по id комнаты и новому значению баллов
    // http://127.0.0.1:8080/rooms/{roomID}/updatepoints/{newPointsValue}
    func updatePoints(req: Request) async throws -> Room {
        guard let room = try await Room.find(req.parameters.get("roomID"), on: req.db) else {
            throw Abort(.notFound)
        }

        let newPoints: Int? = Int(req.parameters.get("newPoints")!)

        if (newPoints != nil) {
            room.points = newPoints!
        } else {
            return room
        }
        
        try await room.save(on: req.db)
        
        return room
    }
    
    // Добавление нового пользователя в комнату (закрытую и открытую) по id комнаты
    func addPlayer(req: Request) async throws -> Room {
        guard let room = try await Room.find(req.parameters.get("roomID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let newPlayer = try req.content.decode(newPlayerDTO.self)
        
        if room.isOpen {
            if room.playersID.contains(newPlayer.playerID) == false {
                room.playersID.append(newPlayer.playerID)
            } else {
                return room
            }
        } else {
            if room.code == newPlayer.code && room.playersID.contains(newPlayer.playerID) == false {
                room.playersID.append(newPlayer.playerID)
            } else {
                return room
            }
        }
        
        try await room.save(on: req.db)
        return room
    }
    
    // Удаление пользователя из комнаты по id комнаты и id пользователя
    // http://127.0.0.1:8080/rooms/{roomID}/{userID}
    func removePlayer(req: Request) async throws -> Room {
        guard let room = try await Room.find(req.parameters.get("roomID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        room.playersID = room.playersID.filter({$0 != req.parameters.get("playerID")})
        try await room.save(on: req.db)
    
        return room
    }

    // Удалениие (закрытие) комнаты
    func delete(req: Request) async throws -> HTTPStatus {
        guard let room = try await Room.find(req.parameters.get("roomID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await room.delete(on: req.db)
        return .noContent
    }
}

struct newPlayerDTO: Content {
    let playerID: UUID
    let code: Int?
}
