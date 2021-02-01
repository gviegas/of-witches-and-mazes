//
//  IntroCompanion.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/10/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// The `Companion` used in the intro.
///
class IntroCompanion: Feline {
    
    override func didAddToLevel(_ level: Level) {
        guard let protagonist = Game.protagonist else {
            fatalError("No protagonist set")
        }
        
        component(ofType: CompanionComponent.self)?.companion = protagonist
        protagonist.component(ofType: CompanionComponent.self)?.companion = self
        
        super.didAddToLevel(level)
    }
}
