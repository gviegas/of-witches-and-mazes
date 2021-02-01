//
//  UISettingElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/8/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays a main settings bar, plus sub-settings for each one.
///
class UISettingElement: UIElement {
    
    /// A class that defines the main-setting entries.
    ///
    class MainSettingEntry {
        
        /// The `UIText` that holds the name of the main setting.
        ///
        let name: UIText
        
        /// The amount of sub-settings under the main setting entry.
        ///
        let subSettingsAmount: Int
        
        /// The `UIBackground` to use when tracking the entry.
        ///
        let background: UIBackground
        
        /// Creates a new instance from the given values.
        ///
        /// - Parameters:
        ///   - name: The `UIText` for the main setting's name.
        ///   - subSettingsAmount: The total sub-settings entries under the main setting.
        ///   - background: The `UIBackgorund` for data tracking.
        ///
        init(name: UIText, subSettingsAmount: Int, background: UIBackground) {
            self.name = name
            self.subSettingsAmount = subSettingsAmount
            self.background = background
        }
    }
    
    /// A class that defines the sub-setting entries.
    ///
    class SubSettingEntry {
        
        /// The `UIText` that holds the name of the sub-setting.
        ///
        let name: UIText
        
        /// The `UIText` that holds the value of the sub-setting.
        ///
        let value: UIText
        
        /// The `UIBackground` to use when tracking the entry.
        ///
        let background: UIBackground
        
        /// Creates a new instance from the given values.
        ///
        /// - Parameters:
        ///   - name: The `UIText` for the sub-setting's name.
        ///   - value: The `UIText` for the sub-setting's value.
        ///   - background: The `UIBackgorund` for data tracking.
        ///
        init(name: UIText, value: UIText, background: UIBackground) {
            self.name = name
            self.value = value
            self.background = background
        }
    }
    
    /// The node to group the contents of the element.
    ///
    private let contents: SKNode
    
    /// The main settings background.
    ///
    private let mainBackground: UIBackground?
    
    /// The sub-settings background, with the main settings names as key.
    ///
    private var subBackgrounds: [String: UIBackground]?
    
    /// The main settings entries, with the main setting names as key.
    ///
    private var mainEntries: [String: MainSettingEntry]
    
    /// The sub-settings entries, with the main settings and sub-settings names as keys.
    ///
    private var subEntries: [String: [String: SubSettingEntry]]
    
    /// The nodes for each main setting's sub-settings, with the main settings names as key.
    ///
    private var subNodes: [String: SKNode]
    
    /// The current setting being displayed.
    ///
    private var currentSetting: String?
    
    /// The maximum number of rows allowed in a single column of sub-settings.
    ///
    let subRows: Int
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// The name of the current main setting that was set by `switchTo(mainSetting:)`
    ///
    var mainSetting: String? {
        return currentSetting
    }
    
