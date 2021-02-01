//
//  Companion.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/12/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A protocol that defines the data associated with a `Companion` instance, used to create
/// its components.
///
protocol CompanionData {
    
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

extension CompanionData {
    
    var size: CGSize {
        return CGSize(width: 64.0, height: 64.0)
    }
    
    var speed: MovementSpeed {
        return .controllable
    }
    
    var physicsShape: PhysicsShape {
        return PhysicsShape.rectangle(size: CGSize(width: 24.0, height: 24.0), center: CGPoint(x: 0, y: -20.0))
    }
    
    var perceptionRadius: PerceptionRadius {
        return .farAway
    }
    
    var maxDistance: TargetDistance {
        return .medium
    }
    
    var shadow: (size: CGSize, image: String)? {
        return (CGSize(width: 24.0, height: 16.0), "Shadow")
    }
}

/// The `Companion` entity.
///
class Companion: Entity, HealthDelegate, PerceptionDelegate, CombatResponder {
    
    /// Creates a new instance from the given data and level.
    ///
    /// - Parameters:
    ///   - data: The `CompanionData` associated with the entity.
    ///   - levelOfExperience: The entity's level of experience.
    ///
    init(data: CompanionData, levelOfExperience: Int) {
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
        addComponent(PhysicsComponent(physicsShape: data.physicsShape, interaction: Interaction.companion))
        
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
        addComponent(PerceptionComponent(interaction: Interaction(contactGroups: [.monster]),
                                         radius: data.perceptionRadius.radiusValue, delegate: self))
        
        // TargetComponent
        addComponent(TargetComponent(source: nil, maxDistance: data.maxDistance.rawValue))
        
        // CompanionComponent
        addComponent(CompanionComponent())
        
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
        addComponent(GroupComponent(group: .protagonist))
        
        if let shadow = data.shadow {
            // ShadowComponent
            addComponent(ShadowComponent(size: shadow.size, imageName: shadow.image))
        }
        
        if let voice = data.voice {
            // VoiceComponent
            addComponent(VoiceComponent(voice: voice.sound, volubleness: voice.volubleness))
        }
        
        // StateComponent
        addComponent(StateComponent(initialState: CompanionInitialState.self,
                                    states: [(CompanionInitialState(entity: self), nil),
                                             (CompanionStandardState(entity: self), .standard),
                                             (CompanionDeathState(entity: self), .death),
                                             (CompanionChaseState(entity: self), nil),
                                             (CompanionAttackState(entity: self), .attack),
                                             (CompanionFollowState(entity: self), nil),
                                             (CompanionQuelledState(entity: self), .quelled),
                                             (CompanionLiftedState(entity: self), .lifted),
                                             (CompanionHurledState(entity: self), .hurled)]))
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
        // ToDo: Consider making the companion able to survive between levels instead
        willRemoveFromGame()
    }
    
    func didSufferDamage(amount: Int, source: Entity?) {
        component(ofType: SpriteComponent.self)?.colorize(colorAnimation: .hit)
        
        if let state = component(ofType: StateComponent.self)?.currentState as? CompanionQuelledState {
            state.didSufferDamage()
        }
    }
    
    func didRestoreHP(amount: Int, source: Entity?) {
        
    }
    
    func didDie(source: Entity?) {
        component(ofType: StateComponent.self)?.enter(stateClass: CompanionDeathState.self)
        if Game.target === self { component(ofType: CursorResponderComponent.self)?.cursorUnselected() }
        if Game.subject === self {component(ofType: InteractionComponent.self)?.willRemoveCurrent() }
    }
    
    func didPerceiveTarget(_ target: Entity) {
        guard let stateComponent = component(ofType: StateComponent.self) else { return }
        guard stateComponent.canEnter(stateClass: CompanionChaseState.self) else { return }
        
        component(ofType: TargetComponent.self)?.source = target
        component(ofType: PerceptionComponent.self)?.detach()
        component(ofType: VoiceComponent.self)?.utterByChance()
        stateComponent.enter(stateClass: CompanionChaseState.self)
    }
    
    func didReceiveHostileAction(from source: Entity?, outcome: CombatOutcome) {
        guard let targetComponent = component(ofType: TargetComponent.self) else { return }
        guard let groupComponent = component(ofType: GroupComponent.self) else { return }
        guard let stateComponent = component(ofType: StateComponent.self) else { return }
        
        if let source = source, source !== targetComponent.source, groupComponent.isHostile(towards: source) {
            guard targetComponent.source == nil || Double.random(in: 0...1.0) > 0.667 else { return }
            targetComponent.source = source
            stateComponent.enter(stateClass: CompanionChaseState.self)
        }
    }
    
    func didReceiveFriendlyAction(from source: Entity?, outcome: CombatOutcome) {
        
    }
}
