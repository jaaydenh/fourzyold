//
//  GameKitMatchData.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/28/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

import Foundation

class GameKitMatchData {
    var tokenLayout:[Int] = []
    var moves:[Int] = []
    var currentMove:[Int] = []
    var moveNumber:Int = 0
    
    init() {
        
    }
    
    init(matchData: NSData) {
        if let combinedDataArray = NSKeyedUnarchiver.unarchiveObjectWithData(matchData) as? [Int] {
            moveNumber = combinedDataArray[0]
            
            if moveNumber > 0 {
                let movesRangeStart = 1
                let movesRangeEnd = moveNumber * 3
                moves = Array(combinedDataArray[movesRangeStart...movesRangeEnd])
            }
            
            if combinedDataArray.count >= (kNumRows * kNumColumns) + moveNumber * 3 + 1  {
                let tokenLayoutRangeStart = moveNumber * 3 + 1
                let tokenLayoutRangeEnd = tokenLayoutRangeStart + kNumRows * kNumColumns - 1
                tokenLayout = Array(combinedDataArray[tokenLayoutRangeStart...tokenLayoutRangeEnd])
            }
        }
    }
    
    func encodeMatchData() -> NSData {
        var combinedDataArray:[Int] = []
        if currentMove.count > 0 {
            moveNumber++
        }
        combinedDataArray.append(moveNumber)
        combinedDataArray.extend(moves + currentMove + tokenLayout)
        
        let matchData:NSData = NSKeyedArchiver.archivedDataWithRootObject(combinedDataArray)

        return matchData
    }
}

