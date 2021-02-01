//
//  UIEmblemElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that defines the main title of the game.
///
class UIMainTitleElement: UIElement {
    
    /// The name of the title's image.
    ///
    private let titleImage: String
    
    /// The dimensions of the element.
    ///
    /// - Note: Accessing the `size` getter will force the main title's texture to be loaded.
    ///
    var size: CGSize {
        return TextureSource.createTexture(imageNamed: titleImage).size()
    }
    
    /// Create a new instance that uses the given title image.
    ///
    /// - Parameter titleImage: The name of the title's image to use.
    ///
    init(titleImage: String) {
        self.titleImage = titleImage
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        return UIImage(rect: rect, image: titleImage, alignment: .center).node
    }
}
