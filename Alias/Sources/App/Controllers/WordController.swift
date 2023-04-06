//
//  WordController.swift
//  
//
//  Created by Ilya Derezovskiy on 07.04.2023.
//

import Fluent
import Vapor

struct WordController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let words = routes.grouped("words")
        words.post(use: create)
        words.get(":level", use: getHandler)
    }

    // Создание всех слов
    func create(req: Request) async throws -> [Word] {
        let words: [Word] = [Word(word: "Киркоров", difficulty: 2),
                             Word(word: "Крысолов", difficulty: 2),
                             Word(word: "Кот Леопольд", difficulty: 2),
                             Word(word: "Лес", difficulty: 1),
                             Word(word: "Пар", difficulty: 1),
                             Word(word: "Дом", difficulty: 1),
                             Word(word: "Противовоздушная оборона", difficulty: 3),
                             Word(word: "Пытаться", difficulty: 3),
                             Word(word: "Искусственный интеллект", difficulty: 3)]
        

        for word in words {
            try await word.save(on: req.db)
        }
        
        return words
    }
    
    // Получение всех слов заданного уровня
    func getHandler(req: Request) async throws -> [String] {
        let level: Int? = Int(req.parameters.get("level")!)
        let words = try await Word.query(on: req.db).all().filter({ $0.difficulty == level} )
    
        return words.map{ $0.word }
    }
}
