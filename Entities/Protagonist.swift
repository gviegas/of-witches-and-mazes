//
//  Protagonist.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/10/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A protocol that defines the data associated with a `Protagonist` instance, used to create
/// its components.
///
protocol ProtagonistData {
    
    /// The name of the entity, expected to be unique.
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
    
    /// The reference `PhysicsShape`.
    ///
    var referenceShape: PhysicsShape { get }
    
    /// The pick up radius.
    ///
    var pickUpRadius: CGFloat { get }
    
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
    var shadow: (size: CGSize, image: String) { get }
    
    /// The list of additional state class types to include alongside the basic protagonist states.
    ///
    var extraStates: [(EntityState.Type, StateName?)] { get }
    
    /// The skill set.
    ///
    var skillSet: [Skill] { get }
    
    /// The pack.
    ///
    var pack: Pack { get }
}

extension ProtagonistData {
    
    var size: CGSize {
        return CGSize(width: 64.0, height: 64.0)
    }
    
    var speed: MovementSpeed {
        return .controllable
    }
    
    var physicsShape: PhysicsShape {
        return .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
    }
    
    var referenceShape: PhysicsShape {
        return .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
    }
    
    var pickUpRadius: CGFloat {
        return 48.0
    }
    
    var maxDistance: TargetDistance {
        return .long
    }
    
    var shadow: (size: CGSize, image: String) {
        return (CGSize(width: 24.0, height: 16.0), "Shadow")
    }
}

/// The `Protagonist` entity.
///
class Protagonist: Entity, HealthDelegate, PickUpDelegate {

