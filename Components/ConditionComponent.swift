//
//  ConditionComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/29/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to be affected by conditions.
///
class ConditionComponent: Component, TextureUser {
    
    static var textureNames: Set<String> {
        return ConditionSymbol.textureNames
    }
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a ConditionComponent must also have a NodeComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity?.component(ofType: SpriteComponent.self) else {
            fatalError("An entity with a ConditionComponent must also have a SpriteComponent")
        }
        return component
    }
    
    private var immunityComponent: ImmunityComponent {
        guard let component = entity?.component(ofType: ImmunityComponent.self) else {
            fatalError("An entity with a ConditionComponent must also have an ImmunityComponent")
        }
        return component
    }
    
    private var logComponent: LogComponent {
        guard let component = entity?.component(ofType: LogComponent.self) else {
            fatalError("An entity with a ConditionComponent must also have a LogComponent")
        }
        return component
    }
    
    private var statusBarComponent: StatusBarComponent {
        guard let component = entity?.component(ofType: StatusBarComponent.self) else {
            fatalError("An entity with a ConditionComponent must also have a StatusBarComponent")
        }
        return component
    }
    
    /// A class defining the state of a condition entry.
    ///
    private class ConditionState {
        
        /// The condition instance.
        ///
        let condition: Condition
        
        /// The elapsed time since the condition was applied.
        ///
        var elapsedTime: TimeInterval
        
        /// The number of times that the condition was applied.
        ///
        var applications: Int
        
        /// Creates a new instance from the given condition instance.
        ///
        /// - Parameter condition: The `Condition` instance.
        ///
        init(condition: Condition) {
            self.condition = condition
            elapsedTime = 0
            applications = 1
        }
    }
    
    /// The `ConditionSymbol` instance.
    ///
    private let conditionSymbol = ConditionSymbol()
    
    /// The current conditions, and how long each has been active.
    ///
    private var conditions: [String: ConditionState] = [:]
    
    /// Checks if the entity has a given condition.
    ///
    /// - Parameter condition: the `Condition` instance to check.
    /// - Returns: `true` if has the given `Condition` instance, `false` otherwise.
    ///
    func hasCondition(_ condition: Condition) -> Bool {
        return conditions[condition.identifier] != nil
    }
    
    /// Checks if the entity has a condition of the given metatype.
    ///
    /// - Parameter condition: the `Condition` instance to check.
    /// - Returns: `true` if has the given `Condition` instance, `false` otherwise.
    ///
    func hasCondition(ofType conditionType: Condition.Type) -> Bool {
        return conditions.first(where: { (arg) in type(of: arg.value.condition) == conditionType }) != nil
    }
    
    /// Applies the given condition.
    ///
    /// - Parameter condition: The condition to apply.
    /// - Returns: `true` if the new condition was successfully applied/reset, `false` otherwise.
    ///
    func applyCondition(_ condition: Condition) -> Bool {
        guard let entity = entity as? Entity,
            entity.component(ofType: HealthComponent.self)?.isDead != true
            else { return false }
        
        guard !immunityComponent.isImmuneTo(condition: condition) else {
            logComponent.writeEntry(content: "Immune", style: .emphasis)
            return false
        }
        
        let flag: Bool
        
        if let state = conditions[condition.identifier] {
            if condition.isResettable { state.elapsedTime = 0 }
            if condition.applyEffects(onEntity: entity, applicationNumber: state.applications + 1) {
                state.applications += 1
            }
            flag = true
        } else if condition.isExclusive && hasCondition(ofType: type(of: condition)) {
            flag = false
        } else if condition.applyEffects(onEntity: entity, applicationNumber: 1) {
            conditions[condition.identifier] = ConditionState(condition: condition)
            if let color = condition.color { spriteComponent.colorize(colorAnimation: color) }
            if let logText = condition.logText { logComponent.writeEntry(content: logText, style: .emphasis) }
            condition.sfx?.play(at: nodeComponent.node.position, sceneKind: .level)
            conditionSymbol.increaseSymbolCount(metatype: type(of: condition))
            flag = true
        } else {
            flag = false
        }
        
        if flag { broadcast() }
        return flag
    }
    
    /// Removes the given condition.
    ///
    /// - Parameter condition: The `Condition` instance to remove.
    ///
    func removeCondition(_ condition: Condition) {
        guard let entity = entity as? Entity else { return }
        
        if let state = conditions[condition.identifier] {
            let _ = state.condition.removeEffects(fromEntity: entity, applications: state.applications)
            conditions[condition.identifier] = nil
            conditionSymbol.decreaseSymbolCount(metatype: type(of: condition))
            broadcast()
        }
    }
    
    /// Removes all active conditions of the given type.
    ///
    /// - Parameter conditionType: The metatype of the conditions to remove.
    ///
    func removeAllConditions(ofType conditionType: Condition.Type) {
        for (_, state) in conditions where type(of: state.condition) == conditionType {
            removeCondition(state.condition)
        }
        if conditions.isEmpty { statusBarComponent.removeConditionSymbols() }
    }
    
    /// Removes all active conditions.
    ///
    func removeAllConditions() {
        for (_, state) in conditions {
            removeCondition(state.condition)
        }
        statusBarComponent.removeConditionSymbols()
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard !conditions.isEmpty, let entity = entity as? Entity else { return }
        
        for (_, state) in conditions {
            state.elapsedTime += seconds
            if let duration = state.condition.duration, duration < state.elapsedTime {
                removeCondition(state.condition)
            } else {
                state.condition.update(onEntity: entity, deltaTime: seconds)
            }
        }
        
        if let node = conditionSymbol.newNode {
            statusBarComponent.addConditionSymbols(node: node, size: conditionSymbol.size)
        } else {
            statusBarComponent.removeConditionSymbols()
        }
    }
}

