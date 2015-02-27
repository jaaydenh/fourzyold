//
//  GKTurnBasedMatchExtension.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 2/25/15.
//  Copyright (c) 2015 PartyTroll. All rights reserved.
//

import Foundation
import GameKit

extension GKTurnBasedMatch {

    func lastMove() -> NSDate {
        var localParticipant:GKTurnBasedParticipant?
        var otherParticipant:GKTurnBasedParticipant?
        var lastMove:NSDate?
    
        for participant in self.participants {
            if participant.playerID == GKLocalPlayer.localPlayer().playerID {
                localParticipant = participant as? GKTurnBasedParticipant
            } else {
                otherParticipant = participant as? GKTurnBasedParticipant
            }
        }
    
        if let localParticipant = localParticipant {
            if let otherParticipant = otherParticipant {
                if localParticipant == self.currentParticipant {
                    lastMove = otherParticipant.lastTurnDate;
                } else {
                    lastMove = localParticipant.lastTurnDate;
                }
            }
        }
        return lastMove!
    }
    
}