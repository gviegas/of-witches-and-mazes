//
//  SpeechComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/14/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that allows an entity to display speech as a text above its node.
///
class SpeechComponent: Component, TextureUser {
    
    static var textureNames: Set<String> {
        return SpeechComponentData.textureNames
    }
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a SpeechComponent must also have a NodeComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity?.component(ofType: SpriteComponent.self) else {
            fatalError("An entity with a SpeechComponent must also have a SpriteComponent")
        }
        return component
    }
    
    /// The parent node of the speech.
    ///
    private let node: SKNode
    
    /// The animation for the speech.
    ///
    private let animation: SKAction
    
    /// The duration of the animation.
    ///
    private let animationTime: TimeInterval
    
    /// The elapsed time since the current speech started. This value is set to `nil` when the speech ends.
    ///
    private var elapsedTime: TimeInterval?
    
    /// The `UISpeechElement` representing the current speech being presented.
    ///
    private var speechElement: UISpeechElement?
    
    /// Creates a new instance.
    ///
    override init() {
        node = SKNode()
        node.zPosition = DepthLayer.decorators.upperBound
        
        let fadeInDuration: TimeInterval = 0.1
        let fadeOutDuration: TimeInterval = 1.0
        let waitDuration: TimeInterval = 3.4
        animationTime = fadeInDuration + fadeOutDuration + waitDuration
        animation = SKAction.sequence([SKAction.fadeIn(withDuration: fadeInDuration),
                                       SKAction.wait(forDuration: waitDuration),
                                       SKAction.fadeOut(withDuration: fadeOutDuration)])
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Presents a speech.
    ///
    /// - ToDo: Consider tying up the speech duration to the size of the text.
    ///
    /// - Parameter text: The speech.
    ///
    func say(text: String) {
        guard node.parent != nil else { return }
        
        // ToDo: A not-so-harsh removal
        node.removeAllChildren()
        elapsedTime = 0
        
        let speech = UISpeechElement.init(text: text,
                                          contentOffset: SpeechComponentData.Speech.contentOffset,
                                          maxLabelLength: SpeechComponentData.Speech.maxLabelLength,
                                          pointerImage: SpeechComponentData.Speech.pointerImage,
                                          backgroundImage: SpeechComponentData.Speech.backgroundImage,
                                          backgroundBorder: SpeechComponentData.Speech.backgroundBorder,
                                          backgroundOffset: SpeechComponentData.Speech.backgroundOffset)
        
        let rect = CGRect(x: -speech.size.width / 2.0, y: spriteComponent.size.height / 2.0 + 1.0,
                          width: speech.size.width, height: speech.size.height)
        
        let speechNode = speech.provideNodeFor(rect: rect)
        speechNode.alpha = 0
        speechNode.run(animation)
        node.addChild(speechNode)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard elapsedTime != nil else { return }
        
        elapsedTime! += seconds
        
        if elapsedTime! >= animationTime {
            node.removeAllChildren()
            elapsedTime = nil
        }
    }
    
    /// Attaches the speech node to the entity's node.
    ///
    /// If the speech node is already attached, this method has no effect.
    ///
    func attach() {
        guard node.parent == nil else { return }
        nodeComponent.node.addChild(node)
    }
    
    /// Detaches the speech node from the entity's node.
    ///
    /// If the speech node is not attached, this method has no effect.
    ///
    func detach() {
        guard node.parent != nil else { return }
        
        node.removeAllChildren()
        node.removeFromParent()
    }
    
    override func didAddToEntity() {
        node.entity = entity
        attach()
    }
    
    override func willRemoveFromEntity() {
        node.entity = nil
        detach()
    }
}

/// A struct that defines the data associated with the `SpeechComponent` class.
///
fileprivate struct SpeechComponentData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Speech.pointerImage, Speech.backgroundImage]
    }
    
    private init() {}
    
    /// The `UISpeechComponent` data.
    ///
    struct Speech {
        private init() {}
        static let contentOffset: CGFloat = 0
        static let maxLabelLength: CGFloat = 200.0
        static let pointerImage = "UI_Pointer_Down"
        static let backgroundImage = "UI_Alpha_Background_8p"
        static let backgroundBorder: UIBorder? = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat = 4.0
    }
}
