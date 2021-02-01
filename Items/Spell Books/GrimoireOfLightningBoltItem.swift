//
//  GrimoireOfLightningBoltItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Item` type that defines the Grimoire of Lightning Bolt, used to cast the Lightning Bolt spell.
///
class GrimoireOfLightningBoltItem: UsableItem, TradableItem, DescribableItem, ResourceItem, DamageItem,
LevelItem, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return LightningBoltAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return LightningBoltAnimation.textureNames.union([IconSet.Item.greyTome.imageName])
    }
    
    let name: String = "Grimoire of Lightning Bolt"
    let icon: Icon = IconSet.Item.greyTome
    let category: ItemCategory = .spellBook
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 74) }
    
    let resourceName = "Spell Components"
    let resourceCost = 10
    
    let blast: Blast
    var damage: Damage { return blast.damage! }
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: GrimoireOfLightningBoltItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        blast = other.blast
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let damage = Damage(scale: 1.85, ratio: 0.3, level: level,
                            modifiers: [.intellect: 0.5],
                            type: .magical, sfx: SoundFXSet.FX.hit)
        
        let animation = LightningBoltAnimation().animation
        
        blast = Blast(medium: .spell,
                      initialSize: CGSize(width: 32.0, height: 32.0),
                      finalSize: CGSize(width: 32.0, height: 32.0),
                      range: 630.0,
                      delay: 0, duration: 0.2, conclusion: 0.4,
                      damage: damage, conditions: nil,
                      animation: animation, sfx: SoundFXSet.FX.explosion)
    }
    
    func copy() -> Item {
        return GrimoireOfLightningBoltItem(other: self)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("GrimoireOfLightningBoltItem can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("GrimoireOfLightningBoltItem can only be used by an entity that has a CastComponent")
        }
        
        castComponent.spell = Spell(kind: .targetBlast, effect: blast, castTime: (0.75, 0, 0.5))
        castComponent.spellBook = self
        stateComponent.enter(namedState: .cast)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a lightning bolt at the selected target.
        """
    }
}

/// The struct defining the animations for the `GrimoireOfLightningBoltItem`'s ray.
///
fileprivate struct LightningBoltAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key]
    }
    
    static var textureNames: Set<String> {
        let standard = ImageArray.createFrom(baseName: "Lightning_Bolt_", first: 1, last: 5)
        return Set<String>(standard)
    }
    
    /// The tuple containing the animations.
    ///
    let animation: (Animation?, Animation?, Animation?)
    
    init() {
        let standard = AnimationSource.getAnimation(forKey: Standard.key) ?? Standard()
        animation = (nil, standard, nil)
    }
    
    private class Standard: TextureAnimation {
        static let key = "LightningBoltAnimation.Standard"
        
        init() {
            var images = ImageArray.createFrom(baseName: "Lightning_Bolt_", first: 1, last: 5)
            images.append(contentsOf: images.reversed())
            var waitings = [Int: TimeInterval]()
            for i in (images.count / 2 + 1)...(images.count - 1) { waitings[i] = 0.05 }
            super.init(images: images, timePerFrame: 0.033, replaceable: false, flipped: false, repeatForever: false,
                       waitings: waitings)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
        
        override func play(node: SKNode) {
            (node as! SKSpriteNode).anchorPoint = CGPoint(x: 0.5, y: 0)
            super.play(node: node)
        }
    }
}
