//
//  GameViewController.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/7/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData!)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, GKLocalPlayerListener {
    
    @IBOutlet var loadingProgressIndicator: UIActivityIndicatorView!
    
    var scene: GameScene!
    var board: Board!
    var match: GKTurnBasedMatch!
    var activePlayer: PieceType = PieceType.Player1
    var isOnline = true
    var isSinglePlayer = false
    var currentMatch: GKTurnBasedMatch!
    var gameData: GameKitMatchData = GameKitMatchData()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.registerListener(self)
        
        // Start the progress indicator animation.
        loadingProgressIndicator.startAnimating()
        
        GameScene.loadSceneAssetsWithCompletionHandler {

            let skView = self.view as! SKView
            //skView.frameInterval = 4
            //skView.showsDrawCount = true
            //skView.showsFPS = true
            skView.multipleTouchEnabled = false
            skView.ignoresSiblingOrder = true
            
            // On iPhone/iPod touch we want to see a similar amount of the scene as on iPad.
            // So, we set the size of the scene to be double the size of the view, which is
            // the whole screen, 3.5- or 4- inch. This effectively scales the scene to 50%.
            //            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            //                viewSize.height *= 2
            //                viewSize.width *= 2
            //            }
        
            var viewSize = self.view.bounds.size
            self.scene = GameScene(size: viewSize)
            self.scene.scaleMode = .AspectFill
            self.currentMatch = self.match

            self.scene.touchHandler = { [unowned self](GridPosition) in self.handleTouch(GridPosition)}
//            self.scene.touchHandler = {
//                [unowned self] in self.handleTouch
//            }()
            self.scene.submitMoveHandler = { [unowned self] in self.handleSubmitMove()}
            
            self.loadingProgressIndicator.stopAnimating()
            self.loadingProgressIndicator.hidden = true
            
            if self.isOnline {
                self.loadPlayerPhotos()
            }

            skView.presentScene(self.scene)
            
            activePieces.removeAll(keepCapacity: false)
            self.layoutMatch()
            
            //UIView.animateWithDuration(2.0) {
                //self.archerButton.alpha = 1.0
                //self.warriorButton.alpha = 1.0
            //}
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
//        super.viewDidDisappear(true)
//        activePieces.removeAll(keepCapacity: false)
//        var test:SKView = self.view as! SKView
//            test.presentScene(nil)
    }
    
    func handleSubmitMove() {
        println("# GameViewController:handleSubmitMove")
        
        if (isOnline && currentMatch != nil) {
            if currentMatch.status == GKTurnBasedMatchStatus.Ended {
                return
            }
            if GKLocalPlayer.localPlayer().playerID != currentMatch.currentParticipant.playerID {
                return
            }
        }
        
        submitMove()
        {
            //activePieces.removeAtIndex(activePieces.count-1)
            self.board.printBoard()
            if self.isSinglePlayer == true {
                if self.activePlayer == .Player2 {
                    self.aiMove()
                }
            }
        }
        println("# test")
    }
    
    func submitMove(completion: () -> ()) {
        
        if (activePieces.count > 0) {
            for piece in activePieces {
                piece.generateActions()
            }
            
            let piece = activePieces[activePieces.count-1]
            
            // update board model
            for activePiece in activePieces {
                let destination = activePiece.moveDestinations[0]
                board.addPieceAtColumn(destination.column, row: destination.row, piece: activePiece)
            }
            
            self.scene.activePiece = piece
            assert(piece.moveDestinations.count > 0)
            
            piece.sprite?.removeAllActions()
            piece.sprite?.size = CGSize(width: kPieceSize, height: kPieceSize)

            scene.removeHighlights()
            
            let destination = piece.moveDestinations[piece.moveDestinations.count-1]
            self.gameData.currentMove.extend([destination.column, destination.row, piece.direction.rawValue])
            
            self.checkForWinnerAndUpdateMatch(true)
            activePieces.removeAtIndex(activePieces.count-1)
            
            piece.animate() {
                self.rotateActivePlayer()
                
                //            if activePieces.count > 0 {
                //                activePieces.removeAll(keepCapacity: false)
                //            }
                
                // TODO: Tie if no more possible moves
                
                self.board.printBoard()
                
                if self.isOnline {
                    self.advanceTurn()
                }
                self.scene.setActivePlayerIndicator(self.activePlayer)
                self.scene.submitButton?.hidden = true
                completion()
            }
        }
    }
    
    // This is the touch handler. GameScene invokes this function whenever it
    // detects that the player touches the screen.
    func handleTouch(gridPosition: GridPosition) {
        
        if (isOnline && currentMatch != nil) {
            if currentMatch.status == GKTurnBasedMatchStatus.Ended {
                return
            }
            if GKLocalPlayer.localPlayer().playerID != currentMatch.currentParticipant.playerID {
                return
            }
        }
        
        // dont allow user interaction while a move is being made
        view.userInteractionEnabled = false
        
        activePieces.removeAll(keepCapacity: false)
        
        let move = Move(column: gridPosition.column, row: gridPosition.row, direction: gridPosition.direction, player: activePlayer)
        
        if let piece = performMove(move) {
            activePieces.append(piece)
            piece.pulseAnimation()
            scene.addHighlightForMove(move)
            scene.submitButton?.hidden = false
        }
        
        view.userInteractionEnabled = true
    }
    
    func performMove(move: Move) -> Piece? {
        let piece = Piece(move: move)
        let canMove = board.getDestinationForPiece(piece, move: move)
        if canMove {
            scene.addSpriteForPiece(piece, isPieceOnBoard: false)
            return piece
        }
        
        return nil
    }
    
    func aiMove() {
        var currentPiece:Piece!
        do {
            var column = Int(arc4random_uniform(8))
            var row = Int(arc4random_uniform(8))
            if let direction = Direction(rawValue: Int(arc4random_uniform(4)) + 1) {
                if direction == .Up {
                    row = 0
                } else if direction == .Down {
                    row = kNumRows - 1
                } else if direction == .Left {
                    column = kNumColumns - 1
                } else if direction == .Right {
                    column = 0
                }
        
                let move = Move(column: column, row: row, direction: direction, player: activePlayer)
                if let piece = performMove(move) {
                    currentPiece = piece
                    activePieces.append(piece)
                    self.handleSubmitMove()
                }
            }
        } while currentPiece == nil
    }
    
    func processPieceAtColumn(move: Move) {
        //assert(board.pieceAtColumn(column, row: row) == nil, "Trying to make a move at a non empty space")
        let piece = Piece(move: move)
        activePieces.append(piece)
        
        let canMove = board.getDestinationForPiece(piece, move: move)
        
        for piece in activePieces {
            let destination = piece.moveDestinations[0]
            piece.column = destination.column
            piece.row = destination.row
            // update gameboard model with destination of gamepiece
            board.addPieceAtColumn(destination.column, row: destination.row, piece: piece)
        }
        activePieces.removeAll(keepCapacity: false)
    }
    
    func advanceTurn() {
        println("# GameViewController:advanceTurn")
        let currentMatch:GKTurnBasedMatch = self.currentMatch //GameKitTurnBasedMatchHelper.sharedInstance().currentMatch
        let updatedMatchData:NSData = self.gameData.encodeMatchData()
        var nextParticipant:GKTurnBasedParticipant!
        if currentMatch.status != GKTurnBasedMatchStatus.Ended {
            if currentMatch.participants.count >= 2 {
                
                nextParticipant = getOpponentForMatch(currentMatch)
                
                let currentParticipant = participantForLocalPlayerInMatch(currentMatch)
                let currentPlayerName = PlayerCache.sharedManager.players[currentParticipant.playerID]!
                
                currentMatch.setLocalizableMessageWithKey("%@ has made a move!", arguments: [currentPlayerName.alias])
                currentMatch.message = "\(currentPlayerName.alias) has made a move!"
                let sortedParticipants:[GKTurnBasedParticipant] = [nextParticipant, currentMatch.currentParticipant]
                
                currentMatch.endTurnWithNextParticipants(sortedParticipants, turnTimeout: GKTurnTimeoutDefault, matchData: updatedMatchData) { (error) -> Void in
                    if (error != nil) {
                        println(error)
                    }
                }
                //println("Send Turn, \(updatedMatchData), \(nextParticipant)")
            }
        }
    }
    
    func layoutMatch()
    {
        println()
        self.activePlayer = PieceType.Player1
        board = Board()

        scene.setupScene()
        
        if let match = currentMatch {
            println("# GameScene:LayoutMatch: existing match")
            
            match.loadMatchDataWithCompletionHandler({ (matchData:NSData!, error:NSError!) -> Void in
                if (error != nil)
                {
                    println("Error fetching matches: \(error.localizedDescription)")
                } else {
                    
                    if let matchData = matchData {
                        self.gameData = GameKitMatchData(matchData: matchData)
                        
                        // The first time a match is loaded generate the tokens if this has not already been done
                        if self.gameData.tokenLayout.count == 0 {
                            let boardNumber = Int(arc4random_uniform(41))
                            self.board.initTokensWithBoard("Board_" + String(boardNumber))
                            //self.board.initTokensWithBoard("Board_27")
                            
                            for var row = kNumRows - 1; row >= 0; row-- {
                                for var column = 0; column < kNumColumns; column++ {
                                    if let token = self.board.tokenAtColumn(column, row: row) {
                                        self.gameData.tokenLayout.append(token.tokenType.rawValue)
                                    }
                                }
                            }
                            
                            match.saveCurrentTurnWithMatchData(self.gameData.encodeMatchData(), completionHandler: { (error) -> Void in
                                if (error != nil)
                                {
                                    println("Error saving current turn with match data: \(error.localizedDescription)")
                                }
                            })
                            
                            self.renderBoardTokens()
                        } else {
                            //[self initTokensWithDimention:self.boardRows]
                            var layoutPos = 0
                            
                            for var row = kNumRows - 1; row >= 0; row-- {
                                for var column = 0; column < kNumColumns; column++ {
                                    if let tokenType = TokenType(rawValue: self.gameData.tokenLayout[layoutPos]) {
                                        let token = Token(column: column, row: row, tokenType: tokenType)
                                        self.board.addTokenAtColumn(column, row: row, token: token)
                                    }
                                    layoutPos++
                                }
                            }
                            
                            self.renderBoardTokens()
                        }
                        
                        if (self.gameData.moves.count >= 3) {
                            for (var i = 0;i < (self.gameData.moves.count - 3) / 3; i++) {
                                let column = self.gameData.moves[i * 3]
                                let row = self.gameData.moves[i * 3 + 1]
                                if let direction = Direction(rawValue: self.gameData.moves[i * 3 + 2]) {
                                    let move = Move(column: column, row: row, direction: direction, player: self.activePlayer)
                                    self.processPieceAtColumn(move)
                                    self.rotateActivePlayer()
                                    self.board.printBoard()
                                }
                            }

                            self.scene.renderBoard(self.board.getAllPieces())
                            
                            self.board.printBoard()
                            
                            let lastMoveColumn = self.gameData.moves[self.gameData.moves.count - 3]
                            let lastMoveRow = self.gameData.moves[self.gameData.moves.count - 2]
                            if let lastMoveDirection = Direction(rawValue: self.gameData.moves[self.gameData.moves.count - 1]) {
                                self.playLastMove(lastMoveColumn, destinationRow: lastMoveRow, direction: lastMoveDirection, updateModel: true)
                                self.rotateActivePlayer()
                            }
                        }
                    }
                    
                    var statusString:NSString
                    if match.status == GKTurnBasedMatchStatus.Ended {
                        statusString = "Match Ended"
                    }
                    else
                    {
                        // let playerNum = match.participants. [match.currentParticipant + 1]
                        //println("Player %@'s Turn", playerNum)
                        //statusString = [NSString stringWithFormat:@"Player %ld's Turn", (long)playerNum]
                    }
                }
                
                self.board.printBoard()
                self.scene.setPlayerNames(match, activePlayer: self.activePlayer)
                self.scene.setActivePlayerIndicator(self.activePlayer)
            })
        } else {
            println("# GameScene:LayoutMatch: new match")
            // Initialize tokens for the board
            let boardNumber = Int(arc4random_uniform(41))
            self.board.initTokensWithBoard("Board_" + String(boardNumber))
            //self.board.initTokensWithBoard("Board_16")
            
            for var row = kNumRows - 1; row >= 0; row-- {
                for var column = 0; column < kNumColumns; column++ {
                    if let token = board.tokenAtColumn(column, row: row) {
                        self.gameData.tokenLayout.append(token.tokenType.rawValue)
                    }
                }
            }
            
            renderBoardTokens()
            scene.player1Label.text = "Player 1"
            scene.player2Label.text = "Player 2"
            scene.setActivePlayerIndicator(activePlayer)
        }
    }
    
    // Triggered when on the game screen and the opponent has just made a move
    func playLastOpponentMove() {
        println("# GameScene:playLastOpponentMove")
        
        if let match = currentMatch {
            
            match.loadMatchDataWithCompletionHandler({ (matchData:NSData!, error:NSError!) -> Void in
                if (error != nil)
                {
                    println("Error fetching matches: \(error.localizedDescription)")
                } else {
                    if let matchData = matchData {
                        self.gameData = GameKitMatchData(matchData: matchData)
                        let count = self.gameData.moves.count
                        
                        if (count >= 3) {
                            if self.board.piecesCount() < self.gameData.getMovesCount() {
                                var column = self.gameData.moves[count - 3]
                                var row = self.gameData.moves[count - 2]
                                if let direction = Direction(rawValue: self.gameData.moves[count - 1]) {
                                    
                                    switch (direction) {
                                    case .Up:
                                        row = 0
                                        break
                                    case .Down:
                                        row = 7
                                        break
                                    case .Left:
                                        column = 7
                                        break
                                    case .Right:
                                        column = 0
                                        break
                                    }
                                    
                                    let move = Move(column: column, row: row, direction: direction, player: self.activePlayer)
                                    
                                    if let piece = self.performMove(move) {
                                        activePieces.append(piece)
                                    }

                                    for piece in activePieces {
                                        piece.generateActions()
                                    }
                                    
                                    let piece = activePieces[activePieces.count-1]
                                    
                                    self.scene.activePiece = piece
                                    
                                    assert(piece.moveDestinations.count > 0)
                                    
                                    piece.animate() {
                                        
                                    }
                                    
                                    // update board model
                                    for activePiece in activePieces {
                                        let destination = activePiece.moveDestinations[0]
                                        self.board.addPieceAtColumn(destination.column, row: destination.row, piece: activePiece)
                                    }
                                    
                                    //println("active player: " + self.activePlayer.description)
                                    self.rotateActivePlayer()
                                    self.checkForWinnerAndUpdateMatch(false)
                                    activePieces.removeAtIndex(activePieces.count-1)
                                }
                            }
                        }
                    }
                    
                    var statusString:NSString
                    if match.status == GKTurnBasedMatchStatus.Ended {
                        statusString = "Match Ended"
                    }
                    else
                    {
                        // let playerNum = match.participants. [match.currentParticipant + 1]
                        //println("Player %@'s Turn", playerNum)
                        //statusString = [NSString stringWithFormat:@"Player %ld's Turn", (long)playerNum]
                    }
                }
                self.board.printBoard()
                
                self.scene.setActivePlayerIndicator(self.activePlayer)
            })
        }
    }
    
    func playLastMove(destinationColumn: Int, destinationRow: Int, direction: Direction, updateModel: Bool) {
        println("# GameScene:playLastMove")
        //self.rotateActivePlayer()
        var row = destinationRow
        var column = destinationColumn
        
        switch (direction) {
        case .Up:
            row = 0
            break
        case .Down:
            row = 7
            break
        case .Left:
            column = 7
            break
        case .Right:
            column = 0
            break
        }
        
        let move = Move(column: column, row: row, direction: direction, player: self.activePlayer)
        
        if let piece = self.performMove(move) {
            activePieces.append(piece)
        }
        
        for piece in activePieces {
            piece.generateActions()
        }

        if activePieces.count > 0 {
            let piece = activePieces[activePieces.count-1]
            scene.activePiece = piece
            assert(piece.moveDestinations.count > 0)
            
            piece.animate() {
                
            }
        }
        
        if updateModel {
            // update board model
            for activePiece in activePieces {
                let destination = activePiece.moveDestinations[0]
                board.addPieceAtColumn(destination.column, row: destination.row, piece: activePiece)
            }
        }
        
        //println("active player: " + self.activePlayer.description)
        //self.rotateActivePlayer()
        self.checkForWinnerAndUpdateMatch(false)
        
        activePieces.removeAtIndex(activePieces.count-1)
        
        board.printBoard()
    }
    
    func rotateActivePlayer() {
        if (activePlayer == .Player1) {
            activePlayer = .Player2
        } else {
            activePlayer = .Player1
        }
        println("# GameScene:RotateActivePlayer: activePlayer = " + activePlayer.description)
    }
    
    func loadPlayerPhotos() {
        let currentParticipant = participantForLocalPlayerInMatch(currentMatch)
        if let playerID = currentParticipant.playerID {
            if let playerImage = PlayerCache.sharedManager.playerPhotos[playerID] {
                scene.loadCurrentPlayerPhoto(playerImage)
            }
        }
        let opponentParticipant = getOpponentForMatch(currentMatch)
        if let playerID = opponentParticipant.playerID {
            if let playerImage = PlayerCache.sharedManager.playerPhotos[playerID] {
                scene.loadOpponentPlayerPhoto(playerImage)
            }
        }
    }
    
    func checkForWinnerAndUpdateMatch(shouldUpdateMatch: Bool) {
        println("# GameViewController:checkForWinnerAndUpdateMatch")
        var winners:[PieceType] = []
        
        for activePiece in activePieces {
            let destination = activePiece.moveDestinations[0]
            var winner = board.checkForWinnerAtRow(destination.row, column: destination.column)
            if (winner != PieceType.None) {
                winners.append(winner)
            }
        }
        
        if (winners.count > 0) {
            var player1Wins = 0
            var player2Wins = 0
            var winner = PieceType.None
            
            for pieceType in winners {
                if pieceType == PieceType.Player1 {
                    player1Wins++
                } else if pieceType == PieceType.Player2 {
                    player2Wins++
                }
            }
            if (player1Wins > 0 && player2Wins > 0) {
                winner = PieceType.None
            } else if (player1Wins > 0) {
                winner = PieceType.Player1
            } else if (player2Wins > 0) {
                winner = PieceType.Player2
            }
            
            endMatchWithWinner(winner, shouldUpdateMatch: shouldUpdateMatch)
        }
    }
    
    func endMatchWithWinner(pieceType: PieceType, shouldUpdateMatch: Bool) {
        println("# GameScene:endMatchWithWinner")
        
        var winner = ""
        
        if (isOnline) {
            let currentParticipant = participantForLocalPlayerInMatch(currentMatch)
            let currentPlayerName = PlayerCache.sharedManager.players[currentParticipant.playerID]!
            let opponentParticipant = getOpponentForMatch(currentMatch)
            let opponentPlayerName = PlayerCache.sharedManager.players[opponentParticipant.playerID]!
            
            if currentMatch.status == GKTurnBasedMatchStatus.Ended {
                if currentParticipant.matchOutcome == GKTurnBasedMatchOutcome.Won {
                    scene.displayEndOfGame(currentPlayerName.alias, isTie: false)
                } else if currentParticipant.matchOutcome == GKTurnBasedMatchOutcome.Lost {
                    scene.displayEndOfGame(opponentPlayerName.displayName, isTie: false)
                } else if currentParticipant.matchOutcome == GKTurnBasedMatchOutcome.Tied {
                    scene.displayEndOfGame("", isTie: true)
                }
            } else if PlayerCache.sharedManager.players.count > 0 {
                if pieceType == PieceType.None {
                    scene.displayEndOfGame("", isTie: true)
                } else if pieceType == activePlayer {
                    let currentPlayerName = PlayerCache.sharedManager.players[currentParticipant.playerID]!
                    scene.displayEndOfGame(currentPlayerName.alias, isTie: false)
                } else {
                    let opponentPlayerName = PlayerCache.sharedManager.players[opponentParticipant.playerID]!
                    scene.displayEndOfGame(opponentPlayerName.displayName, isTie: false)
                }
            }
            
            if shouldUpdateMatch {
                var opponent:GKTurnBasedParticipant!
                opponent = getOpponentForMatch(currentMatch)
                
                if pieceType == PieceType.None {
                    currentMatch.currentParticipant.matchOutcome = GKTurnBasedMatchOutcome.Tied
                    opponent.matchOutcome = GKTurnBasedMatchOutcome.Tied
                    currentMatch.message = "\(opponentPlayerName.displayName) has Tied a match versus \(currentPlayerName.alias)"
                } else if pieceType == activePlayer {
                    currentMatch.currentParticipant.matchOutcome = GKTurnBasedMatchOutcome.Won
                    opponent.matchOutcome = GKTurnBasedMatchOutcome.Lost
                    currentMatch.message = "\(opponentPlayerName.displayName) has Lost a match versus \(currentPlayerName.alias)"
                } else {
                    currentMatch.currentParticipant.matchOutcome = GKTurnBasedMatchOutcome.Lost
                    opponent.matchOutcome = GKTurnBasedMatchOutcome.Won
                    currentMatch.message = "\(opponentPlayerName.displayName) has Won a match versus \(currentPlayerName.alias)"
                }
                
                let updatedMatchData:NSData = self.gameData.encodeMatchData()
                
                currentMatch.endMatchInTurnWithMatchData(updatedMatchData, completionHandler: { (error) -> Void in
                    if error != nil {
                        println(error)
                    }
                })
            }
            
        } else {
            if pieceType == PieceType.Player1 {
                winner = "Player 1"
                scene.displayEndOfGame(winner, isTie: false)
            } else if pieceType == PieceType.Player2 {
                winner = "Player 2"
                scene.displayEndOfGame(winner, isTie: false)
            } else if pieceType == PieceType.None {
                winner = "Tie"
                scene.displayEndOfGame("", isTie: true)
            }
        }
        //NSDictionary *winParams = @{@"Winner": winner}
        //[[OALSimpleAudio sharedInstance] playEffect:@"win1.mp3"]
        //[Flurry logEvent:@"Game_Over" withParameters:winParams]
    }
    
    func renderBoardTokens() {
        println("# GameScene:renderBoardTokens")
        for token in board.getAllTokens() {
            if token != nil {
                if token?.tokenType != TokenType.None {
                    scene.addSpriteForToken(token!)
                }
            }
        }
    }
    
    func player(player: GKPlayer!, receivedTurnEventForMatch match: GKTurnBasedMatch!, didBecomeActive: Bool) {
        println("receivedTurnEventForMatch:GameViewController")
        let currentMatch = self.currentMatch as GKTurnBasedMatch
        let turnMatch = match as GKTurnBasedMatch
        var currentMatchID = currentMatch.matchID.capitalizedString
        var turnMatchID = turnMatch.matchID.capitalizedString
        
        if ((currentMatch.matchID) != nil) {
            if (currentMatch.matchID == turnMatch.matchID) {
                playLastOpponentMove()
            }
        }
    }
    
    func player(player: GKPlayer!, matchEnded match: GKTurnBasedMatch!) {
        if (self.currentMatch != nil) {
            if (self.currentMatch.matchID == match.matchID) {
                playLastOpponentMove()
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
