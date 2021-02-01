//
//  SoundFXSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/30/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A struct containing the set of all available `SoundFX`s for the game.
///
struct SoundFXSet {
    
    /// The special effects.
    ///
    struct FX {
        static let alert = SoundFX(fileName: "SFX_Alert")
        static let ambush = SoundFX(fileName: "SFX_Ambush")
        static let attack = SoundFX(fileName: "SFX_Attack")
        static let blade = SoundFX(fileName: "SFX_Blade")
        static let boiling = SoundFX(fileName: "SFX_Boiling")
        static let breaking = SoundFX(fileName: "SFX_Breaking")
        static let brick = SoundFX(fileName: "SFX_Brick")
        static let choosing = SoundFX(fileName: "SFX_Choosing")
        static let conjuration = SoundFX(fileName: "SFX_Conjuration")
        static let conjurationHit = SoundFX(fileName: "SFX_Conjuration_Hit")
        static let consuming = SoundFX(fileName: "SFX_Consuming")
        static let cracking = SoundFX(fileName: "SFX_Cracking")
        static let crushing = SoundFX(fileName: "SFX_Crushing")
        static let crystal = SoundFX(fileName: "SFX_Crystal")
        static let curse = SoundFX(fileName: "SFX_Curse")
        static let curseHit = SoundFX(fileName: "SFX_Curse_Hit")
        static let cutter = SoundFX(fileName: "SFX_Cutter")
        static let dark = SoundFX(fileName: "SFX_Dark")
        static let darkHit = SoundFX(fileName: "SFX_Dark_Hit")
        static let defense = SoundFX(fileName: "SFX_Defense")
        static let disarm = SoundFX(fileName: "SFX_Disarm")
        static let disorient = SoundFX(fileName: "SFX_Disorient")
        static let drinking = SoundFX(fileName: "SFX_Drinking")
        static let dying = SoundFX(fileName: "SFX_Dying")
        static let energy = SoundFX(fileName: "SFX_Energy")
        static let energyHit = SoundFX(fileName: "SFX_Energy_Hit")
        static let evade = SoundFX(fileName: "SFX_Evade")
        static let explosion = SoundFX(fileName: "SFX_Explosion")
        static let flurryAttack = SoundFX(fileName: "SFX_Flurry_Attack")
        static let genericAttack = SoundFX(fileName: "SFX_Generic_Attack")
        static let genericHit = SoundFX(fileName: "SFX_Generic_Hit")
        static let genericRangedAttack = SoundFX(fileName: "SFX_Generic_Ranged_Attack")
        static let glass = SoundFX(fileName: "SFX_Glass")
        static let gold = SoundFX(fileName: "SFX_Gold")
        static let grass = SoundFX(fileName: "SFX_Grass")
        static let hammer = SoundFX(fileName: "SFX_Hammer")
        static let hide = SoundFX(fileName: "SFX_Hide")
        static let hit = SoundFX(fileName: "SFX_Hit")
        static let ice = SoundFX(fileName: "SFX_Ice")
        static let iceHit = SoundFX(fileName: "SFX_Ice_Hit")
        static let improving = SoundFX(fileName: "SFX_Improving")
        static let landing = SoundFX(fileName: "SFX_Landing")
        static let liquid = SoundFX(fileName: "SFX_Liquid")
        static let magicalAttack = SoundFX(fileName: "SFX_Magical_Attack")
        static let magicalHit = SoundFX(fileName: "SFX_Magical_Hit")
        static let magnet = SoundFX(fileName: "SFX_Magnet")
        static let metal = SoundFX(fileName: "SFX_Metal")
        static let naturalAttack = SoundFX(fileName: "SFX_Natural_Attack")
        static let naturalHit = SoundFX(fileName: "SFX_Natural_Hit")
        static let poison = SoundFX(fileName: "SFX_Poison")
        static let preciousItem = SoundFX(fileName: "SFX_Precious_Item")
        static let rangedAttack = SoundFX(fileName: "SFX_Ranged_Attack")
        static let rangedHit = SoundFX(fileName: "SFX_Ranged_Hit")
        static let rive = SoundFX(fileName: "SFX_Rive")
        static let spell = SoundFX(fileName: "SFX_Spell")
        static let spellHit = SoundFX(fileName: "SFX_Spell_Hit")
        static let steel = SoundFX(fileName: "SFX_Steel")
        static let throwShield = SoundFX(fileName: "SFX_Throw_Shield")
        static let trap = SoundFX(fileName: "SFX_Trap")
        static let using = SoundFX(fileName: "SFX_Using")
        static let volley = SoundFX(fileName: "SFX_Volley")
        static let weakAttack = SoundFX(fileName: "SFX_Weak_Attack")
        static let weakHit = SoundFX(fileName: "SFX_Weak_Hit")
    }
    
    /// The voice-like effects.
    ///
    struct Voice {
        static let bird = SoundFX(fileName: "Voice_Bird")
        static let cat = SoundFX(fileName: "Voice_Cat")
        static let cruelBeing = SoundFX(fileName: "Voice_Cruel_Being")
        static let dreadfulBeing = SoundFX(fileName: "Voice_Dreadful_Being")
        static let evilBeing = SoundFX(fileName: "Voice_Evil_Being")
        static let femaleCleric = SoundFX(fileName: "Voice_Female_Cleric")
        static let femalePaladin = SoundFX(fileName: "Voice_Female_Paladin")
        static let feral = SoundFX(fileName: "Voice_Feral")
        static let goblin = SoundFX(fileName: "Voice_Goblin")
        static let grimBeing = SoundFX(fileName: "Voice_Grim_Being")
        static let hound = SoundFX(fileName: "Voice_Hound")
        static let insect = SoundFX(fileName: "Voice_Insect")
        static let lazyBeast = SoundFX(fileName: "Voice_Lazy_Beast")
        static let lonePrincess = SoundFX(fileName: "Voice_Lone_Princess")
        static let madBeast = SoundFX(fileName: "Voice_Mad_Beast")
        static let malePaladin = SoundFX(fileName: "Voice_Male_Paladin")
        static let nixe = SoundFX(fileName: "Voice_Nixe")
        static let oldBeing = SoundFX(fileName: "Voice_Old_Being")
        static let primalBeast = SoundFX(fileName: "Voice_Primal_Beast")
        static let rascal = SoundFX(fileName: "Voice_Rascal")
        static let secretBeing = SoundFX(fileName: "Voice_Secret_Being")
        static let singingSiren = SoundFX(fileName: "Voice_Singing_Siren")
        static let siren = SoundFX(fileName: "Voice_Siren")
        static let sorcerer = SoundFX(fileName: "Voice_Sorcerer")
        static let spectre = SoundFX(fileName: "Voice_Spectre")
        static let tinyBeast = SoundFX(fileName: "Voice_Tiny_Beast")
        static let toad = SoundFX(fileName: "Voice_Toad")
        static let witch = SoundFX(fileName: "Voice_Witch")
        static let youngFay = SoundFX(fileName: "Voice_Young_Fay")
    }
}
