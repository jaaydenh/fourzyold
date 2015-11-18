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
        var lastMove:NSDate = NSDate()
    
        for participant in self.participants! {
            if participant.player?.playerID == GKLocalPlayer.localPlayer().playerID {
                localParticipant = participant as GKTurnBasedParticipant
            } else {
                otherParticipant = participant as GKTurnBasedParticipant
            }
        }
    
        if let localParticipant = localParticipant {
            if let otherParticipant = otherParticipant {
                if self.currentParticipant != nil {
                    if localParticipant == self.currentParticipant {
                        if otherParticipant.lastTurnDate != nil {
                            lastMove = otherParticipant.lastTurnDate!
                        }
                    } else {
                        if localParticipant.lastTurnDate != nil {
                            lastMove = localParticipant.lastTurnDate!
                        }
                    }
                } else {
                    if localParticipant.lastTurnDate != nil {
                        lastMove = localParticipant.lastTurnDate!
                    }
                }
            }
        }
        return lastMove
    }
    
}