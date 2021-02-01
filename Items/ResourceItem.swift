//
//  ResourceItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/8/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that defines an `Item` type that requires, and possibly consumes, another one
/// as a resource.
///
protocol ResourceItem: Item {
    
    /// The unique name of the `Item` type used as resource.
    ///
    var resourceName: String { get }
    
    /// The resource cost, in quantity of `resourceName` items.
    ///
    /// This property defines the quantity of items, identified by `resourceName`, are required to use
    /// the conforming type. These items are consumed (i.e., removed from inventory) when the `ResourceItem`
    /// is used. For cases where `resourceCost` is `0`, all that is required is for one item of `resourceName`
    /// to be present, it will not be consumed.
    ///
    var resourceCost: Int { get }
}

extension ResourceItem {
    
    /// Consumes a given number of items named `resourceName` from the inventory of the given entity.
    ///
    /// - Note: If the item used as resource is a `StackableItem`, its stack count is considered
    ///   toward the resource cost.
    ///
    /// - Parameters:
    ///   - entity: The entity providing the `InventoryComponent` from where to draw the resources.
    ///   - cost: The optional quantity to consume. If set to `nil`, the `resourceCost` property is used.
    ///     The default value is `nil`.
    /// - Returns: `true` if the resources could be removed from the inventory, `false` if the inventory
    ///   does not contain the amount of resources needed - in which case nothing is removed.
    ///   For `ResourceItem`s that do not consume resources on use, `true` is returned when any quantity
    ///   of resources are owned, but nothing is removed from the inventory.
    ///
    func consumeResources(from entity: Entity, cost: Int? = nil) -> Bool {
        guard let inventoryComponent = entity.component(ofType: InventoryComponent.self) else {
            fatalError("ResourceItem can only be used by an entity that has an InventoryComponent")
        }
        
        let total = inventoryComponent.quantityOf(itemsNamed: resourceName)
        var cost = cost ?? resourceCost
        if let resourceUsageComponent = entity.component(ofType: ResourceUsageComponent.self) {
            cost = resourceUsageComponent.alterCost(of: self, cost: cost)
        }
        if total >= cost {
            if cost > 0 { let _ = inventoryComponent.removeMany(itemsNamed: resourceName, quantity: cost) }
            return true
        }
        return false
    }
    
    /// Computes the total number of times that the item can be used by the given entity before it
    /// runs out of ressources.
    ///
    /// - Parameters:
    ///   - entity: The entity providing the `InventoryComponent` from where to check for resources.
    ///   - cost: The optional quantity to use in the computation. If set to `nil`, the `resourceCost`
    ///     property is used. The default value is `nil`.
    /// - Returns: The total number of times that the item could be used, considering the current amount
    ///   of resources that the entity possess. For `ResourceItem`s that do not consume resources on use,
    ///   it returns either `0` when no resources are owned, or `1` when any number of resources are owned.
    ///
    func computeTotalUses(for entity: Entity, cost: Int? = nil) -> Int {
        guard let inventoryComponent = entity.component(ofType: InventoryComponent.self) else {
            fatalError("ResourceItem can only be used by an entity that has an InventoryComponent")
        }
        
        let total = inventoryComponent.quantityOf(itemsNamed: resourceName)
        var cost = cost ?? resourceCost
        if let resourceUsageComponent = entity.component(ofType: ResourceUsageComponent.self) {
            cost = resourceUsageComponent.alterCost(of: self, cost: cost)
        }
        
        return (cost > 0 ? total / cost : 1)
    }
}
