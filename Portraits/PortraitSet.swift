//
//  PortraitSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A structure defining the set of all available portraits.
///
struct PortraitSet {
    
    /// The dimensions of the portraits.
    ///
    static let size = CGSize(width: 48.0, height: 48.0)
    
    /// The Question portrait, for portrait-less things.
    ///
    static let question = Portrait(imageName: "Portrait_Question", size: size, canFlip: false)
    
    /// The portraits used by protagonists.
    ///
    static let fighter = Portrait(imageName: "Portrait_Fighter", size: size, canFlip: true)
    static let rogue = Portrait(imageName: "Portrait_Rogue", size: size, canFlip: true)
    static let wraith = Portrait(imageName: "Portrait_Wraith", size: size, canFlip: true)
    static let wizard = Portrait(imageName: "Portrait_Wizard", size: size, canFlip: true)
    static let cleric = Portrait(imageName: "Portrait_Cleric", size: size, canFlip: true)
    
    /// The portraits used by NPCs.
    ///
    static let lostLenore = Portrait(imageName: "Portrait_Lost_Lenore", size: size, canFlip: true)
    
    /// The portraits used by companions.
    ///
    static let feline = Portrait(imageName: "Portrait_Feline", size: size, canFlip: false)
    static let hound = Portrait(imageName: "Portrait_Hound", size: size, canFlip: true)
    
    /// The portraits used by monsters.
    ///
    static let aberration = Portrait(imageName: "Portrait_Aberration", size: size, canFlip: false)
    static let acolyte = Portrait(imageName: "Portrait_Acolyte", size: size, canFlip: true)
    static let archpriestess = Portrait(imageName: "Portrait_Archpriestess", size: size, canFlip: false)
    static let assassin = Portrait(imageName: "Portrait_Assassin", size: size, canFlip: true)
    static let azollyan = Portrait(imageName: "Portrait_Azollyan", size: size, canFlip: true)
    static let bat = Portrait(imageName: "Portrait_Bat", size: size, canFlip: true)
    static let beetle = Portrait(imageName: "Portrait_Beetle", size: size, canFlip: true)
    static let chafer = Portrait(imageName: "Portrait_Chafer", size: size, canFlip: false)
    static let creeper = Portrait(imageName: "Portrait_Creeper", size: size, canFlip: false)
    static let deathCap = Portrait(imageName: "Portrait_Death_Cap", size: size, canFlip: true)
    static let defiler = Portrait(imageName: "Portrait_Defiler", size: size, canFlip: true)
    static let desecrator = Portrait(imageName: "Portrait_Desecrator", size: size, canFlip: false)
    static let destroyingAngel = Portrait(imageName: "Portrait_Destroying_Angel", size: size, canFlip: false)
    static let enchantress = Portrait(imageName: "Portrait_Enchantress", size: size, canFlip: true)
    static let fairy = Portrait(imageName: "Portrait_Fairy", size: size, canFlip: true)
    static let feral = Portrait(imageName: "Portrait_Feral", size: size, canFlip: true)
    static let feralon = Portrait(imageName: "Portrait_Feralon", size: size, canFlip: true)
    static let flightlessMenace = Portrait(imageName: "Portrait_Flightless_Menace", size: size, canFlip: true)
    static let gelatinousCube = Portrait(imageName: "Portrait_Gelatinous_Cube", size: size, canFlip: false)
    static let gigas = Portrait(imageName: "Portrait_Gigas", size: size, canFlip: true)
    static let grotesque = Portrait(imageName: "Portrait_Grotesque", size: size, canFlip: true)
    static let hellHound = Portrait(imageName: "Portrait_Hell_Hound", size: size, canFlip: false)
    static let hermit = Portrait(imageName: "Portrait_Hermit", size: size, canFlip: true)
    static let ignisFatuus = Portrait(imageName: "Portrait_Ignis_Fatuus", size: size, canFlip: false)
    static let mermaid = Portrait(imageName: "Portrait_Mermaid", size: size, canFlip: true)
    static let paladin = Portrait(imageName: "Portrait_Paladin", size: size, canFlip: true)
    static let plagueRat = Portrait(imageName: "Portrait_Plague_Rat", size: size, canFlip: true)
    static let rat = Portrait(imageName: "Portrait_Rat", size: size, canFlip: true)
    static let sorcerer = Portrait(imageName: "Portrait_Sorcerer", size: size, canFlip: true)
    static let spectre = Portrait(imageName: "Portrait_Spectre", size: size, canFlip: true)
    static let theraxyan = Portrait(imageName: "Portrait_Theraxyan", size: size, canFlip: true)
    static let undine = Portrait(imageName: "Portrait_Undine", size: size, canFlip: false)
    static let vermin = Portrait(imageName: "Portrait_Vermin", size: size, canFlip: true)
    static let wanderer = Portrait(imageName: "Portrait_Wanderer", size: size, canFlip: false)
    static let warlock = Portrait(imageName: "Portrait_Warlock", size: size, canFlip: false)
    static let willOTheWisp = Portrait(imageName: "Portrait_Will-o'-the-wisp", size: size, canFlip: false)
    static let witch = Portrait(imageName: "Portrait_Witch", size: size, canFlip: false)
}
