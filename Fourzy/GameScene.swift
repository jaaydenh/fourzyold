//
//  GameScene.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/7/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

import SpriteKit
import GameKit

class GameScene:BaseScene {
    
    var board: Board!
    
    let gameLayer = SKNode()
    let piecesLayer = SKSpriteNode()
    
    let leftActionArea = SKSpriteNode()
    let rightActionArea = SKSpriteNode()
    let topActionArea = SKSpriteNode()
    let bottomActionArea = SKSpriteNode()
    
    var isMultiplayer = true
    var activePiece:Piece?
    var activePieces:[Piece] = []
    
    //var backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var gameData: GameKitMatchData = GameKitMatchData()
    var activePlayer:PieceType = PieceType.Player1
    var currentMatch:GKTurnBasedMatch!
    
     override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = SKColor.whiteColor()
        
        gameLayer.hidden = false
        gameLayer.position = CGPoint(x: 0, y: 0)
        self.addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: (-kTileWidth * NumColumns / 2) - kTapAreaWidth,
            y: (-kTileHeight * NumRows / 2) - kTapAreaWidth)
        
        piecesLayer.position = layerPosition
        piecesLayer.zPosition = 1
        gameLayer.addChild(piecesLayer)
        
        createContent()
    }
    
    override func didMoveToView(view: SKView) {
        println("didMoveToView")
//        piecesLayer.removeAllChildren()
//        addTapAreas()
        //if let match = GameKitTurnBasedMatchHelper.sharedInstance().currentMatch {
        layoutMatch()
        //}
    }
    
    override func willMoveFromView(view: SKView) {
        println("willMoveFromView")
    }
    
    func touchedActivePiece(point: CGPoint) -> Bool {
        if activePieces.count > 0 {
            let activePiece = activePieces[activePieces.count-1]
            var touchRect:CGRect
            var sprite = activePiece.sprite
            if let sprite = activePiece.sprite {
                if activePiece.direction == .Up || activePiece.direction == .Down {
                    touchRect = CGRectMake(sprite.position.x - 8, sprite.position.y - 50, 46.0, 130.0)
                } else {
                    touchRect = CGRectMake(sprite.position.x - 50, sprite.position.y - 8, 130.0, 46.0)
                }
                
                if CGRectContainsPoint(touchRect, point) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func addSpriteForPiece(piece: Piece, isPieceOnBoard: Bool) {
        let sprite = SKSpriteNode(imageNamed: piece.pieceType.spriteName)
        if isPieceOnBoard {
            sprite.position = pointInsideBoardForColumn(piece.column, row:piece.row)
        } else {
            sprite.position = pointOutsideBoardForColumn(piece.column, row:piece.row, direction:piece.direction)
        }
        
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        sprite.size = CGSize(width: kPieceSize, height: kPieceSize)
        piecesLayer.addChild(sprite)
        piece.sprite = sprite
    }
    
    func addSpriteForToken(token: Token) {
        let sprite = SKSpriteNode(imageNamed: token.tokenType.spriteName)
        sprite.position = pointInsideBoardForColumn(token.column, row: token.row)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        sprite.size = CGSize(width: kPieceSize, height: kPieceSize)
        piecesLayer.addChild(sprite)
        token.sprite = sprite
    }
    
    // Converts a column,row pair into a CGPoint that is relative to the pieceLayer and is inside the board area.
    func pointInsideBoardForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(x: column * kTileWidth + kTapAreaWidth + kPieceSize/2, y: row * kTileHeight + kTapAreaWidth + kPieceSize/2)
    }
    
    // Converts a column,row pair into a CGPoint that is relative to the pieceLayer and is outside the board area.
    func pointOutsideBoardForColumn(column: Int, row: Int, direction: Direction) -> CGPoint {
        if (direction == .Up) {
            return CGPoint(x: column * kTileWidth + kTapAreaWidth + kPieceSize/2, y: 5 + kPieceSize/2)
        } else if (direction == .Down) {
            return CGPoint(x: column * kTileWidth + kGridXOffset + kPieceSize/2, y: (row+1) * kTileHeight + kTapAreaWidth + 5 + kPieceSize/2)
        } else if (direction == .Left) {
            return CGPoint(x: (column+1) * kTileWidth + kTapAreaWidth + 5 + kPieceSize/2, y: row * kTileHeight + kTapAreaWidth + kPieceSize/2)
        } else if (direction == .Right) {
            return CGPoint(x: 5 + kPieceSize/2, y: row * kTileHeight + kTapAreaWidth + kPieceSize/2)
        }
        
        
        return CGPoint(
            x: column*kTileWidth + kTapAreaWidth,
            y: (row-1)*kTileHeight + kTapAreaWidth)
    }
    
    func rotateActivePlayer() {
        if (activePlayer == .Player1) {
            activePlayer = .Player2
        } else {
            activePlayer = .Player1
        }
    }
    
    func loadPlayerPhotos() {
        let currentParticipant = getOpponentForMatch(currentMatch)
        if let playerID = currentParticipant.playerID {
            if let playerImage = PlayerCache.sharedManager.playerPhotos[playerID] {
                let playerTexture = SKTexture(image: playerImage)
                let player1ImageNode = SKSpriteNode(texture: playerTexture, size: CGSize(width: 50, height: 50))
                player1ImageNode.position = CGPoint(x: -60, y: 200)
                addChild(player1ImageNode)
            }
        }
    }
    
    func createContent() {
        
        //let playerImageView = UIImageView(image: PlayerCache.sharedManager.playerPhotos[currentParticipant.playerID])
        //playerImageView.frame = CGRect(x: 50, y: 50, width: 100, height: 100)
        //addChild(playerImageView)
        
        //[self setupTapAreas]
        
        var winnerLabel = SKLabelNode(fontNamed:"Arial Bold")
        winnerLabel.fontSize = 26
        winnerLabel.fontColor = SKColor.blackColor()
        winnerLabel.position = CGPointMake(0, 0)
        winnerLabel.zPosition = 1.0
        winnerLabel.hidden = false
        winnerLabel.name = kWinnerLabelName
        
        addChild(winnerLabel)
        //addBoard()
        
        addBackgroundImage()
        addBoardCorners()
        //addTapAreas()
        
        //addBoardCorners()
        //[self addBackButton]
        //[self addMenuButton]
        //[self loadSounds]
    }
    
    func addBoard() {
        board = Board()
        //board = Board(imageNamed: "grid8")
        //board.anchorPoint = CGPointMake(0.0, 0.0)
        //board.position = CGPointMake(kGridXOffset, kGridYOffset)
        //board.size = CGSizeMake(320.0, 320.0)
        //addChild(self.board)
        
        //[self.board loadLayouts]
        //[self setupBoardCorners]
        //[self initWithDimension:self.boardRows]
        //[self resetBoardTokens]
        //[self initTokensWithDimention:self.boardRows]
    }
    
    //    func getPieceAtPosition(xPosition x:NSInteger, yPosition y:NSInteger) -> GamePiece {
    //
    //    }
    
    // Converts a point relative to the board into column and row numbers.
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int, direction: Direction) {
        
        var y = Int(point.y)
        var x = Int(point.x)
        var row = (y - kTapAreaWidth) / kTileHeight
        var column = (x - kTapAreaWidth) / kTileWidth
        
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
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if var activePiece = self.activePiece {
            if let sprite = activePiece.sprite {
                if sprite.hasActions() {
                    let destinationRect = CGRect(x: activePiece.moveDestination.x, y: activePiece.moveDestination.y, width: CGFloat(kPieceSize), height: CGFloat(kPieceSize))
                    if (CGRectIntersectsRect(destinationRect, sprite.frame)) {
                        if self.activePieces.count > 0 {
                            var piece = self.activePieces[self.activePieces.count-1]
                            self.activePieces.removeAtIndex(self.activePieces.count-1)
                            let sequence = SKAction.sequence(piece.actions)
                            piece.sprite?.runAction(sequence)
                            self.activePiece = piece
                        }
                    }
                }
            }
        }
    }
    
    // assumption: only call this method with a valid row and column that is within the bounds of the board and does not contain a piece
    func getDestinationForPiece(piece:Piece, direction:Direction, startingRow:Int, startingColumn:Int) {
        var destinationRow: Int
        var destinationColumn: Int
        
        switch (direction) {
        case .Down:
            destinationRow = 0
            destinationColumn = startingColumn
            
            for var row:Int = startingRow; row >= 0;row-- {
                if let token = board.tokenAtColumn(startingColumn, row: row) {
                    if (token.tokenType == .Sticky) {
                        if (board.pieceAtColumn(startingColumn, row: row) != nil) {
                            // If the piece in the sticky square can move
                            if (row - 1 >= 0 && board.pieceAtColumn(startingColumn, row: row - 1) == nil){
                                if let stuckPiece = board.pieceAtColumn(startingColumn, row: row) {
                                    stuckPiece.resetMovement()
                                    getDestinationForPiece(stuckPiece, direction: .Down, startingRow: row - 1, startingColumn: startingColumn)
                                    activePieces.append(stuckPiece)
                                    destinationRow = row
                                    break
                                }
                            } else {
                                // piece in sticky square cannot move
                                destinationRow = row + 1
                                break
                            }
                        } else {
                            destinationRow = row
                            break
                        }
                    } else if board.pieceAtColumn(startingColumn, row: row) != nil {
                        destinationRow = row + 1
                        break
                    } else if token.tokenType == .UpArrow {
                        destinationRow = row
                        getDestinationForPiece(piece, direction: .Up, startingRow: row + 1, startingColumn: startingColumn)
                        break
                    } else if token.tokenType == .DownArrow {
                        destinationRow = row
                        getDestinationForPiece(piece, direction: .Down, startingRow: row - 1, startingColumn: startingColumn)
                        break
                    } else if token.tokenType == .LeftArrow {
                        destinationRow = row
                        getDestinationForPiece(piece, direction: .Left, startingRow: row, startingColumn: startingColumn - 1)
                        break
                    } else if token.tokenType == .RightArrow {
                        destinationRow = row
                        getDestinationForPiece(piece, direction: .Right, startingRow: row, startingColumn: startingColumn + 1)
                        break
                    } else if token.tokenType == .Blocker {
                        destinationRow = row + 1
                        break
                    }
                } else {
                    if board.pieceAtColumn(startingColumn, row: row) != nil {
                        destinationRow = row + 1
                        break
                    }
                }
                
                destinationRow = row
            }
            break
            
        case .Up:
            destinationRow = Int(kNumRows) - 1
            destinationColumn = startingColumn
            
            for var row:Int = startingRow; row <= Int(kNumRows) - 1;row++ {
                if let token = board.tokenAtColumn(startingColumn, row: row) {
                    if token.tokenType == .Sticky {
                        if board.pieceAtColumn(startingColumn, row: row) != nil {
                            // If the piece in the sticky square can move
                            if row + 1 < Int(kNumRows) && board.pieceAtColumn(startingColumn, row: row + 1) == nil {
                                if let stuckPiece = board.pieceAtColumn(startingColumn, row: row) {
                                    stuckPiece.resetMovement()
                                    getDestinationForPiece(stuckPiece, direction: .Up, startingRow: row + 1, startingColumn: startingColumn)
                                    activePieces.append(stuckPiece)
                                    destinationRow = row
                                    break
                                }
                            } else {
                                // piece in sticky square cannot move
                                destinationRow = row - 1
                                break
                            }
                        } else {
                            destinationRow = row
                            break
                        }
                    } else if board.pieceAtColumn(startingColumn, row: row) != nil {
                        destinationRow = row - 1
                        break
                    } else if token.tokenType == .UpArrow {
                        destinationRow = row
                        getDestinationForPiece(piece, direction: .Up, startingRow: row + 1, startingColumn: startingColumn)
                        break
                    } else if token.tokenType == .DownArrow {
                        destinationRow = row
                        getDestinationForPiece(piece, direction: .Down, startingRow: row - 1, startingColumn: startingColumn)
                        break
                    } else if token.tokenType == .LeftArrow {
                        destinationRow = row
                        getDestinationForPiece(piece, direction: .Left, startingRow: row, startingColumn: startingColumn - 1)
                        break
                    } else if token.tokenType == .RightArrow {
                        destinationRow = row
                        getDestinationForPiece(piece, direction: .Right, startingRow: row, startingColumn: startingColumn + 1)
                        break
                    } else if token.tokenType == .Blocker {
                        destinationRow = row - 1
                        break
                    }
                } else {
                    if board.pieceAtColumn(startingColumn, row: row) != nil {
                        destinationRow = row - 1
                        break
                    }
                }
                
                destinationRow = row
            }
            break
            
        case .Left:
            destinationRow = startingRow
            destinationColumn = 0
            
            for var column:Int = startingColumn; column >= 0;column-- {
                if let token = board.tokenAtColumn(column, row: startingRow) {
                    if token.tokenType == .Sticky {
                        if board.pieceAtColumn(column, row: startingRow) != nil {
                            // If the piece in the sticky square can move
                            if column - 1 >= 0 && board.pieceAtColumn(column - 1, row: startingRow) == nil {
                                if let stuckPiece = board.pieceAtColumn(column, row: startingRow) {
                                    stuckPiece.resetMovement()
                                    getDestinationForPiece(stuckPiece, direction: .Left, startingRow: startingRow, startingColumn: column - 1)
                                    activePieces.append(stuckPiece)
                                    destinationColumn = column
                                    break
                                }
                            } else {
                                // piece in sticky square cannot move
                                destinationColumn = column + 1
                                break
                            }
                        } else {
                            destinationColumn = column
                            break
                        }
                    } else if board.pieceAtColumn(column, row: startingRow) != nil {
                        destinationColumn = column + 1
                        break
                    } else if token.tokenType == .UpArrow {
                        destinationColumn = column
                        getDestinationForPiece(piece, direction: .Up, startingRow: startingRow + 1, startingColumn: column)
                        break
                    } else if token.tokenType == .DownArrow {
                        destinationColumn = column
                        getDestinationForPiece(piece, direction: .Down, startingRow: startingRow - 1, startingColumn: column)
                        break
                    } else if token.tokenType == .LeftArrow {
                        destinationColumn = column
                        getDestinationForPiece(piece, direction: .Left, startingRow: startingRow, startingColumn: column - 1)
                        break
                    } else if token.tokenType == .RightArrow {
                        destinationColumn = column
                        getDestinationForPiece(piece, direction: .Right, startingRow: startingRow, startingColumn: column + 1)
                        break
                    } else if token.tokenType == .Blocker {
                        destinationColumn = column + 1
                        break
                    }
                } else {
                    if board.pieceAtColumn(column, row: startingRow) != nil {
                        destinationColumn = column + 1
                        break
                    }
                }
                
                destinationColumn = column
            }
            break
            
        case .Right:
            destinationRow = startingRow
            destinationColumn = Int(kNumColumns) - 1
            
            for var column:Int = startingColumn; column <= Int(kNumColumns) - 1;column++ {
                if let token = board.tokenAtColumn(column, row: startingRow) {
                    if token.tokenType == .Sticky {
                        if board.pieceAtColumn(column, row: startingRow) != nil {
                            // If the piece in the sticky square can move
                            if column + 1 < Int(kNumColumns) && board.pieceAtColumn(column + 1, row: startingRow) == nil {
                                if let stuckPiece = board.pieceAtColumn(column, row: startingRow) {
                                    stuckPiece.resetMovement()
                                    getDestinationForPiece(stuckPiece, direction: .Right, startingRow: startingRow, startingColumn: column + 1)
                                    activePieces.append(stuckPiece)
                                    destinationColumn = column
                                    break
                                }
                            } else {
                                // piece in sticky square cannot move
                                destinationColumn = column - 1
                                break
                            }
                        } else {
                            destinationColumn = column
                            break
                        }
                    } else if board.pieceAtColumn(column, row: startingRow) != nil {
                        destinationColumn = column - 1
                        break
                    } else if token.tokenType == .UpArrow {
                        destinationColumn = column
                        getDestinationForPiece(piece, direction: .Up, startingRow: startingRow + 1, startingColumn: column)
                        break
                    } else if token.tokenType == .DownArrow {
                        destinationColumn = column
                        getDestinationForPiece(piece, direction: .Down, startingRow: startingRow - 1, startingColumn: column)
                        break
                    } else if token.tokenType == .LeftArrow {
                        destinationColumn = column
                        getDestinationForPiece(piece, direction: .Left, startingRow: startingRow, startingColumn: column - 1)
                        break
                    } else if token.tokenType == .RightArrow {
                        destinationColumn = column
                        getDestinationForPiece(piece, direction: .Right, startingRow: startingRow, startingColumn: column + 1)
                        break
                    } else if token.tokenType == .Blocker {
                        destinationColumn = column - 1
                        break
                    }
                } else {
                    if board.pieceAtColumn(column, row: startingRow) != nil {
                        destinationColumn = column - 1
                        break
                    }
                }
                
                destinationColumn = column
            }
            break
            
        default:
            break
        }
        let position = GridPosition(column: destinationColumn, row: destinationRow)
        piece.moveDestinations.append(position)
    }
    
    // MARK: GameKitTurnBasedMatchHelperDelegate Methods
    
    func enterNewGame(match:GKTurnBasedMatch) {
        println("Entering new game...")
        currentMatch = match
    }
    
    func playLastMove() {
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
                                
                                if let piece = self.placePieceAtColumn(column, row: row, pieceType: self.activePlayer, direction: direction) {
                                    self.activePieces.append(piece)
                                }
                                for piece in self.activePieces {
                                    piece.generateActions()
                                }
                                
                                let piece = self.activePieces[self.activePieces.count-1]

                                self.activePiece = piece
                                assert(piece.moveDestinations.count > 0)
                                //self.activePieces.removeAtIndex(0)
                                
                                piece.animate()
                                
                                //let destination = piece.moveDestinations[0]
                                // update gameboard model with destination of gamepiece
                                //self.board.addPieceAtColumn(destination.column, row: destination.row, piece: piece)
                                
                                // update board model
                                for activePiece in self.activePieces {
                                    let destination = activePiece.moveDestinations[0]
                                    self.board.addPieceAtColumn(destination.column, row: destination.row, piece: activePiece)
                                }
                                
                                //println("play last move - print board")
                                //self.board.printBoard()
                                println("active player: " + self.activePlayer.description)
                                self.rotateActivePlayer()
                                self.checkForWinnerAndUpdateMatch(false)
                                self.activePieces.removeAtIndex(self.activePieces.count-1)
                                //self.processPieceAtColumn(column, row: row, pieceType: self.activePlayer, direction: direction)

                                
//                                if self.activePieces.count > 0 {
//                                    self.activePieces.removeAll(keepCapacity: false)
//                                }
                            }
                            
                            //self.renderBoard()
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
                
            })
        }
    }
    
    func layoutMatch()
    {
        self.activePlayer = PieceType.Player1
        board = Board()
        piecesLayer.removeAllChildren()
        addTapAreas()
        
        if let match = currentMatch {

            match.loadMatchDataWithCompletionHandler({ (matchData:NSData!, error:NSError!) -> Void in
                if (error != nil)
                {
                    println("Error fetching matches: \(error.localizedDescription)")
                } else {
                    
                    println(match)
                    
                    if let matchData = matchData {
                        self.gameData = GameKitMatchData(matchData: matchData)
                        
                        if self.gameData.tokenLayout.count == 0 {
                            let boardNumber = Int(arc4random_uniform(4))
                            self.board.initTokensWithBoard("Board_" + String(boardNumber))
                            
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
                        
                        if (self.gameData.moves.count > 0) {
                            for (var i = 0;i < self.gameData.moves.count / 3; i++) {
                                let column = self.gameData.moves[i * 3]
                                let row = self.gameData.moves[i * 3 + 1]
                                if let direction = Direction(rawValue: self.gameData.moves[i * 3 + 2]) {
                                    self.processPieceAtColumn(column, row: row, pieceType: self.activePlayer, direction: direction)
                                    self.rotateActivePlayer()
                                }
                            }
                            
                            self.renderBoard()
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
                println("layout match - print board")
                self.board.printBoard()
            })
        } else {
            // Initialize tokens for the board
            let boardNumber = Int(arc4random_uniform(4))
            self.board.initTokensWithBoard("Board_" + String(boardNumber))
            //self.board.initTokensWithBoard("Board_2")
            
            for var row = kNumRows - 1; row >= 0; row-- {
                for var column = 0; column < kNumColumns; column++ {
                    if let token = board.tokenAtColumn(column, row: row) {
                        self.gameData.tokenLayout.append(token.tokenType.rawValue)
                    }
                }
            }

            renderBoardTokens()
        }
    }
    
    func advanceTurn() {
        println("advanceTurn")
        let currentMatch:GKTurnBasedMatch = self.currentMatch //GameKitTurnBasedMatchHelper.sharedInstance().currentMatch
        let updatedMatchData:NSData = self.gameData.encodeMatchData()
        var nextParticipant:GKTurnBasedParticipant!
        if currentMatch.status != GKTurnBasedMatchStatus.Ended {
            if currentMatch.participants.count >= 2 {
                
                nextParticipant = getOpponentForMatch(currentMatch)
                let sortedParticipants:[GKTurnBasedParticipant] = [nextParticipant, currentMatch.currentParticipant]
                
                currentMatch.endTurnWithNextParticipants(sortedParticipants, turnTimeout: GKTurnTimeoutDefault, matchData: updatedMatchData) { (error) -> Void in
                    if (error != nil) {
                        println(error)
                    }
                }
                //println("Send Turn, \(updatedMatchData), \(nextParticipant)")
                //TODO: update game scene UI to switch active player
            }
        }
    }
    
    func renderBoard() {
        for piece in board.getAllPieces() {
            if piece != nil {
                addSpriteForPiece(piece!, isPieceOnBoard: true)
            }
        }
    }
    
    func renderBoardTokens() {
        for token in board.getAllTokens() {
            if token != nil {
                if token?.tokenType != TokenType.None {
                    addSpriteForToken(token!)
                }
            }
        }
    }
    
    func processPieceAtColumn(column: Int, row: Int, pieceType: PieceType, direction: Direction) {
        //assert(board.pieceAtColumn(column, row: row) == nil, "Trying to make a move at a non empty space")
        let piece = Piece(column: column, row: row, pieceType: pieceType, direction: direction)
        activePieces.append(piece)
        getDestinationForPiece(piece, direction: direction, startingRow: row, startingColumn: column)
        
        for piece in activePieces {
            let destination = piece.moveDestinations[0]
            piece.column = destination.column
            piece.row = destination.row
            // update gameboard model with destination of gamepiece
            board.addPieceAtColumn(destination.column, row: destination.row, piece: piece)
        }
        activePieces.removeAll(keepCapacity: false)
    }
    
    func placePieceAtColumn(column: Int, row: Int, pieceType: PieceType, direction: Direction) -> Piece? {
        if board.pieceAtColumn(column, row: row) == nil {
            let piece = Piece(column: column, row: row, pieceType: pieceType, direction: direction)
            getDestinationForPiece(piece, direction: direction, startingRow: row, startingColumn: column)
            addSpriteForPiece(piece, isPieceOnBoard: false)
            
            return piece
        }
        return nil
    }
    
    func checkForWinnerAndUpdateMatch(shouldUpdateMatch: Bool) {
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
        println("endMatch")
        
        var winnerLabel = self.childNodeWithName(kWinnerLabelName) as SKLabelNode
        var winner = ""
    
        if (isMultiplayer) {
            if PlayerCache.sharedManager.players.count > 0 {
                if pieceType == activePlayer {
                    let currentParticipant = participantForLocalPlayerInMatch(currentMatch)
                    let currentPlayerName = PlayerCache.sharedManager.players[currentParticipant.playerID]!
                    winnerLabel.text =  "\(currentPlayerName.alias) Wins!"
                    winnerLabel.hidden = false
                } else {
                    let opponentParticipant = getOpponentForMatch(currentMatch)
                    let opponentPlayerName = PlayerCache.sharedManager.players[opponentParticipant.playerID]!
                    winnerLabel.text =  "\(opponentPlayerName.displayName) Wins!"
                    winnerLabel.hidden = false
                }
            }
        } else {
            if pieceType == PieceType.Player1 {
                winner = "Player 1"
                winnerLabel.text =  "Player 1 Wins!"
                winnerLabel.hidden = false
            } else if pieceType == PieceType.Player2 {
                winner = "Player 2"
                winnerLabel.text = "Player 2 Wins!"
                winnerLabel.hidden = false
            } else if pieceType == PieceType.None {
                winner = "Tie"
                winnerLabel.text = "Tie!"
                winnerLabel.hidden = false
            }
        }
        
        if isMultiplayer && shouldUpdateMatch {
            var opponent:GKTurnBasedParticipant!
            
            opponent = getOpponentForMatch(currentMatch)
            
            if pieceType == PieceType.None {
                currentMatch.currentParticipant.matchOutcome = GKTurnBasedMatchOutcome.Tied
                opponent.matchOutcome = GKTurnBasedMatchOutcome.Tied
            } else if pieceType == activePlayer {
                currentMatch.currentParticipant.matchOutcome = GKTurnBasedMatchOutcome.Won
                opponent.matchOutcome = GKTurnBasedMatchOutcome.Lost
            } else {
                currentMatch.currentParticipant.matchOutcome = GKTurnBasedMatchOutcome.Lost
                opponent.matchOutcome = GKTurnBasedMatchOutcome.Won
            }
            
            let updatedMatchData:NSData = self.gameData.encodeMatchData()
            
            currentMatch.endMatchInTurnWithMatchData(updatedMatchData, completionHandler: { (error) -> Void in
                if error != nil {
                    println(error)
                }
            })
        }
        
    //NSDictionary *winParams = @{@"Winner": winner}
    //[[OALSimpleAudio sharedInstance] playEffect:@"win1.mp3"]
    //[Flurry logEvent:@"Game_Over" withParameters:winParams]
    }
    
    func removeHighlights() {
        
        self.piecesLayer.enumerateChildNodesWithName("highlight", usingBlock: { (node, stop) -> Void in
            node.removeFromParent()
        })
    }
    
    func addGamePieceHighlightFrom(row: Int, column: Int, direction: Direction) {
    
        var startRow = row
        var startColumn = column
        
        self.removeHighlights()
    
        for piece in self.activePieces {
    
            if (startRow  < 0) {
                startRow = 0
            }
            
            if (startColumn < 0) {
                startColumn = 0
            }
    
            for position in piece.moveDestinations.reverse() {
                let highlight = SKSpriteNode(imageNamed: "highlight")
                highlight.alpha = 0.2
                if (piece.pieceType == PieceType.Player2) {
                    highlight.color = UIColor.orangeColor()
                    highlight.colorBlendFactor = 0.9
                } else if (piece.pieceType == PieceType.Player1) {
                    highlight.color = UIColor.greenColor()
                    highlight.colorBlendFactor = 0.3
                }
            
                highlight.anchorPoint = CGPointMake(0.0, 0.0)
                highlight.name = "highlight"
            
                if (direction == .Down) {
                    highlight.size = CGSize(width: kTileWidth, height: (startRow - position.row + 1) * kTileHeight)
                    highlight.position = CGPoint(x: position.column * kTileWidth + kGridXOffset, y:  (position.row * kTileHeight) + 40)
                } else if (direction == .Up) {
                    highlight.size = CGSize(width: kTileWidth, height: (position.row - startRow + 1) * kTileHeight)
                    highlight.position = CGPoint(x: position.column * kTileWidth + kGridXOffset, y: (startRow * kTileHeight) + 40)
                } else if (direction == .Right) {
                    highlight.size = CGSize(width: (position.column - startColumn + 1) * kTileWidth, height: kTileHeight)
                    highlight.position = CGPoint(x: (column * kTileWidth) + kGridXOffset, y: position.row * kTileHeight + 40)
                } else if (direction == .Left) {
                    highlight.size = CGSize(width: (startColumn - position.column + 1) * kTileWidth, height: kTileHeight)
                    highlight.position = CGPoint(x: kGridXOffset + (position.column * kTileWidth), y: position.row * kTileHeight + 40)
                }
            
                startRow = position.row
                startColumn = position.column
            
                self.piecesLayer.addChild(highlight)
            }
        }
    }
    
    override class func loadSceneAssets() {
        
        //Goblin.loadSharedAssets()
        
        //sSharedLeafEmitterA = .emitterNodeWithName("Leaves_01")
        
        // Load Trees
        //        let atlas = SKTextureAtlas(named: "Environment")
        //        var sprites = [
        //            SKSpriteNode(texture: atlas.textureNamed("small_tree_base.png")),
        //            SKSpriteNode(texture: atlas.textureNamed("small_tree_middle.png")),
        //            SKSpriteNode(texture: atlas.textureNamed("small_tree_top.png"))
        //        ]
        //        sSharedSmallTree = Tree(sprites:sprites, usingOffset:25.0)
        
    }
    
    func addBackgroundImage() {
        var grid = SKSpriteNode(imageNamed:"grid8")
        //grid.anchorPoint = CGPointMake(0.0, 0.0)
        //grid.position = CGPointMake(kGridXOffset, kGridYOffset)
        addChild(grid)
    }
    
    func addTapAreas() {
        leftActionArea.texture = SKTexture(imageNamed: "tap_area")
        leftActionArea.size = CGSize(width: kTapAreaWidth, height: kTileHeight * kNumRows)
        leftActionArea.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        leftActionArea.position = CGPoint(x: 0, y: kTapAreaWidth)
        piecesLayer.addChild(leftActionArea)
        
        rightActionArea.texture = SKTexture(imageNamed: "tap_area")
        rightActionArea.size = CGSize(width: kTapAreaWidth, height: kTileHeight * kNumRows)
        rightActionArea.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        rightActionArea.position = CGPoint(x: kNumColumns * kTileWidth + kTapAreaWidth, y: kTapAreaWidth)
        piecesLayer.addChild(rightActionArea)
        
        topActionArea.texture = SKTexture(imageNamed: "tap_area")
        topActionArea.size = CGSize(width: kTileWidth * kNumRows, height:kTapAreaWidth)
        topActionArea.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        topActionArea.position = CGPoint(x: kTapAreaWidth, y: kTileWidth * kNumRows + kTapAreaWidth)
        piecesLayer.addChild(topActionArea)
        
        bottomActionArea.texture = SKTexture(imageNamed: "tap_area")
        bottomActionArea.size = CGSize(width: kTileWidth * kNumColumns, height: kTapAreaWidth)
        bottomActionArea.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        bottomActionArea.position = CGPoint(x: kTapAreaWidth, y: 0)
        piecesLayer.addChild(bottomActionArea)
    }
    
    func addBoardCorners() {
        var corner1 = SKSpriteNode(imageNamed:"board_corner")
        corner1.size = CGSize(width: kTapAreaWidth, height: kTapAreaWidth)
        //corner1.anchorPoint = CGPointMake(0.0, 0.0)
        corner1.position = CGPointMake(-140.0, 140.0)
        corner1.alpha = 0.5
        gameLayer.addChild(corner1)
        
        var corner2 = SKSpriteNode(imageNamed:"board_corner")
        corner2.size = CGSize(width: kTapAreaWidth, height: kTapAreaWidth)
        //corner2.anchorPoint = CGPointMake(0.0, 0.0)
        corner2.position = CGPointMake(140.0, 140.0)
        corner2.alpha = 0.5
        gameLayer.addChild(corner2)
        
        var corner3 = SKSpriteNode(imageNamed:"board_corner")
        corner3.size = CGSize(width: kTapAreaWidth, height: kTapAreaWidth)
        //corner3.anchorPoint = CGPointMake(0.0, 0.0)
        corner3.position = CGPointMake(140.0, -140)
        corner3.alpha = 0.5
        gameLayer.addChild(corner3)
        
        var corner4 = SKSpriteNode(imageNamed:"board_corner")
        corner4.size = CGSize(width: kTapAreaWidth, height: kTapAreaWidth)
        //corner4.anchorPoint = CGPointMake(0.0, 0.0)
        corner4.position = CGPointMake(-140.0, -140.0)
        corner4.alpha = 0.5
        gameLayer.addChild(corner4)
    }
}
