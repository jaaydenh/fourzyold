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
    
    // The scene handles touches. If it recognizes that the user touches the screen
    // then it communicates back to the ViewController that a swap needs to take place.
    // You could also use a delegate for this.
    var touchHandler: ((GridPosition) -> ())?
    var submitMoveHandler: (() -> ())?
    
    let gameLayer = SKNode()
    let piecesLayer = SKNode()
    let tokensLayer = SKNode()
    let boardLayer = SKNode()
    let tapLayer = SKNode()
    
    var leftActionArea = SKSpriteNode()
    var rightActionArea = SKSpriteNode()
    var topActionArea = SKSpriteNode()
    var bottomActionArea = SKSpriteNode()
    var player1Indicator = SKSpriteNode()
    var player2Indicator = SKSpriteNode()
    var player1Label = SKLabelNode(fontNamed:"Arial Bold")
    var player2Label = SKLabelNode(fontNamed:"Arial Bold")
    var currentPlayerName:String = ""
    var opponentPlayerName:String = ""
    var submitButton:SKButton?
    var activePiece:Piece?
    
    //var backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    // Pre-load sound resources
    // let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
    // let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    
     override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = SKColor.whiteColor()

        gameLayer.hidden = false

        gameLayer.position = CGPoint(x: 0, y: 0)
        self.addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: (-kTileWidth * NumColumns / 2) - kTapAreaWidth,
            y: (-kTileHeight * NumRows / 2) - kTapAreaWidth - 30)
        
        piecesLayer.position = layerPosition
        piecesLayer.zPosition = 1
        gameLayer.addChild(piecesLayer)
        
        tokensLayer.position = layerPosition
        gameLayer.addChild(tokensLayer)
        
        boardLayer.position = layerPosition
        gameLayer.addChild(boardLayer)
        
        createContent()
    }
    
    func setupScene() {
        piecesLayer.removeAllChildren()
        tokensLayer.removeAllChildren()
        
        addTapAreas()
        addTapArrows()
    }
    
    func addActivePiece(piece:Piece) {
        activePieces.append(piece)
        println(activePieces.count)
    }
    
    override func didMoveToView(view: SKView) {
        println("# GameScene:didMoveToView")
//        piecesLayer.removeAllChildren()
//        addTapAreas()
        //if let match = GameKitTurnBasedMatchHelper.sharedInstance().currentMatch {
        //layoutMatch()
        //}
    }
    
    override func willMoveFromView(view: SKView) {
        println("# GameScene:willMoveFromView")
    }
    
