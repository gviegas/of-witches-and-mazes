//
//  SkillComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/20/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that provides an entity with a skill set.
///
class SkillComponent: Component {
    
    /// The valid range for skill points.
    ///
    static let skillPointsRange = 0...50
    
    /// The skill set.
    ///
    private let skillSet: [Skill]
    
    /// The dictionary describing which skills have been put to wait by `triggerSkillWaitTime(_:)`, with
    /// `WaitTimeSkill` identifiers as key and remaining time as value.
    ///
    private var skillsOnWait: [ObjectIdentifier: TimeInterval]
    
    /// The number of skills in the set.
    ///
    var count: Int {
        return skillSet.count
    }
    
    /// All skills.
    ///
    var skills: [Skill] {
        return skillSet
    }
    
    /// The usable skills.
    ///
    var usableSkills: [UsableSkill] {
        return skills.compactMap { $0 as? UsableSkill }
    }
    
    /// The passive skills.
    ///
    var passiveSkills: [PassiveSkill] {
        return skills.compactMap { $0 as? PassiveSkill }
    }
    
    /// The total number of skill points awarded, not considering points spent.
    ///
    var totalPoints: Int {
        didSet {
            let lowerBound = SkillComponent.skillPointsRange.lowerBound
            let upperBound = SkillComponent.skillPointsRange.upperBound
            totalPoints = max(lowerBound, min(upperBound, totalPoints))
        }
    }
    
    /// The number of skill points remaining after computing unlocked skills.
    ///
    var currentPoints: Int {
        return skills.reduce(totalPoints) { result, skill in result - (skill.unlocked ? skill.cost : 0) }
    }
    
    /// Creates a new instance from the given skill set.
    ///
    /// - Parameters:
    ///   - skillSet: An array containing all the available skills for the entity.
    ///   - skillPoints: The amount of skill points to start with.
    ///
    init(skillSet: [Skill], skillPoints: Int) {
        self.skillSet = skillSet
        skillsOnWait = [:]
        let lowerBound = SkillComponent.skillPointsRange.lowerBound
        let upperBound = SkillComponent.skillPointsRange.upperBound
        totalPoints = max(lowerBound, min(upperBound, skillPoints))
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard !skillsOnWait.isEmpty else { return }
        
        skillsOnWait.forEach {
            skillsOnWait[$0.key]! -= seconds
            if skillsOnWait[$0.key]! <= 0 { skillsOnWait[$0.key] = nil }
        }
    }
    
    /// Retrieves a skill of the given class type from the skill set.
    ///
    /// - Parameter skillClass: The class type of the skill to retrieve.
    /// - Returns: The first skill in the set that conforms to the given type, or `nil`
    ///   if the set does not contain a skill of this type.
    ///
    func skillOfClass(_ skillClass: Skill.Type) -> Skill? {
        return skillSet.first { type(of: $0) == skillClass }
    }
    
    /// Triggers the wait time of the given skill.
    ///
    /// If the skill is currently on wait time, calling this method has no effect.
    ///
    /// - Parameter skill: The `WaitTimeSkill` instance for which to trigger wait time.
    ///
    func triggerSkillWaitTime(_ skill: WaitTimeSkill) {
        guard skills.contains(where: { $0 === skill }) else { return }
        
        let id = ObjectIdentifier(skill)
        if skillsOnWait[id] == nil { skillsOnWait[id] = skill.waitTime }
    }
    
    /// Checks whether or not the given skill is on wait time.
    ///
    /// - Parameter skill: The `WaitTimeSkill` instance to check.
    /// - Returns: A `(Bool, TimeInterval?)` where the first value states whether or the skill is
    ///   on wait time, and the second value holds the remaining time on wait.
    ///
    func isSkillOnWaitTime(_ skill: WaitTimeSkill) -> (isOnWait: Bool, remainingTime: TimeInterval?) {
        let remainingTime = skillsOnWait[ObjectIdentifier(skill)]
        return (remainingTime != nil, remainingTime)
    }
    
    /// Informs the component that one of the skills in the set was modified.
    ///
    /// - Parameter skill: The `Skill` instance that was modified.
    ///
    func didChangeSkill(_ skill: Skill) {
        broadcast()
    }
    
    override func didAddToEntity() {
        guard let entity = entity as? Entity else { return }
        
        for skill in passiveSkills where skill.unlocked {
            skill.didUnlock(onEntity: entity)
        }
    }
}
