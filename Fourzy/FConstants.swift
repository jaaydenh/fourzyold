//
//  Constants.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/9/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

let kPieceSize = 30
let kTapAreaWidth: Int = 40
let kNumRows: Int = 8
let kNumColumns: Int = 8
let kWinnerLabelName = "winnerLabel"
let kTileWidth: Int = 30
let kTileHeight: Int = 30
let kGridXOffset: Int = 40
let kGridYOffset: Int = 150
let kGamePieceName = "gamepiece"
let kTokenName = "token"

enum Player {
    case None, Player1, Player2
}

enum Direction:Int {
    case Up = 1, Down, Left, Right
}

//enum TokenType {
//    case None, Sticky, UpArrow, DownArrow, LeftArrow, RightArrow, Blocker
//}