//
//  ShoreContentProbability.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/17/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// The `ContentProbability` instances for the Shore.
///
struct ShoreContentProbability {
    
    /// The `ContentProbability` for the entrance.
    ///
    static let entrance: ContentProbability = Entrance()
    
    /// The `ContentProbability` for the exit.
    ///
    static let exit: ContentProbability = Exit()
    
    /// The default `ContentProbability`.
    ///
    static let `default`: ContentProbability = Default()
    
    /// The one-time `ContentProbability` list.
    ///
    static let oneTime: [ContentProbability] = [OneTimeMerchant(), OneTimeElite(), OneTimeRare(), OneTimeTrap(),
                                                OneTimeSpikeTrap(), OneTimeBoltTrap(), OneTimeCurePool(),
                                                OneTimeHermit(), OneTimePack()]
    
    
    private class Entrance: ContentProbability {
        
        init() {
            let rules: [ContentType: ContentRule] = [
                .destructible: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .edge),
                .enemy: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .any),
                .protagonist: ContentRule(creationRule: .exactlyOnce, localizationRule: .any, placementRule: .any)
            ]
            
            let weights: [ContentType: Double] = [.destructible: 1.0, .enemy: 0.1]
            
            let roomDensity: ClosedRange<Double> = 0...0.17
            let corridorDensity: ClosedRange<Double> = 0...0.065
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
    
    private class Exit: ContentProbability {
        
        init() {
            let rules: [ContentType: ContentRule] = [
                .destructible: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .edge),
                .enemy: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .any),
                .exit: ContentRule(creationRule: .exactlyOnce, localizationRule: .mainRoom, placementRule: .any),
                .treasure: ContentRule(creationRule: .noMoreThanOnce, localizationRule: .any, placementRule: .edge)
            ]
            
            let weights: [ContentType: Double] = [.destructible: 1.0, .enemy: 0.3, .treasure: 0.005]
            
            let roomDensity: ClosedRange<Double> = 0...0.17
            let corridorDensity: ClosedRange<Double> = 0...0.065
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
    
    private class Default: ContentProbability {
        
