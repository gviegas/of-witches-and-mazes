//
//  AlterationItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/26/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol tha defines an `Item` type that has an `Alteration` property.
///
protocol AlterationItem: Item {
    
    /// The `Alteration`.
    ///
    var alteration: Alteration { get set }
}
