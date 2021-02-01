//
//  ArrowItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/24/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Item` type that defines the Arrow, used as ammunition for bows.
///
class ArrowItem: TradableItem, StackableItem, DescribableItem, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return ArrowAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return ArrowAnimation.textureNames.union([IconSet.Item.redPotion.imageName])
    }
    
    static let capacity: Int = 50
    
    let name: String = "Arrow"
    let icon: Icon = IconSet.Item.arrow
    let category: ItemCategory = .general
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = false
    let price: Int = 3
    var stack: ItemStack
    
    /// The arrow item animation.
    ///
    static var animation = ArrowAnimation.instance
    
    required init(quantity: Int) {
        let capacity = ArrowItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
    }
    
    func copy() -> Item {
        return ArrowItem(quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return ArrowItem(quantity: stackCount)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Ammunition for bows.
        """
    }
}

/// An `Animation` type that defines the arrow item animation.
///
fileprivate class ArrowAnimation: Animation, TextureUser, AnimationUser {
    private static let key = "ArrowAnimation"
    
    static var animationKeys: Set<String> {
        return [key]
    }
    
    static var textureNames: Set<String> {
        return ["Arrow"]
    }
    
    /// The instance of the class.
    ///
    static var instance: Animation {
        return AnimationSource.getAnimation(forKey: key) ?? ArrowAnimation()
    }
    
    let replaceable: Bool = true
    let duration: TimeInterval? = nil
    
    private init() {
        AnimationSource.storeAnimation(self, forKey: ArrowAnimation.key)
    }
    
    func play(node: SKNode) {
        guard let node = node as? SKSpriteNode else { return }
        
        let texture = TextureSource.createTexture(imageNamed: "Arrow")
        node.texture = texture
        node.size = texture.size()
    }
}
