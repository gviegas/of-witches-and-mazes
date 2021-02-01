//
//  DisableDeviceSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that enables an entity to disarm traps and open locks.
///
class DisableDeviceSkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.tools.imageName]
    }
    
    let name: String = "Disable Device"
    let icon: Icon = IconSet.Skill.tools
    let cost: Int = 7
    var unlocked: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Treasure chests no longer require a key to unlock, and some kinds of traps can now be disarmed.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        entity.addComponent(DisarmDeviceComponent())
    }
}
