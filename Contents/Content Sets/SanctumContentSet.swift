//
//  SanctumContentSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/17/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// The `ContentSet` for the Sanctum.
///
class SanctumContentSet: ContentSet, TextureUser, AnimationUser {
    
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
    static let instance = SanctumContentSet()
    
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
        case .other(let name) where name == "Web":
            content = Content(type: type, isDynamic: false, isObstacle: false,
                              entity: Web(levelOfExperience: Game.levelOfExperience!))
        case .other(let name) where name == "Tiny Web":
            content = Content(type: type, isDynamic: false, isObstacle: false,
                              entity: TinyWeb(levelOfExperience: Game.levelOfExperience!))
        case .other(let name) where name == "Will-o'-the-wisp":
            content = Content(type: type, isDynamic: true, isObstacle: false,
                              entity: WillOTheWisp(levelOfExperience: Game.levelOfExperience!))
        case .other(let name) where name == "Destroying Angel":
            content = Content(type: type, isDynamic: true, isObstacle: false,
                              entity: DestroyingAngel(levelOfExperience: Game.levelOfExperience!))
        case .other(let name) where name == "Acolyte":
            content = Content(type: type, isDynamic: true, isObstacle: false,
                              entity: Acolyte(levelOfExperience: Game.levelOfExperience!))
        case .other(let name) where name == "Archpriestess":
            content = Content(type: type, isDynamic: true, isObstacle: false,
                              entity: Archpriestess(levelOfExperience: Game.levelOfExperience!))
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
        (Vase.self, 0.8),
        (Crate.self, 0.6),
        (ReinforcedCrate.self, 0.3),
        (IronCrate.self, 0.1),
        (Barrel.self, 0.7),
        (ExplosiveBarrel.self, 0.6),
        (NoxiousBarrel.self, 0.6)]
    
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
        case is IronCrate.Type:
            entity = IronCrate(levelOfExperience: levelOfExperience)
        case is Barrel.Type:
            entity = Barrel(levelOfExperience: levelOfExperience, inhabited: Double.random(in: 0...1.0) > 0.95)
        case is ExplosiveBarrel.Type:
            entity = ExplosiveBarrel(levelOfExperience: levelOfExperience)
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
        (Defiler.self, 1.0),
        (Desecrator.self, 1.0),
        (DestroyingAngel.self, 0.45),
        (Acolyte.self, 0.4),
        (WillOTheWisp.self, 0.6),
        (Bat.self, 0.7),
        (Rat.self, 0.7)]
    
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
        case is Defiler.Type:
            entity = Defiler(levelOfExperience: levelOfExperience)
        case is Desecrator.Type:
            entity = Desecrator(levelOfExperience: levelOfExperience)
        case is DestroyingAngel.Type:
            entity = DestroyingAngel(levelOfExperience: levelOfExperience)
        case is Acolyte.Type:
            entity = Acolyte(levelOfExperience: levelOfExperience)
        case is WillOTheWisp.Type:
            entity = WillOTheWisp(levelOfExperience: levelOfExperience)
        case is Bat.Type:
            entity = Bat(levelOfExperience: levelOfExperience)
        case is Rat.Type:
            entity = Rat(levelOfExperience: levelOfExperience)
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
        (Archpriestess.self, 1.0),
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
        case is Archpriestess.Type:
            entity = Archpriestess(levelOfExperience: levelOfExperience)
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
        (Web.self, 0.8),
        (TinyWeb.self, 0.8),
        (SpikeTrap.self, 1.0),
        (BoltTrap.self, 0.25),
        (Obelisk.self, 0.8),
        (DiseasePool.self, 0.7),
        (CurePool.self, 0.1),
        (ExplosiveTrap.self, 0.2),
        (ElectricTrap.self, 0.4),
        (DispellingTrap.self, 0.5)]
    
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
