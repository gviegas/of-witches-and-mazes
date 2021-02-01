//
//  VendorComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/15/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to manage prices on trades.
///
class VendorComponent: Component {
    
    /// The accumulated expenses since last reset.
    ///
    private var expense: Int
    
    /// The accumulated profits since last reset.
    ///
    private var profit: Int
    
    /// The maximum amount that the entity is able to spend initially.
    ///
    private var funds: Int
    
    /// The upper limit for all prices.
    ///
    let ceiling: Int
    
    /// The factor to apply on items sold by the entity.
    ///
    var sellFactor: Float
    
    /// The factor to apply on items bought by the entity.
    ///
    var buyFactor: Float
    
    /// Returns the total spent by the entity since last reset.
    ///
    var totalSpent: Int {
        return expense
    }
    
    /// Returns the total earned by the entity since last reset.
    ///
    var totalEarned: Int {
        return expense
    }
    
    /// The amount of funds available for the vendor, considering expense and profit.
    ///
    var fundsAvailable: Int {
        return max(0, funds + profit - expense)
    }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - funds: The maximum amount that the entity can spend initially.
    ///   - sellFactor: The factor to apply on items sold.
    ///   - buyFactor: The factor to apply on items bought
    ///   - ceiling: The upper limit for all prices.
    ///
    init(funds: Int, sellFactor: Float, buyFactor: Float, ceiling: Int) {
        assert(funds >= 0)
        
        self.funds = funds
        self.sellFactor = sellFactor
        self.buyFactor = buyFactor
        self.ceiling = ceiling
        self.expense = 0
        self.profit = 0
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Checks if a given amount can be spent.
    ///
    /// - Parameter amount: The amount to check.
    /// - Returns: `true` if the amount can be spent, `false` if the entity has reached
    ///   its maximum expenditure.
    ///
    func canSpend(amount: Int) -> Bool {
        return expense + amount <= funds + profit
    }
    
    /// Spends the given value.
    ///
    /// - Parameter amount: The amount to spend.
    /// - Returns: `true` if the amount could be spent, `false` if the entity has reached
    ///   its maximum expenditure.
    ///
    func spend(amount: Int) -> Bool {
        let newExpense = expense + amount
        if newExpense <= funds + profit {
            expense = newExpense
            return true
        }
        return false
    }
    
    /// Earns the given value.
    ///
    /// - Parameter amount: The amount to earn.
    ///
    func earn(amount: Int) {
        profit += amount
    }
    
    /// Converts a given item price to the one used by the entity when selling.
    ///
    /// - Parameter item: The item from which a new price is to be computed.
    /// - Returns: A new price to use, or `nil` if the entity will not sell the item.
    ///
    func sellPriceFor(item: Item) -> Int? {
        guard let originalPrice = (item as? TradableItem)?.price else { return nil }
        return min(max(Int((Float(originalPrice) * sellFactor).rounded()), 1), ceiling)
    }
    
    /// Converts a given item price to the one used by the entity when buying.
    ///
    /// - Parameter item: The item from which a new price is to be computed.
    /// - Returns: A new price to use, or `nil` if the entity will not buy the item.
    ///
    func buyPriceFor(item: Item) -> Int? {
        guard let originalPrice = (item as? TradableItem)?.price else { return nil }
        return min(max(Int((Float(originalPrice) * buyFactor).rounded()), 0), ceiling)
    }
    
    /// Resets the expense and profit amounts.
    ///
    /// - Parameter funds: An optional new maximum amount that can be spent initially. The
    ///   default value is `nil`, which means that the last funds provided are to be kept.
    ///
    func reset(funds: Int? = nil) {
        if let funds = funds, funds >= 0 {
            self.funds = funds
        }
        expense = 0
        profit = 0
    }
}
