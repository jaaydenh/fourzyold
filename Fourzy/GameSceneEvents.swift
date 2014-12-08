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

            let piece = activePieces[0]
            activePiece = piece
            assert(piece.moveDestinations.count > 0)
            //activePieces.removeAtIndex(0)
            
            piece.animate()
            
            let destination = piece.moveDestinations[0]
            //board.addPieceAtColumn(destination.column, row: destination.row, piece: piece)
            self.gameData.currentMove.extend([destination.column, destination.row, piece.direction.rawValue])

            rotateActivePlayer()
            
//            [self removeHighlights];
            
            // update board model
            for activePiece in activePieces {
                let destination = activePiece.moveDestinations[0]
                board.addPieceAtColumn(destination.column, row: destination.row, piece: activePiece)
            }
            

            
//            var winner = board.checkForWinnerAtRow(destination.row, column: destination.column)
//            if (winner != PieceType.None) {
//                winners.append(winner)
//            }
            
            checkForWinnerAndUpdateMatch(true)
//            var winners:[PieceType] = []
//            
//            for activePiece in activePieces {
//                let destination = activePiece.moveDestinations[0]
//                var winner = board.checkForWinnerAtRow(destination.row, column: destination.column)
//                if (winner != PieceType.None) {
//                    winners.append(winner)
//                }
//            }
////          [self printBoard];
//            
//            if (winners.count > 0) {
//                var player1Wins = 0;
//                var player2Wins = 0;
//                var winner = PieceType.None
//                
//                for pieceType in winners {
//                    if pieceType == PieceType.Player1 {
//                        player1Wins++;
//                    } else if pieceType == PieceType.Player2 {
//                        player2Wins++;
//                    }
//                }
//                if (player1Wins > 0 && player2Wins > 0) {
//                    winner = PieceType.None
//                } else if (player1Wins > 0) {
//                    winner = PieceType.Player1
//                } else if (player2Wins > 0) {
//                    winner = PieceType.Player2
//                }
//                
//                endMatchWithWinner(winner)
//            }
            if activePieces.count > 0 {
                activePieces.removeAll(keepCapacity: false)
            }
//
//            //TODO: Tie if no more possible moves
            if self.isMultiplayer {
                advanceTurn()
            }
        } else {
            if activePieces.count > 0 {
                activePieces[0].sprite?.removeFromParent()
                activePieces.removeAll(keepCapacity: false)
            }
            
            //[self removeHighlights];
            
            //var piece: Piece;
            
            let (success, column, row, direction) = convertPoint(touchLocation)
            if success {
                println("touchlocation: x: \(touchLocation.x), y: \(touchLocation.y)")
                println("column: \(column), row: \(row)")
                assert(column >= 0 && column < NumColumns)
                assert(row >= 0 && row < NumRows)
                
                if let piece = placePieceAtColumn(column, row: row, pieceType: activePlayer, direction: direction) {
                    activePieces.append(piece)
                }
            }
        }
    }
}
