//
//  Word.swift
//  
//
//  Created by Ilya Derezovskiy on 07.04.2023.
//

import Fluent
import Vapor

final class Word: Model, Content {
    static let schema = "words"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "word")
    var word: String
    
    @Field(key: "difficulty")
    var difficulty: Int // 1 - high complexity, 2 - average difficulty, 3 - low difficulty

    init() { }

    init(id: UUID? = nil, word: String, difficulty: Int) {
        self.id = id
        self.word = word
        self.difficulty = difficulty
    }
}
