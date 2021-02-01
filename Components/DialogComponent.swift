//
//  DialogComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/22/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component that enables an entity to provide text for a `DialogOverlay`.
///
class DialogComponent: Component {
    
    /// The text source.
    ///
    private let textSource: WeightedDistribution<String>
    
    /// The text to use for the dialog.
    ///
    /// Every time this getter is accessed, it produces a random value from the component's distribution.
    ///
    var text: String {
        return textSource.nextValue()
    }
    
    /// Creates a new instance from the given distribution.
    ///
    /// - Parameter textSource: A `WeightedDistribution` that generates text.
    ///
    init(textSource: WeightedDistribution<String>) {
        self.textSource = textSource
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
