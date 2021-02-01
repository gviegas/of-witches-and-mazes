//
//  GladeContentSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// The `ContentSet` for the Glade.
///
class GladeContentSet: ContentSet, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        let itemTypes = IntroProtagonist.itemTypes + IntroObject.itemTypes + IntroEnemy.itemTypes
        let items = itemTypes.reduce(Set<String>()) { (result, itemType) in
            guard let animationUser = itemType as? AnimationUser.Type else { return result }
            return result.union(animationUser.animationKeys)
        }
        
        return IntroObject.animationKeys
            .union(IntroEnemy.animationKeys)
            .union(IntroCompanion.animationKeys)
            .union(Portal.animationKeys)
            .union(items)
    }
    
    static var textureNames: Set<String> {
        let itemTypes = IntroProtagonist.itemTypes + IntroObject.itemTypes + IntroEnemy.itemTypes
        let items = itemTypes.reduce(Set<String>()) { (result, itemType) in
            guard let textureUser = itemType as? TextureUser.Type else { return result }
            return result.union(textureUser.textureNames)
        }
        
        return IntroObject.textureNames
            .union(IntroEnemy.textureNames)
            .union(IntroCompanion.textureNames)
            .union(Portal.textureNames)
            .union(items)
    }
    
    /// The instance of the class for the first intro.
    ///
    static let firstIntro = GladeContentSet(isFirst: true)
    
    /// The instance of the class for the second intro.
    ///
    static let secondIntro = GladeContentSet(isFirst: false)
    
    let cellSize = CGSize(width: 64.0, height: 64.0)
    
    /// The flag stating whether or not the instance refers to the first intro.
    ///
    private let isFirst: Bool
    
    /// Creates a new instance for the first or second intro.
    ///
    /// - Parameter isFirst: A flag stating whether or not the instance refers to the first intro.
    ///
    private init(isFirst: Bool) {
        self.isFirst = isFirst
    }
    
    func makeContent(ofType type: ContentType) -> Content? {
        assert(Game.protagonist != nil)
        
        let content: Content?
        
        if isFirst {
            switch type {
            case .enemy:
                content = Content(type: type, isDynamic: true, isObstacle: false,
                                  entity: IntroEnemy(levelOfExperience: 1, unaware: true))
            case .destructible:
                content = Content(type: type, isDynamic: true, isObstacle: false,
                                  entity: IntroObject(levelOfExperience: 1))
            case .exit:
                content = Content(type: type, isDynamic: false, isObstacle: true, entity: Portal())
            case .protagonist:
                content = Content(type: type, isDynamic: true, isObstacle: false, entity: Game.protagonist!)
            default:
                content = nil
            }
        } else {
            switch type {
            case .enemy:
                content = Content(type: type, isDynamic: true, isObstacle: false,
                                  entity: IntroEnemy(levelOfExperience: Int.random(in: 5...10), unaware: false))
            case .companion:
                content = Content(type: type, isDynamic: true, isObstacle: false,
                                  entity: IntroCompanion(levelOfExperience: Int.random(in: 35...40)))
            case .destructible:
                content = Content(type: type, isDynamic: true, isObstacle: false,
                                  entity: IntroObject(levelOfExperience: Int.random(in: 35...40)))
            case .exit:
                content = Content(type: type, isDynamic: false, isObstacle: true, entity: Portal())
            case .protagonist:
                content = Content(type: type, isDynamic: true, isObstacle: false, entity: Game.protagonist!)
            default:
                content = nil
            }
        }
        
        return content
    }
}
