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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if (isMultiplayer && currentMatch != nil) {
            if currentMatch.status == GKTurnBasedMatchStatus.Ended {
                return
            }
            if GKLocalPlayer.localPlayer().playerID != currentMatch.currentParticipant.playerID {
                return
            }
        }

        if let sprite = activePiece?.sprite {
            if sprite.hasActions() {
                return
            }
        }
        
        var touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(piecesLayer)
        
        if (touchedActivePiece(touchLocation)) {
            println("touched active piece")
            assert(activePieces.count > 0)
            for piece in activePieces {
                piece.generateActions()
            }

            let piece = activePieces[activePieces.count-1]
            
            // update board model
            for activePiece in activePieces {
                let destination = activePiece.moveDestinations[0]
                board.addPieceAtColumn(destination.column, row: destination.row, piece: activePiece)
            }

            activePiece = piece
            assert(piece.moveDestinations.count > 0)
            
            piece.sprite?.removeAllActions()
            piece.sprite?.size = CGSize(width: kPieceSize, height: kPieceSize)
            
            piece.animate()
            
            let destination = piece.moveDestinations[0]
            self.gameData.currentMove.extend([destination.column, destination.row, piece.direction.rawValue])

            self.removeHighlights()
            println("active player: " + self.activePlayer.description)
            checkForWinnerAndUpdateMatch(true)
            activePieces.removeAtIndex(activePieces.count-1)
            
            rotateActivePlayer()
            
//            if activePieces.count > 0 {
//                activePieces.removeAll(keepCapacity: false)
//            }

            // TODO: Tie if no more possible moves
            
            board.printBoard()
            
            if self.isMultiplayer {
                advanceTurn()
            }
        } else {
            if activePieces.count > 0 {
                activePieces[activePieces.count-1].sprite?.removeFromParent()
                activePieces.removeAll(keepCapacity: false)
            }
            
            let (success, column, row, direction) = convertPoint(touchLocation)
            if success {
                //println("touchlocation: x: \(touchLocation.x), y: \(touchLocation.y)")
                //println("column: \(column), row: \(row)")
                assert(column >= 0 && column < NumColumns)
                assert(row >= 0 && row < NumRows)
                
                if let piece = placePieceAtColumn(column, row: row, pieceType: activePlayer, direction: direction) {
                    activePieces.append(piece)
                    piece.pulseAnimation()
                    //pulseAnimation(piece.sprite!)
                    self.addGamePieceHighlightFrom(row, column: column, direction: direction)
                }
            }
        }
    }
}
