    //
//  ViewController.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 9/10/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

import UIKit
import GameKit

let PresentAuthenticationViewController = "present_authentication_view_controller"
let LocalPlayerIsAuthenticated = "local_player_authenticated"


class ViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, GKTurnBasedMatchmakerViewControllerDelegate, GKLocalPlayerListener {
    
    var authenticationViewController: UIViewController!
    @IBOutlet var matchListTableView: UITableView?
    var matches = []
    var refreshControl:UIRefreshControl!
    var lastError:NSError!
    var enableGameCenter:Bool!
    var loadingMatches:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAuthenticationViewController", name: PresentAuthenticationViewController, object: nil)
        
        authenticateLocalPlayer()
        //GameKitTurnBasedMatchHelper.sharedInstance().authenticateLocalPlayer()
        
        //GameKitTurnBasedMatchHelper.sharedInstance().viewControllerDelegate = self;
        
        self.refreshControl = UIRefreshControl();
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh");
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)

        self.matchListTableView?.addSubview(refreshControl)
    }
    
    func authenticateLocalPlayer() {
        var localPlayer = GKLocalPlayer.localPlayer()

        if localPlayer.authenticated {
            NSNotificationCenter.defaultCenter().postNotificationName(LocalPlayerIsAuthenticated, object: nil)
            println("Local Player is Authenticated: \(localPlayer.authenticated)")
            return
        }

        localPlayer.authenticateHandler = {(viewController:UIViewController!, error:NSError!) -> Void in
            
            if (error != nil) {
                self.setLastError(error!)
            }
            
            if((viewController) != nil) {
                //self.presentViewController(viewController, animated: true, completion: nil)
                self.showAuthenticationDialogWhenReasonable(viewController)
            } else if (localPlayer.authenticated){
                println("Local player already authenticated")
                self.enableGameCenter = true
                localPlayer.registerListener(self)
                self.localPlayerWasAuthenticated()
                NSNotificationCenter.defaultCenter().postNotificationName(LocalPlayerIsAuthenticated, object: nil)
            } else {
                println("Local player could not be authenticated, disabling GameCenter")
                self.enableGameCenter = false
            }
        }
    }
    
    func showAuthenticationDialogWhenReasonable(authenticationViewController:UIViewController) {
        self.authenticationViewController = authenticationViewController;
        NSNotificationCenter.defaultCenter().postNotificationName(PresentAuthenticationViewController, object: self)
    }
    
    func localPlayerWasAuthenticated() {
        
        //[GKTurnBasedEventHandler sharedTurnBasedEventHandler].delegate = self;
        loadMatches()
    }

    func loadMatches() {
        if ((loadingMatches) != nil) {
            if loadingMatches == true {
                return
            }
        }

        loadingMatches = true;
        
        GKTurnBasedMatch.loadMatchesWithCompletionHandler { (matches:[AnyObject]!, error:NSError!) -> Void in
            if (error != nil)
            {
                println("Error fetching matches: \(error.localizedDescription)");
            }
            if matches != nil {
                self.matches = matches as [GKTurnBasedMatch]
                
                self.didFetchMatches(matches)
            }

            
            self.loadingMatches = false
        }
    }
    
    
    
    func setLastError(error:NSError) {
        if let lastError = error.copy() as? NSError {
            
            println("GameKitHelper ERROR: \(lastError.userInfo?.description)")
        
            if error.domain == GKErrorDomain {
                if error.code == GKErrorCode.NotSupported.rawValue {
                    // Not supported
                } else if error.code == GKErrorCode.Cancelled.rawValue {
                    // Login cancelled
                }
            }
        }
    }
    
    func refresh(sender:AnyObject) {
        println("refresh")
        //GameKitTurnBasedMatchHelper.sharedInstance().loadMatches()
        loadMatches()
    }
    
    override func viewDidAppear(animated: Bool) {

        println("ViewController: viewdidappear")
        if GKLocalPlayer.localPlayer().authenticated {
            loadMatches()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    @IBAction func newGame(sender: AnyObject) {
        println("start new game")
        //GameKitTurnBasedMatchHelper.sharedInstance().findMatchWithMinPlayers(2, maxPlayers: 2, showExistingMatches: false)
        //self.performSegueWithIdentifier("segueToGamePlay", sender: self)

        var request = GKMatchRequest()
        request.minPlayers = 2;
        request.maxPlayers = 2;
        request.defaultNumberOfPlayers = 2;
        request.playerAttributes = 0xFFFFFFFF;
        
        var mmvc = GKTurnBasedMatchmakerViewController(matchRequest: request)
        mmvc.turnBasedMatchmakerDelegate = self;

        self.presentViewController(mmvc, animated:true, completion:nil)
    }
    
    @IBAction func newPassAndPlayGame(sender: AnyObject) {
        println("start new pass and play game")
        self.performSegueWithIdentifier("segueToGamePlay", sender: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: nil)

        let match: GKTurnBasedMatch = self.matches[indexPath.row] as GKTurnBasedMatch
        
        cell.textLabel.text = match.matchID
        
        if match.status == GKTurnBasedMatchStatus.Ended {
            cell.detailTextLabel?.text = "Game Over"
        } else {
            let localPlayerID = GKLocalPlayer.localPlayer().playerID
            println(match.currentParticipant)
            if let currentParticipant = match.currentParticipant.playerID {
                if match.currentParticipant.playerID == localPlayerID {
                    cell.detailTextLabel?.text = "Your Turn"
                } else  {
                    cell.detailTextLabel?.text = "Waiting For Turn"
                }
            } else {
                cell.detailTextLabel?.text = "Waiting For Turn"
            }
        }
        


//        var opponentPlayerId: String
//        
//        for participant in matchData.participants {
//            if participant.playerID != nil {
//                if participant.playerID != localPlayerID {
//                    opponentPlayerId = participant.playerID
//                }
//            } else {
//                opponentPlayerId = "empty"
//            }
//
//        }
        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("select match" + self.matches[indexPath.row].matchID);
        //GameKitTurnBasedMatchHelper.sharedInstance().currentMatch = self.matches[indexPath.row] as GKTurnBasedMatch
        let match = self.matches[indexPath.row] as GKTurnBasedMatch
        self.performSegueWithIdentifier("segueToGamePlay", sender: match)
    }
    
    func showAuthenticationViewController() {
        //self.presentViewController(GameKitTurnBasedMatchHelper.sharedInstance().authenticationViewController, animated: true, completion: nil)
        self.presentViewController(authenticationViewController, animated: true, completion: nil)
    }
    
    func didFetchMatches(matches: [AnyObject]!) {
        println("didFetchMatches");
        
        if let matchList = matches as? [GKTurnBasedMatch]
        {
            self.matches = matchList;
            self.matchListTableView!.reloadData()
        }
        
        self.refreshControl.endRefreshing()
    }
    
    func enterNewGame(match:GKTurnBasedMatch) {
        println("Entering new game...")
        //GameKitTurnBasedMatchHelper.sharedInstance().currentMatch = match
        self.performSegueWithIdentifier("segueToGamePlay", sender: match)
    }

    func layoutMatch(match: GKTurnBasedMatch) {
        println("layoutMatch...")
        //GameKitTurnBasedMatchHelper.sharedInstance().currentMatch = match
        self.performSegueWithIdentifier("segueToGamePlay", sender: match)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("prepareForSegue")
        if segue.identifier == "segueToGamePlay" {
           let gameViewController = segue.destinationViewController as GameViewController
            //gameViewController.delegate = self
            if sender != nil {
                gameViewController.match = sender as GKTurnBasedMatch
                gameViewController.isMultiplayer = true
            } else {
                gameViewController.isMultiplayer = false
            }
        }
    }
    
        // The user has cancelled
    func turnBasedMatchmakerViewControllerWasCancelled(viewController: GKTurnBasedMatchmakerViewController!) {
        println("### MM cancelled!")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Matchmaking has failed with an error
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController!, didFailWithError error: NSError!) {
        println("### MM failed: \(error)")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // A turned-based match has been found, the game should start
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController!, didFindMatch match: GKTurnBasedMatch!) {
        println("### Yeah......Game starting......")
        self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("segueToGamePlay", sender: match)
    }
    
    // Called when a users chooses to quit a match and that player has the current turn.  The developer should call playerQuitInTurnWithOutcome:nextPlayer:matchData:completionHandler: on the match passing in appropriate values.  They can also update matchOutcome for other players as appropriate.
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController!, playerQuitForMatch match: GKTurnBasedMatch!) {
        println("### Quit.....match")
        // TODO
    }
    
    func player(player: GKPlayer!, receivedTurnEventForMatch match: GKTurnBasedMatch!, didBecomeActive: Bool) {
        println("receivedTurnEventForMatch:didBecomeActive: \(didBecomeActive)")
        self.performSegueWithIdentifier("segueToGamePlay", sender: match)
    }
}
