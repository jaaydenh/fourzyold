//
//  Utilities.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 11/30/14.
//  Copyright (c) 2014 PartyTroll. All rights reserved.
//

import GameKit

// array of pieces currently being animated or with actions pending
var activePieces:[Piece] = []

func getOpponentForMatch(match: GKTurnBasedMatch) -> GKTurnBasedParticipant {
    let localPlayerID = GKLocalPlayer.localPlayer().playerID
    var opponent: GKTurnBasedParticipant!
    
    for p in match.participants!
    {
        if let playerID = p.player?.playerID {
            if playerID != localPlayerID
            {
                opponent = p as GKTurnBasedParticipant
                break
            }
        } else {
            opponent = p as GKTurnBasedParticipant
        }

    }
    assert(opponent != nil)
    return opponent
}

func participantForLocalPlayerInMatch(match: GKTurnBasedMatch) -> GKTurnBasedParticipant {
    let localPlayerID = GKLocalPlayer.localPlayer().playerID
    var localPlayerParticipant: GKTurnBasedParticipant!
    
    for p in match.participants!
    {
        if p.player?.playerID == localPlayerID
        {
            localPlayerParticipant = p as GKTurnBasedParticipant
            break
        }
    }
    
    return localPlayerParticipant
}