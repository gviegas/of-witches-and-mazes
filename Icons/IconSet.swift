//
//  IconSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/26/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A struct defining the set of all available icons.
///
struct IconSet {
    
    /// The dimensions of the icons.
    ///
    static let size = CGSize(width: 32.0, height: 32.0)
    
    /// The item icons.
    ///
    struct Item {
        static let amethystRing = Icon(imageName: "Icon_Amethyst_Ring_Item", size: size)
        static let aquamarineRing = Icon(imageName: "Icon_Aquamarine_Ring_Item", size: size)
        static let arrow = Icon(imageName: "Icon_Arrow_Item", size: size)
        static let bastardSword = Icon(imageName: "Icon_Bastard_Sword_Item", size: size)
        static let beigePotion = Icon(imageName: "Icon_Beige_Potion_Item", size: size)
        static let blueGrimoire = Icon(imageName: "Icon_Blue_Grimoire_Item", size: size)
        static let blueHeaterShield = Icon(imageName: "Icon_Blue_Heater_Shield_Item", size: size)
        static let bluePotion = Icon(imageName: "Icon_Blue_Potion_Item", size: size)
        static let bomb = Icon(imageName: "Icon_Bomb_Item", size: size)
        static let brassHauberk = Icon(imageName: "Icon_Brass_Hauberk_Item", size: size)
        static let brownBook = Icon(imageName: "Icon_Brown_Book_Item", size: size)
        static let brownRecurveBow = Icon(imageName: "Icon_Brown_Recurve_Bow_Item", size: size)
        static let brownTunic = Icon(imageName: "Icon_Brown_Tunic_Item", size: size)
        static let cobaltCuirass = Icon(imageName: "Icon_Cobalt_Cuirass_Item", size: size)
        static let commonSword = Icon(imageName: "Icon_Common_Sword_Item", size: size)
        static let copperHauberk = Icon(imageName: "Icon_Copper_Hauberk_Item", size: size)
        static let copperRing = Icon(imageName: "Icon_Copper_Ring_Item", size: size)
        static let coralRing = Icon(imageName: "Icon_Coral_Ring_Item", size: size)
        static let cuirass = Icon(imageName: "Icon_Cuirass_Item", size: size)
        static let cutlass = Icon(imageName: "Icon_Cutlass_Item", size: size)
        static let dagger = Icon(imageName: "Icon_Dagger_Item", size: size)
        static let glaucousPotion = Icon(imageName: "Icon_Glaucous_Potion_Item", size: size)
        static let goldCuirass = Icon(imageName: "Icon_Gold_Cuirass_Item", size: size)
        static let goldPieces = Icon(imageName: "Icon_Gold_Pieces_Item", size: size)
        static let goldRing = Icon(imageName: "Icon_Gold_Ring_Item", size: size)
        static let greenBook = Icon(imageName: "Icon_Green_Book_Item", size: size)
        static let greenGrimoire = Icon(imageName: "Icon_Green_Grimoire_Item", size: size)
        static let greenOvalShield = Icon(imageName: "Icon_Green_Oval_Shield_Item", size: size)
        static let greenPotion = Icon(imageName: "Icon_Green_Potion_Item", size: size)
        static let greyTome = Icon(imageName: "Icon_Grey_Tome_Item", size: size)
        static let greyTunic = Icon(imageName: "Icon_Grey_Tunic_Item", size: size)
        static let hauberk = Icon(imageName: "Icon_Hauberk_Item", size: size)
        static let heaterShield = Icon(imageName: "Icon_Heater_Shield_Item", size: size)
        static let huntingBow = Icon(imageName: "Icon_Hunting_Bow_Item", size: size)
        static let key = Icon(imageName: "Icon_Key_Item", size: size)
        static let longBow = Icon(imageName: "Icon_Long_Bow_Item", size: size)
        static let orangeTome = Icon(imageName: "Icon_Orange_Tome_Item", size: size)
        static let ovalShield = Icon(imageName: "Icon_Oval_Shield_Item", size: size)
        static let pinkPotion = Icon(imageName: "Icon_Pink_Potion_Item", size: size)
        static let purpleBook = Icon(imageName: "Icon_Purple_Book_Item", size: size)
        static let purplePotion = Icon(imageName: "Icon_Purple_Potion_Item", size: size)
        static let rapier = Icon(imageName: "Icon_Rapier_Item", size: size)
        static let recurveBow = Icon(imageName: "Icon_Recurve_Bow_Item", size: size)
        static let redBook = Icon(imageName: "Icon_Red_Book_Item", size: size)
        static let redGrimoire = Icon(imageName: "Icon_Red_Grimoire_Item", size: size)
        static let redPotion = Icon(imageName: "Icon_Red_Potion_Item", size: size)
        static let redRoundShield = Icon(imageName: "Icon_Red_Round_Shield_Item", size: size)
        static let roundShield = Icon(imageName: "Icon_Round_Shield_Item", size: size)
        static let royalSword = Icon(imageName: "Icon_Royal_Sword_Item", size: size)
        static let rufousPotion = Icon(imageName: "Icon_Rufous_Potion_Item", size: size)
        static let silverRing = Icon(imageName: "Icon_Silver_Ring_Item", size: size)
        static let spatha = Icon(imageName: "Icon_Spatha_Item", size: size)
        static let spellComponents = Icon(imageName: "Icon_Spell_Components_Item", size: size)
        static let steelCuirass = Icon(imageName: "Icon_Steel_Cuirass_Item", size: size)
        static let toy = Icon(imageName: "Icon_Toy_Item", size: size)
        static let uncommonSword = Icon(imageName: "Icon_Uncommon_Sword_Item", size: size)
        static let whiteRecurveBow = Icon(imageName: "Icon_White_Recurve_Bow_Item", size: size)
        static let whiteTunic = Icon(imageName: "Icon_White_Tunic_Item", size: size)
        static let yarn = Icon(imageName: "Icon_Yarn_Item", size: size)
        static let yellowPotion = Icon(imageName: "Icon_Yellow_Potion_Item", size: size)
        static let yellowTome = Icon(imageName: "Icon_Yellow_Tome_Item", size: size)
    }
    
