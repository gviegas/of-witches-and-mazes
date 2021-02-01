//
//  LootNode.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UpdateNode` subclass that defines the loot node.
///
class LootNode: UpdateNode, Identifiable, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return LootAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return LootAnimation.textureNames
    }
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
    
    /// The pick up radius of the loot.
    ///
    static let pickUpRadius: CGFloat = 32.0
    
    /// The duration of the loot node.
    ///
    static let duration: TimeInterval = 120.0
    
    /// The elapsed time since creation.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The dropped items.
    ///
    /// The loot is generated on initialization and stored in this property. It can be
    /// freely manipulated by others, e.g. to remove an item when it is looted. Nevertheless,
    /// new items should not be added to this list, since it could otherwise be at odds with
    /// the generation rules specified on creation.
    ///
    var droppedItems: [Item]
    
    /// Creates a new instance from the given list of items and position.
    ///
    /// - Parameters:
    ///   - droppedItems: The list of dropped items to make available.
    ///   - position: The position of the loot node.
    ///
    init(droppedItems: [Item], position: CGPoint) {
        self.droppedItems = droppedItems
        super.init()
        
        let physicsBody = SKPhysicsBody(circleOfRadius: LootNode.pickUpRadius)
        physicsBody.pinned = true
        Interaction.loot.updateInteractions(onPhysicsBody: physicsBody)
        self.physicsBody = physicsBody
        self.position = position
        
        let node = SKSpriteNode(color: .clear, size: CGSize(width: 32.0, height: 32.0))
        LootAnimation.instance.play(node: node)
        addChild(node)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        if elapsedTime >= LootNode.duration { removeFromParent() }
    }
    
    /// Plays the loot sound effect.
    ///
    func playSoundEffect() {
        SoundFXSet.FX.consuming.play(at: position, sceneKind: .level)
    }
}

/// The `TextureAnimation` representing the `LootNode`s animation.
///
fileprivate class LootAnimation: TextureAnimation, TextureUser, AnimationUser {
    private static let key = "LootAnimation"
    
    static var animationKeys: Set<String> {
        return [key]
    }
    
    static var textureNames: Set<String> {
        return Set<String>(ImageArray.createFrom(baseName: "Glow_", first: 1, last: 8))
    }
    
    /// The instance of the class.
    ///
    static var instance: Animation {
        return AnimationSource.getAnimation(forKey: key) ?? LootAnimation()
    }
    
    private init() {
        let images = ImageArray.createFrom(baseName: "Glow_", first: 1, last: 8)
        super.init(images: images, timePerFrame: 0.083, replaceable: false, flipped: false, repeatForever: true)
        AnimationSource.storeAnimation(self, forKey: LootAnimation.key)
    }
}
