//
//  Monster.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/10/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A protocol that defines the data associated with a `Monster` instance, used to create
/// its components.
///
protocol MonsterData {
    
    /// The entity name, expected to be unique.
    ///
    var name: String { get }
    
    /// The size.
    ///
    var size: CGSize { get }
    
    /// The speed.
    ///
    var speed: MovementSpeed { get }
    
    /// The `PhysicsShape`.
    ///
    var physicsShape: PhysicsShape { get }
    
    /// The perception radius.
    ///
    var perceptionRadius: PerceptionRadius { get }
    
    /// The maximum distance from a target before disengaging.
    ///
    var maxDistance: TargetDistance { get }
    
    /// The progression values.
    ///
    var progressionValues: EntityProgressionValues { get }
    
    /// The `DirectionalAnimationSet`.
    ///
    var animationSet: DirectionalAnimationSet { get }
    
    /// The portrait.
    ///
    var portrait: Portrait { get }
    
    /// The size and file name of the shadow image.
    ///
    var shadow: (size: CGSize, image: String)? { get }
    
    /// The sound and volubleness of the entity's voice.
    ///
    var voice: (sound: SoundFX, volubleness: VoiceComponent.Volubleness)? { get }
}

extension MonsterData {
    
    var perceptionRadius: PerceptionRadius {
        return .average
    }
    
    var maxDistance: TargetDistance {
        return .medium
    }
}

/// The `Monster` entity.
///
class Monster: Entity, HealthDelegate, PerceptionDelegate, CombatResponder {
    
    /// Creates a new instance from the given data and level.
    ///
    /// - Parameters:
    ///   - data: The `MonsterData` associated with the entity.
    ///   - levelOfExperience: The entity's level of experience.
    ///
    init(data: MonsterData, levelOfExperience: Int) {
        super.init(name: data.name)
        
        // NodeComponent
        addComponent(NodeComponent())
        
        // CursorResponderComponent
        addComponent(CursorResponderComponent(size: data.size))
        
        // SpriteComponent
        addComponent(SpriteComponent(size: data.size, animationSet: data.animationSet))
        
        // MovementComponent
        addComponent(MovementComponent(baseSpeed: data.speed.numericValue))
        
        // DirectionComponent
        let direction = [Direction.north, Direction.south, Direction.east, Direction.west].randomElement()!
        addComponent(DirectionComponent(direction: direction))
        
        // PhysicsComponent
        addComponent(PhysicsComponent(physicsShape: data.physicsShape, interaction: Interaction.monster))
        
        // DepthComponent
        addComponent(DepthComponent())
        
        // PortraitComponent
        addComponent(PortraitComponent(portrait: data.portrait))
        
        // HealthComponent
        addComponent(HealthComponent(baseHP: data.progressionValues.healthPointsValue.initialValue, delegate: self))
        
        // AbilityComponent
        addComponent(AbilityComponent(abilities: data.progressionValues.abilityValues.mapValues { $0.initialValue } ))
        
        // DamageAdjustmentComponent
        addComponent(DamageAdjustmentComponent())
        
        // CriticalHitComponent
        addComponent(CriticalHitComponent())
        
        // DefenseComponent
        addComponent(DefenseComponent())
        
        // ResistanceComponent
        addComponent(ResistanceComponent())
        
        // MitigationComponent
        addComponent(MitigationComponent())
        
        // QuellComponent
        addComponent(QuellComponent())
        
        // PerceptionComponent
        addComponent(PerceptionComponent(interaction: Interaction(contactGroups: [.protagonist, .companion]),
                                         radius: data.perceptionRadius.radiusValue, delegate: self))
        
        // TargetComponent
        addComponent(TargetComponent(source: nil, maxDistance: data.maxDistance.rawValue))
        
        // StatusBarComponent
        addComponent(StatusBarComponent(hidden: true))
        
        // SpeechComponent
        addComponent(SpeechComponent())
        
        // ImmunityComponent
        addComponent(ImmunityComponent())
        
        // ConditionComponent
        addComponent(ConditionComponent())
        
        // VulnerabilityComponent
        addComponent(VulnerabilityComponent())
        
        // IntimidationComponent
        addComponent(IntimidationComponent())
        
        // LogComponent
        addComponent(LogComponent())
        
        // ProgressionComponent
        addComponent(ProgressionComponent(values: data.progressionValues, levelOfExperience: levelOfExperience))
        
        // GroupComponent
        addComponent(GroupComponent(group: .antagonist))
        
        if let shadow = data.shadow {
            // ShadowComponent
            addComponent(ShadowComponent(size: shadow.size, imageName: shadow.image))
        }
        
        if let voice = data.voice {
            // VoiceComponent
            addComponent(VoiceComponent(voice: voice.sound, volubleness: voice.volubleness))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didAddToLevel(_ level: Level) {
        super.didAddToLevel(level)
        
        component(ofType: StateComponent.self)?.enterInitialState()
        component(ofType: SpriteComponent.self)?.animate(name: .idle)
    }
    
    override func willRemoveFromLevel(_ level: Level) {
        super.willRemoveFromLevel(level)
        
        component(ofType: NodeComponent.self)?.node.removeFromParent()
        willRemoveFromGame()
    }
    
    func didSufferDamage(amount: Int, source: Entity?) {
        component(ofType: SpriteComponent.self)?.colorize(colorAnimation: .hit)
        
        if let state = component(ofType: StateComponent.self)?.currentState as? MonsterQuelledState {
            state.didSufferDamage()
        }
    }
    
    func didRestoreHP(amount: Int, source: Entity?) {
        
    }
    
    func didDie(source: Entity?) {
        component(ofType: StateComponent.self)?.enter(stateClass: MonsterDeathState.self)
        if Game.target === self { component(ofType: CursorResponderComponent.self)?.cursorUnselected() }
    }
    
    func didPerceiveTarget(_ target: Entity) {
        guard let stateComponent = component(ofType: StateComponent.self) else { return }
        guard stateComponent.canEnter(stateClass: MonsterChaseState.self) else { return }
        
        component(ofType: TargetComponent.self)?.source = target
        component(ofType: PerceptionComponent.self)?.detach()
        component(ofType: VoiceComponent.self)?.utterByChance()
        stateComponent.enter(stateClass: MonsterChaseState.self)
    }
    
    func didReceiveHostileAction(from source: Entity?, outcome: CombatOutcome) {
        guard let targetComponent = component(ofType: TargetComponent.self) else { return }
        guard let groupComponent = component(ofType: GroupComponent.self) else { return }
        guard let stateComponent = component(ofType: StateComponent.self) else { return }
        
        if let source = source, source !== targetComponent.source, groupComponent.isHostile(towards: source) {
            guard targetComponent.source == nil || Double.random(in: 0...1.0) > 0.667 else { return }
            targetComponent.source = source
            stateComponent.enter(stateClass: MonsterChaseState.self)
        } else if source == nil, let protagonist = Game.protagonist {
            targetComponent.source = protagonist
            stateComponent.enter(stateClass: MonsterChaseState.self)
        }
    }
    
    func didReceiveFriendlyAction(from source: Entity?, outcome: CombatOutcome) {
        
    }
}
