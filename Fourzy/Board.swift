//
//  Board.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/12/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

import SpriteKit

let NumRows = 8
let NumColumns = 8

class Board: SKNode {
    
    // The 2D array that keeps track of the Game Pieces locations
    private var pieces = Array2D<Piece>(columns: Int(kNumColumns), rows: Int(kNumRows))
    
    // The 2D array that contains the layout of the level.
    private var tokens = Array2D<Token>(columns: Int(kNumColumns), rows: Int(kNumRows))
    
    var currentPlayer = 0
    var layouts: NSInteger = 0
    var currentLayout: NSInteger = 0
    var lastLayout: NSInteger = 0
    //let backgroundTexture: SKTexture
    
    //var activePieces:[Piece] = []
    
    override init () {

        // initialize properties
        // backgroundTexture = SKTexture(imageNamed: "grid8")
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initTokensWithBoard(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            
            // The dictionary contains an array named "tiles". This array contains
            // one element for each row of the level. Each of those row elements in
            // turn is also an array describing the columns in that row. If a column
            // is 1, it means there is a tile at that location, 0 means there is not.
            if let tokensArray: AnyObject = dictionary["tokens"] {
                
                // Loop through the rows...
                for (row, rowArray) in enumerate(tokensArray as! [[Int]]) {
                    
                    // Note: In Sprite Kit (0,0) is at the bottom of the screen,
                    // so we need to read this file upside down.
                    let tileRow = NumRows - row - 1
                    
                    // Loop through the columns in the current row...
                    for (column, value) in enumerate(rowArray) {
                        
                        if let tokenType = TokenType(rawValue: value) {
                            let token = Token(column: column, row: tileRow, tokenType: tokenType)
                            addTokenAtColumn(column, row: tileRow, token: token)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Updating the Board
    
    func removePieceAtColumn(column: Int, row: Int) {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        assert(pieces[column, row] != nil)
        pieces[column, row] = nil
    }
    
    func addPieceAtColumn(column: Int, row: Int, piece: Piece) {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        //assert(pieces[column, row] == nil)
        pieces[column, row] = piece
    }
    
    func addTokenAtColumn(column: Int, row: Int, token: Token) {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        assert(tokens[column, row] == nil)
        tokens[column, row] = token
    }
    
    // MARK: Querying the Board
    
    // Returns the piece at the specified column and row, or nil when there is none.
    func pieceAtColumn(column: Int, row: Int) -> Piece? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return pieces[column, row]
    }
    
    func getAllPieces() -> Array<Piece?> {
        return pieces.getArray()
    }
    
    func getAllTokens() -> Array<Token?> {
        return tokens.getArray()
    }
    
    func tokenAtColumn(column: Int, row: Int) -> Token? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tokens[column, row]
    }
    
    func piecesCount() -> Int {
        var count = 0
        
        for (var row = kNumRows - 1;row >= 0;row--) {
            for (var column = 0;column < kNumColumns;column++) {
                if let piece = pieceAtColumn(column, row: row) {
                    count++
                }
            }
        }
        
        return count
    }
    
    func printBoard() {
        var count = 0
        println()
        for (var row = kNumRows - 1;row >= 0;row--) {
            for (var column = 0;column < kNumColumns;column++) {
                if let piece = pieceAtColumn(column, row: row) {
                    print(piece.description)
                } else {
                    print("0")
                }
                print(" ")
            }
            println()
        }
    }
    
    func getDestinationForPiece(piece: Piece, move: Move) -> Bool {
        println("# Board:GetDestinationForPiece")
        let direction = move.direction
        let startingRow = move.row
        let startingColumn = move.column
        var destinationRow: Int
        var destinationColumn: Int
        var destinationDirection: Direction
        var canMove: Bool = false
        
        if (pieceAtColumn(startingColumn, row: startingRow) != nil) {
            if let token = tokenAtColumn(startingColumn, row: startingRow) {
                if (token.tokenType != .Sticky) {
                    return false
                }
            } else {
                return false
            }
        } else {
            if let token = tokenAtColumn(startingColumn, row: startingRow) {
                if (token.tokenType == .Blocker) {
                    return false
                }
            }
        }
        
        switch (direction) {
        case .Down:
            destinationRow = 0
            destinationColumn = startingColumn
            destinationDirection = .Down
            
            for var row:Int = startingRow; row >= 0;row-- {
                if let token = tokenAtColumn(startingColumn, row: row) {
                    if (token.tokenType == .Sticky) {
                        if (pieceAtColumn(startingColumn, row: row) != nil) {
                            // If the piece in the sticky square can move
                            if (row - 1 >= 0 && (pieceAtColumn(startingColumn, row: row - 1) == nil || tokenAtColumn(startingColumn, row: row - 1)?.tokenType == TokenType.Sticky)) {
                                if let stuckPiece = pieceAtColumn(startingColumn, row: row) {
                                    stuckPiece.resetMovement()
                                    let move = Move(column: startingColumn, row: row - 1, direction: .Down, player: stuckPiece.pieceType)
                                    let result = getDestinationForPiece(stuckPiece, move: move)
                                    if result {
                                        activePieces.append(stuckPiece)
                                        destinationRow = row
                                        canMove = true
                                    } else {
                                        //canMove = false
                                    }
                                    break
                                }
                            } else {
                                // piece in sticky square cannot move
                                destinationRow = row + 1
                                //canMove = false
                                break
                            }
                        } else {
                            destinationRow = row
                            canMove = true
                            break
                        }
                    } else if pieceAtColumn(startingColumn, row: row) != nil {
                        destinationRow = row + 1
                        canMove = true
                        break
                    } else if token.tokenType == .UpArrow {
                        destinationRow = row
                        let move = Move(column: startingColumn, row: row + 1, direction: .Up, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .DownArrow {
                        destinationRow = row
                        let move = Move(column: startingColumn, row: row - 1, direction: .Down, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .LeftArrow {
                        destinationRow = row
                        let move = Move(column: startingColumn - 1, row: row, direction: .Left, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .RightArrow {
                        destinationRow = row
                        let move = Move(column: startingColumn + 1, row: row, direction: .Right, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .Blocker {
                        destinationRow = row + 1
                        canMove = true
                        break
                    }
                } else {
                    if pieceAtColumn(startingColumn, row: row) != nil {
                        destinationRow = row + 1
                        canMove = true
                        break
                    }
                }
                
                destinationRow = row
                canMove = true
            }
            break
            
        case .Up:
            destinationRow = Int(kNumRows) - 1
            destinationColumn = startingColumn
            destinationDirection = .Up
            
            for var row:Int = startingRow; row <= Int(kNumRows) - 1;row++ {
                if let token = tokenAtColumn(startingColumn, row: row) {
                    if token.tokenType == .Sticky {
                        if pieceAtColumn(startingColumn, row: row) != nil {
                            // If the piece in the sticky square can move
                            if (row + 1 < Int(kNumRows) && (pieceAtColumn(startingColumn, row: row + 1) == nil || tokenAtColumn(startingColumn, row: row + 1)?.tokenType == TokenType.Sticky)) {
                                if let stuckPiece = pieceAtColumn(startingColumn, row: row) {
                                    stuckPiece.resetMovement()
                                    let move = Move(column: startingColumn, row: row + 1, direction: .Up, player: stuckPiece.pieceType)
                                    let result = getDestinationForPiece(stuckPiece, move: move)
                                    if result {
                                        activePieces.append(stuckPiece)
                                        destinationRow = row
                                        canMove = true
                                    } else {
                                        //canMove = false
                                    }
                                    break
                                }
                            } else {
                                // piece in sticky square cannot move
                                destinationRow = row - 1
                                //canMove = false
                                break
                            }
                        } else {
                            destinationRow = row
                            canMove = true
                            break
                        }
                    } else if pieceAtColumn(startingColumn, row: row) != nil {
                        destinationRow = row - 1
                        canMove = true
                        break
                    } else if token.tokenType == .UpArrow {
                        destinationRow = row
                        let move = Move(column: startingColumn, row: row + 1, direction: .Up, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .DownArrow {
                        destinationRow = row
                        let move = Move(column: startingColumn, row: row - 1, direction: .Down, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .LeftArrow {
                        destinationRow = row
                        let move = Move(column: startingColumn - 1, row: row, direction: .Left, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .RightArrow {
                        destinationRow = row
                        let move = Move(column: startingColumn + 1, row: row, direction: .Right, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .Blocker {
                        destinationRow = row - 1
                        canMove = true
                        break
                    }
                } else {
                    if pieceAtColumn(startingColumn, row: row) != nil {
                        destinationRow = row - 1
                        canMove = true
                        break
                    }
                }
                
                destinationRow = row
                canMove = true
            }
            break
            
        case .Left:
            destinationRow = startingRow
            destinationColumn = 0
            destinationDirection = .Left
            
            for var column:Int = startingColumn; column >= 0;column-- {
                if let token = tokenAtColumn(column, row: startingRow) {
                    if token.tokenType == .Sticky {
                        if pieceAtColumn(column, row: startingRow) != nil {
                            // If the piece in the sticky square can move
                            if (column - 1 >= 0 && (pieceAtColumn(column - 1, row: startingRow) == nil || tokenAtColumn(column - 1, row: startingRow)?.tokenType == TokenType.Sticky)) {
                                if let stuckPiece = pieceAtColumn(column, row: startingRow) {
                                    stuckPiece.resetMovement()
                                    let move = Move(column: column - 1, row: startingRow, direction: .Left, player: stuckPiece.pieceType)
                                    let result = getDestinationForPiece(stuckPiece, move: move)
                                    if result {
                                        activePieces.append(stuckPiece)
                                        destinationColumn = column
                                        canMove = true
                                    } else {
                                        //canMove = false
                                    }
                                    break
                                }
                            } else {
                                // piece in sticky square cannot move
                                destinationColumn = column + 1
                                //canMove = false
                                break
                            }
                        } else {
                            destinationColumn = column
                            canMove = true
                            break
                        }
                    } else if pieceAtColumn(column, row: startingRow) != nil {
                        destinationColumn = column + 1
                        canMove = true
                        break
                    } else if token.tokenType == .UpArrow {
                        destinationColumn = column
                        let move = Move(column: column, row: startingRow + 1, direction: .Up, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .DownArrow {
                        destinationColumn = column
                        let move = Move(column: column, row: startingRow - 1, direction: .Down, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .LeftArrow {
                        destinationColumn = column
                        let move = Move(column: column - 1, row: startingRow, direction: .Left, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .RightArrow {
                        destinationColumn = column
                        let move = Move(column: column + 1, row: startingRow, direction: .Right, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .Blocker {
                        destinationColumn = column + 1
                        canMove = true
                        break
                    }
                } else {
                    if pieceAtColumn(column, row: startingRow) != nil {
                        destinationColumn = column + 1
                        canMove = true
                        break
                    }
                }
                
                destinationColumn = column
                canMove = true
            }
            break
            
        case .Right:
            destinationRow = startingRow
            destinationColumn = Int(kNumColumns) - 1
            destinationDirection = .Right
            
            for var column:Int = startingColumn; column <= Int(kNumColumns) - 1;column++ {
                if let token = tokenAtColumn(column, row: startingRow) {
                    if token.tokenType == .Sticky {
                        if pieceAtColumn(column, row: startingRow) != nil {
                            // If the piece in the sticky square can move
                            if (column + 1 < Int(kNumColumns) && (pieceAtColumn(column + 1, row: startingRow) == nil || tokenAtColumn(column + 1, row: startingRow)?.tokenType == TokenType.Sticky)) {
                                if let stuckPiece = pieceAtColumn(column, row: startingRow) {
                                    stuckPiece.resetMovement()
                                    let move = Move(column: column + 1, row: startingRow, direction: .Right, player: stuckPiece.pieceType)
                                    let result = getDestinationForPiece(stuckPiece, move: move)
                                    if result {
                                        activePieces.append(stuckPiece)
                                        destinationColumn = column
                                        canMove = true
                                    } else {
                                        //canMove = false
                                    }
                                    break
                                }
                            } else {
                                // piece in sticky square cannot move
                                destinationColumn = column - 1
                                //canMove = false
                                break
                            }
                        } else {
                            destinationColumn = column
                            canMove = true
                            break
                        }
                    } else if pieceAtColumn(column, row: startingRow) != nil {
                        destinationColumn = column - 1
                        canMove = true
                        break
                    } else if token.tokenType == .UpArrow {
                        destinationColumn = column
                        let move = Move(column: column, row: startingRow + 1, direction: .Up, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .DownArrow {
                        destinationColumn = column
                        let move = Move(column: column, row: startingRow - 1, direction: .Down, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .LeftArrow {
                        destinationColumn = column
                        let move = Move(column: column - 1, row: startingRow, direction: .Left, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .RightArrow {
                        destinationColumn = column
                        let move = Move(column: column + 1, row: startingRow, direction: .Right, player: piece.pieceType)
                        getDestinationForPiece(piece, move: move)
                        canMove = true
                        break
                    } else if token.tokenType == .Blocker {
                        destinationColumn = column - 1
                        canMove = true
                        break
                    }
                } else {
                    if pieceAtColumn(column, row: startingRow) != nil {
                        destinationColumn = column - 1
                        canMove = true
                        break
                    }
                }
                
                destinationColumn = column
                canMove = true
            }
            break
            
        default:
            break
        }
        
        let position = GridPosition(column: destinationColumn, row: destinationRow, direction: destinationDirection)
        piece.moveDestinations.append(position)
        return canMove
    }
    
    func checkForWinnerAtRow(row: Int, column: Int) -> PieceType {
        var winner = PieceType.None
        var winMethod = ""
    
        winner = checkForWinnerInRow(row)
        if (winner != PieceType.None) {
            winMethod = "row"
        }
        if (winner == PieceType.None) {
            winner = checkForWinnerInColumn(column)
            if (winner != PieceType.None) {
                winMethod = "column"
            }
        }
        if (winner == PieceType.None) {
            winner = checkDiagonalForWinnerAtRow(row, currentColumn:column)
            if (winner != PieceType.None) {
                winMethod = "diagonal"
            }
        }
    
        return winner
    }
    
    func checkForWinnerInRow(row: Int) -> PieceType {
        var winCounter = 0
    
        for (var column = 0; column < NumColumns; column++) {
            if column > 0 && pieceAtColumn(column, row: row)?.pieceType != pieceAtColumn(column - 1, row: row)?.pieceType {
                winCounter = 0
            }
            if let currentPiece = pieceAtColumn(column, row: row)?.pieceType {
                winCounter = updateWinCounterWithRow(row, column: column, player: currentPiece, wins: winCounter)
                if (winCounter >= 4) {
                    return currentPiece
                }
            }
        }
    
        return PieceType.None
    }
    
    func checkForWinnerInColumn(column: Int) -> PieceType {
        var winCounter = 0
    
        for (var row = 0; row < NumRows; row++) {
            if row > 0 && pieceAtColumn(column, row: row)?.pieceType != pieceAtColumn(column, row: row - 1)?.pieceType {
                winCounter = 0
            }
            
            if let currentPiece = pieceAtColumn(column, row: row)?.pieceType {
                winCounter = updateWinCounterWithRow(row, column: column, player: currentPiece, wins: winCounter)
                if (winCounter >= 4) {
                    return currentPiece
                }
            }
        }
    
        return PieceType.None
    }
    
    func checkDiagonalForWinnerAtRow(currentRow: Int, currentColumn: Int) -> PieceType {
        var winCounter = 0
        var startingRow = 0
        var startingColumn = 0
        var row: Int, column: Int
    
        for (row = currentRow, column = currentColumn; row >= 0 && column >= 0;row--,column--) {
            startingRow = row
            startingColumn = column
        }
    
        for (row = startingRow, column = startingColumn; row < NumRows && column < NumColumns; row++,column++) {
            if (row > startingRow && column > startingColumn && pieceAtColumn(column, row: row)?.pieceType != pieceAtColumn(column-1, row: row-1)?.pieceType) {
                winCounter = 0
            }
            if let currentPiece = pieceAtColumn(column, row: row)?.pieceType {
                winCounter = updateWinCounterWithRow(row, column: column, player: currentPiece, wins: winCounter)
    
                if (winCounter >= 4) {
                    return currentPiece
                }
            }
        }
    
        winCounter = 0
    
        for (row = currentRow, column = currentColumn; row < NumRows && column >= 0;row++,column--) {
            startingRow = row
            startingColumn = column
        }
    
        for (row = startingRow, column = startingColumn; row >= 0 && column < NumColumns;row--,column++) {
            if (row < startingRow && column > startingColumn && pieceAtColumn(column, row: row)?.pieceType != pieceAtColumn(column-1, row: row+1)?.pieceType) {
                winCounter = 0
            }
            if let currentPiece = pieceAtColumn(column, row: row)?.pieceType {
                winCounter = updateWinCounterWithRow(row, column: column, player: currentPiece, wins: winCounter)
                
                if (winCounter >= 4) {
                    return currentPiece
                }
            }
        }
    
        return PieceType.None
    }
    
    func updateWinCounterWithRow(row:Int, column:Int, player:PieceType, wins:Int) -> Int {
        var winCounter = wins
        if pieceAtColumn(column, row: row)?.pieceType != PieceType.None {
            if pieceAtColumn(column, row: row)?.pieceType == player {
                winCounter++
            } else {
                winCounter = 0
            }
        } else {
            winCounter = 0
        }
    
        return winCounter
    }
}
