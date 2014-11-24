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
    
    init() {
        
    }
    
    init(matchData: NSData) {
        if let combinedDataArray = NSKeyedUnarchiver.unarchiveObjectWithData(matchData) as? [Int] {
            //if combinedDataArray.count >= (Int(kNumRows) * Int(kNumColumns)) {
                
                //let tokenLayoutRangeEnd = Int(kNumRows) * Int(kNumColumns)
                //tokenLayout = Array(combinedDataArray[0...tokenLayoutRangeEnd])
                
                let movesRangeStart = Int(kNumRows) * Int(kNumColumns)
                let movesRangeEnd = combinedDataArray.count + movesRangeStart
                //moves = Array(combinedDataArray[movesRangeStart...movesRangeEnd])
                moves = combinedDataArray
            //} else {
                //TODO: throw error here
                //println("Match data is corrupt when initializing matchdata")
            //}
        }
    }
    
    func encodeMatchData() -> NSData {
        var finalDataArray:[Int] = []
        if currentMove.count > 0 {
            finalDataArray = tokenLayout + moves + currentMove
        }
        let matchData:NSData = NSKeyedArchiver.archivedDataWithRootObject(finalDataArray)

        return matchData;
    }
}

