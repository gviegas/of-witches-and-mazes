//
//  NightGladeContentSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/16/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// The `ContentSet` for the Night Glade.
///
class NightGladeContentSet: ContentSet, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return RandomDestructible.animationKeys
            .union(RandomEnemy.animationKeys)
            .union(RandomElite.animationKeys)
            .union(RandomRare.animationKeys)
            .union(RandomTrap.animationKeys)
            .union(LostLenore.animationKeys)
            .union(Portal.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return RandomDestructible.textureNames
            .union(RandomEnemy.textureNames)
            .union(RandomElite.textureNames)
            .union(RandomRare.textureNames)
            .union(RandomTrap.textureNames)
            .union(LostLenore.textureNames)
            .union(Portal.textureNames)
            .union(Chest.textureNames)
    }
    
    /// The instance of the class.
    ///
    static let instance = NightGladeContentSet()
    
    let cellSize = CGSize(width: 64.0, height: 64.0)
    
    private init() {}
    
    func makeContent(ofType type: ContentType) -> Content? {
        assert(Game.protagonist != nil)

        let content: Content?
        
        switch type {
        case .destructible:
            content = RandomDestructible.next(levelOfExperience: Game.levelOfExperience!)
        case .elite:
            content = RandomElite.next(levelOfExperience: Game.levelOfExperience!)
        case .enemy:
            content = RandomEnemy.next(levelOfExperience: Game.levelOfExperience!)
        case .exit:
            content = Content(type: type, isDynamic: false, isObstacle: true, entity: Portal())
        case .merchant:
            content = Content(type: type, isDynamic: false, isObstacle: true,
                              entity: LostLenore(levelOfExperience: Game.levelOfExperience!))
        case .protagonist:
            content = Content(type: type, isDynamic: true, isObstacle: false, entity: Game.protagonist!)
        case .rare:
            content = RandomRare.next(levelOfExperience: Game.levelOfExperience!)
        case .trap:
            content = RandomTrap.next(levelOfExperience: Game.levelOfExperience!)
        case .treasure:
            content = Content(type: type, isDynamic: false, isObstacle: true,
                              entity: Chest(levelOfExperience: Game.levelOfExperience!))
        case .other(let name) where name == "Spike Trap":
            content = Content(type: type, isDynamic: false, isObstacle: false,
                              entity: SpikeTrap(levelOfExperience: Game.levelOfExperience!))
        case .other(let name) where name == "Bolt Trap":
            content = Content(type: type, isDynamic: false, isObstacle: true,
                              entity: BoltTrap(levelOfExperience: Game.levelOfExperience!))
        case .other(let name) where name == "Cure Pool":
            content = Content(type: type, isDynamic: false, isObstacle: false,
                              entity: CurePool(levelOfExperience: Game.levelOfExperience!))
        case .other(let name) where name == "Dispelling Trap":
            content = Content(type: type, isDynamic: false, isObstacle: false,
                              entity: DispellingTrap(levelOfExperience: Game.levelOfExperience!))
        case .other(let name) where name == "Acid Pool":
            content = Content(type: type, isDynamic: false, isObstacle: false,
                              entity: AcidPool(levelOfExperience: Game.levelOfExperience!))
        case .other(let name) where name == "Feralon":
            content = Content(type: type, isDynamic: true, isObstacle: false,
                              entity: Feralon(levelOfExperience: Game.levelOfExperience!))
        case .other(let name) where name == "Feral":
            content = Content(type: type, isDynamic: true, isObstacle: false,
                              entity: Feral(levelOfExperience: Game.levelOfExperience!))
        case .other(let name) where name == "Death Cap":
            content = Content(type: type, isDynamic: true, isObstacle: false,
                              entity: DeathCap(levelOfExperience: Game.levelOfExperience!))
        case .companion, .indestructible, .other:
            content = nil
        }
        
        return content
    }
}

