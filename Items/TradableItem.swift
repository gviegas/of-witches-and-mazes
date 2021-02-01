//
//  TradableItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/2/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that defines an `Item` type that can be used in trades.
///
protocol TradableItem: Item {
    
    /// The item's price.
    ///
    var price: Int { get }
}

extension TradableItem {
    
    /// Calculates the item's price.
    ///
    /// - Parameter basePrice: The item's base price.
    /// - Returns: The item's price.
    ///
    func calculatePrice(basePrice: Int) -> Int {
        let price: Int
        if let item = self as? LevelItem {
            var exp = 0.5
            if let item = self as? AlterationItem { exp += Double(item.alteration.stats.count) * 0.075 }
            let factor = pow(Double(item.itemLevel), exp)
            price = Int((Double(basePrice) * factor).rounded())
        } else {
            price = basePrice
        }
        
        return price
    }
}
