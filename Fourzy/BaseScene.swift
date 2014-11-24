//
//  BaseScene.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/12/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

import SpriteKit

class BaseScene : SKScene {
    
    
    // ASSET LOADING
    class func loadSceneAssetsWithCompletionHandler(completionHandler: () -> Void) {
        let queue = dispatch_get_main_queue()
        
        let backgroundQueue = dispatch_get_global_queue(CLong(DISPATCH_QUEUE_PRIORITY_HIGH), 0)
        dispatch_async(backgroundQueue) {
            self.loadSceneAssets()
            
            dispatch_async(queue, completionHandler)
        }
    }
    
    class func loadSceneAssets() {
        
    }
}


