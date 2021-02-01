//
//  VicarsPack.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/22/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `Pack` subclass defining the Vicar's Pack.
///
class VicarsPack: Pack {
    
    /// Creates a new instance from the given level of experience.
    ///
    /// - Parameter levelOfExperience: The level of experience of the entity that will own the pack.
    ///
    init(levelOfExperience: Int) {
        let items: [Item] = [GoldPiecesItem(quantity: 50),
                             CommonSwordItem(level: levelOfExperience),
                             RestorativePotionItem(quantity: 5),
                             YarnItem(level: levelOfExperience, quantity: 3)]
        let equipment: [Item] = [items[1], items[2], items[3]]
        super.init(items: items, equipment: equipment)
    }
}
