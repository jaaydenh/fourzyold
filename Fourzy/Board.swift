//
//  Board.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/12/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

import Foundation
import Spritekit

let NumRows = 8
let NumColumns = 8

class Board: SKNode {
    
    // The 2D array that keeps track of the Game Pieces locations
    private var pieces = Array2D<Piece>(columns: Int(kNumColumns), rows: Int(kNumRows))
    
    // The 2D array that contains the layout of the level.
    private var tokens = Array2D<Token>(columns: Int(kNumColumns), rows: Int(kNumRows))
    
    var currentPlayer = 0;
    //var lastPiece: GamePiece
    var layouts: NSInteger = 0
    var currentLayout: NSInteger = 0
    var lastLayout: NSInteger = 0
    //var grid:[[Piece]] = [[]]
    //let backgroundTexture: SKTexture
    
    override init () {

        // initialize properties
        // backgroundTexture = SKTexture(imageNamed: "grid8")
        super.init()
        //super.init(texture: backgroundTexture, color: nil, size: backgroundTexture.size())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initTokensWithBoard(filename:String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            
            // The dictionary contains an array named "tiles". This array contains
            // one element for each row of the level. Each of those row elements in
            // turn is also an array describing the columns in that row. If a column
            // is 1, it means there is a tile at that location, 0 means there is not.
            if let tilesArray: AnyObject = dictionary["tokens"] {
                
                // Loop through the rows...
                for (row, rowArray) in enumerate(tilesArray as [[Int]]) {
                    
                    // Note: In Sprite Kit (0,0) is at the bottom of the screen,
                    // so we need to read this file upside down.
                    let tileRow = NumRows - row - 1
                    
                    // Loop through the columns in the current row...
                    for (column, value) in enumerate(rowArray) {
                        
                        // If the value is 1, create a tile object.
                        if value == 1 {
                            //tiles[column, tileRow] = Tile()
                        }
                    }
                }
            }
        }
    }
    
    func initWithDimension(rows: NSInteger, columns: NSInteger) {
        
        //        for var row = 0; row < kBoardRows; row++ {
        //
        //        }
        //
        //        for (NSInteger i = 0; i < dimension; i++) {
        //        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:dimension];
        //        for (NSInteger j = 0; j < dimension; j++) {
        //        //[array addObject:[[M2Cell alloc] initWithPosition:M2PositionMake(i, j)]];
        //        GamePiece *piece = [[GamePiece alloc] init];
        //        piece.player = Empty;
        //        [array addObject:piece];
        //        }
        //        [self.grid addObject:array];
        //        }
    }
    
    // MARK: Updating the Board
    
    func removePieceAtColumn(column: Int, row: Int) {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        assert(pieces[column, row] != nil)
        pieces[column, row] = nil;
    }
    
    func addPieceAtColumn(column: Int, row: Int, piece: Piece) {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        assert(pieces[column, row] == nil)
        pieces[column, row] = piece;
    }
    
    // MARK: Querying the Board
    
    // Returns the cookie at the specified column and row, or nil when there is none.
    func pieceAtColumn(column: Int, row: Int) -> Piece? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return pieces[column, row]
    }
    
    func getAllPieces() -> Array<Piece?> {
        return pieces.getArray()
    }
    
    // Determines whether there's a tile at the specified column and row.
    func tokenAtColumn(column: Int, row: Int) -> Token? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tokens[column, row]
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
            //winner = [self checkDiagonalForWinnerAtRow:row andColumn:column];
            if (winner != PieceType.None) {
                winMethod = "diagonal"
            }
        }
    
        return winner;
    }
    
    func checkForWinnerInRow(row: Int) -> PieceType {
        var currentPiece:PieceType
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
        var currentPiece:PieceType
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
