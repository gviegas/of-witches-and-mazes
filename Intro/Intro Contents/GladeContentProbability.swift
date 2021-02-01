//
//  GladeContentProbability.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// The `ContentProbability` instances for the Glade.
///
struct GladeContentProbability {
    
    /// The `ContentProbability` for the first entrance.
    ///
    static let firstEntrance: ContentProbability = Entrance(isFirst: true)
    
    /// The `ContentProbability` for the first exit.
    ///
    static let firstExit: ContentProbability = Exit(isFirst: true)
    
    /// The first default `ContentProbability`.
    ///
    static let firstDefault: ContentProbability = Default(isFirst: true)
    
    /// The first one-time `ContentProbability` list.
    ///
    static let firstOneTime: [ContentProbability] = [OneTime(isFirst: true)]
    
    /// The `ContentProbability` for the second entrance.
    ///
    static let secondEntrance: ContentProbability = Entrance(isFirst: false)
    
    /// The `ContentProbability` for the second exit.
    ///
    static let secondExit: ContentProbability = Exit(isFirst: false)
    
    /// The second default `ContentProbability`.
    ///
    static let secondDefault: ContentProbability = Default(isFirst: false)
    
    /// The second one-time `ContentProbability` list.
    ///
    static let secondOneTime: [ContentProbability] = [OneTime(isFirst: false)]
    

    private class Entrance: ContentProbability {
        
        init(isFirst: Bool) {
            let rules: [ContentType: ContentRule]
            let weights: [ContentType: Double]
            let roomDensity: ClosedRange<Double>
            let corridorDensity: ClosedRange<Double>
            
            if isFirst {
                rules = [.protagonist: ContentRule(creationRule: .exactlyOnce, localizationRule: .mainRoom,
                                                   placementRule: .any)]
                weights = [:]
                roomDensity = 0...0
                corridorDensity = 0...0
            } else {
                rules = [.protagonist: ContentRule(creationRule: .exactlyOnce, localizationRule: .mainRoom,
                                                   placementRule: .any),
                         .companion: ContentRule(creationRule: .exactlyOnce, localizationRule: .mainRoom,
                                                 placementRule: .any)]
                weights = [:]
                roomDensity = 0...0
                corridorDensity = 0...0
            }
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
    
    private class Exit: ContentProbability {
        
        init(isFirst: Bool) {
            let rules: [ContentType: ContentRule]
            let weights: [ContentType: Double]
            let roomDensity: ClosedRange<Double>
            let corridorDensity: ClosedRange<Double>
            
            if isFirst {
                rules = [.exit: ContentRule(creationRule: .exactlyOnce, localizationRule: .mainRoom,
                                            placementRule: .any)]
                weights = [:]
                roomDensity = 0...0
                corridorDensity = 0...0
            } else {
                rules = [.exit: ContentRule(creationRule: .exactlyOnce, localizationRule: .mainRoom,
                                            placementRule: .any),
                         .destructible: ContentRule(creationRule: .any, localizationRule: .any,
                                                    placementRule: .any)]
                weights = [.destructible: 1.0]
                roomDensity = 0...0.075
                corridorDensity = 0...0.075
            }
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
    
    private class Default: ContentProbability {
        
        init(isFirst: Bool) {
            let rules: [ContentType: ContentRule]
            let weights: [ContentType: Double]
            let roomDensity: ClosedRange<Double>
            let corridorDensity: ClosedRange<Double>
            
            if isFirst {
                rules = [:]
                weights = [:]
                roomDensity = 0...0
                corridorDensity = 0...0
            } else {
                rules = [.destructible: ContentRule(creationRule: .any, localizationRule: .any,
                                                          placementRule: .any),
                         .enemy: ContentRule(creationRule: .any, localizationRule: .any,
                                                   placementRule: .any)]
                weights = [.destructible: 1.0, .enemy: 0.45]
                roomDensity = 0.05...0.075
                corridorDensity = 0...0.075
            }
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
    
    private class OneTime: ContentProbability {
        
        init(isFirst: Bool) {
            let rules: [ContentType: ContentRule]
            let weights: [ContentType: Double]
            let roomDensity: ClosedRange<Double>
            let corridorDensity: ClosedRange<Double>
            
            if isFirst {
                rules = [.enemy: ContentRule(creationRule: .exactlyOnce, localizationRule: .mainRoom,
                                                   placementRule: .any),
                         .destructible: ContentRule(creationRule: .any, localizationRule: .any,
                                                          placementRule: .edge)]
                weights = [.destructible: 1.0]
                roomDensity = 0...0.025
                corridorDensity = 0...0.02
            } else {
                rules = [:]
                weights = [:]
                roomDensity = 0...0
                corridorDensity = 0...0
            }
            
            super.init(rules: rules, weights: weights, roomDensity: roomDensity, corridorDensity: corridorDensity)
        }
    }
}
