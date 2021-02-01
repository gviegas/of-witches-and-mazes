//
//  UIHealthBar.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/30/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that displays a health bar in the UI.
///
class UIHealthBar {
    
    /// The bar.
    ///
    private let bar: SKSpriteNode
    
    /// The health.
    ///
    private let health: SKSpriteNode
    
    /// The label.
    ///
    private let label: UIText
    
    /// The health bar node.
    ///
    let node: SKNode
    
    /// The size of the health bar.
    ///
    let size: CGSize
    
    /// The width of the health, without the bar.
    ///
    let healthWidth: CGFloat
    
    /// The text displayed in the health bar.
    ///
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - healthWidth: The width of the health in the health bar.
    ///   - healthImage: The name of the health image.
    ///   - barImage: The name of the bar image.
    ///   - flipped: A flag stating whether or not the bar should be flipped vertically.
    ///     The default value is `false`.
    ///
    init(healthWidth: CGFloat, healthImage: String, barImage: String, flipped: Bool = false) {
        health = SKSpriteNode(texture: TextureSource.createTexture(imageNamed: healthImage))
        health.size.width = healthWidth
        health.anchorPoint = CGPoint.zero
        
        let rect = CGRect(origin: CGPoint(x: -health.size.width / 2.0, y: -health.size.height / 2.0),
                          size: health.size)
        label = UIText(rect: rect, style: .bar, text: nil, alignment: .center)
        label.node.zPosition = 1
        
        bar = SKSpriteNode(texture: TextureSource.createTexture(imageNamed: barImage))
        bar.addChild(health)
        bar.addChild(label.node)
        
        node = SKNode()
        node.addChild(bar)
        
        size = bar.size
        self.healthWidth = healthWidth
        
        if flipped {
            bar.xScale = -1.0
            label.node.xScale = -1.0
            health.xScale = -1.0
            health.position = CGPoint(x: health.size.width / 2.0, y: -health.size.height / 2.0)
        } else {
            health.position = CGPoint(x: -health.size.width / 2.0, y: -health.size.height / 2.0)
        }
    }
    
    /// Resizes the health relative to its original width.
    ///
    /// - Parameter normalizedValue: A value between 0 and 1.0.
    ///
    func resizeTo(normalizedValue value: CGFloat) {
        guard value >= 0 else { return }
        health.size.width = min(healthWidth * value, healthWidth)
    }
}
