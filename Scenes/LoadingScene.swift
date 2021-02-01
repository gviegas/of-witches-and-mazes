//
//  LoadingScene.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/29/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `Scene` subclass representing the loading screen.
///
class LoadingScene: Scene {
    
    /// The loading node.
    ///
    private let node: SKLabelNode
    
    override init() {
        let uiText = UIText(maxWidth: 1024.0, style: .loading, text: "Now Loading...")
        uiText.flash()
        node = uiText.node
        super.init()
        backgroundColor = .black
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(node)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