    /// The skill icons.
    ///
    struct Skill {
        static let angel = Icon(imageName: "Icon_Angel_Skill", size: size)
        static let arrows = Icon(imageName: "Icon_Arrows_Skill", size: size)
        static let auraHoly = Icon(imageName: "Icon_Aura_Holy_Skill", size: size)
        static let banner = Icon(imageName: "Icon_Banner_Skill", size: size)
        static let barrierHoly = Icon(imageName: "Icon_Barrier_Holy_Skill", size: size)
        static let beam = Icon(imageName: "Icon_Beam_Skill", size: size)
        static let coffin = Icon(imageName: "Icon_Coffin_Skill", size: size)
        static let crosses = Icon(imageName: "Icon_Crosses_Skill", size: size)
        static let daggerPiercing = Icon(imageName: "Icon_Dagger_Piercing_Skill", size: size)
        static let faceAndDagger = Icon(imageName: "Icon_Face_And_Dagger_Skill", size: size)
        static let faceBloody = Icon(imageName: "Icon_Face_Bloody_Skill", size: size)
        static let faceHiding = Icon(imageName: "Icon_Face_Hiding_Skill", size: size)
        static let faceHoly = Icon(imageName: "Icon_Face_Holy_Skill", size: size)
        static let handMagic = Icon(imageName: "Icon_Hand_Magic_Skill", size: size)
        static let heart = Icon(imageName: "Icon_Heart_Skill", size: size)
        static let intimidatingStance = Icon(imageName: "Icon_Intimidating_Stance_Skill", size: size)
        static let light = Icon(imageName: "Icon_Light_Skill", size: size)
        static let locked = Icon(imageName: "Icon_Locked_Skill", size: size)
        static let pendant = Icon(imageName: "Icon_Pendant_Skill", size: size)
        static let poison = Icon(imageName: "Icon_Poison_Skill", size: size)
        static let powerDiamond = Icon(imageName: "Icon_Power_Diamond_Skill", size: size)
        static let powerSphere = Icon(imageName: "Icon_Power_Sphere_Skill", size: size)
        static let reflect = Icon(imageName: "Icon_Reflect_Skill", size: size)
        static let scroll = Icon(imageName: "Icon_Scroll_Skill", size: size)
        static let shieldDefending = Icon(imageName: "Icon_Shield_Defending_Skill", size: size)
        static let shieldThrowing = Icon(imageName: "Icon_Shield_Throwing_Skill", size: size)
        static let skullMagic = Icon(imageName: "Icon_Skull_Magic_Skill", size: size)
        static let spellColliding = Icon(imageName: "Icon_Spell_Colliding_Skill", size: size)
        static let spellDisintegrating = Icon(imageName: "Icon_Spell_Disintegrating_Skill", size: size)
        static let spellFlame = Icon(imageName: "Icon_Spell_Flame_Skill", size: size)
        static let spellMissile = Icon(imageName: "Icon_Spell_Missile_Skill", size: size)
        static let spellSphere = Icon(imageName: "Icon_Spell_Sphere_Skill", size: size)
        static let spellTwisting = Icon(imageName: "Icon_Spell_Twisting_Skill", size: size)
        static let steal = Icon(imageName: "Icon_Steal_Skill", size: size)
        static let swordAndBow = Icon(imageName: "Icon_Sword_And_Bow_Skill", size: size)
        static let swordBloody = Icon(imageName: "Icon_Sword_Bloody_Skill", size: size)
        static let swordDashing = Icon(imageName: "Icon_Sword_Dashing_Skill", size: size)
        static let swordGrip = Icon(imageName: "Icon_Sword_Grip_Skill", size: size)
        static let swordGuarding = Icon(imageName: "Icon_Sword_Guarding_Skill", size: size)
        static let swordParrying = Icon(imageName: "Icon_Sword_Parrying_Skill", size: size)
        static let swordShining = Icon(imageName: "Icon_Sword_Shining_Skill", size: size)
        static let symbolMagic = Icon(imageName: "Icon_Symbol_Magic_Skill", size: size)
        static let target = Icon(imageName: "Icon_Target_Skill", size: size)
        static let tools = Icon(imageName: "Icon_Tools_Skill", size: size)
    }
}
