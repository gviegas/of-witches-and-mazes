//
//  PersonaComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/24/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component that provides an entity with a persona name.
///
class PersonaComponent: Component {
    
    /// The maximum length of the persona string.
    ///
    static let maxLength = 16
    
    /// Creates anew instance from the given persona name.
    ///
    init(personaName: String) {
        self.personaName = String(personaName.prefix(PersonaComponent.maxLength))
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The persona name.
    ///
    var personaName: String {
        didSet { personaName = String(personaName.prefix(PersonaComponent.maxLength)) }
    }
}
