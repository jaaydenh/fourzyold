//
//  PlayerCache.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 12/15/14.
//  Copyright (c) 2014 PartyTroll. All rights reserved.
//

import GameKit

class PlayerCache {
    var players = [String: GKPlayer]()
    var playerPhotos = [String: UIImage]()
    
    class var sharedManager: PlayerCache {
        struct Static {
            static let instance = PlayerCache()
        }
        return Static.instance
    }
}
