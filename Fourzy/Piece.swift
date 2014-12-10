//
//  Piece.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/16/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

import SpriteKit

class Piece: Printable, Hashable {
    let column: Int
    let row: Int
    let pieceType: PieceType
    let direction: Direction
    var moveDestination: CGPoint!
    var actions: [SKAction] = []
    var moveDestinations: [GridPosition] = []
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, pieceType: PieceType, direction: Direction) {
        self.column = column
        self.row = row
        self.pieceType = pieceType
        self.direction = direction
        self.moveDestinations = []
    }
    
    var description: String {
        return "type:\(pieceType) square:(\(column),\(row))"
    }
    
    var hashValue: Int {
        return row*10 + column
    }
    
    func resetMovement() {
        actions.removeAll(keepCapacity: false)
        moveDestinations.removeAll(keepCapacity: false)
    }
    
    func generateActions() {
        if var lastPosition = sprite?.position {
            for position in moveDestinations.reverse() {
                let moveLocation = CGPoint(x: position.column * Int(kTileWidth) + Int(kTapAreaWidth), y: position.row * Int(kTileHeight) + Int(kTapAreaWidth))
                var xDiff:Double = Double(moveLocation.x - lastPosition.x)
                var yDiff:Double = Double(moveLocation.y - lastPosition.y)
                var distance = sqrt(xDiff * xDiff + yDiff * yDiff)
                let move = SKAction.moveTo(moveLocation, duration: distance/260.0)
                actions.append(move)
                lastPosition = moveLocation;
                moveDestination = moveLocation;
            }
        }
    }
    
    func animate() {
        let sequence = SKAction.sequence(actions)
        if let sprite = sprite {
            sprite.removeAllActions()
            sprite.runAction(sequence)
        }
    }
}

enum PieceType: Int, Printable {
    case None = 0, Player1, Player2
    
    var spriteName: String {
        let spriteNames = [
            "gamepiece4",
            "gamepiece6"]
        
        return spriteNames[rawValue - 1]
    }
    
    var description: String {
        return spriteName
    }
}

func ==(lhs: Piece, rhs: Piece) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}
