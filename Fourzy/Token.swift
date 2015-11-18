//
//  Token.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/20/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

import SpriteKit

class Token: CustomStringConvertible, Hashable {
    var column: Int
    var row: Int
    let tokenType: TokenType
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, tokenType: TokenType) {
        self.column = column
        self.row = row
        self.tokenType = tokenType
    }
    
    var description: String {
        return "type:\(tokenType) square:(\(column),\(row))"
    }
    
    var hashValue: Int {
        return row*10 + column
    }
}

enum TokenType: Int, CustomStringConvertible {
    
    case None = 0, Sticky, UpArrow, DownArrow, LeftArrow, RightArrow, Blocker
    
    var spriteName: String {
        let spriteNames = [
            "Sticky1",
            "UpArrow",
            "DownArrow",
            "LeftArrow",
            "RightArrow",
            "Blocker"]
        
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    static func random() -> TokenType {
        return TokenType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
    
    var description: String {
        return spriteName
    }
}

func ==(lhs: Token, rhs: Token) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}
