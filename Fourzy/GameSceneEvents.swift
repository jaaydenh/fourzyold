//
//  GameSceneEvents.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/13/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

import SpriteKit
import GameKit

extension GameScene {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let sprite = activePiece?.sprite {
            if sprite.hasActions() {
                return
            }
        }
        
        if activePieces.count > 0 {
            activePieces[activePieces.count-1].sprite?.removeFromParent()
            activePieces.removeAll(keepCapacity: false)
        }
        
        self.removeHighlights()
        
        let touch = touches.first
        let touchLocation = touch!.locationInNode(piecesLayer)
        
        let (success, column, row, direction) = convertPoint(touchLocation)
        if success {
            assert(column >= 0 && column < NumColumns)
            assert(row >= 0 && row < NumRows)
            
            // Communicate this touch back to the ViewController.
            if let handler = touchHandler {
                let position = GridPosition(column: column, row: row, direction: direction)
                handler(position)
            }
        } else {
            submitButton?.hidden = true
        }
    }
    
    // Converts a point relative to the board into a column, row and direction
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int, direction: Direction) {
        
        let y = Int(point.y)
        let x = Int(point.x)
        let row = (y - kTapAreaWidth) / kTileHeight
        let column = (x - kTapAreaWidth) / kTileWidth
        
        if topActionArea.containsPoint(point) {
            return (true, column, Int(kNumRows - 1), .Down)
        } else if bottomActionArea.containsPoint(point) {
            return (true, column, 0, .Up)
        } else if rightActionArea.containsPoint(point) {
            return (true, Int(kNumColumns - 1), row,  .Left)
        } else if leftActionArea.containsPoint(point) {
            return (true, 0, row, .Right)
        } else {
            return (false, 0, 0, .Up)
        }
    }
}
