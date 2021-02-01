//
//  IntroProtagonist.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/2/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The `Protagonist` used in the intro.
///
class IntroProtagonist: Protagonist, PerceptionDelegate, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        let animationSet = LostLenoreAnimationSet.animationKeys
        return animationSet
    }
    
    static var textureNames: Set<String> {
        return LostLenoreAnimationSet.textureNames.union([PortraitSet.lostLenore.imageName])
    }
    
    /// The `Item` types associated with this entity.
    ///
    static let itemTypes: [Item.Type] = [RoyalSwordItem.self, HealingPotionItem.self, SilverRingItem.self,
                                         GoldPiecesItem.self]
    
    /// The flag stating whether or not the loot page was presented (it does so only once).
    ///
    private var lootPageDone: Bool = false
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = IntroProtagonistData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience, personaName: "Lenore")
        
        // StateComponent (replaces the superclass')
        addComponent(StateComponent(initialState: IntroInitialState.self,
                                    states: [(IntroInitialState(entity: self), nil),
                                             (IntroStandardState(entity: self), .standard),
                                             (IntroUseState(entity: self), .use),
                                             (IntroAttackState(entity: self), .attack),
                                             (IntroLiftState(entity: self), .lift),
                                             (IntroHurlState(entity: self), .hurl),
                                             (IntroPageState(entity: self), nil)]))
        
        // Sets `IntroInitialState` for the first intro
        setFirstIntroState()
        
        // InventoryComponent (replaces the superclass')
        let royalSword = RoyalSwordItem(level: levelOfExperience)
        let healingPotions = HealingPotionItem(quantity: 5)
        let silverRing = SilverRingItem(level: levelOfExperience)
        addComponent(InventoryComponent(capacity: 90, items: [GoldPiecesItem(quantity: 1000),
                                                              GoldPiecesItem(quantity: 1000),
                                                              GoldPiecesItem(quantity: 1000),
                                                              royalSword,
                                                              healingPotions,
                                                              silverRing]))
        
        // EquipmentComponent (replaces the superclass')
        addComponent(EquipmentComponent(items: [royalSword, healingPotions, silverRing]))
        
        // PerceptionComponent
        addComponent(PerceptionComponent(interaction: Interaction(contactGroups: [.monster, .obstacle]),
                                         radius: 256.0, delegate: self))
        
        // Make immortal
        component(ofType: HealthComponent.self)?.isImmortal = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Sets the `IntroInitialState` contents for the first intro.
    ///
    private func setFirstIntroState() {
        guard let introState = component(ofType: StateComponent.self)?.state(IntroInitialState.self) as? IntroInitialState else {
            return
        }
        
        let title = "- The Basics -"
        let text = """
        The player character must go through different dungeons, defeating monsters and amassing treasures.
        
        Pressing \
        $\(InputButton.up.firstSymbolFromMapping)$, \
        $\(InputButton.down.firstSymbolFromMapping)$ \
        $\(InputButton.left.firstSymbolFromMapping)$ or \
        $\(InputButton.right.firstSymbolFromMapping)$ moves the character around.
        
        The health bar is located at the top-left. If the health drops to zero, the character dies.
        
        The equipped items are located below the health bar. A character can have up to six items equipped. \
        Equipped items are mapped to the \
        $\(InputButton.item1.firstSymbolFromMapping)$, \
        $\(InputButton.item2.firstSymbolFromMapping)$, \
        $\(InputButton.item3.firstSymbolFromMapping)$, \
        $\(InputButton.item4.firstSymbolFromMapping)$, \
        $\(InputButton.item5.firstSymbolFromMapping)$ and \
        $\(InputButton.item6.firstSymbolFromMapping)$ keys.
        
        The skills are located below the items. A red icon with a lock means that the skill cannot be used yet. \
        Skills are mapped to the \
        $\(InputButton.skill1.firstSymbolFromMapping)$, \
        $\(InputButton.skill2.firstSymbolFromMapping)$, \
        $\(InputButton.skill3.firstSymbolFromMapping)$, \
        $\(InputButton.skill4.firstSymbolFromMapping)$ and \
        $\(InputButton.skill5.firstSymbolFromMapping)$ keys.
        
        Pressing $\(InputButton.pause.firstSymbolFromMapping)$ during gameplay will pause the game and display the \
        options menu.
        """
        introState.entries = [.label(style: .title, text: title),
                              .space(4.0),
                              .attributedLabel(text: UITextStyle.applyHighlight(text: text, mark: "$")),
                              .space(4.0),]
        introState.leftOption = nil
        introState.rightOption = "CLOSE"
    }
    
    /// Sets the `IntroState` contents for the second intro.
    ///
    private func setSecondIntroState() {
        guard let introState = component(ofType: StateComponent.self)?.state(IntroInitialState.self) as? IntroInitialState else {
            return
        }
        
        let title = "- Dungeons -"
        let text = """
        Each dungeon comprises multiple areas. All areas must be traversed to finish the dungeon.

        Dying will cause the current area to be recreated, with the character placed at the entrance. \
        Experience and loot is kept.
        
        Items can be traded with Lenore here, who often goes missing inside the dungeons. \
        Pressing the interaction button ($\(InputButton.interact.firstSymbolFromMapping)$) \
        when close to her will open a dialog.

        Pressing the interaction button when close to some objects, like barrels and vases, will cause them to
        be lifted by the character. Pressing the same button again will cause the object to be tossed at the \
        cursor location or, if a target is set, at its current position.
        
        The cat over there is a companion. Companions can be helpful in combat, if a bit erratic. They can \
        be tossed, too.
        
        Now, to the next portal.
        """
        introState.entries = [.label(style: .title, text: title),
                              .space(4.0),
                              .attributedLabel(text: UITextStyle.applyHighlight(text: text, mark: "$")),
                              .space(4.0),]
        introState.leftOption = nil
        introState.rightOption = "CLOSE"
    }
    
    func didPerceiveTarget(_ target: Entity) {
        guard let pageState = component(ofType: StateComponent.self)?.state(IntroPageState.self) as? IntroPageState else {
            return
        }
        
        let title, text: String
        switch target {
        case let enemy as IntroEnemy:
            title = "- Monsters -"
            text = """
            Monsters will try to kill the character.
            
            Items, skills and objects can be used to damage monsters. For instance, with a sword equipped in \
            the first item slot, pressing $\(InputButton.item1.firstSymbolFromMapping)$ will perform an attack.
            
            Attacks and many other actions will be performed towards the cursor location, unless a target is set.
            
            Clicking on a monster will set it as the current target (its health bar will be displayed \
            alongside the character's).
            
            Another way to select targets is through the cycle targets button \
            ($\(InputButton.cycleTargets.firstSymbolFromMapping)$).
            """
            // Remove `monster` category from perception's interaction
            if let interaction = component(ofType: PerceptionComponent.self)?.interaction {
                if interaction.contactGroups.contains(.monster) {
                    let newInteraction = Interaction(
                        contactGroups: interaction.contactGroups.subtracting([.monster]))
                    component(ofType: PerceptionComponent.self)?.interaction = newInteraction
                }
            }
            // Set the page state callback to make the enemy aware
            pageState.onClose = { enemy.makeAware() }
        case is Portal:
            title = "- Portals -"
            text = """
            Portals will lead the character to the next area.
            
            They can be activated by pressing the interaction button \
            ($\(InputButton.interact.firstSymbolFromMapping)$), as long as the character is close enough.
            
            There is no way back.
            """
            // Remove `obstacle` category from perception's interaction
            if let interaction = component(ofType: PerceptionComponent.self)?.interaction {
                if interaction.contactGroups.contains(.obstacle) {
                    let newInteraction = Interaction(
                        contactGroups: interaction.contactGroups.subtracting([.obstacle]))
                    component(ofType: PerceptionComponent.self)?.interaction = newInteraction
                }
            }
            // Update the intro state's content for the second intro
            setSecondIntroState()
        default:
            return
        }
        
        // Set the page state
        pageState.entries = [.label(style: .title, text: title),
                             .space(4.0),
                             .attributedLabel(text: UITextStyle.applyHighlight(text: text, mark: "$")),
                             .space(4.0),]
        pageState.leftOption = nil
        pageState.rightOption = "CLOSE"
        component(ofType: StateComponent.self)!.enter(stateClass: IntroPageState.self)
    }
    
    override func willRemoveFromLevel(_ level: Level) {
        component(ofType: StateComponent.self)?.enter(stateClass: IntroInitialState.self)
        super.willRemoveFromLevel(level)
    }
    
    override func didPickUp(kind: PickUpKind) {
        super.didPickUp(kind: kind)
        
        guard !lootPageDone,
            let pageState = component(ofType: StateComponent.self)?.state(IntroPageState.self) as? IntroPageState
            else { return }
        
        lootPageDone = true
        let title = "- Loot -"
        let text = """
        Monsters and some objects may drop loot when defeated/destroyed.

        Walking close to dropped loot will cause it to be picked up and added to the character's inventory.

        The inventory can be managed in the character menu ($\(InputButton.character.firstSymbolFromMapping)$).
        """
        // Set the page state
        pageState.entries = [.label(style: .title, text: title),
                             .space(4.0),
                             .attributedLabel(text: UITextStyle.applyHighlight(text: text, mark: "$")),
                             .space(4.0),]
        pageState.leftOption = nil
        pageState.rightOption = "CLOSE"
        component(ofType: StateComponent.self)!.enter(stateClass: IntroPageState.self)
    }
}