    /// Cretes a new instance from the given values.
    ///
    /// - Parameters:
    ///   - mainSettings: The name of each main setting.
    ///   - subSettings: The sub-settings for each main setting. The index matches those of the
    ///     `mainSettings` array.
    ///   - subRows: The maximum amount of rows without splitting the sub-settings in two columns.
    ///   - entryOffset: The offset to apply between adjacent entries.
    ///   - contentOffset: The offset to apply between element contents.
    ///   - mainLabelSize: The size of the text label for the main settings.
    ///   - subLabelSize: The size of the text label for the sub-settings.
    ///   - mainBackgroundImage: An optional background image to enclose the main settings. The default
    ///     value is `nil`.
    ///   - mainBackgroundBorder: An optional border for the main background. The default value is `nil`.
    ///   - mainBackgroundOffset: The offset to apply between the main background's border and the element
    ///     contents. The default value is `0`.
    ///   - subBackgroundImage: An optional background image to enclose the sub-settings. The default
    ///     value is `nil`.
    ///   - subBackgroundBorder: An optional border for the sub background. The default value is `nil`.
    ///   - subBackgroundOffset: The offset to apply between the sub background's border and the element
    ///     contents. The default value is `0`.
    ///
    init(mainSettings: [String], subSettings: [[String]], subRows: Int, entryOffset: CGFloat,
         contentOffset: CGFloat, mainLabelSize: CGSize, subLabelSize: CGSize,
         mainBackgroundImage: String? = nil, mainBackgroundBorder: UIBorder? = nil,
         mainBackgroundOffset: CGFloat = 0, subBackgroundImage: String? = nil,
         subBackgroundBorder: UIBorder? = nil, subBackgroundOffset: CGFloat = 0) {
        
        assert(mainSettings.count > 0 && mainSettings.count == subSettings.count)
        
        contents = SKNode()
        contents.zPosition = 1
        subNodes = [:]
        mainEntries = [:]
        subEntries = [:]
        subBackgrounds = subBackgroundImage != nil ? [:] : nil
        self.subRows = subRows
        
        let mainNode = SKNode()
        mainNode.zPosition = 1
        
        var mainSize = CGSize(width: CGFloat(mainSettings.count) * mainLabelSize.width +
            CGFloat(mainSettings.count - 1) * contentOffset, height: mainLabelSize.height)
        var subSizes = [String: CGSize]()
        var subMax = CGSize.zero
        
        for (i, mainSetting) in mainSettings.enumerated() {
            // Create the main setting
            let mainRect = CGRect(x: CGFloat(i) * (mainLabelSize.width + contentOffset), y: 0,
                                  width: mainLabelSize.width, height: mainLabelSize.height)
            let mainName = UIText(rect: CGRect(origin: CGPoint.zero, size: mainRect.size), style: .subtitle,
                                  text: mainSetting, alignment: .center)
            let mainBackground = UIBackground.defaultBlackBackground(rect: mainRect)
            
            let mainEntryNode = SKNode()
            mainEntryNode.zPosition = 1
            mainEntryNode.addChild(mainName.node)
            mainEntryNode.position.x -= mainBackground.node.size.width / 2.0
            mainEntryNode.position.y -= mainBackground.node.size.height / 2.0
            
            mainBackground.node.addChild(mainEntryNode)
            
            mainNode.addChild(mainBackground.node)
            mainEntries[mainSetting] = MainSettingEntry(name: mainName, subSettingsAmount: subSettings[i].count,
                                                        background: mainBackground)
            subEntries[mainSetting] = [:]
            subNodes[mainSetting] = SKNode()
            subNodes[mainSetting]!.zPosition = 1
            
            // Create its sub-settings
            var subSize = CGSize.zero
            for (j, subSetting) in subSettings[i].enumerated() {
                var subOrigin: CGPoint
                if subSettings[i].count > subRows {
                    // Split the sub-settings in two columns
                    let middle = subSettings[i].count % 2 == 0 ? subSettings[i].count / 2 : subSettings[i].count / 2 + 1
                    if j < middle {
                        // It must go on the left column
                        subOrigin = CGPoint(x: 0, y: CGFloat(middle - j - 1) * (subLabelSize.height + entryOffset))
                    } else {
                        // It must go on the right column
                        subOrigin = CGPoint(x: subLabelSize.width * 2.0 + contentOffset + entryOffset,
                                            y: CGFloat(middle * 2 - j - 1) * (subLabelSize.height + entryOffset))
                    }
                    // Update the sub size
                    if subSize == CGSize.zero {
                        subSize = CGSize(width: subLabelSize.width * 4.0 + contentOffset * 2.0 + entryOffset,
                                         height: CGFloat(middle) * subLabelSize.height + CGFloat(middle - 1) * entryOffset)
                    }
                } else {
                    // Arrange the sub-settings in a single column
                    subOrigin = CGPoint(x: 0, y: CGFloat(subSettings[i].count - j - 1) * (subLabelSize.height + entryOffset))
                    // Update the sub size
                    if subSize == CGSize.zero {
                        let count = CGFloat(subSettings[i].count)
                        subSize = CGSize(width: subLabelSize.width * 2.0 + contentOffset,
                                         height: count * subLabelSize.height + (count - 1) * entryOffset)
                    }
                }
                
                let subNameRect = CGRect(origin: CGPoint.zero, size: subLabelSize)
                let subName = UIText(rect: subNameRect, style: .text, text: subSetting, alignment: .center)
                
                let subValueRect = CGRect(origin: CGPoint(x: subLabelSize.width + contentOffset, y: 0),
                                          size: subLabelSize)
                let subValue = UIText(rect: subValueRect, style: .value, text: nil, alignment: .center)
                
                let subBackgroundSize = CGSize(width: subLabelSize.width * 2.0 + contentOffset,
                                               height: subLabelSize.height)
                let subBackgroundRect = CGRect(origin: subOrigin, size: subBackgroundSize)
                let subBackground = UIBackground.defaultBlackBackground(rect: subBackgroundRect)
                
                let subEntryNode = SKNode()
                subEntryNode.zPosition = 1
                subEntryNode.addChild(subName.node)
                subEntryNode.addChild(subValue.node)
                subEntryNode.position.x -= subBackground.node.size.width / 2.0
                subEntryNode.position.y -= subBackground.node.size.height / 2.0
                
                subBackground.node.addChild(subEntryNode)
                
                subNodes[mainSetting]!.addChild(subBackground.node)
                subEntries[mainSetting]![subSetting] = SubSettingEntry(name: subName, value: subValue,
                                                                       background: subBackground)
            }
            
            // Create the sub background
            if let image = subBackgroundImage {
                let frame = CGRect(origin: CGPoint.zero, size: subSize)
                if let border = subBackgroundBorder {
                    let rect = CGRect(x: 0, y: 0,
                                      width: frame.width + border.left + border.right + subBackgroundOffset * 2.0,
                                      height: frame.height + border.top + border.bottom + subBackgroundOffset * 2.0)
                    subBackgrounds![mainSetting] = UIBackground(image: image, rect: rect, border: border)
                    let halfWidth = subBackgrounds![mainSetting]!.node.size.width / 2.0
                    let halfHeight = subBackgrounds![mainSetting]!.node.size.height / 2.0
                    subNodes[mainSetting]!.position.x -=  halfWidth - border.left - subBackgroundOffset
                    subNodes[mainSetting]!.position.y -= halfHeight - border.bottom - subBackgroundOffset
                    subSize = rect.size
                } else {
                    let rect = CGRect(x: 0, y: 0,
                                      width: frame.width + subBackgroundOffset * 2.0,
                                      height: frame.height + subBackgroundOffset * 2.0)
                    subBackgrounds![mainSetting] = UIBackground(image: image, rect: rect)
                    let halfWidth = subBackgrounds![mainSetting]!.node.size.width / 2.0
                    let halfHeight = subBackgrounds![mainSetting]!.node.size.height / 2.0
                    subNodes[mainSetting]!.position.x -= halfWidth - subBackgroundOffset
                    subNodes[mainSetting]!.position.y -= halfHeight - subBackgroundOffset
                    subSize = rect.size
                }
                subBackgrounds![mainSetting]!.node.addChild(subNodes[mainSetting]!)
            }
            
            // Update the sub maximum size
            if subSize.width > subMax.width { subMax.width = subSize.width }
            if subSize.height > subMax.height { subMax.height = subSize.height }
            
            subSizes[mainSetting] = subSize
        }
        
        // Create the main background
        if let image = mainBackgroundImage {
            let frame = CGRect(origin: CGPoint.zero, size: mainSize)
            if let border = mainBackgroundBorder {
                let rect = CGRect(x: 0, y: 0,
                                  width: frame.width + border.left + border.right + mainBackgroundOffset * 2.0,
                                  height: frame.height + border.top + border.bottom + mainBackgroundOffset * 2.0)
                mainBackground = UIBackground(image: image, rect: rect, border: border)
                mainNode.position.x -= mainBackground!.node.size.width / 2.0 - border.left - mainBackgroundOffset
                mainNode.position.y -= mainBackground!.node.size.height / 2.0 - border.bottom - mainBackgroundOffset
                mainSize = rect.size
            } else {
                let rect = CGRect(x: 0, y: 0,
                                  width: frame.width + mainBackgroundOffset * 2.0,
                                  height: frame.height + mainBackgroundOffset * 2.0)
                mainBackground = UIBackground(image: image, rect: rect)
                mainNode.position.x -= mainBackground!.node.size.width / 2.0 - mainBackgroundOffset
                mainNode.position.y -= mainBackground!.node.size.height / 2.0 - mainBackgroundOffset
                mainSize = rect.size
            }
            mainBackground!.node.addChild(mainNode)
        } else {
            mainBackground = nil
        }
        
        // Arrange the main node
        var mainPosition = CGPoint.zero
        if let mainBackground = mainBackground {
            if mainSize.width < subMax.width {
                mainPosition = CGPoint(x: (subMax.width - mainSize.width) / 2.0 + mainSize.width / 2.0,
                                       y: subMax.height + entryOffset + mainSize.height / 2.0)
            } else {
                mainPosition = CGPoint(x: mainSize.width / 2.0, y: subMax.height + entryOffset + mainSize.height / 2.0)
            }
            mainBackground.node.position = mainPosition
            contents.addChild(mainBackground.node)
        } else {
            if mainSize.width < subMax.width {
                mainPosition = CGPoint(x: (subMax.width - mainSize.width) / 2.0,
                                       y: subMax.height + entryOffset + mainSize.height / 2.0)
            } else {
                mainPosition = CGPoint(x: 0, y: subMax.height + entryOffset + mainSize.height / 2.0)
            }
            mainNode.position = mainPosition
            contents.addChild(mainNode)
        }
        
        // Arrange the sub nodes
        if let subBackgrounds = subBackgrounds {
            if mainBackground == nil {
                mainPosition.x += mainSize.width / 2.0
                mainPosition.y += mainSize.height / 2.0
            }
            for (key, subBackground) in subBackgrounds {
                let size = subSizes[key]!
                subBackground.node.position.x = mainPosition.x
                subBackground.node.position.y = mainPosition.y - entryOffset - (mainSize.height / 2.0) - (size.height / 2.0)
            }
        } else {
            if mainBackground != nil {
                mainPosition.x -= mainSize.width / 2.0
                mainPosition.y -= mainSize.height / 2.0
            }
            for (key, subNode) in subNodes {
                let size = subSizes[key]!
                subNode.position.x = mainPosition.x + mainSize.width / 2.0 - size.width / 2.0
                subNode.position.y = mainPosition.y - entryOffset - size.height
            }
        }
        
        // Set the final size of the element
        size = CGSize(width: max(mainSize.width, subMax.width), height: mainSize.height + subMax.height + entryOffset)
    }
    
