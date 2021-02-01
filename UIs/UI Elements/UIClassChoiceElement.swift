//
//  UIClassChoiceElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays a set of class choices for the protagonist.
///
class UIClassChoiceElement: UIElement {
    
    /// A class that defines an entry in the element for a choice of class.
    ///
    class ClassEntry {
        
        /// The `UIPortrait` that holds the portrait of the class.
        ///
        let portrait: UIPortrait
        
        /// The `UIText` that holds the name of the class.
        ///
        let name: UIText
        
        /// The `UIText` that holds information about the class.
        ///
        let info: UIText
        
        /// Creates a new instance from the given values.
        ///
        /// - Parameters:
        ///   - portrait: The `UIPortrait` to use for the class portrait.
        ///   - name: The `UIText` to use for the class name.
        ///   - info: The `UIText` to use for the class information.
        ///
        init(portrait: UIPortrait, name: UIText, info: UIText) {
            self.portrait = portrait
            self.name = name
            self.info = info
        }
    }
    
    /// The node to group the contents of the element.
    ///
    private let contents: SKNode
    
    /// The class choice entries, with the entry name as key.
    ///
    private var entries: [String: ClassEntry]
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Cretes a new instance from the given values.
    ///
    /// - Parameters:
    ///   - choices: The names of the classes to choose.
    ///   - entryOffset: The offset to apply between adjacent choices.
    ///   - contentOffset: The offset to apply between element contents.
    ///   - nameLabelSize: The size of the name label.
    ///   - infoLabelSize: The size of the info label.
    ///   - emptyPortraitImage: The empty portrait image to display.
    ///   - backgroundImage: An optional background image to enclose the choices. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(choices: [String], entryOffset: CGFloat, contentOffset: CGFloat, nameLabelSize: CGSize, infoLabelSize: CGSize,
         emptyPortraitImage: String, backgroundImage: String? = nil, backgroundBorder: UIBorder? = nil,
         backgroundOffset: CGFloat = 0) {
        
        assert(!choices.isEmpty)
        
        contents = SKNode()
        entries = [:]
        
        let groupNode = SKNode()
        groupNode.zPosition = 1
        
        // Create an entry for each class choice
        for (index, choice) in choices.enumerated() {
            let portrait = UIPortrait(emptyPortraitImage: emptyPortraitImage)
            var nameRect: CGRect
            var infoRect: CGRect
            
            if portrait.node.size.width >= max(nameLabelSize.width, infoLabelSize.width) {
                // Align the labels relative to the portrait
                let portraitX = portrait.node.size.width / 2.0
                let portraitY = (nameLabelSize.height + infoLabelSize.height + contentOffset * 2.0) +
                    portrait.node.size.height / 2.0
                portrait.node.position = CGPoint(x: portraitX, y: portraitY)
                
                nameRect = CGRect(x: (portrait.node.size.width - nameLabelSize.width) / 2.0,
                                  y: infoLabelSize.height + contentOffset,
                                  width: nameLabelSize.width, height: nameLabelSize.height)
                
                infoRect = CGRect(x: (portrait.node.size.width - infoLabelSize.width) / 2.0, y: 0,
                                  width: infoLabelSize.width, height: infoLabelSize.height)
            } else {
                // First align the labels, and then the portrait relative to them
                if nameLabelSize.width > infoLabelSize.width {
                    nameRect = CGRect(x: 0, y: infoLabelSize.height + contentOffset,
                                      width: nameLabelSize.width, height: nameLabelSize.height)
                    
                    infoRect = CGRect(x: (nameLabelSize.width - infoLabelSize.width) / 2.0, y: 0,
                                      width: infoLabelSize.width, height: infoLabelSize.height)
                    
                    portrait.node.position = CGPoint(x: nameRect.midX,
                                                     y: nameRect.maxY + contentOffset + portrait.node.size.height / 2.0)
                } else {
                    infoRect = CGRect(x: 0, y: 0, width: infoLabelSize.width, height: infoLabelSize.height)
                    
                    nameRect = CGRect(x: (infoLabelSize.width - nameLabelSize.width) / 2.0,
                                      y: infoLabelSize.height + contentOffset,
                                      width: nameLabelSize.width, height: nameLabelSize.height)
                    
                    portrait.node.position = CGPoint(x: infoRect.midX,
                                                     y: nameRect.maxY + contentOffset + portrait.node.size.height / 2.0)
                }
            }
            
            let name = UIText(rect: nameRect, style: .subtitle, text: choice, alignment: .center)
            let info = UIText(rect: infoRect, style: .text, text: nil, alignment: .center)
            entries[choice] = ClassEntry(portrait: portrait, name: name, info: info)
            
            // Group the entry contents
            let node = SKNode()
            node.zPosition = 1
            node.addChild(portrait.node)
            node.addChild(name.node)
            node.addChild(info.node)
            
            // Position the entry based on its index
            let entryWidth = max(portrait.node.size.width, max(nameLabelSize.width, infoLabelSize.width))
            node.position.x = CGFloat(index) * (entryWidth + entryOffset)
            groupNode.addChild(node)
        }
        
        // Calculate the current dimensions of the element
        let portraitSize = entries.first!.value.portrait.node.size
        let entryWidth = max(portraitSize.width, max(nameLabelSize.width, infoLabelSize.width))
        let width = CGFloat(choices.count) * entryWidth + CGFloat(choices.count - 1) * entryOffset
        let height = portraitSize.height + nameLabelSize.height + infoLabelSize.height + contentOffset * 2.0
        
        // The background, if set, must be large enough to enclose the whole contents
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        if let image = backgroundImage {
            var background: UIBackground
            if let border = backgroundBorder {
                let rect = CGRect(x: 0, y: 0,
                                  width: frame.width + border.left + border.right + backgroundOffset * 2.0,
                                  height: frame.height + border.top + border.bottom + backgroundOffset * 2.0)
                background = UIBackground(image: image, rect: rect, border: border)
                groupNode.position.x -= background.node.size.width / 2.0 - border.left - backgroundOffset
                groupNode.position.y -= background.node.size.height / 2.0 - border.bottom - backgroundOffset
            } else {
                let rect = CGRect(x: 0, y: 0,
                                  width: frame.width + backgroundOffset * 2.0,
                                  height: frame.height + backgroundOffset * 2.0)
                background = UIBackground(image: image, rect: rect)
                groupNode.position.x -= background.node.size.width / 2.0 - backgroundOffset
                groupNode.position.y -= background.node.size.height / 2.0 - backgroundOffset
            }
            // Set the element to have the same dimensions as the background
            size = CGSize(width: background.node.size.width, height: background.node.size.height)
            background.node.addChild(groupNode)
            contents.addChild(background.node)
        } else {
            size = frame.size
            contents.addChild(groupNode)
        }
    }
    
    /// Retrieves the `ClassEntry` of the given class choice name.
    ///
    /// - Parameter name: The name that identifies the class choice.
    /// - Returns: The `ClassEntry` under the given `name`, or `nil` if not found.
    ///
    func entryNamed(_ name: String) -> ClassEntry? {
        return entries[name]
    }
    
    /// Adds tracking data for the given entry.
    ///
    /// - Parameters:
    ///   - name: The name that identifies the class choice.
    ///   - data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackingDataForEntry(named name: String, data: Any) -> Bool {
        guard let node = entries[name]?.portrait.node else { return false }
        return addTrackingDataForNode(node, data: data)
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height  - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}
