//
//  ContentProbability.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that specifies a content probability, used for random generation of contents.
///
/// The main purpose of this class is to define how to generate contents for a single `Room` instance.
/// Note that the content rules may change the way the other properties are to be interpreted. For example,
/// a content with `creationRule` set as `exactlyOnce` does not need to have a weight value, and the densities
/// may not matter if this is the only content type defined.
///
class ContentProbability {
    
    /// The rules associated with the contents to be created.
    ///
    let rules: [ContentType: ContentRule]
    
    /// The weights associated with the contents to be created.
    ///
    let weights: [ContentType: Double]
    
    /// The amount of room area to be filled with content.
    ///
    /// It must be a range between 0.0 and 1.0, where a value of 0.0 will leave the room
    /// empty and a value of 1.0 will fill the whole area.
    ///
    let roomDensity: ClosedRange<Double>
    
    /// The amount of corridor area to be filled with content.
    ///
    /// It must be a range between 0.0 and 1.0, where a value of 0.0 will leave the corridor
    /// empty and a value of 1.0 will fill the whole area.
    ///
    let corridorDensity: ClosedRange<Double>
    
    /// Created a new instance from the given values.
    ///
    /// - Parameters:
    ///   - rules: A dictionary of content types and the rules associated with them.
    ///   - weights: A dictionary of content types and the weights associated with them.
    ///   - roomDensity: The amount of room area to fill with content.
    ///   - corridorDensity: The amount of corridor area to fill with content.
    ///
    init(rules: [ContentType: ContentRule], weights: [ContentType: Double],
         roomDensity: ClosedRange<Double>, corridorDensity: ClosedRange<Double>) {
        
        assert(roomDensity.lowerBound >= 0 && roomDensity.upperBound <= 1.0)
        assert(corridorDensity.lowerBound >= 0 && corridorDensity.upperBound <= 1.0)
        
        self.rules = rules
        self.weights = weights
        self.roomDensity = roomDensity
        self.corridorDensity = corridorDensity
    }
}
