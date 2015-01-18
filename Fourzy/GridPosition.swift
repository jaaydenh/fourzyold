//
//  GridPosition.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/26/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

struct GridPosition {
    let row: Int
    let column: Int
    var direction: Direction
    
    init(column: Int, row: Int, direction: Direction) {
        self.column = column
        self.row = row
        self.direction = direction
    }
}
