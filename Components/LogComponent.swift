//
//  LogComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/1/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that provides an entity with a log of events, which is displayed as floating
/// text on the entity's node.
///
class LogComponent: Component {
    
    /// A class that stores the state of a log entry under update.
    ///
    private class LogEntry {
        
        /// The `UIText` that represents the label being updated.
        ///
        var label: UIText
        
        /// The time spent being updated.
        ///
        var elapsedTime: TimeInterval = 0

        /// Creates a new instance from the given text label.
        ///
        /// - Parameter label: The `UIText` that the state represents.
        ///
        init(label: UIText) {
            self.label = label
        }
    }
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a LogComponent must also have a NodeComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity?.component(ofType: SpriteComponent.self) else {
            fatalError("An entity with a LogComponent must also have a SpriteComponent")
        }
        return component
    }
    
    /// The minimum delay between the presentation of multiple entries.
    ///
    private static let displayInterval: TimeInterval = 0.15
    
    /// The action to run on each entry.
    ///
    private static let action: SKAction = .sequence([.fadeIn(withDuration: 0.1),
                                                     .move(by: CGVector(dx: 0, dy: 20.0), duration: 0.4),
                                                     .fadeOut(withDuration: 1.0)])
    
    /// The duration of the action.
    ///
    private static var actionTime: TimeInterval {
        return action.duration
    }
    
    /// The parent node of the entries.
    ///
    private let node: SKNode
    
    /// The current log entries being displayed.
    ///
    private var entries: [LogEntry]
    
    /// The log entries waiting to be displayed.
    ///
    private var queuedEntries: [LogEntry]
    
    /// The elapsed time since the last entry was displayed.
    ///
    private var lastDisplayTime: TimeInterval
    
    /// Creates a new instance.
    ///
    override init() {
        node = SKNode()
        node.zPosition = DepthLayer.decorators.upperBound
        entries = []
        queuedEntries = []
        lastDisplayTime = 0
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Writes a new entry to the log, which is presented immeditely.
    ///
    /// - Parameters:
    ///   - content: The content of the entry.
    ///   - style: The `UITextStyle` for the entry label.
    ///
    func writeEntry(content: String, style: UITextStyle) {
        let entry = LogEntry(label: UIText(maxWidth: 128.0, style: style, text: content))
        entry.label.node.alpha = 0
        entry.label.node.run(LogComponent.action)
        queuedEntries.append(entry)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        lastDisplayTime += seconds
        
        if !entries.isEmpty {
            var i = 0
            repeat {
                if entries[i].elapsedTime >= LogComponent.actionTime {
                    entries[i].label.node.removeFromParent()
                    entries.remove(at: i)
                } else {
                    entries[i].elapsedTime += seconds
                    i += 1
                }
            } while i < entries.count
        }
        
        guard lastDisplayTime >= LogComponent.displayInterval, !queuedEntries.isEmpty else { return }
        
        let entry = queuedEntries.removeFirst() // Note: O(n)
        node.addChild(entry.label.node)
        entries.append(entry)
        lastDisplayTime = 0
    }
    
    /// Attaches the log node to the entity's node.
    ///
    /// If the log node is already attached, this method has no effect.
    ///
    func attach() {
        guard node.parent == nil else { return }
        nodeComponent.node.addChild(node)
    }
    
    /// Detaches the log node from the entity's node.
    ///
    /// If the log node is not attached, this method has no effect.
    ///
    func detach() {
        guard node.parent != nil else { return }
        
        node.removeAllChildren()
        node.removeFromParent()
        entries = []
        queuedEntries = []
    }
    
    override func didAddToEntity() {
        node.entity = entity
        attach()
    }
    
    override func willRemoveFromEntity() {
        node.entity = nil
        detach()
    }
}
