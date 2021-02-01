//
//  Experimental.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/23/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

#if DEBUG
import SpriteKit
import GameplayKit

struct INITDEBUG {
    
    enum Flags {
        case skdebug
        case protagonistImmortal
        case protagonistSpectator
        case usableSkillsUnlocked
        case passiveSkillsUnlocked
        case skillPointsAward
    }
    
    private init() {}
    
    static let activeFlags: Set<Flags> = []
    
    static func run() {
        if activeFlags.contains(.skdebug) {
            if let view = SceneManager.currentScene?.view {
                view.showsFPS = true
                view.showsNodeCount = true
                view.showsPhysics = true
                view.showsDrawCount = true
                view.showsQuadCount = true
            }
        }
        print("----------------INITDEBUG end----------------")
    }
}

extension Scene {
    override func sceneDidLoad() {
        if self is LevelScene {
            if INITDEBUG.activeFlags.contains(.protagonistImmortal) {
                Game.protagonist?.component(ofType: HealthComponent.self)?.isImmortal = true
            }
            
            if INITDEBUG.activeFlags.contains(.protagonistSpectator) {
                Game.protagonist?.component(ofType: PhysicsComponent.self)?.interaction = .monster
            }
            
            if INITDEBUG.activeFlags.contains(.usableSkillsUnlocked) {
                Game.protagonist?.component(ofType: SkillComponent.self)?.usableSkills.forEach {
                    $0.unlocked = true
                }
            }
            
            if INITDEBUG.activeFlags.contains(.passiveSkillsUnlocked) {
                Game.protagonist?.component(ofType: SkillComponent.self)?.passiveSkills.forEach {
                    $0.unlocked = true
                }
            }
            
            if INITDEBUG.activeFlags.contains(.skillPointsAward) {
                Game.protagonist?.component(ofType: SkillComponent.self)?.totalPoints = 50
            }
        }
    }
}
#endif