/// The class that randomly generates `Content`s of `destructible` type.
///
private class RandomDestructible: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return values.reduce(Set<String>()) { (result, value) in
            guard let animationUser = value.0 as? AnimationUser.Type else { return result }
            return result.union(animationUser.animationKeys)
        }
    }
    
    static var textureNames: Set<String> {
        return values.reduce(Set<String>()) { (result, value) in
            guard let textureUser = value.0 as? TextureUser.Type else { return result }
            return result.union(textureUser.textureNames)
        }
    }
    
    /// The distribution values.
    ///
    private static let values: [(InanimateObject.Type, Double)] = [
        (Vase.self, 0.2),
        (Crate.self, 1.0),
        (ReinforcedCrate.self, 0.1),
        (Barrel.self, 0.65),
        (NoxiousBarrel.self, 0.3)]
    
    /// The weighted distribution.
    ///
    private static let distr = WeightedDistribution(values: values)
    
    private init() {}
    
    /// Generates random content.
    ///
    /// - Parameter levelOfExperience: The level of experience for the content.
    /// - Returns: A random `Content`, or `nil` if no content could be generated.
    ///
    class func next(levelOfExperience: Int) -> Content? {
        guard EntityProgression.levelRange.contains(levelOfExperience) else { return nil }
        
        let entity: Entity?
        
        switch distr.nextValue() {
        case is Vase.Type:
            entity = Vase(levelOfExperience: levelOfExperience, inhabited: Double.random(in: 0...1.0) > 0.95)
        case is Crate.Type:
            entity = Crate(levelOfExperience: levelOfExperience, inhabited: Double.random(in: 0...1.0) > 0.95)
        case is ReinforcedCrate.Type:
            entity = ReinforcedCrate(levelOfExperience: levelOfExperience, inhabited: Bool.random())
        case is Barrel.Type:
            entity = Barrel(levelOfExperience: levelOfExperience, inhabited: Double.random(in: 0...1.0) > 0.95)
        case is NoxiousBarrel.Type:
            entity = NoxiousBarrel(levelOfExperience: levelOfExperience)
        default:
            entity = nil
        }
        
        guard entity != nil else { return nil }
        return Content(type: .destructible, isDynamic: true, isObstacle: false, entity: entity!)
    }
}

/// The class that randomly generates `Content`s of `enemy` type.
///
private class RandomEnemy: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return values.reduce(Set<String>()) { (result, value) in
            guard let animationUser = value.0 as? AnimationUser.Type else { return result }
            return result.union(animationUser.animationKeys)
        }
    }
    
    static var textureNames: Set<String> {
        return values.reduce(Set<String>()) { (result, value) in
            guard let textureUser = value.0 as? TextureUser.Type else { return result }
            return result.union(textureUser.textureNames)
        }
    }
    
    /// The distribution values.
    ///
    private static let values: [(Monster.Type, Double)] = [
        (Beetle.self, 1.0),
        (Chafer.self, 1.0),
        (Creeper.self, 0.8),
        (DeathCap.self, 0.35),
        (Fairy.self, 0.65),
        (Feral.self, 1.0),
        (Grotesque.self, 0.15)]
    
    /// The weighted distribution.
    ///
    private static let distr = WeightedDistribution(values: values)
    
    private init() {}
    
    /// Generates random content.
    ///
    /// - Parameter levelOfExperience: The level of experience for the content.
    /// - Returns: A random `Content`, or `nil` if no content could be generated.
    ///
    class func next(levelOfExperience: Int) -> Content? {
        guard EntityProgression.levelRange.contains(levelOfExperience) else { return nil }
        
        let entity: Entity?
        
        switch distr.nextValue() {
        case is Beetle.Type:
            entity = Beetle(levelOfExperience: levelOfExperience)
        case is Chafer.Type:
            entity = Chafer(levelOfExperience: levelOfExperience)
        case is Creeper.Type:
            entity = Creeper(levelOfExperience: levelOfExperience)
        case is DeathCap.Type:
            entity = DeathCap(levelOfExperience: levelOfExperience)
        case is Fairy.Type:
            entity = Fairy(levelOfExperience: levelOfExperience)
        case is Feral.Type:
            entity = Feral(levelOfExperience: levelOfExperience)
        case is Grotesque.Type:
            entity = Grotesque(levelOfExperience: levelOfExperience)
        default:
            entity = nil
        }
        
        guard entity != nil else { return nil }
        return Content(type: .enemy, isDynamic: true, isObstacle: false, entity: entity!)
    }
}

/// The class that randomly generates `Content`s of `elite` type.
///
private class RandomElite: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return values.reduce(Set<String>()) { (result, value) in
            guard let animationUser = value.0 as? AnimationUser.Type else { return result }
            return result.union(animationUser.animationKeys)
        }
    }
    
    static var textureNames: Set<String> {
        return values.reduce(Set<String>()) { (result, value) in
            guard let textureUser = value.0 as? TextureUser.Type else { return result }
            return result.union(textureUser.textureNames)
        }
    }
    
    /// The distribution values.
    ///
    private static let values: [(Monster.Type, Double)] = [(GelatinousCube.self, 1.0)]
    
    /// The weighted distribution.
    ///
    private static let distr = WeightedDistribution(values: values)
    
    private init() {}
    
    /// Generates random content.
    ///
    /// - Parameter levelOfExperience: The level of experience for the content.
    /// - Returns: A random `Content`, or `nil` if no content could be generated.
    ///
    class func next(levelOfExperience: Int) -> Content? {
        guard EntityProgression.levelRange.contains(levelOfExperience) else { return nil }
        
        let entity: Entity?
        
        switch distr.nextValue() {
        case is GelatinousCube.Type:
            entity = GelatinousCube(levelOfExperience: levelOfExperience)
        default:
            entity = nil
        }
        
        guard entity != nil else { return nil }
        return Content(type: .elite, isDynamic: true, isObstacle: false, entity: entity!)
    }
}