/// A class that creates sprites to represent active conditions.
///
fileprivate class ConditionSymbol: TextureUser {
    
    static var textureNames: Set<String> {
        return ["Symbol_Poison", "Symbol_Curse", "Symbol_Condemn", "Symbol_DOT", "Symbol_Weaken", "Symbol_Soften",
                "Symbol_Hamper", "Symbol_Hypnotism", "Symbol_Entomb", "Symbol_Quell"]
    }
    
    /// An enum defining the names for condition symbols.
    ///
    private enum SymbolName {
        case poison, curse, condemn, dot, weaken, soften, hamper, hypnotism, entomb, quell
        
        /// The `Condition` type that the name represents.
        ///
        var metatype: Condition.Type {
            switch self {
            case .poison:
                return PoisonCondition.self
            case .curse:
                return CurseCondition.self
            case .condemn:
                return CondemnCondition.self
            case .dot:
                return DamageOverTimeCondition.self
            case .weaken:
                return WeakenCondition.self
            case .soften:
                return SoftenCondition.self
            case .hamper:
                return HamperCondition.self
            case .hypnotism:
                return HypnotismCondition.self
            case .entomb:
                return EntombCondition.self
            case .quell:
                return QuellCondition.self
            }
        }
        
        /// Retrieves the `SymbolName` that represents a given `Condition` type.
        ///
        /// - Parameter metatype: The `Condition` type for which to retrieve the name.
        /// - Returns: The `SymbolName` that represents the `Condition`, or `nil` if not representable.
        ///
        static func fromType(_ metatype: Condition.Type) -> SymbolName? {
            switch metatype {
            case is PoisonCondition.Type:
                return poison
            case is CurseCondition.Type:
                return curse
            case is CondemnCondition.Type:
                return condemn
            case is DamageOverTimeCondition.Type:
                return dot
            case is WeakenCondition.Type:
                return weaken
            case is SoftenCondition.Type:
                return soften
            case is HamperCondition.Type:
                return hamper
            case is HypnotismCondition.Type:
                return hypnotism
            case is EntombCondition.Type:
                return entomb
            case is QuellCondition.Type:
                return quell
            default:
                return nil
            }
        }
    }
    
    /// The size of a single condition symbol.
    ///
    private static let symbolSize = CGSize(width: 16.0, height: 16.0)
    
    /// The list containing the current symbol names and how many times `increaseSymbolCount(metatype:)`
    /// was called for each one.
    ///
    private var currentNames = [(name: SymbolName, count: Int)]()
    
    /// The node containing the symbol sprites for the current conditions.
    ///
    /// - Note: Every time this getter is accessed, a new node is created, which represents the
    ///   current active symbols.
    ///
    var newNode: SKNode? {
        guard !currentNames.isEmpty else { return nil }
        return makeSymbolBar(names: currentNames.map({ $0.name }))
    }
    
    /// The size of the current node.
    ///
    /// If no conditions are active, the size is zero.
    ///
    var size: CGSize {
        guard !currentNames.isEmpty else { return .zero }
        return CGSize(width: CGFloat(currentNames.count) * ConditionSymbol.symbolSize.width,
                      height: ConditionSymbol.symbolSize.height)
    }
    
    /// Makes a new sprite for the given `SymbolName`.
    ///
    /// - Parameter name: The `SymbolName` for which to create the symbol.
    /// - Returns: A sprite that represents the symbol.
    ///
    private func makeSymbol(name: SymbolName) -> SKSpriteNode {
        let image: String
        switch name {
        case .poison:
            image = "Symbol_Poison"
        case .curse:
            image = "Symbol_Curse"
        case .condemn:
            image = "Symbol_Condemn"
        case .dot:
            image = "Symbol_DOT"
        case .weaken:
            image = "Symbol_Weaken"
        case .soften:
            image = "Symbol_Soften"
        case .hamper:
            image = "Symbol_Hamper"
        case .hypnotism:
            image = "Symbol_Hypnotism"
        case .entomb:
            image = "Symbol_Entomb"
        case .quell:
            image = "Symbol_Quell"
        }
        return SKSpriteNode(texture: TextureSource.createTexture(imageNamed: image),
                            size: ConditionSymbol.symbolSize)
    }
    
    /// Makes a new node for the given list of `SymbolName`s.
    ///
    /// - Parameter names: The list of `SymbolName`s for which to create the symbol bar.
    /// - Returns: A node that represents the symbol bar, which contains all currently active symbols.
    ///
    private func makeSymbolBar(names: [SymbolName]) -> SKNode? {
        let symbols = names.compactMap { makeSymbol(name: $0) }
        guard !symbols.isEmpty else { return nil }
        
        let node = SKNode()
        let symbolWidth = ConditionSymbol.symbolSize.width
        let totalWidth = symbolWidth * CGFloat(symbols.count)
        for i in symbols.indices {
            node.addChild(symbols[i])
            symbols[i].position.x += -totalWidth / 2.0 + symbolWidth / 2.0 + CGFloat(i) * symbolWidth
        }
        return node
    }
    
    /// Increases the symbol count for the given `Condition` type.
    ///
    /// - Parameter metatype: The `Condition` type for which to increase the symbol count.
    ///
    func increaseSymbolCount(metatype: Condition.Type) {
        guard let name = SymbolName.fromType(metatype) else { return }
        
        if let index = currentNames.firstIndex(where: { $0.name == name }) {
            currentNames[index].count += 1
        } else {
            currentNames.append((name, 1))
        }
    }
    
    /// Decreases the symbol count for the given `Condition` type.
    ///
    /// - Parameter metatype: The `Condition` type for which to descrease the symbol count.
    ///
    func decreaseSymbolCount(metatype: Condition.Type) {
        guard let name = SymbolName.fromType(metatype) else { return }
        
        if let index = currentNames.firstIndex(where: { $0.name == name }) {
            if currentNames[index].count == 1 {
                currentNames.remove(at: index)
            } else {
                currentNames[index].count -= 1
            }
        }
    }
    
    /// Removes the symbol for the given `Condition` type.
    ///
    /// - Parameter metatype: The `Condition` type for which to remove the symbol.
    ///
    func removeSymbol(metatype: Condition.Type) {
        guard let name = SymbolName.fromType(metatype) else { return }
        
        if let index = currentNames.firstIndex(where: { $0.name == name }) {
            currentNames.remove(at: index)
        }
    }
    
    /// Removes all symbols.
    ///
    func removeAllSymbols() {
        currentNames = []
    }
}
