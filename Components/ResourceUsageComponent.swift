//
//  ResourceUsageComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/31/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component that enables an entity to alter how certain item categories consume resources.
///
class ResourceUsageComponent: Component {
    
    /// The dictionary containing the resource cost ratio for item categories.
    ///
    /// The `alterCost(of:cost:)` method uses the values found in this dictionary to alter the
    /// resource cost of items.
    ///
    var costRatios: [ItemCategory: Double]
    
    /// Creates a new instance from the given cost ratios dictionary.
    ///
    /// - Parameter costRatios: A dictionary containing the ratios to use when altering the resource
    ///   costs for items the of the given categories.
    ///
    init(costRatios: [ItemCategory: Double]) {
        self.costRatios = costRatios
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Alters the cost of a given item.
    ///
    /// - Parameters:
    ///   - item: The `ResourceItem` for which an altered resource cost must be computed.
    ///   - cost: An optional cost to be used when computing the altered cost. If `cost` is `nil`,
    ///     the item's `resourceCost` value is used.
    ///
    func alterCost(of item: ResourceItem, cost: Int?) -> Int {
        guard let ratio = costRatios[item.category] else {
            return cost ?? item.resourceCost
        }
        return Int((ratio * Double(cost ?? item.resourceCost)).rounded())
    }
}