    /// Creates a new instance from the given data, level and persona.
    ///
    /// - Parameters:
    ///   - data: The `ProtagonistData` associated with the entity.
    ///   - levelOfExperience: The entity's level of experience.
    ///   - personaName: The name to set for the persona component.
    ///
    init(data: ProtagonistData, levelOfExperience: Int, personaName: String) {
        super.init(name: data.name)
        
        // NodeComponent
        addComponent(NodeComponent())
        
        // SpriteComponent
        addComponent(SpriteComponent(size: data.size, animationSet: data.animationSet))
        
        // MovementComponent
        addComponent(MovementComponent(baseSpeed: data.speed.numericValue))
        
        // DirectionComponent
        addComponent(DirectionComponent(direction: .south))
        
        // PhysicsComponent
        addComponent(PhysicsComponent(physicsShape: data.physicsShape, interaction: Interaction.protagonist))
        
        // DepthComponent
        addComponent(DepthComponent())
        
        // AttackComponent
        addComponent(AttackComponent(interaction: Interaction.protagonistEffect, referenceShape: data.referenceShape))

        // HealthComponent
        addComponent(HealthComponent(baseHP: data.progressionValues.healthPointsValue.initialValue, delegate: self))
        
        // AbilityComponent
        addComponent(AbilityComponent(abilities: data.progressionValues.abilityValues.mapValues { $0.initialValue }))
        
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
        
        // BarrierComponent
        addComponent(BarrierComponent())
        
        // QuellComponent
        addComponent(QuellComponent())
        
        // CastComponent
        addComponent(CastComponent())
        
        // SubjectComponent
        addComponent(SubjectComponent())
        
        // TargetComponent
        addComponent(TargetComponent(source: nil, maxDistance: data.maxDistance.rawValue))
        
        // ConcealmentComponent
        addComponent(ConcealmentComponent())
        
        // CompanionComponent
        addComponent(CompanionComponent())
        
        // PickUpComponent
        addComponent(PickUpComponent(interaction: Interaction(contactGroups: [.loot]),
                                     radius: data.pickUpRadius, delegate: self))
        
        // LiftComponent
        addComponent(LiftComponent(hurlInteraction: .protagonistEffectOnObstacle))
        
        // PortraitComponent
        addComponent(PortraitComponent(portrait: data.portrait))
        
        // TouchComponent
        addComponent(TouchComponent())
        
        // InfluenceComponent
        addComponent(InfluenceComponent())

        // ThrowingComponent
        addComponent(ThrowingComponent())
        
        // MissileComponent
        addComponent(MissileComponent(interaction: Interaction.protagonistEffectOnObstacle))
        
        // BlastComponent
        addComponent(BlastComponent(interaction: Interaction.protagonistEffect))
        
        // RayComponent
        addComponent(RayComponent(interaction: Interaction.protagonistEffect))
        
        // ShadowComponent
        addComponent(ShadowComponent(size: data.shadow.size, imageName: data.shadow.image))
        
        // ActionComponent
        addComponent(ActionComponent())
        
        // ImmunityComponent
        addComponent(ImmunityComponent())
        
        // StatusBarComponent
        addComponent(StatusBarComponent(hidden: true))
        
        // ConditionComponent
        addComponent(ConditionComponent())
        
        // VulnerabilityComponent
        addComponent(VulnerabilityComponent())
        
        // IntimidationComponent
        addComponent(IntimidationComponent())
        
        // LogComponent
        addComponent(LogComponent())
        
        // PersonaComponent
        addComponent(PersonaComponent(personaName: personaName))
        
        // SpeechComponent
        addComponent(SpeechComponent())
        
        // ProgressionComponent
        addComponent(ProgressionComponent(values: data.progressionValues, levelOfExperience: levelOfExperience))
        
        // StageComponent
        let stageInfo = StageInfo(run: 1, completion: [], currentLevel: .nightGlade, currentSublevel: 1)
        addComponent(StageComponent(stageInfo: stageInfo))
        
        // StateComponent
        let states: [(GKState, StateName?)] = [(ProtagonistInitialState(entity: self), nil),
                                               (ProtagonistStandardState(entity: self), .standard),
                                               (ProtagonistLiftState(entity: self), .lift),
                                               (ProtagonistHurlState(entity: self), .hurl),
                                               (ProtagonistAttackState(entity: self), .attack),
                                               (ProtagonistShotState(entity: self), .shot),
                                               (ProtagonistThrowState(entity: self), .toss),
                                               (ProtagonistUseState(entity: self), .use),
                                               (ProtagonistCastState(entity: self), .cast),
                                               (ProtagonistQuelledState(entity: self), .quelled),
                                               (ProtagonistDeathState(entity: self), .death),
                                               (DialogState(entity: self), nil),
                                               (GameOverState(entity: self), nil)]
        
        let extraStates: [(GKState, StateName?)] = data.extraStates.map { ($0.0.init(entity: self), $0.1) }
        
        addComponent(StateComponent(initialState: ProtagonistInitialState.self, states: states + extraStates))
        
        // SkillComponent
        let points = data.progressionValues.skillPointsValue?.forLevel(levelOfExperience) ?? 0
        addComponent(SkillComponent(skillSet: data.skillSet, skillPoints: points))
        
        // InventoryComponent
        addComponent(InventoryComponent(capacity: 90, items: data.pack.items))
        
        // EquipmentComponent
        addComponent(EquipmentComponent(items: data.pack.equipment))
        
        // GroupComponent
        addComponent(GroupComponent(group: .protagonist))
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
    }
    
    func didSufferDamage(amount: Int, source: Entity?) {
        component(ofType: SpriteComponent.self)?.colorize(colorAnimation: .hit)
        
        if let state = component(ofType: StateComponent.self)?.currentState as? ProtagonistQuelledState {
            state.didSufferDamage()
        }
    }
    
    func didRestoreHP(amount: Int, source: Entity?) {
        
    }
    
    func didDie(source: Entity?) {
        component(ofType: StateComponent.self)?.enter(stateClass: ProtagonistDeathState.self)
        component(ofType: SubjectComponent.self)?.nullifyCurrent()
    }
    
    func didPickUp(kind: PickUpKind) {

    }
}
