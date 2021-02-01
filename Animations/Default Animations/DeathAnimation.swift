//
//  DeathAnimation.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/8/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class defining the default death animation. It paints the node black and fades it out.
///
class DeathAnimation: Animation, AnimationUser {
    private static let key = "DeathAnimation"
    
    static var animationKeys: Set<String> {
        return [key]
    }
    
    /// The instance of the class.
    ///
    static var instance: Animation {
        return AnimationSource.getAnimation(forKey: key) ?? DeathAnimation()
    }
    
    var replaceable: Bool
    var duration: TimeInterval?
    
    /// The animation's action.
    ///
    private let action: SKAction
    
    private init() {
        replaceable = false
        duration = 1.0
        let colorize = SKAction.colorize(with: .black, colorBlendFactor: 1.0, duration: duration!)
        let fade = SKAction.fadeOut(withDuration: duration!)
        action = .group([colorize, fade])
        AnimationSource.storeAnimation(self, forKey: DeathAnimation.key)
    }
    
    func play(node: SKNode) {
        node.run(action)
    }
}
