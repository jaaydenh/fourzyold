//
//  Piece.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/16/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

import SpriteKit

class Piece: Printable, Hashable {
    var column: Int
    var row: Int
    let pieceType: PieceType
    let direction: Direction
    var moveDestination: CGPoint!
    var actions: [SKAction] = []
    var moveDestinations: [GridPosition] = []
    var sprite: SKSpriteNode?
    
    init(move: Move) {
        self.column = move.column
        self.row = move.row
        self.pieceType = move.player
        self.direction = move.direction
        self.moveDestinations = []
    }
    
    var description: String {
        return "\(pieceType)"
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
                let moveLocation = CGPoint(x: position.column * Int(kTileWidth) + Int(kTapAreaWidth) + kPieceSize/2, y: position.row * Int(kTileHeight) + Int(kTapAreaWidth) + kPieceSize/2)
                var xDiff:Double = Double(moveLocation.x - lastPosition.x)
                var yDiff:Double = Double(moveLocation.y - lastPosition.y)
                var distance = sqrt(xDiff * xDiff + yDiff * yDiff)
                let move = SKAction.moveTo(moveLocation, duration: distance/260.0)
                actions.append(move)
                lastPosition = moveLocation
                moveDestination = moveLocation
            }
        }
    }
    
    func pulseAnimation() {
        sprite?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        var pulseActions: [SKAction] = [];
        var moveActions: [SKAction] = [];
        let growAction = SKAction.resizeToWidth(CGFloat(kPieceSize+7), height: CGFloat(kPieceSize+7), duration: 0.5)
        let growMove = SKAction.moveByX(-0.5, y: -0.5, duration: 0.5)
        let shrinkAction = SKAction.resizeToWidth(CGFloat(kPieceSize), height: CGFloat(kPieceSize), duration: 0.5)
        let shrinkMove = SKAction.moveByX(0.5, y: 0.5, duration: 0.5)
        
        pulseActions.append(growAction)
        moveActions.append(growMove)
        pulseActions.append(shrinkAction)
        moveActions.append(shrinkMove)

        let sequence1 = SKAction.sequence(pulseActions)
        let sequence2 = SKAction.sequence(moveActions)
        let pulse = SKAction.repeatActionForever(sequence1)
        //let move = SKAction.repeatActionForever(sequence2)
        sprite?.runAction(pulse)
        //sprite?.runAction(move)
    }
    
    func animate() {
        let sequence = SKAction.sequence(actions)
        if let sprite = sprite {
            sprite.removeAllActions()
            sprite.runAction(sequence)
        }
    }
    
    func setColumn(column: Int) {
        self.column = column
    }
    
    func setRow(row: Int) {
        self.row = row
    }
}

enum PieceType: Int, Printable {
    case None = 0, Player1, Player2
    
    var spriteName: String {
        let spriteNames = [
            "blue_piece",
            "red_piece"]
        
        return spriteNames[rawValue - 1]
    }
    
    var description: String {
        return String(rawValue)
    }
}

func ==(lhs: Piece, rhs: Piece) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}