//    func touchedActivePiece(point: CGPoint) -> Bool {
//        if activePieces.count > 0 {
//            let activePiece = activePieces[activePieces.count-1]
//            var touchRect:CGRect
//            var sprite = activePiece.sprite
//            if let sprite = activePiece.sprite {
//                if activePiece.direction == .Up || activePiece.direction == .Down {
//                    touchRect = CGRectMake(sprite.position.x - 20, sprite.position.y - 50, 31.0, 130.0)
//                } else {
//                    touchRect = CGRectMake(sprite.position.x - 50, sprite.position.y - 20, 130.0, 31.0)
//                }
//                
//                if CGRectContainsPoint(touchRect, point) {
//                    return true
//                }
//            }
//        }
//        
//        return false
//    }
    
    func addSubmitButton() {

        var buttonTexture = SKTexture(imageNamed: "button")
        var buttonSelectedTexture = SKTexture(imageNamed: "buttonSelected")
        
        if let button = SKButton(normalTexture: buttonTexture, selectedTexture: buttonSelectedTexture, disabledTexture: buttonTexture) as SKButton? {
            button.setButtonLabel(title: "Submit", font: "Helvetica Neue Medium", fontSize: 18)
            button.size = CGSize(width: 150, height: 27)
            button.position = CGPoint(x: 160, y: -30)
            button.setButtonAction(self, triggerEvent: SKButton.FTButtonActionType.TouchDown, action: "submitMove")
            button.hidden = true
            submitButton = button
            boardLayer.addChild(submitButton!)
        }
    }
    
    func submitMove() {
        println("# GameScene:submitMove")
        
        if let sprite = activePiece?.sprite {
            if sprite.hasActions() {
                return
            }
        }
        
        // Communicate this touch back to the ViewController.
        if let handler = submitMoveHandler {
            handler()
        }
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
        //sprite.zPosition = 10
        sprite.size = CGSize(width: kPieceSize, height: kPieceSize)
        tokensLayer.addChild(sprite)
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
    
    func loadCurrentPlayerPhoto(playerImage: UIImage) {
        let playerTexture = SKTexture(image: playerImage)
        let player1ImageNode = SKSpriteNode(texture: playerTexture, size: CGSize(width: 50, height: 50))
        player1ImageNode.position = CGPoint(x: -55, y: 190)
        addChild(player1ImageNode)
    }
    
    func loadOpponentPlayerPhoto(playerImage: UIImage) {
        let playerTexture = SKTexture(image: playerImage)
        let player2ImageNode = SKSpriteNode(texture: playerTexture, size: CGSize(width: 50, height: 50))
        player2ImageNode.position = CGPoint(x: 60, y: 190)
        addChild(player2ImageNode)
    }
    
    func createContent() {
        
        var winnerLabel = SKLabelNode(fontNamed:"Arial Bold")
        winnerLabel.fontSize = 26
        winnerLabel.fontColor = SKColor.blackColor()
        winnerLabel.position = CGPointMake(0, 115)
        winnerLabel.zPosition = 1.0
        winnerLabel.hidden = false
        winnerLabel.name = kWinnerLabelName
        
        addChild(winnerLabel)
        
        addBackgroundImage()
        addPlayerIcons()
        addPlayerIndicators()
        addPlayerLabels()
        addSubmitButton()
        //addTapAreas()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if var activePiece = self.activePiece {
            if let sprite = activePiece.sprite {
                if sprite.hasActions() {
                    let destinationRect = CGRect(x: activePiece.moveDestination.x - (CGFloat(kPieceSize) / 2), y: activePiece.moveDestination.y - (CGFloat(kPieceSize) / 2), width: CGFloat(kPieceSize), height: CGFloat(kPieceSize))
                    if (CGRectIntersectsRect(destinationRect, sprite.frame)) {
                        if activePieces.count > 0 {
                            var piece = activePieces[activePieces.count-1]
                            activePieces.removeAtIndex(activePieces.count-1)
                            let sequence = SKAction.sequence(piece.actions)
                            piece.sprite?.runAction(sequence)
                            self.activePiece = piece
                        }
                    }
                }
            }
        }
    }
    
    func enterNewGame(match:GKTurnBasedMatch) {
        println("# GameScene:enterNewGame")
        //currentMatch = match
    }
    
    func setPlayerNames(match:GKTurnBasedMatch, activePlayer: PieceType) {
        let currentParticipant = participantForLocalPlayerInMatch(match)
        let localPlayerID = GKLocalPlayer.localPlayer().playerID
        var isLocalActive = false;
        
        currentPlayerName = PlayerCache.sharedManager.players[localPlayerID]!.alias
        let opponentParticipant = getOpponentForMatch(match)
        if let opponentPlayerID = opponentParticipant.playerID {
            var opponent = PlayerCache.sharedManager.players[opponentPlayerID]!
            opponentPlayerName = opponent.displayName
        } else {
            opponentPlayerName = "Waiting for opponent"
        }
        
        if let currentParticipant = match.currentParticipant {
            if let currentParticipantPlayerId = currentParticipant.playerID {
                if currentParticipantPlayerId == localPlayerID {
                    isLocalActive = true
                } else  {
                    isLocalActive = false
                }
            } else {
                opponentPlayerName = "Waiting for opponent"
            }
        } else {
            opponentPlayerName = "Waiting for opponent"
        }
        
        //var player1Label = self.childNodeWithName(kPlayer1LabelName) as SKLabelNode
        //var player2Label = self.childNodeWithName(kPlayer2LabelName) as SKLabelNode
        
        if (activePlayer == .Player1) {
            if isLocalActive {
                player1Label.text = currentPlayerName
                player2Label.text = opponentPlayerName
            } else {
                player1Label.text = opponentPlayerName
                player2Label.text = currentPlayerName
            }
        } else if (activePlayer == .Player2) {
            if isLocalActive {
                player1Label.text = opponentPlayerName
                player2Label.text = currentPlayerName
            } else {
                player1Label.text = currentPlayerName
                player2Label.text = opponentPlayerName
            }
        }
    }
    
    func setActivePlayerIndicator(activePlayer: PieceType) {
        if activePlayer == PieceType.Player1 {
            self.player1Indicator.hidden = false
            self.player2Indicator.hidden = true
        } else if activePlayer == PieceType.Player2 {
            self.player1Indicator.hidden = true
            self.player2Indicator.hidden = false
        }
    }
    
    func renderBoard(pieces: Array<Piece?>) {
        println("# GameScene:renderBoard")
        for piece in pieces {
            if piece != nil {
                addSpriteForPiece(piece!, isPieceOnBoard: true)
            }
        }
    }
    
    func displayEndOfGame(winner:String, isTie:Bool) {
        var winnerLabel = self.childNodeWithName(kWinnerLabelName) as SKLabelNode
        if isTie {
            winnerLabel.text = "Tie!"
        } else {
            winnerLabel.text =  "\(winner) Wins!"
        }
        winnerLabel.hidden = false
    }
    
    func removeHighlights() {
        
        self.piecesLayer.enumerateChildNodesWithName("highlight", usingBlock: { (node, stop) -> Void in
            node.removeFromParent()
        })
    }
    
    func addHighlightForMove(move: Move) {
    
        var startRow = move.row
        var startColumn = move.column
        
        self.removeHighlights()
    
        for piece in activePieces.reverse() {
    
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
                    //highlight.color = UIColor.orangeColor()
                    highlight.color = UIColor(red: 0.99, green: 0.4, blue: 0.29, alpha: 100.0)
                    highlight.colorBlendFactor = 1.0
                } else if (piece.pieceType == PieceType.Player1) {
                    highlight.color = UIColor(red: 0.11, green: 0.7, blue: 0.91, alpha: 100.0)
                    //highlight.alpha = 0.6
                    highlight.colorBlendFactor = 1.0
                }
            
                highlight.anchorPoint = CGPointMake(0.0, 0.0)
                highlight.name = "highlight"
            
                if (position.direction == .Down) {
                    highlight.size = CGSize(width: kTileWidth, height: (startRow - position.row + 1) * kTileHeight)
                    highlight.position = CGPoint(x: position.column * kTileWidth + kGridXOffset - 1, y:  (position.row * kTileHeight) + 37)
                } else if (position.direction == .Up) {
                    highlight.size = CGSize(width: kTileWidth, height: (position.row - startRow + 1) * kTileHeight)
                    highlight.position = CGPoint(x: position.column * kTileWidth + kGridXOffset - 1, y: (startRow * kTileHeight) + 37)
                } else if (position.direction == .Right) {
                    highlight.size = CGSize(width: (position.column - startColumn + 1) * kTileWidth, height: kTileHeight)
                    highlight.position = CGPoint(x: (startColumn * kTileWidth) + kGridXOffset - 2, y: position.row * kTileHeight + 38)
                } else if (position.direction == .Left) {
                    highlight.size = CGSize(width: (startColumn - position.column + 1) * kTileWidth, height: kTileHeight)
                    highlight.position = CGPoint(x: kGridXOffset + (position.column * kTileWidth) - 2, y: position.row * kTileHeight + 38)
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
    
    func addPlayerIcons() {
        var player1Icon = SKSpriteNode(imageNamed: "playerIcon1")
        player1Icon.position = CGPoint(x: -55, y: 190)
        player1Icon.size = CGSize(width: 55, height: 55)
        gameLayer.addChild(player1Icon)
        
        var player2Icon = SKSpriteNode(imageNamed: "playerIcon2")
        player2Icon.position = CGPoint(x: 60, y: 190)
        player2Icon.size = CGSize(width: 55, height: 55)
        gameLayer.addChild(player2Icon)
    }
    
    func addPlayerIndicators() {
        player1Indicator.texture = SKTexture(imageNamed: "Player1Indicator")
        player1Indicator.size = CGSize(width: 55, height: 9)
        player1Indicator.position = CGPoint(x: -55, y: 147)
        player1Indicator.hidden = false
        gameLayer.addChild(player1Indicator)
        
        player2Indicator.texture = SKTexture(imageNamed: "Player2Indicator")
        player2Indicator.size = CGSize(width: 55, height: 9)
        player2Indicator.position = CGPoint(x: 60, y: 147)
        player2Indicator.hidden = false
        gameLayer.addChild(player2Indicator)
    }
    
    func addPlayerLabels() {
        player1Label = SKLabelNode(fontNamed:"Arial Bold")
        player1Label.fontSize = 16
        player1Label.fontColor = SKColor.blackColor()
        player1Label.position = CGPoint(x: -55, y: 235)
        player1Label.name = kPlayer1LabelName
        player1Label.text = ""
        gameLayer.addChild(player1Label)
        
        player2Label.fontSize = 16
        player2Label.fontColor = SKColor.blackColor()
        player2Label.position = CGPoint(x: 60, y: 235)
        player2Label.name = kPlayer2LabelName
        player2Label.text = ""
        gameLayer.addChild(player2Label)
    }
    
    func addBackgroundImage() {
        var background = SKSpriteNode(imageNamed: "bright-squares")
        background.size = CGSize(width: 320, height: 568)
        //background.position = CGPointMake(self.size.width/2, self.size.height/2);
        //addChild(background)
        
        //let grid = SKSpriteNode()
        //grid.texture = SKTexture(imageNamed: "grid2")
        var grid = SKSpriteNode(imageNamed:"grid3")
        grid.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        grid.position = CGPoint(x: kTapAreaWidth, y: kTapAreaWidth)
        boardLayer.addChild(grid)
    }
    
    func addTapArrows() {
        let moveDown = SKAction.moveByX(0.0, y: -9.0, duration: 0.5)
        let moveUp = SKAction.moveByX(0.0, y: 9.0, duration: 0.5)
        let moveLeft = SKAction.moveByX(-9.0, y: 0.0, duration: 0.5)
        let moveRight = SKAction.moveByX(9.0, y: 0.0, duration: 0.5)
        
        for var i:Int = 0; i < 8;i++ {
            var downArrow = SKSpriteNode(imageNamed: "down_arrow")
            downArrow.size = CGSize(width: 14.0, height: 8.0)
            downArrow.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            downArrow.position = CGPoint(x: 30 * i + kTapAreaWidth + 8, y: kTileWidth * kNumRows + kTapAreaWidth + 12)
            boardLayer.addChild(downArrow)
            
            var moveActions: [SKAction] = []

            moveActions.append(moveDown)
            moveActions.append(moveUp)

            let downSequence = SKAction.sequence(moveActions)
            let moveDownAction = SKAction.repeatActionForever(downSequence)
            downSequence.timingMode = SKActionTimingMode.EaseIn
            downArrow.runAction(moveDownAction)
            
            var upArrow = SKSpriteNode(imageNamed: "up_arrow")
            upArrow.size = CGSize(width: 14.0, height: 8.0)
            upArrow.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            upArrow.position = CGPoint(x: 30 * i + kTapAreaWidth + 8, y: 16)
            boardLayer.addChild(upArrow)

            var upActions: [SKAction] = []
            upActions.append(moveUp)
            upActions.append(moveDown)

            let upSequence = SKAction.sequence(upActions)
            upSequence.timingMode = SKActionTimingMode.EaseIn
            let moveUpAction = SKAction.repeatActionForever(upSequence)
            upArrow.runAction(moveUpAction)
            
            var leftArrow = SKSpriteNode(imageNamed: "left_arrow")
            leftArrow.size = CGSize(width: 8.0, height: 14.0)
            leftArrow.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            leftArrow.position = CGPoint(x: kNumColumns * kTileWidth + kTapAreaWidth + 14, y: 30 * i + kTapAreaWidth + 10)
            boardLayer.addChild(leftArrow)
            
            var leftActions: [SKAction] = []
            leftActions.append(moveLeft)
            leftActions.append(moveRight)
            
            let leftSequence = SKAction.sequence(leftActions)
            leftSequence.timingMode = SKActionTimingMode.EaseIn
            let moveLeftAction = SKAction.repeatActionForever(leftSequence)
            leftArrow.runAction(moveLeftAction)
            
            var rightArrow = SKSpriteNode(imageNamed: "right_arrow")
            rightArrow.size = CGSize(width: 8.0, height: 14.0)
            rightArrow.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            rightArrow.position = CGPoint(x: 16, y: 30 * i + kTapAreaWidth + 8)
            boardLayer.addChild(rightArrow)
            
            var rightActions: [SKAction] = []
            rightActions.append(moveRight)
            rightActions.append(moveLeft)
            
            let rightSequence = SKAction.sequence(rightActions)
            rightSequence.timingMode = SKActionTimingMode.EaseIn
            let moveRightAction = SKAction.repeatActionForever(rightSequence)
            rightArrow.runAction(moveRightAction)
        }
    }
    
    func addTapAreas() {
        //leftActionArea.strokeColor = SKColor.redColor()
        //leftActionArea.fillColor = SKColor.yellowColor()

        leftActionArea.texture = SKTexture(imageNamed: "tap_area")
        leftActionArea.size = CGSize(width: kTapAreaWidth, height: kTileHeight * kNumRows)
        leftActionArea.hidden = true
        leftActionArea.size = CGSize(width: 45, height: 45)
        leftActionArea.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        leftActionArea.centerRect = CGRectMake(15/45, 15/45, 15/45, 15/45)
        leftActionArea.xScale = 38.0/45.0
        leftActionArea.yScale = 30.0 * 8.0/45.0
        leftActionArea.position = CGPoint(x: -1, y: kTapAreaWidth)
        boardLayer.addChild(leftActionArea)

        rightActionArea.texture = SKTexture(imageNamed: "tap_area")
        //rightActionArea.size = CGSize(width: kTapAreaWidth, height: kTileHeight * kNumRows)
        rightActionArea.hidden = true
        rightActionArea.size = CGSize(width: 45, height: 45)
        rightActionArea.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        rightActionArea.centerRect = CGRectMake(15/45, 15/45, 15/45, 15/45)
        rightActionArea.xScale = 38.0/45.0
        rightActionArea.yScale = 30.0 * 8.0/45.0
        rightActionArea.position = CGPoint(x: kNumColumns * kTileWidth + kTapAreaWidth + 1, y: kTapAreaWidth)
        boardLayer.addChild(rightActionArea)
        
        topActionArea.texture = SKTexture(imageNamed: "tap_area")
        //topActionArea.size = CGSize(width: kTileWidth * kNumRows, height:kTapAreaWidth)
        topActionArea.hidden = true
        topActionArea.size = CGSize(width: 45, height: 45)
        topActionArea.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        topActionArea.centerRect = CGRectMake(15/45, 15/45, 15/45, 15/45)
        topActionArea.xScale = 30.0 * 8.0/45.0
        topActionArea.yScale = 38.0/45.0
        topActionArea.position = CGPoint(x: kTapAreaWidth, y: kTileWidth * kNumRows + kTapAreaWidth + 1)
        boardLayer.addChild(topActionArea)
        
        bottomActionArea.texture = SKTexture(imageNamed: "tap_area")
        //bottomActionArea.size = CGSize(width: kTileWidth * kNumColumns, height: kTapAreaWidth)
        bottomActionArea.hidden = true
        bottomActionArea.size = CGSize(width: 45, height: 45)
        bottomActionArea.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        bottomActionArea.centerRect = CGRectMake(15/45, 15/45, 15/45, 15/45)
        bottomActionArea.xScale = 30.0 * 8.0/45.0
        bottomActionArea.yScale = 38.0/45.0
        bottomActionArea.position = CGPoint(x: kTapAreaWidth, y: 0 - 1)
        boardLayer.addChild(bottomActionArea)
    }
}
