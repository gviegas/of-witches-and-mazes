//
//  AnimationName.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/20/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An enum defining the animation names, used to identify the context
/// in which a given animation must play.
///
enum AnimationName: String {
    // Basic
    case idle
    case walk
    case lift, hold, carry, hurl
    case attack
    case aim, shoot
    case direct, toss
    case use, useEnd
    case cast, castEnd
    case quell
    case hit
    case death
    
    // Monster-related
    case rangedAttack
    case causeBlast
    case causeRay
    
    // Fighter-related
    case defend, defendEnd
    case dash, dashEnd
    
    // Trap-related
    case trigger, triggerEnd
}
