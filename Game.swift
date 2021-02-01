//
//  Game.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/7/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A struct that represents the global game data.
///
struct Game {
    
    private init() {}
    
    /// The protagonist of the game.
    ///
    static var protagonist: Entity?
    
    /// The entity which the protagonist is interacting with.
    ///
    static var subject: Entity? {
        return protagonist?.component(ofType: SubjectComponent.self)?.subject
    }
    
    /// The entity which the protagonist is targeting.
    ///
    static var target: Entity? {
        return protagonist?.component(ofType: TargetComponent.self)?.source
    }
    
    /// The current level of experience of the protagonist.
    ///
    static var levelOfExperience: Int? {
        return protagonist?.component(ofType: ProgressionComponent.self)?.levelOfExperience
    }
}
