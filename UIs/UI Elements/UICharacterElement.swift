//
//  UICharacterElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/1/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays information about a character's state.
/// It includes a portrait, name and health bars, and icon slots.
///
class UICharacterElement: UIElement {
    
    /// The node that holds all the contents of the element.
    ///
    let contents: SKNode
    
    /// The portrait.
    ///
    let portrait: UIPortrait
    
    /// The name bar.
    ///
    let nameBar: UINameBar
    
    /// The health bar.
    ///
    let healthBar: UIHealthBar
    
    /// The icon slots for items.
    ///
    let itemSlots: [UIIcon]
    
    /// The icon slots for skills.
    ///
    let skillSlots: [UIIcon]
    
    /// The shortcuts for items.
    ///
    let itemShortcuts: [UIKeyboardShortcut]
    
    /// The shortcuts for skills.
    ///
    let skillShortcuts: [UIKeyboardShortcut]
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - itemEmptyIconImage: The empty icon image to use for the item slots.
    ///   - skillEmptyIconImage: The empty icon image to use for the skill slots.
    ///   - emptyPortraitImage: The empty portrait image to use.
    ///   - nameBarImage: The name bar image to use.
    ///   - healthBarImage: The health bar image to use.
    ///   - healthImage: The health image to use for the health bar.
    ///   - itemShortcutImage: The shortcut image to use for the item slots.
    ///   - skillShortcutImage: The shortcut image to use for the skill slots.
    ///   - itemCount: The amount of item slots to create.
    ///   - skillCount: The amount of skill slots to create.
    ///   - healthWidth: The width of the health bar's health.
    ///   - nameSize: An optional size for the text in the name bar. If set to `nil`,
    ///     the `nameBarImage` size is used.
    ///   - shortcutTextSize: An optional size for the shortcut text. If set to `nil`,
    ///     the size of the shortcut images are used.
    ///
    init(itemEmptyIconImage: String, skillEmptyIconImage: String, emptyPortraitImage: String,
         nameBarImage: String, healthBarImage: String, healthImage: String, itemShortcutImage: String,
         skillShortcutImage: String, itemCount: Int, skillCount: Int, healthWidth: CGFloat,
         nameSize: CGSize?, shortcutTextSize: CGSize?) {
        
        let node = SKNode()
        node.zPosition = 1
        
        let contentOffset: CGFloat = 8.0
        
        contents = SKNode()
        portrait = UIPortrait(emptyPortraitImage: emptyPortraitImage)
        nameBar = UINameBar(barImage: nameBarImage, textSize: nameSize)
        healthBar = UIHealthBar(healthWidth: healthWidth, healthImage: healthImage, barImage: healthBarImage)
        
        var itemSlots = [UIIcon]()
        for _ in 0..<itemCount {
            itemSlots.append(UIIcon(emptyIconImage: itemEmptyIconImage))
        }
        self.itemSlots = itemSlots
        
        var skillSlots = [UIIcon]()
        for _ in 0..<skillCount {
            skillSlots.append(UIIcon(emptyIconImage: skillEmptyIconImage))
        }
        self.skillSlots = skillSlots
        
        var itemShortcuts = [UIKeyboardShortcut]()
        for _ in 0..<itemCount {
            itemShortcuts.append(UIKeyboardShortcut(shortcutImage: itemShortcutImage,
                                                    maxTextSize: shortcutTextSize))
        }
        self.itemShortcuts = itemShortcuts
        
        var skillShortcuts = [UIKeyboardShortcut]()
        for _ in 0..<skillCount {
            skillShortcuts.append(UIKeyboardShortcut(shortcutImage: skillShortcutImage,
                                                     maxTextSize: shortcutTextSize))
        }
        self.skillShortcuts = skillShortcuts
        
        // Scale down shortcuts if they exceed the slots' width
        if itemShortcuts.first!.node.size.width > itemSlots.first!.node.size.width {
            let ratio = itemShortcuts.first!.node.size.width - itemSlots.first!.node.size.width
            let newSize = CGSize(width: itemSlots.first!.node.size.width,
                                 height: itemShortcuts.first!.node.size.height * ratio)
            itemShortcuts.forEach { $0.node.scale(to: newSize) }
        }
        if skillShortcuts.first!.node.size.width > skillSlots.first!.node.size.width {
            let ratio = skillShortcuts.first!.node.size.width - skillSlots.first!.node.size.width
            let newSize = CGSize(width: skillSlots.first!.node.size.width,
                                 height: skillShortcuts.first!.node.size.height * ratio)
            skillShortcuts.forEach { $0.node.scale(to: newSize) }
        }
        
        // Calculate the top size (portrait plus bars)
        let topSize = CGSize(width: portrait.node.size.width + max(nameBar.size.width, healthBar.size.width),
                             height: max(portrait.node.size.height, nameBar.size.height + healthBar.size.height))
        
        // Calculate the bottom size (slots plus shortcuts)
        let itemShortcutsHeight = itemShortcuts.first!.node.size.height
        let skillShortcutsHeight = skillShortcuts.first!.node.size.height
        let itemsSize = CGSize(width: itemSlots.first!.node.size.width * CGFloat(itemCount),
                               height: itemSlots.first!.node.size.height + itemShortcutsHeight)
        let skillsSize = CGSize(width: skillSlots.first!.node.size.width * CGFloat(skillCount),
                                height: skillSlots.first!.node.size.height + skillShortcutsHeight)
        let bottomSize = CGSize(width: max(itemsSize.width, skillsSize.width),
                                height: itemsSize.height + skillsSize.height + contentOffset * 2.0)
        
        // Position the top contents
        let barsHeight = nameBar.size.height + healthBar.size.height
        if portrait.node.size.height > barsHeight {
            portrait.node.position = CGPoint(x: portrait.node.size.width / 2.0,
                                             y: portrait.node.size.height / 2.0)
            nameBar.node.position = CGPoint(x: portrait.node.size.width + nameBar.size.width / 2.0,
                                            y: portrait.node.size.height / 2.0 + nameBar.size.height / 2.0)
            healthBar.node.position = CGPoint(x: portrait.node.size.width + healthBar.size.width / 2.0,
                                              y: portrait.node.size.height / 2.0 - healthBar.size.height / 2.0)
        } else {
            portrait.node.position = CGPoint(x: portrait.node.size.width / 2.0,
                                             y: barsHeight / 2.0)
            nameBar.node.position = CGPoint(x: portrait.node.size.width + nameBar.size.width / 2.0,
                                            y: barsHeight / 2.0 + nameBar.size.height / 2.0)
            healthBar.node.position = CGPoint(x: portrait.node.size.width + healthBar.size.width / 2.0,
                                              y: barsHeight / 2.0 - healthBar.size.height / 2.0)
        }
        if topSize.width < bottomSize.width {
            let offset = (bottomSize.width - topSize.width) / 2.0
            portrait.node.position.x += offset
            nameBar.node.position.x += offset
            healthBar.node.position.x += offset
        }
        portrait.node.position.y += bottomSize.height
        nameBar.node.position.y += bottomSize.height
        healthBar.node.position.y += bottomSize.height

        node.addChild(portrait.node)
        node.addChild(nameBar.node)
        node.addChild(healthBar.node)
        
        // Position the bottom contents
        var itemsOffset, skillsOffset: CGFloat
        if itemsSize.width > skillsSize.width {
            itemsOffset = 0
            skillsOffset = (itemsSize.width - skillsSize.width) / 2.0
        } else {
            itemsOffset = (skillsSize.width - itemsSize.width) / 2.0
            skillsOffset = 0
        }
        for i in 0..<itemCount {
            let shortcutY = itemShortcutsHeight / 2.0 + skillsSize.height + contentOffset
            let size = itemSlots[i].node.size
            let offset = max((topSize.width - bottomSize.width) / 2.0, 0) + itemsOffset
            itemSlots[i].node.position = CGPoint(x: size.width / 2.0 + offset + size.width * CGFloat(i),
                                                 y: size.height / 2.0 + itemShortcutsHeight / 2.0 + shortcutY)
            node.addChild(itemSlots[i].node)
            itemShortcuts[i].node.position = CGPoint(x: itemSlots[i].node.position.x, y: shortcutY)
            node.addChild(itemShortcuts[i].node)
        }
        for i in 0..<skillCount {
            let size = skillSlots[i].node.size
            let offset = max((topSize.width - bottomSize.width) / 2.0, 0) + skillsOffset
            skillSlots[i].node.position = CGPoint(x: size.width / 2.0 + offset + size.width * CGFloat(i),
                                                  y: size.height / 2.0 + skillShortcutsHeight)
            node.addChild(skillSlots[i].node)
            skillShortcuts[i].node.position = CGPoint(x: skillSlots[i].node.position.x, y: skillShortcutsHeight / 2.0)
            node.addChild(skillShortcuts[i].node)
        }
        
        contents.addChild(node)
        size = CGSize(width: max(topSize.width, bottomSize.width), height: topSize.height + bottomSize.height)
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}
