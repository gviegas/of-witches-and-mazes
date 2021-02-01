//
//  SpriteComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/31/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// The main drawable component of an entity.
///
class SpriteComponent: Component {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a SpriteComponent must also have a NodeComponent")
        }
        return component
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity?.component(ofType: DirectionComponent.self) else {
            fatalError("An entity with a SpriteComponent must also have a DirectionComponent")
        }
        return component
    }
    
    /// The sprite that represents the entity.
    ///
    private let sprite: SKSpriteNode
    
    /// A flag stating whether or not the sprite was flipped by the last animation played.
    ///
    private var isFlipped: Bool
    
    /// The latest animation played.
    ///
    private var latestAnimation: (name: AnimationName, direction: Direction)?
    
    /// The number of color animations that were applied and not yet removed.
    ///
    private var colorCount: (revealed: Int, cleared: Int) {
        didSet { colorCount = (max(0, colorCount.revealed), max(0, colorCount.cleared)) }
    }
    
    /// The animation set that animates the entity.
    ///
    var animationSet: DirectionalAnimationSet? {
        didSet { latestAnimation = nil }
    }
    
    /// The name of the latest played animation.
    ///
    var animationName: AnimationName? {
        return latestAnimation?.name
    }
    
    /// The direction of the latest played animation.
    ///
    var animationDirection: Direction? {
        return latestAnimation?.direction
    }
    
    /// The texture of the sprite.
    ///
    var texture: SKTexture? {
        get {
            return sprite.texture
        }
        set {
            sprite.texture = newValue
        }
    }
    
    /// The original size of the sprite.
    ///
    let size: CGSize
    
    /// The current size of the sprite, considering the current texture/animation.
    ///
    var currentSize: CGSize {
        return sprite.size
    }
    
    /// Creates a new instance that initializes a sprite with the given values.
    ///
    /// - Parameters:
    ///   - size: The size of the sprite.
    ///   - color: The color of the sprite. The default value is `NSColor.clear`.
    ///   - texture: An optional texture to initialize the sprite with. The default value is `nil`.
    ///   - position: The position to set the sprite at. The default value is `CGPoint.zero`.
    ///
    init(size: CGSize, color: NSColor = .clear, texture: SKTexture? = nil, position: CGPoint = CGPoint.zero) {
        self.size = size
        sprite = SKSpriteNode(texture: texture, color: color, size: size)
        sprite.position = position
        isFlipped = false
        colorCount = (0, 0)
        super.init()
    }
    
    /// Creates a new instance that uses a `DirectionalAnimationSet` to animate the sprite.
    ///
    /// - Parameters:
    ///   - size: The size of the sprite.
    ///   - animationSet: The `DirectionalAnimationSet` instance to be used by the animation.
    ///
    convenience init(size: CGSize, animationSet: DirectionalAnimationSet?) {
        self.init(size: size)
        self.animationSet = animationSet
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Attaches the sprite node to the entity's node.
    ///
    /// If the sprite node is already attached, this method has no effect.
    ///
    func attach() {
        if sprite.parent == nil {
            nodeComponent.node.addChild(sprite)
        }
    }
    
    /// Detaches the sprite node from the entity's node.
    ///
    /// If the sprite node is not attached, this method has no effect.
    ///
    func detach() {
        sprite.removeFromParent()
    }
    
    /// Retrieves and plays the named animation from the `animationSet`. The current direction
    /// from the entity's `DirectionComponent` is used to choose the right animation.
    ///
    /// - Parameter name: The name of the animation to play.
    /// - Returns: `true` if the animation could be played, `false` otherwise.
    ///
    @discardableResult
    func animate(name: AnimationName) -> Bool {
        guard let animationSet = animationSet,
            let animation = animationSet.getAnimation(named: name, forDirection: directionComponent.direction)
            else { return false }
        
        if let texturedAnimation = animation as? TextureAnimation {
            if texturedAnimation.flipped {
                if !isFlipped {
                    sprite.xScale *= -1.0
                    isFlipped = true
                }
            } else if isFlipped {
                sprite.xScale *= -1.0
                isFlipped = false
            }
        }
        
        animation.play(node: sprite)
        latestAnimation = (name, directionComponent.direction)
        return true
    }
    
    /// Plays the given animation.
    ///
    /// - Parameter animation: The animation to play.
    ///
    func animate(animation: Animation) {
        if let texturedAnimation = animation as? TextureAnimation {
            if texturedAnimation.flipped {
                if !isFlipped {
                    sprite.xScale *= -1.0
                    isFlipped = true
                }
            } else if isFlipped {
                sprite.xScale *= -1.0
                isFlipped = false
            }
        }
        
        animation.play(node: sprite)
        latestAnimation = nil
    }
    
    /// Colorizes the sprite with the given `ColorAnimation`.
    ///
    /// - Parameter colorAnimation: The `ColorAnimation` to use.
    ///
    func colorize(colorAnimation: ColorAnimation) {
        let shouldPlay: Bool
        
        if colorAnimation === ColorAnimation.revealed {
            shouldPlay = colorCount.revealed == 1
            colorCount.revealed -= 1
        } else if colorAnimation === ColorAnimation.cleared {
            shouldPlay = colorCount.revealed == 0 && colorCount.cleared == 1
            colorCount.cleared -= 1
        } else if !colorAnimation.animationUndoesItself {
            if colorAnimation === ColorAnimation.concealed {
                shouldPlay = colorCount.revealed == 0
                colorCount.revealed += 1
                colorCount.cleared = 0
            } else if colorCount.revealed == 0 {
                shouldPlay = true
                colorCount.cleared += 1
            } else {
                shouldPlay = false
            }
        } else {
            shouldPlay = colorCount.revealed == 0 && colorCount.cleared == 0
        }
        
        if shouldPlay { colorAnimation.play(node: sprite) }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if let depth = entity?.component(ofType: DepthComponent.self)?.depth {
            sprite.zPosition = depth
        } else {
            sprite.zPosition = 0
        }
    }
    
    override func didAddToEntity() {
        sprite.entity = entity
        attach()
    }
    
    override func willRemoveFromEntity() {
        sprite.entity = nil
        detach()
    }
    
    /// Resets the sprite properties.
    ///
    func reset() {
        sprite.removeAllActions()
        sprite.alpha = 1.0
        sprite.color = .clear
        sprite.colorBlendFactor = 0
    }
}
