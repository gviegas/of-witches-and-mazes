//
//  IntimidationComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/30/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

/// A component that enables an entity to intimidate and/or become intimidated, causing vulnerability.
///
class IntimidationComponent: Component {
    
    private var vulnerabilityComponent: VulnerabilityComponent {
        guard let component = entity?.component(ofType: VulnerabilityComponent.self) else {
            fatalError("An entity with an IntimidationComponent must also have a VulnerabilityComponent")
        }
        return component
    }
    
    /// The private backing for the `isIntimidated` getter.
    ///
    private var intimidated = false
    
    /// The flag stating whether the entity can intimidate others.
    ///
    var canIntimidate: Bool = false
    
    /// The flag stating whether the entity can be intimidated by others.
    ///
    var canBeIntimidated: Bool = true {
        didSet {
            if !canBeIntimidated && intimidated { cancelIntimidation() }
        }
    }
    
    /// The flag stating whether the entity is intimidated.
    ///
    var isIntimidated: Bool { return intimidated }
    
    /// Intimidates the given entity.
    ///
    /// - Parameter target: The entity to intimidate.
    /// - Returns: `true` if the target could be intimidated, `false` if the component's entity cannot
    ///   intimidate, the target cannot be intimidated or is already intimidated.
    ///
    @discardableResult
    func intimidate(target: Entity) -> Bool {
        guard canIntimidate,
            let targetIntimidationComponent = target.component(ofType: IntimidationComponent.self),
            targetIntimidationComponent.canBeIntimidated
            else { return false }
        
        return targetIntimidationComponent.becomeIntimidated()
    }
    
    /// Becomes intimidated.
    ///
    /// - Returns: `true` if the target could become intimidated, `false` if it cannot be intimidated or
    ///   is already intimidated.
    ///
    func becomeIntimidated() -> Bool {
        guard !intimidated, canBeIntimidated else { return false }
        vulnerabilityComponent.increaseVulnerability()
        intimidated = true
        return true
    }
    
    /// Cancels intimidation from itself.
    ///
    func cancelIntimidation() {
        guard intimidated else { return }
        vulnerabilityComponent.decreaseVulnerability()
        intimidated = false
    }
}
