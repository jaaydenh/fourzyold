//
//  Array2D.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/19/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

struct Array2D<T> {
    let columns: Int
    let rows: Int
    private var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(count: rows*columns, repeatedValue: nil)
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[row*columns + column]
        }
        set {
            array[row*columns + column] = newValue
        }
    }
    
    func getArray() -> Array<T?> {
        return array
    }
}