    /// Retrieves the main setting entry under the given name.
    ///
    /// - Parameter name: the name of the main setting.
    /// - Returns: The `MainSettingEntry` for the given main setting, or `nil` if not found.
    ///
    func mainSettingNamed(_ name: String) -> MainSettingEntry? {
        return mainEntries[name]
    }
    
    /// Retrieves the main settings's sub-setting for the given name.
    ///
    /// - Parameters:
    ///   - mainSetting: The main setting that the sub-setting refers to.
    ///   - name: The name of the sub-setting to retrieve.
    /// - Returns: The `SubSettingEntry` for the given sub-setting, or `nil` if not found.
    ///
    func subSettingOf(mainSetting: String, named name: String) -> SubSettingEntry? {
        return subEntries[mainSetting]?[name]
    }
    
    /// Switches from the current main setting to the given one.
    ///
    /// - Parameter mainSetting: The name of the main setting to switch to, or `nil` to hide all.
    /// - Returns: `true` if switched to the given setting, `false` otherwise.
    ///
    @discardableResult
    func switchTo(mainSetting: String?) -> Bool {
        guard let mainSetting = mainSetting else {
            if let currentSetting = currentSetting {
                subBackgrounds![currentSetting]!.node.removeFromParent()
                self.currentSetting = nil
            }
            return true
        }
        
        if currentSetting != mainSetting {
            if let _ = subBackgrounds {
                if let newNode = subBackgrounds![mainSetting]?.node {
                    if let currentSetting = currentSetting {
                        subBackgrounds![currentSetting]!.node.removeFromParent()
                    }
                    contents.addChild(newNode)
                } else {
                    return false
                }
            } else {
                if let newNode = subNodes[mainSetting] {
                    if let currentSetting = currentSetting {
                        subNodes[currentSetting]!.removeFromParent()
                    }
                    contents.addChild(newNode)
                } else {
                    return false
                }
            }
            currentSetting = mainSetting
        }
        return true
    }
    
    /// Adds tracking data for the given main setting.
    ///
    /// - Parameters:
    ///   - name: The name of the main setting.
    ///   - data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackingDataForMainSetting(named name: String, data: Any) -> Bool {
        guard let node = mainEntries[name]?.background.node else { return false }
        return addTrackingDataForNode(node, data: data)
    }
    
    /// Adds tracking data for the given sub-setting.
    ///
    /// - Parameters:
    ///   - mainSetting: The main setting that the sub-setting refers to.
    ///   - name: The name of the sub-setting.
    ///   - data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackingDataForSubSetting(mainSetting: String, named name: String, data: Any) -> Bool {
        guard let node = subEntries[mainSetting]?[name]?.background.node else { return false }
        return addTrackingDataForNode(node, data: data)
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}
