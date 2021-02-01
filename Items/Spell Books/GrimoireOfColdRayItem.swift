//
//  GrimoireOfColdRayItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/10/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Item` type that defines the Grimoire of Cold Ray, used to cast the Cold Ray spell.
///
class GrimoireOfColdRayItem: UsableItem, TradableItem, DescribableItem, ResourceItem, DamageItem, LevelItem,
TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return ColdRayAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return ColdRayAnimation.textureNames.union([IconSet.Item.blueGrimoire.imageName])
    }
    
    let name: String = "Grimoire of Cold Ray"
    let icon: Icon = IconSet.Item.blueGrimoire
    let category: ItemCategory = .spellBook
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 45) }
    
    let resourceName = "Spell Components"
    let resourceCost = 4
    
    let ray: Ray
    let condition: HamperCondition
    var damage: Damage { return ray.damage! }
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: GrimoireOfColdRayItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        ray = other.ray
        condition = other.condition
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let damage = Damage(scale: 1.0, ratio: 0.25, level: level,
                            modifiers: [.intellect: 0.5],
                            type: .magical, sfx: SoundFXSet.FX.iceHit)
        
        condition = HamperCondition(slowFactor: 0.5, isExclusive: true, isResettable: true, duration: 6.0,
                                    source: nil, color: nil, sfx: nil)
        
        let animation = ColdRayAnimation().animation
        
        ray = Ray(medium: .spell,
                  initialSize: CGSize(width: 0, height: 24.0),
                  finalSize: CGSize(width: 320.0, height: 24.0),
                  delay: animation.0?.duration ?? 0.5,
                  duration: animation.1?.duration ?? 0.5,
                  conclusion: animation.2?.duration ?? 0.5,
                  damage: damage, conditions: [condition],
                  animation: animation,
                  sfx: SoundFXSet.FX.ice)
    }
    
    func copy() -> Item {
        return GrimoireOfColdRayItem(other: self)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("GrimoireOfColdRayItem can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("GrimoireOfColdRayItem can only be used by an entity that has a CastComponent")
        }
        
        condition.source = entity
        let duration = ray.delay + ray.duration + ray.conclusion
        castComponent.spell = Spell(kind: .ray, effect: ray, castTime: (0.75, duration, 0.5))
        castComponent.spellBook = self
        stateComponent.enter(namedState: .cast)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a ray of cold that damages and slows affected targets.
        Lasts \(Int(condition.duration!.rounded())) seconds.
        """
    }
}

/// The struct that defines the animations for the `GrimoireOfColdRayItem`'s ray.
///
fileprivate struct ColdRayAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Beginning.key, Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        let beginning = ImageArray.createFrom(baseName: "Azure_Beam_Beginning_", first: 1, last: 6)
        let standard = ImageArray.createFrom(baseName: "Azure_Beam_", first: 1, last: 8)
        let end = ImageArray.createFrom(baseName: "Azure_Beam_End_", first: 1, last: 4)
        return Set<String>(beginning + standard + end)
    }
    
    /// The tuple containing the animations.
    ///
    let animation: (Animation?, Animation?, Animation?)
    
    init() {
        let beginning = AnimationSource.getAnimation(forKey: Beginning.key) ?? Beginning()
        let standard = AnimationSource.getAnimation(forKey: Standard.key) ?? Standard()
        let end = AnimationSource.getAnimation(forKey: End.key) ?? End()
        animation = (beginning, standard, end)
    }
    
    private class Beginning: TextureAnimation {
        static let key = "ColdRayAnimation.Beginning"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Azure_Beam_Beginning_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.033, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Beginning.key)
        }
        
        override func play(node: SKNode) {
            (node as! SKSpriteNode).anchorPoint = CGPoint(x: 0, y: 0.5)
            super.play(node: node)
        }
    }
    
    private class Standard: TextureAnimation {
        static let key = "ColdRayAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Azure_Beam_", first: 1, last: 8)
            super.init(images: images, timePerFrame: 0.033, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
        
        override func play(node: SKNode) {
            (node as! SKSpriteNode).anchorPoint = CGPoint(x: 0, y: 0.5)
            super.play(node: node)
        }
    }
    
    private class End: TextureAnimation {
        static let key = "ColdRayAnimation.End"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Azure_Beam_End_", first: 1, last: 4)
            super.init(images: images, timePerFrame: 0.033, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
        
        override func play(node: SKNode) {
            (node as! SKSpriteNode).anchorPoint = CGPoint(x: 0, y: 0.5)
            super.play(node: node)
        }
    }
}
