//
//  Extensions.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/19/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

import Foundation

extension Dictionary {
    
    // Loads a JSON file from the app bundle into a new dictionary
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            
            var data: NSData?
            do {
                data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
            } catch {
                print("Could not load level file: \(filename), error: \(error)")
            }

            //let data: NSData? = NSData(contentsOfFile: path, options: NSDataReadingOptions(), error: &error)
            if let data = data {
                
                var dictionary: AnyObject?
                do {
                    dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                } catch {
                    print("Could not load level file: \(filename), error: \(error)")
                }

                if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                    return dictionary
                } else {
//                    print("Level file '\(filename)' is not valid JSON: \(error!)")
                    return nil
                }
            } else {
                return nil
            }
        } else {
            print("Could not find level file: \(filename)")
            return nil
        }
    }
}