/// The `ProtagonistData` defining the data associated with the `IntroProtagonist` entity.
///
fileprivate class IntroProtagonistData: ProtagonistData {
    
    let name: String
    let progressionValues: EntityProgressionValues
    let animationSet: DirectionalAnimationSet
    let portrait: Portrait
    let extraStates: [(EntityState.Type, StateName?)]
    let skillSet: [Skill]
    let pack: Pack
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        name = "Merchant"
        progressionValues = IntroProtagonistProgressionValues.instance
        animationSet = LostLenoreAnimationSet()
        portrait = PortraitSet.lostLenore
        extraStates = []
        pack = Pack(items: [], equipment: [])
        skillSet = [UnappraisalSkill(), AttachmentSkill()]
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `IntroProtagonist` entity.
///
fileprivate class IntroProtagonistProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = IntroProtagonistProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 4, rate: 0.4),
            Ability.agility: ProgressionValue(initialValue: 4, rate: 0.4),
            Ability.intellect: ProgressionValue(initialValue: 9, rate: 0.9),
            Ability.faith: ProgressionValue(initialValue: 2, rate: 0.2)]
        
        let healthPointsValue = ProgressionValue(initialValue: 15, rate: 7.5)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: .zero)
    }
}

/// The Unappraisal skill.
///
fileprivate class UnappraisalSkill: PassiveSkill {
    
    let name: String = "Unappraisal"
    let icon: Icon = IconSet.Skill.pendant
    let cost: Int = 0
    var unlocked: Bool = true
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Vastly underestimates the value of items when buying.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {}
}

/// The Attachment skill.
///
fileprivate class AttachmentSkill: PassiveSkill {
    
    let name: String = "Attachment"
    let icon: Icon = IconSet.Skill.heart
    let cost: Int = 0
    var unlocked: Bool = true
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Vastly overestimates the value of items when selling.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {}
}
