//
//  Set.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/21/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

struct GameSet<T: Hashable>: SequenceType, CustomStringConvertible {
    private var dictionary = Dictionary<T, Bool>()
    
    mutating func addElement(newElement: T) {
        dictionary[newElement] = true
    }
    
    mutating func removeElement(element: T) {
        dictionary[element] = nil
    }
    
    func containsElement(element: T) -> Bool {
        return dictionary[element] != nil
    }
    
    func allElements() -> [T] {
        return Array(dictionary.keys)
    }
    
    var count: Int {
        return dictionary.count
    }
    
    func unionSet(otherSet: GameSet<T>) -> GameSet<T> {
        var combined = GameSet<T>()
        
        for obj in dictionary.keys {
            combined.dictionary[obj] = true
        }
        
        for obj in otherSet.dictionary.keys {
            combined.dictionary[obj] = true
        }
        
        return combined
    }
    
    func generate() -> IndexingGenerator<Array<T>> {
        return allElements().generate()
    }
    
    var description: String {
        return dictionary.description
    }
}
