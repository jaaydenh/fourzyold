//
//  SKButton.swift
//  Fourzy
//
//  Created by Halko, Jaayden on 2/21/15.
//  Copyright (c) 2015 PartyTroll. All rights reserved.
//

import Foundation
import SpriteKit

class SKButton: SKSpriteNode {
    
    enum FTButtonActionType: Int {
        case TouchUpInside = 1,
        TouchDown, TouchUp
    }
    
    var isEnabled: Bool = true {
        didSet {
            if (disabledTexture != nil) {
                texture = isEnabled ? defaultTexture : disabledTexture
            }
        }
    }
    var isSelected: Bool = false {
        didSet {
            texture = isSelected ? selectedTexture : defaultTexture
        }
    }
    var defaultTexture: SKTexture
    var selectedTexture: SKTexture
    var label: SKLabelNode
    
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(normalTexture defaultTexture: SKTexture!, selectedTexture:SKTexture!, disabledTexture: SKTexture?) {
        
        self.defaultTexture = defaultTexture
        self.selectedTexture = selectedTexture
        self.disabledTexture = disabledTexture
        self.label = SKLabelNode(fontNamed: "Helvetica")
        super.init(texture: defaultTexture, color: UIColor.whiteColor(), size: defaultTexture.size())
        userInteractionEnabled = true
        
        
        self.label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        self.label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        addChild(self.label)
        
        // Adding this node as an empty layer. Without it the touch functions are not being called
        // The reason for this is unknown when this was implemented...?
        let bugFixLayerNode = SKSpriteNode(texture: nil, color: nil, size: defaultTexture.size())
        bugFixLayerNode.position = self.position
        addChild(bugFixLayerNode)
        
    }
    
    /**
    * Taking a target object and adding an action that is triggered by a button event.
    */
    func setButtonAction(target: AnyObject, triggerEvent event:FTButtonActionType, action:Selector) {
        
        switch (event) {
        case .TouchUpInside:
            targetTouchUpInside = target
            actionTouchUpInside = action
        case .TouchDown:
            targetTouchDown = target
            actionTouchDown = action
        case .TouchUp:
            targetTouchUp = target
            actionTouchUp = action
        }
        
    }
    
    func setButtonLabel(#title: NSString, font: String, fontSize: CGFloat) {
        var title = title
        var font = font
        var fontSize = fontSize
        
        self.label.text = title
        self.label.fontSize = fontSize
        self.label.fontName = font
        
    }
    
    var disabledTexture: SKTexture?
    var actionTouchUpInside: Selector?
    var actionTouchUp: Selector?
    var actionTouchDown: Selector?
    weak var targetTouchUpInside: AnyObject?
    weak var targetTouchUp: AnyObject?
    weak var targetTouchDown: AnyObject?
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)  {
        let touch: AnyObject! = touches.anyObject()
        let touchLocation = touch.locationInNode(parent)
        
        if (!isEnabled) {
            return
        }
        isSelected = true
        if (targetTouchDown != nil && targetTouchDown!.respondsToSelector(actionTouchDown!)) {
            UIApplication.sharedApplication().sendAction(actionTouchDown!, to: targetTouchDown, from: self, forEvent: nil)
        }
        
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent)  {
        
        if (!isEnabled) {
            return
        }
        
        let touch: AnyObject! = touches.anyObject()
        let touchLocation = touch.locationInNode(parent)
        
        if (CGRectContainsPoint(frame, touchLocation)) {
            isSelected = true
        } else {
            isSelected = false
        }
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        if (!isEnabled) {
            return
        }
        
        isSelected = false
        
        if (targetTouchUpInside != nil && targetTouchUpInside!.respondsToSelector(actionTouchUpInside!)) {
            let touch: AnyObject! = touches.anyObject()
            let touchLocation = touch.locationInNode(parent)
            
            if (CGRectContainsPoint(frame, touchLocation) ) {
                UIApplication.sharedApplication().sendAction(actionTouchUpInside!, to: targetTouchUpInside, from: self, forEvent: nil)
            }
            
        }
        
        if (targetTouchUp != nil && targetTouchUp!.respondsToSelector(actionTouchUp!)) {
            UIApplication.sharedApplication().sendAction(actionTouchUp!, to: targetTouchUp, from: self, forEvent: nil)
        }
    }
}