        init() {
            let rules: [ContentType: ContentRule] = [
                .destructible: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .edge),
                .enemy: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .any),
                .trap: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .middle),
                .treasure: ContentRule(creationRule: .noMoreThanOnce, localizationRule: .any, placementRule: .edge)
            ]
            
            let weights: [ContentType: Double] = [.destructible: 1.0, .enemy: 0.3, .trap: 0.1, .treasure: 0.005]
            
            let roomDensity: ClosedRange<Double> = 0...0.17
            let corridorDensity: ClosedRange<Double> = 0...0.065
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
    
    private class OneTimeMerchant: ContentProbability {
        
        init() {
            let rules: [ContentType: ContentRule] = [
                .destructible: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .edge),
                .enemy: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .any),
                .merchant: ContentRule(creationRule: .noMoreThanOnce, localizationRule: .any, placementRule: .any),
                .treasure: ContentRule(creationRule: .noMoreThanOnce, localizationRule: .any, placementRule: .edge)
            ]
            
            let weights: [ContentType: Double] = [.destructible: 1.0, .enemy: 0.1, .merchant: 1.0, .treasure: 0.005]
            
            let roomDensity: ClosedRange<Double> = 0...0.17
            let corridorDensity: ClosedRange<Double> = 0...0.065
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
    
    private class OneTimeElite: ContentProbability {
        
        init() {
            let rules: [ContentType: ContentRule] = [
                .destructible: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .edge),
                .enemy: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .any),
                .elite: ContentRule(creationRule: .exactlyOnce, localizationRule: .any, placementRule: .any),
                .treasure: ContentRule(creationRule: .noMoreThanOnce, localizationRule: .any, placementRule: .edge)
            ]
            
            let weights: [ContentType: Double] = [.destructible: 1.0, .enemy: 0.1, .treasure: 0.01]
            
            let roomDensity: ClosedRange<Double> = 0...0.17
            let corridorDensity: ClosedRange<Double> = 0...0.065
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
    
    private class OneTimeRare: ContentProbability {
        
        init() {
            let rules: [ContentType: ContentRule] = [
                .destructible: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .edge),
                .enemy: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .any),
                .rare: ContentRule(creationRule: .exactlyOnce, localizationRule: .any, placementRule: .any),
                .treasure: ContentRule(creationRule: .exactlyOnce, localizationRule: .any, placementRule: .edge)
            ]
            
            let weights: [ContentType: Double] = [.destructible: 1.0, .enemy: 0.25]
            
            let roomDensity: ClosedRange<Double> = 0...0.17
            let corridorDensity: ClosedRange<Double> = 0...0.065
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
    
    private class OneTimeTrap: ContentProbability {
        
        init() {
            let rules: [ContentType: ContentRule] = [
                .destructible: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .edge),
                .enemy: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .any),
                .trap: ContentRule(creationRule: .atLeastOnce, localizationRule: .any, placementRule: .middle),
                .treasure: ContentRule(creationRule: .noMoreThanOnce, localizationRule: .any, placementRule: .middle)
            ]
            
            let weights: [ContentType: Double] = [.destructible: 1.0, .enemy: 0.1, .trap: 1.0, .treasure: 0.1]
            
            let roomDensity: ClosedRange<Double> = 0...0.17
            let corridorDensity: ClosedRange<Double> = 0...0.065
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
    
    private class OneTimeSpikeTrap: ContentProbability {
        
        init() {
            let rules: [ContentType: ContentRule] = [
                .destructible: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .edge),
                .enemy: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .any),
                .treasure: ContentRule(creationRule: .noMoreThanOnce, localizationRule: .mainRoom,
                                       placementRule: .middle),
                .other("Spike Trap"): ContentRule(creationRule: .atLeastOnce, localizationRule: .any,
                                                  placementRule: .any)
            ]
            
            let weights: [ContentType: Double] = [.destructible: 0.4, .enemy: 0.03, .treasure: 0.1,
                                                  .other("Spike Trap"): 1.0]
            
            let roomDensity: ClosedRange<Double> = 0...0.33
            let corridorDensity: ClosedRange<Double> = 0...0.078
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
    
    private class OneTimeBoltTrap: ContentProbability {
        
        init() {
            let rules: [ContentType: ContentRule] = [
                .destructible: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .edge),
                .enemy: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .any),
                .treasure: ContentRule(creationRule: .noMoreThanOnce, localizationRule: .mainRoom,
                                       placementRule: .edge),
                .other("Bolt Trap"): ContentRule(creationRule: .atLeastOnce, localizationRule: .any,
                                                 placementRule: .edge)
            ]
            
            let weights: [ContentType: Double] = [.destructible: 0.2, .enemy: 0.05, .treasure: 0.1,
                                                  .other("Bolt Trap"): 1.0]
            
            let roomDensity: ClosedRange<Double> = 0...0.17
            let corridorDensity: ClosedRange<Double> = 0...0.065
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
    
    private class OneTimeCurePool: ContentProbability {
        
        init() {
            let rules: [ContentType: ContentRule] = [
                .destructible: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .edge),
                .enemy: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .any),
                .treasure: ContentRule(creationRule: .noMoreThanOnce, localizationRule: .mainRoom,
                                       placementRule: .edge),
                .other("Cure Pool"): ContentRule(creationRule: .exactlyOnce, localizationRule: .mainRoom,
                                                 placementRule: .middle)
            ]
            
            let weights: [ContentType: Double] = [.destructible: 0.1, .enemy: 0.05, .treasure: 0.025]
            
            let roomDensity: ClosedRange<Double> = 0...0.083
            let corridorDensity: ClosedRange<Double> = 0...0.033
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
    
    private class OneTimeHermit: ContentProbability {
        
        init() {
            let rules: [ContentType: ContentRule] = [
                .destructible: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .edge),
                .treasure: ContentRule(creationRule: .noMoreThanOnce, localizationRule: .mainRoom,
                                       placementRule: .any),
                .other("Hermit"): ContentRule(creationRule: .atLeastOnce, localizationRule: .any,
                                              placementRule: .any),
                .other("Spike Trap"): ContentRule(creationRule: .atLeastOnce, localizationRule: .any,
                                                  placementRule: .any),
                .other("Cure Pool"): ContentRule(creationRule: .exactlyOnce, localizationRule: .mainRoom,
                                                 placementRule: .any),
            ]
            
            let weights: [ContentType: Double] = [.destructible: 1.0, .treasure: 0.05, .other("Hermit"): 0.8,
                                                  .other("Spike Trap"): 0.3]
            
            let roomDensity: ClosedRange<Double> = 0...0.26
            let corridorDensity: ClosedRange<Double> = 0...0.07
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
    
    private class OneTimePack: ContentProbability {
        
        init() {
            let rules: [ContentType: ContentRule] = [
                .destructible: ContentRule(creationRule: .any, localizationRule: .any, placementRule: .edge),
                .treasure: ContentRule(creationRule: .atLeastOnce, localizationRule: .mainRoom,
                                       placementRule: .edge),
                .other("Ignis Fatuus"): ContentRule(creationRule: .atLeastOnce, localizationRule: .mainRoom,
                                                 placementRule: .any),
                .other("Cure Pool"): ContentRule(creationRule: .exactlyOnce, localizationRule: .mainRoom,
                                                 placementRule: .middle),
            ]
            
            let weights: [ContentType: Double] = [.destructible: 1.0, .treasure: 0.025, .other("Ignis Fatuus"): 0.4]
            
            let roomDensity: ClosedRange<Double> = 0...0.17
            let corridorDensity: ClosedRange<Double> = 0...0.065
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
}
