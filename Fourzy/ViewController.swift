    //
//  ViewController.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 9/10/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

import UIKit
import GameKit
import QuartzCore
    
let PresentAuthenticationViewController = "present_authentication_view_controller"
let LocalPlayerIsAuthenticated = "local_player_authenticated"

class ViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, GKTurnBasedMatchmakerViewControllerDelegate, GKLocalPlayerListener {
    
    var authenticationViewController: UIViewController!
    @IBOutlet var matchListTableView: UITableView?
    var matches = []
    var players = [String: GKPlayer]()
    var refreshControl:UIRefreshControl!
    var lastError:NSError!
    var enableGameCenter:Bool!
    var loadingMatches:Bool!
    var gameViewController:GameViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.redColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAuthenticationViewController", name: PresentAuthenticationViewController, object: nil)
        
        authenticateLocalPlayer()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)

        self.matchListTableView?.addSubview(refreshControl)
        
        self.matchListTableView?.registerNib(UINib(nibName: "GamesListCell", bundle: nil), forCellReuseIdentifier: "GamesListCell")
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
        self.authenticationViewController = authenticationViewController
        NSNotificationCenter.defaultCenter().postNotificationName(PresentAuthenticationViewController, object: self)
    }
    
    func localPlayerWasAuthenticated() {
        loadMatches()
    }

    func loadMatches() {
        println("# ViewController:loadMatches")
        if ((loadingMatches) != nil) {
            if loadingMatches == true {
                return
            }
        }

        loadingMatches = true
        
        GKTurnBasedMatch.loadMatchesWithCompletionHandler { (matches:[AnyObject]!, error:NSError!) -> Void in
            if (error != nil)
            {
                println("Error fetching matches: \(error.localizedDescription)")
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
        loadMatches()
    }
    
    override func viewDidAppear(animated: Bool) {

        println("# ViewController:viewDidAppear")
        if GKLocalPlayer.localPlayer().authenticated {
            loadMatches()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func newGame(sender: AnyObject) {
        println("start new game")

        var request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        request.defaultNumberOfPlayers = 2
        //request.playerAttributes = 0xFFFFFFFF
        
        var mmvc = GKTurnBasedMatchmakerViewController(matchRequest: request)
        mmvc.turnBasedMatchmakerDelegate = self
        mmvc.showExistingMatches = false
        
        self.presentViewController(mmvc, animated:true, completion:nil)
    }
    
    @IBAction func editGamesList(sender: AnyObject) {
        
    }
//    @IBAction func editGamesList(sender: AnyObject) {
//                println("start new pass and play game")
//    }
    
    @IBAction func newSinglePlayerGame(sender: AnyObject) {
        println("start new single player game")
    }
    
    @IBAction func newPassAndPlayGame(sender: AnyObject) {
        println("start new pass and play game")
        self.performSegueWithIdentifier("segueToGamePlay", sender: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if (cell.respondsToSelector(Selector("tintColor"))) {
            if (tableView == self.matchListTableView) {
                let cornerRadius:CGFloat = 5.0
                let cornerHeight:CGFloat = 5.0
                cell.backgroundColor = UIColor.clearColor()
                var layer:CAShapeLayer = CAShapeLayer()
                var pathRef:CGMutablePathRef = CGPathCreateMutable()
                var bounds:CGRect = CGRectInset(cell.bounds, 0, 0);
                var addLine = false
                if (indexPath.row == 0 && indexPath.row == (tableView.numberOfRowsInSection(indexPath.section) - 1)) {
                    CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerHeight)
                } else if (indexPath.row == 0) {
                    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                    addLine = true
                } else if (indexPath.row ==  (tableView.numberOfRowsInSection(indexPath.section) - 1)) {
                    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
                } else {
                    CGPathAddRect(pathRef, nil, bounds);
                    addLine = true
                }
                layer.path = pathRef;
                //CFRelease(pathRef);
                layer.fillColor = UIColor(white: 1.0, alpha: 1.0).CGColor
                
                if (addLine == true) {
                    var lineLayer:CALayer = CALayer()
                    var lineHeight:CGFloat = (1.0 / UIScreen.mainScreen().scale)
                    lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight)
                    lineLayer.backgroundColor = tableView.separatorColor.CGColor
                    layer.addSublayer(lineLayer)
                }
                var testView:UIView = UIView(frame: bounds)
                testView.layer.insertSublayer(layer, atIndex: 0)
                testView.backgroundColor = UIColor.clearColor()
                cell.backgroundView = testView;
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        let cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: "GamesListCell") as GamesListCell
        let cell = tableView.dequeueReusableCellWithIdentifier("GamesListCell", forIndexPath: indexPath) as GamesListCell
        
        // Remove seperator inset
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            cell.separatorInset = UIEdgeInsetsZero
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if cell.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins:")) {
            cell.preservesSuperviewLayoutMargins = false
        }
        
        // Explictly set your cell's layout margins
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        cell.matchStatusLabel?.textColor = UIColor.blackColor()
        
        let match: GKTurnBasedMatch = self.matches[indexPath.row] as GKTurnBasedMatch
        let opponentParticipant = getOpponentForMatch(match)
        
        if opponentParticipant.playerID != nil {
            //let opponentPlayer = self.players[opponentParticipant.playerID]
            let opponentPlayer = PlayerCache.sharedManager.players[opponentParticipant.playerID]
            cell.opponentDisplayNameLabel?.text = opponentPlayer?.displayName
        } else {
            cell.opponentDisplayNameLabel?.text = "Waiting For Opponent"
        }
            //cell.lastMoveLabel?.text = "1d"
        if match.status == GKTurnBasedMatchStatus.Ended {
            let localParticipant = participantForLocalPlayerInMatch(match)
            
            if localParticipant.matchOutcome == GKTurnBasedMatchOutcome.Won {
                cell.matchStatusLabel?.text = "You Won"
                cell.matchStatusLabel?.textColor = UIColor.blueColor()
            } else if localParticipant.matchOutcome == GKTurnBasedMatchOutcome.Lost {
                cell.matchStatusLabel?.text = "You Lost"
                cell.matchStatusLabel?.textColor = UIColor.orangeColor()
            }

        } else {
            //cell.lastMoveLabel?.text = match.lastMove().description
            
            let localPlayerID = GKLocalPlayer.localPlayer().playerID

            if let currentParticipantPlayerId = match.currentParticipant.playerID {
                if currentParticipantPlayerId == localPlayerID {
                    cell.matchStatusLabel?.text = "Your Turn"
                } else  {
                    cell.matchStatusLabel?.text = "Waiting For Turn"
                }
            } else {
                cell.matchStatusLabel?.text = "Waiting For Turn"
            }
        }
        
        cell.lastMoveLabel?.text = ""
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            var matchList = matches as [GKTurnBasedMatch]
            matchList.removeAtIndex(indexPath.row)
            //self.matchListTableView?.reloadData()
            var indexPaths:NSMutableArray = []
            indexPaths.addObject(indexPath.row)
            matchListTableView?.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("select match" + self.matches[indexPath.row].matchID)

        let match = self.matches[indexPath.row] as GKTurnBasedMatch
        self.performSegueWithIdentifier("segueToGamePlay", sender: match)
    }
    
    func showAuthenticationViewController() {
        self.presentViewController(authenticationViewController, animated: true, completion: nil)
    }
    
    func sortMatchesByPlayerTurn(matches: [GKTurnBasedMatch]) -> [GKTurnBasedMatch] {
        var matchList = matches as [GKTurnBasedMatch]
        for match in matches {
            if match.currentParticipant != nil && match.currentParticipant.playerID != nil {
                if match.currentParticipant.playerID == GKLocalPlayer.localPlayer().playerID {
                    let index = find(matches, match)
                    matchList.removeAtIndex(index!)
                    matchList.insert(match, atIndex: 0)
                }
            }
        }

        return matchList
    }
    
    func didFetchMatches(matches: [AnyObject]!) {
        println("# ViewController:didFetchMatches")
        
        if let matchList = matches as? [GKTurnBasedMatch]
        {
//            self.matches = self.matches.sortedArrayUsingComparator {
//             (obj1, obj2) -> NSComparisonResult in
//                
//                let m1 = obj1 as GKTurnBasedMatch
//                let date1 = m1.lastMove()
//                let m2 = obj2 as GKTurnBasedMatch
//                let date2 = m2.lastMove()
//                //if (date1 != nil && date2 != nil) {
//                    return date1.compare(date2)
//                //}
//            
//            }
            
            self.matches = sortMatchesByPlayerTurn(matchList)
            
            var playerList:[String] = []
            for match in self.matches {
                
                var matchParticipants = match.participants as [GKTurnBasedParticipant]
                let playerIDs = matchParticipants.map { ($0 as GKTurnBasedParticipant).playerID }
                
                //TODO: check if players dictionary already contains a player before loading that players data
                for playerID in playerIDs {
                    if playerID != nil {
                        if !contains(playerList, playerID) {
                            playerList.append(playerID)
                        }
                    }
                }
            }
            if playerList.count > 0 {
                loadPlayerData(playerList)
            } else {
                self.matchListTableView!.reloadData()
            }
        }
        
        self.refreshControl.endRefreshing()
    }
    
    func enterNewGame(match:GKTurnBasedMatch) {
        println("# EnterNewGame")
        self.performSegueWithIdentifier("segueToGamePlay", sender: match)
    }

    func layoutMatch(match: GKTurnBasedMatch) {
        println("* LayoutMatch")
        self.performSegueWithIdentifier("segueToGamePlay", sender: match)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("# ViewController:prepareForSegue")
        if segue.identifier == "segueToGamePlay" {
            gameViewController = segue.destinationViewController as GameViewController
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
        println("# ViewController:turnBasedMatchmakerViewController:didFindMatch")
        self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("segueToGamePlay", sender: match)
    }
    
    // Called when a users chooses to quit a match and that player has the current turn.  The developer should call playerQuitInTurnWithOutcome:nextPlayer:matchData:completionHandler: on the match passing in appropriate values.  They can also update matchOutcome for other players as appropriate.
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController!, playerQuitForMatch match: GKTurnBasedMatch!) {
        println("### Quit.....match")
        // TODO
    }

    func player(player: GKPlayer!, receivedTurnEventForMatch match: GKTurnBasedMatch!, didBecomeActive: Bool) {
        println("receivedTurnEventForMatch:didBecomeActive:ViewController \(didBecomeActive)")
        loadMatches()
    }
    
    func player(player: GKPlayer!, matchEnded match: GKTurnBasedMatch!) {
        loadMatches()

        //self.performSegueWithIdentifier("segueToGamePlay", sender: match)
    }
    
    func loadPlayerPhoto(player: GKPlayer) {
        player.loadPhotoForSize(GKPhotoSizeSmall, withCompletionHandler: { (photo, error) -> Void in
            if (photo != nil) {
                
                if PlayerCache.sharedManager.playerPhotos[player.playerID] == nil {
                    PlayerCache.sharedManager.playerPhotos[player.playerID] = photo
                }

                //self.storePhoto(photo, ForPlayer:player)
            }
            if (error != nil) {
                //self.setLastError(error!)
            }
        })
    }
    
    func loadPlayerData(playerList:[AnyObject]) {

        if playerList.count > 0 {
            
            GKPlayer.loadPlayersForIdentifiers(playerList, withCompletionHandler: { (players, error) -> Void in
                if (error != nil) {
                    self.setLastError(error!)
                }
                if let playersFound = players as? [GKPlayer] {
                    for player in playersFound {
                        //self.players[player.playerID] = player
                        
                        PlayerCache.sharedManager.players[player.playerID] = player
                        self.loadPlayerPhoto(player)
                    }
                }
                self.matchListTableView!.reloadData()
            })
        }
    }
    
    func topMostController() -> UIViewController? {

        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while ((topController.presentedViewController) != nil) {
                topController = topController.presentedViewController!
            }
            
            return topController
        }
        
        return nil
    }
}
