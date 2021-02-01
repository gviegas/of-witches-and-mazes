//
//  ContentRule.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A struct that specifies the rules associated with a type of content to be created.
///
/// This rules will govern how, and if, the content will be created by a content generator. It
/// should be expected that no content will be created unless the generator can abide by the rules.
///
struct ContentRule {
    
    /// An enum that specifies the number of times that this type of content should be created.
    ///
    enum CreationRule {
        case noMoreThanOnce
        case exactlyOnce
        case atLeastOnce
        case any
    }
    
    /// An enum that specifies where, in a room, this type of content can be laid.
    ///
    enum LocalizationRule {
        case mainRoom
        case corridor
        case any
    }
    
    /// An enum that specifies where, in a room rect, this type of content can be laid.
    ///
    enum PlacementRule {
        case corner
        case edge
        case middle
        case any
    }
    
    /// The creation rule of this type of content.
    ///
    let creationRule: CreationRule
    
    /// The localization rule for this type of content.
    ///
    let localizationRule: LocalizationRule
    
    /// The placement rule for this type of content.
    ///
    let placementRule: PlacementRule
}
