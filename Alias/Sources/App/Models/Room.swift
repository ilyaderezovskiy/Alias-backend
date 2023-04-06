//
//  Room.swift
//  
//
//  Created by Ilya Derezovskiy on 06.04.2023.
//

import Fluent
import Vapor

final class Room: Model, Content {
    static let schema = "rooms"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "adminID")
    var adminID: UUID?
    
    @Field(key: "playersID")
    var playersID: [UUID]
    
    @Field(key: "difficulty")
    var difficulty: Int // 1 - high complexity, 2 - average difficulty, 3 - low difficulty
    
    @Field(key: "isOpen")
    var isOpen: Bool
    
    @Field(key: "code")
    var code: Int?
    
    @Field(key: "points")
    var points: Int
    
    @Field(key: "gameTime")
    var gameTime: Int
    
    @Field(key: "teamsCount")
    var teamsCount: Int
    

    init() { }

    init(id: UUID? = nil, adminID: UUID? = nil, playersID: [UUID], difficulty: Int, isOpen: Bool, code: Int? = nil, points: Int, gameTime: Int, teamsCount: Int) {
        self.id = id
        self.adminID = adminID
        self.playersID = playersID
        self.difficulty = difficulty
        self.isOpen = isOpen
        self.code = code
        self.points = points
        self.gameTime = gameTime
        self.teamsCount = teamsCount
    }
}
