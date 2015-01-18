//
//  GameViewController.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 10/7/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData!)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, GKLocalPlayerListener {
    
    @IBOutlet var loadingProgressIndicator: UIActivityIndicatorView!
    
    var scene: GameScene!
    var match:GKTurnBasedMatch!
    var isMultiplayer = true
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.registerListener(self)
        
        // Start the progress indicator animation.
        self.loadingProgressIndicator.startAnimating()
        
        GameScene.loadSceneAssetsWithCompletionHandler {
            var viewSize = self.view.bounds.size
            
            // On iPhone/iPod touch we want to see a similar amount of the scene as on iPad.
            // So, we set the size of the scene to be double the size of the view, which is
            // the whole screen, 3.5- or 4- inch. This effectively scales the scene to 50%.
            //            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            //                viewSize.height *= 2
            //                viewSize.width *= 2
            //            }
            
            self.scene = GameScene(size: viewSize)
            self.scene.scaleMode = .AspectFill
            self.scene.currentMatch = self.match
            self.scene.isMultiplayer = self.isMultiplayer
            
            self.loadingProgressIndicator.stopAnimating()
            self.loadingProgressIndicator.hidden = true
            
            if self.isMultiplayer {
                self.scene.loadPlayerPhotos()
            }
            
            let skView = self.view as SKView

            skView.showsDrawCount = true
            skView.showsFPS = true
            skView.multipleTouchEnabled = false
            skView.ignoresSiblingOrder = true

            skView.presentScene(self.scene)
            
            UIView.animateWithDuration(2.0) {
                //self.archerButton.alpha = 1.0
                //self.warriorButton.alpha = 1.0
            }
        }
    }
    
    func player(player: GKPlayer!, receivedTurnEventForMatch match: GKTurnBasedMatch!, didBecomeActive: Bool) {
        println("receivedTurnEventForMatch:GameViewController")
        if (self.scene.currentMatch != nil) {
            if (self.scene.currentMatch.matchID == match.matchID) {
                self.scene.playLastMove()
            }
        }
    }
    
    func player(player: GKPlayer!, matchEnded match: GKTurnBasedMatch!) {
        if (self.scene.currentMatch.matchID == match.matchID) {
            self.scene.playLastMove()
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
