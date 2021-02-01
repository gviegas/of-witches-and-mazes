//
//  ProgressionComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/8/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to make progression, increasing in power.
///
class ProgressionComponent: Component {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a ProgressionComponent must also have a NodeComponent")
        }
        return component
    }
    
    /// The progression values.
    ///
    private let values: EntityProgressionValues
    
    /// The private backing for the `levelOfExperience` getter.
    ///
    private var _levelOfExperience: Int {
        didSet { broadcast() }
    }
    
    /// The private backing for the `experience` getter.
    ///
    private var _experience: Int
    
    /// The entity's current level of experience.
    ///
    var levelOfExperience: Int {
        return _levelOfExperience
    }
    
    /// The total experience gained by the entity.
    ///
    var experience: Int {
        return _experience
    }
    
    /// The difficult grade of the entity, used as a multiplier when calculating the amount of
    /// experience awarded by the entity.
    ///
    var grade = 1.0
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - values: The `EntityProgressionValues` instance defining how to make progression for the entity.
    ///   - levelOfExperience: The level of experience to set.
    ///
    init(values: EntityProgressionValues, levelOfExperience: Int) {
        assert(EntityProgression.levelRange.contains(levelOfExperience))
        
        self.values = values
        self._levelOfExperience = levelOfExperience
        self._experience = 0
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didAddToEntity() {
        guard let entity = entity as? Entity else { return }
        EntityProgression.toLevel(levelOfExperience, values: values, entity: entity)
    }
    
    /// Gains the given amount of experience.
    ///
    /// - Parameter xp: The amount of experience to gain.
    ///
    func gainXP(_ xp: Int) {
        guard levelOfExperience < EntityProgression.levelRange.upperBound,
            let entity = entity as? Entity
            else { return }
        
        var totalXP = _experience + xp
        var requiredXP = EntityProgression.requiredXPForLevel(_levelOfExperience + 1)
        
        if totalXP >= requiredXP {
            _levelOfExperience += 1
            EntityProgression.toLevel(_levelOfExperience, values: values, entity: entity)
            totalXP -= requiredXP
            requiredXP = EntityProgression.requiredXPForLevel(_levelOfExperience + 1)
            if totalXP >= requiredXP {
                // No more than one level per xp reward
                totalXP = requiredXP - 1
            }
            
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "Reached Level \(_levelOfExperience)!")
                scene.presentNote(note)
                SoundFXSet.FX.improving.play(at: nil, sceneKind: .level)
            }
        }
        
        _experience = totalXP
        
        entity.component(ofType: LogComponent.self)?.writeEntry(content: "XP: \(xp)", style: .xp)
    }
}