/// The class that randomly generates `Content`s of `rare` type.
///
private class RandomRare: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return values.reduce(Set<String>()) { (result, value) in
            guard let animationUser = value.0 as? AnimationUser.Type else { return result }
            return result.union(animationUser.animationKeys)
        }
    }
    
    static var textureNames: Set<String> {
        return values.reduce(Set<String>()) { (result, value) in
            guard let textureUser = value.0 as? TextureUser.Type else { return result }
            return result.union(textureUser.textureNames)
        }
    }
    
    /// The distribution values.
    ///
    private static let values: [(Monster.Type, Double)] = [
        (Feralon.self, 1.0),
        (Enchantress.self, 0.2),
        (Assassin.self, 0.2),
        (Paladin.self, 0.2),
    ]
    
    /// The weighted distribution.
    ///
    private static let distr = WeightedDistribution(values: values)
    
    private init() {}
    
    /// Generates random content.
    ///
    /// - Parameter levelOfExperience: The level of experience for the content.
    /// - Returns: A random `Content`, or `nil` if no content could be generated.
    ///
    class func next(levelOfExperience: Int) -> Content? {
        guard EntityProgression.levelRange.contains(levelOfExperience) else { return nil }
        
        let entity: Entity?
        
        switch distr.nextValue() {
        case is Feralon.Type:
            entity = Feralon(levelOfExperience: levelOfExperience)
        case is Enchantress.Type:
            entity = Enchantress(levelOfExperience: levelOfExperience)
        case is Assassin.Type:
            entity = Assassin(levelOfExperience: levelOfExperience)
        case is Paladin.Type:
            entity = Paladin(levelOfExperience: levelOfExperience)
        default:
            entity = nil
        }
        
        guard entity != nil else { return nil }
        return Content(type: .rare, isDynamic: true, isObstacle: false, entity: entity!)
    }
}

/// The class that randomly generates `Content`s of `trap` type.
///
private class RandomTrap: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return values.reduce(Set<String>()) { (result, value) in
            guard let animationUser = value.0 as? AnimationUser.Type else { return result }
            return result.union(animationUser.animationKeys)
        }
    }
    
    static var textureNames: Set<String> {
        return values.reduce(Set<String>()) { (result, value) in
            guard let textureUser = value.0 as? TextureUser.Type else { return result }
            return result.union(textureUser.textureNames)
        }
    }
    
    /// The distribution values.
    ///
    private static let values: [(InanimateObject.Type, Double)] = [
        (AcidPool.self, 0.6),
        (Web.self, 0.8),
        (TinyWeb.self, 0.9),
        (SpikeTrap.self, 1.0),
        (BoltTrap.self, 0.75),
        (Obelisk.self, 0.3),
        (DiseasePool.self, 0.4),
        (CurePool.self, 0.05),
        (ExplosiveTrap.self, 0.3),
        (ElectricTrap.self, 0.3),
        (DispellingTrap.self, 0.1)]
    
    /// The weighted distribution.
    ///
    private static let distr = WeightedDistribution(values: values)
    
    private init() {}
    
    /// Generates random content.
    ///
    /// - Parameter levelOfExperience: The level of experience for the content.
    /// - Returns: A random `Content`, or `nil` if no content could be generated.
    ///
    class func next(levelOfExperience: Int) -> Content? {
        guard EntityProgression.levelRange.contains(levelOfExperience) else { return nil }
        
        let entity: Entity?
        var isObstacle = false
        
        switch distr.nextValue() {
        case is AcidPool.Type:
            entity = AcidPool(levelOfExperience: levelOfExperience)
        case is Web.Type:
            entity = Web(levelOfExperience: levelOfExperience)
        case is TinyWeb.Type:
            entity = TinyWeb(levelOfExperience: levelOfExperience)
        case is SpikeTrap.Type:
            entity = SpikeTrap(levelOfExperience: levelOfExperience)
        case is BoltTrap.Type:
            entity = BoltTrap(levelOfExperience: levelOfExperience)
            isObstacle = true
        case is Obelisk.Type:
            entity = Obelisk(levelOfExperience: levelOfExperience)
            isObstacle = true
        case is DiseasePool.Type:
            entity = DiseasePool(levelOfExperience: levelOfExperience)
        case is CurePool.Type:
            entity = CurePool(levelOfExperience: levelOfExperience)
        case is ExplosiveTrap.Type:
            entity = ExplosiveTrap(levelOfExperience: levelOfExperience)
        case is ElectricTrap.Type:
            entity = ElectricTrap(levelOfExperience: levelOfExperience)
        case is DispellingTrap.Type:
            entity = DispellingTrap(levelOfExperience: levelOfExperience)
        default:
            entity = nil
        }
        
        guard entity != nil else { return nil }
        return Content(type: .trap, isDynamic: false, isObstacle: isObstacle, entity: entity!)
    }
}
