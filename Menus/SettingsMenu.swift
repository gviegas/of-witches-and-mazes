//
//  SettingsMenu.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/9/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `Menu` type that defines the game settings menu.
///
class SettingsMenu: Menu, TextureUser {
    
    static var textureNames: Set<String> {
        return SettingsMenuData.textureNames
    }
    
    /// An enum that defines the settings entries.
    ///
    private enum Setting: String {
        case video = "Video"
        case audio = "Audio"
        case controls = "Controls"
        
        /// The list of sub-settings for the main setting.
        ///
        var subSettings: [(name: String, valueString: String, valueData: Any?)] {
            var subEntries = [(String, String, Any?)]()
            
            switch self {
            case .video:
                let subList: [VideoSubSettings] = [.windowedMode]
                subEntries = subList.map { ($0.rawValue, $0.valueString, $0.valueData) }
            case .audio:
                let subList: [AudioSubSettings] = [.sfxVolume, .bgmVolume]
                subEntries = subList.map { ($0.rawValue, $0.valueString, $0.valueData) }
            case .controls:
                let subList: [ControlsSubSettings] = [.characterMenu, .cycleTargets, .clearTarget, .interact,
                                                      .moveNorth, .moveSouth, .moveWest, .moveEast,
                                                      .item1, .item2, .item3, .item4, .item5, .item6,
                                                      .skill1, .skill2, .skill3, .skill4, .skill5]
                subEntries = subList.map { ($0.rawValue, $0.valueString, $0.valueData) }
            }
            
            return subEntries
        }
    }
    
//    /// An enum defining the sub-settings available for a `.game` `Setting`.
//    ///
//    private enum GameSubSettings: String {
//        case autoSave = "Auto Save"
//
//        /// The string representing the value associated with the sub-setting.
//        ///
//        var valueString: String {
//            // ToDo
//            return ""
//        }
//
//        /// The data associated with the sub-setting value.
//        ///
//        var valueData: Any? {
//            // ToDo
//            return nil
//        }
//    }
    
    /// An enum defining the sub-settings available for a `.video` `Setting`.
    ///
    private enum VideoSubSettings: String {
        case windowedMode = "Windowed Mode"
        
        /// The string representing the value associated with the sub-setting.
        ///
        var valueString: String {
            var str = ""
            switch self {
            case .windowedMode:
                guard let data = valueData as? Bool else { break }
                str = data ? "on" : "off"
            }
            return str
        }
        
        /// The data associated with the sub-setting value.
        ///
        var valueData: Any? {
            let data: Any?
            switch self {
            case .windowedMode:
                data = Window.windowedMode
            }
            return data
        }
    }
    
    /// An enum defining the sub-settings available for a `.audio` `Setting`.
    ///
    private enum AudioSubSettings: String {
        case sfxVolume = "Effects Volume"
        case bgmVolume = "Music Volume"
        
        /// The string representing the value associated with the sub-setting.
        ///
        var valueString: String {
            var str = ""
            switch self {
            case .sfxVolume, .bgmVolume:
                if let volume = valueData as? Float {
                    str = "\(Int((volume * 100.0).rounded()))%"
                }
            }
            return str
        }
        
        /// The data associated with the sub-setting value.
        ///
        var valueData: Any? {
            let data: Any?
            switch self {
            case .sfxVolume:
                data = SoundFX.volume
            case .bgmVolume:
                data = BGMPlayback.volume
            }
            return data
        }
    }
    
    /// An enum defining the sub-settings available for a `.controls` `Setting`.
    ///
    private enum ControlsSubSettings: String {
        case characterMenu = "Character Menu"
        case cycleTargets = "Cycle Targets"
        case clearTarget = "Clear Target"
        case interact = "Interact"
        case moveNorth = "Move North"
        case moveSouth = "Move South"
        case moveWest = "Move West"
        case moveEast = "Move East"
        case item1 = "Item 1"
        case item2 = "Item 2"
        case item3 = "Item 3"
        case item4 = "Item 4"
        case item5 = "Item 5"
        case item6 = "Item 6"
        case skill1 = "Skill 1"
        case skill2 = "Skill 2"
        case skill3 = "Skill 3"
        case skill4 = "Skill 4"
        case skill5 = "Skill 5"
        
        /// The string representing the value associated with the sub-setting.
        ///
        var valueString: String {
            return (valueData as? InputButton)?.symbolFromMapping ?? ""
        }
        
        /// The data associated with the sub-setting value.
        ///
        var valueData: Any? {
            let data: Any?
            switch self {
            case .characterMenu:
                data = InputButton.character
            case .cycleTargets:
                data = InputButton.cycleTargets
            case .clearTarget:
                data = InputButton.clearTarget
            case .interact:
                data = InputButton.interact
            case .moveNorth:
                data = InputButton.up
            case .moveSouth:
                data = InputButton.down
            case .moveWest:
                data = InputButton.left
            case .moveEast:
                data = InputButton.right
            case .item1:
                data = InputButton.item1
            case .item2:
                data = InputButton.item2
            case .item3:
                data = InputButton.item3
            case .item4:
                data = InputButton.item4
            case .item5:
                data = InputButton.item5
            case .item6:
                data = InputButton.item6
            case .skill1:
                data = InputButton.skill1
            case .skill2:
                data = InputButton.skill2
            case .skill3:
                data = InputButton.skill3
            case .skill4:
                data = InputButton.skill4
            case .skill5:
                data = InputButton.skill5
            }
            return data
        }
    }
    
    /// An enum that defines the tracking data for the setting element.
    ///
    private enum SettingTrackingData {
        case main(index: Int), sub(index: Int)
    }
    
    let node: SKNode
    
    /// The `UISettingElement` instance.
    ///
    private let settingElement: UISettingElement
    
    /// The `UIOptionElement` instance.
    ///
    private let optionElement: UIOptionElement
    
    /// The `UITitleElement` instance.
    ///
    private let titleElement: UITitleElement
    
    /// The setting entries.
    ///
    private let settingEntries = [Setting.video, Setting.audio, Setting.controls]
    
    /// A `(mainIndex, subIndex)` pair holding the indices of the currently selected setting.
    ///
    private var selection: (main: Int?, sub: Int?) = (nil, nil)
    
    /// A set holding the main settings that were modified since `open(onClose:)` was called.
    ///
    private var changedSettings: Set<Setting> = []
    
    /// The currently active controllable overlay.
    ///
    private var controllableOverlay: ControllableOverlay? {
        didSet {
            if controllableOverlay != nil, let menuScene = menuScene {
                menuScene.tooltipOverlay = nil
            }
        }
    }
    
    /// A flag indicating whether or not the menu is open.
    ///
    private var isOpen = false
    
    /// The current callback to call when closing the menu.
    ///
    private var onClose: (() -> Void)?
    
    required init(rect: CGRect) {
        node = SKNode()
        
        // Create the setting element
        settingElement = UISettingElement(mainSettings: settingEntries.map { $0.rawValue },
                                          subSettings: settingEntries.map { $0.subSettings.map { $0.name } },
                                          subRows: SettingsMenuData.Setting.subRows,
                                          entryOffset: SettingsMenuData.Setting.entryOffset,
                                          contentOffset: SettingsMenuData.Setting.contentOffset,
                                          mainLabelSize: SettingsMenuData.Setting.mainLabelSize,
                                          subLabelSize: SettingsMenuData.Setting.subLabelSize,
                                          mainBackgroundImage: SettingsMenuData.Setting.mainBackgroundImage,
                                          mainBackgroundBorder: SettingsMenuData.Setting.mainBackgroundBorder,
                                          mainBackgroundOffset: SettingsMenuData.Setting.mainBackgroundOffset,
                                          subBackgroundImage: SettingsMenuData.Setting.subBackgroundImage,
                                          subBackgroundBorder: SettingsMenuData.Setting.subBackgroundBorder,
                                          subBackgroundOffset: SettingsMenuData.Setting.subBackgroundOffset)
        
        // Create the option element
        optionElement = UIOptionElement(size: SettingsMenuData.Option.size,
                                        entryOffset: SettingsMenuData.Option.entryOffset,
                                        contentOffset: SettingsMenuData.Option.contentOffset,
                                        primaryButtonImage: SettingsMenuData.Option.primaryButtonImage,
                                        secondaryButtonImage: SettingsMenuData.Option.secondaryButtonImage,
                                        regularKeyImage: SettingsMenuData.Option.regularKeyImage,
                                        wideKeyImage: SettingsMenuData.Option.wideKeyImage)
        
        // Create the title element
        titleElement = UITitleElement(title: SettingsMenuData.Title.title,
                                      maxSize: SettingsMenuData.Title.maxSize,
                                      backgroundImage: SettingsMenuData.Title.backgroundImage,
                                      backgroundBorder: SettingsMenuData.Title.backgroundBorder)
        
        // Add tracking data to the setting element
        for (i, mainSetting)  in zip(settingEntries.indices, settingEntries) {
            settingElement.addTrackingDataForMainSetting(named: mainSetting.rawValue,
                                                         data: SettingTrackingData.main(index: i))
            
            let subSettings = mainSetting.subSettings
            for (j, subSetting) in zip(subSettings.indices, subSettings) {
                settingElement.addTrackingDataForSubSetting(mainSetting: mainSetting.rawValue,
                                                            named: subSetting.name,
                                                            data: SettingTrackingData.sub(index: j))
            }
        }
        
        // Generate the menu tree
        generate(rect: rect)
    }
    
    /// Generates the menu tree and appends it to the `node` property.
    ///
    /// - Parameter rect: The boundaries of the menu.
    ///
    private func generate(rect: CGRect) {
        var flag: Bool
        
        // The base offset between elements
        let yOffset: CGFloat = SettingsMenuData.elementYOffset
        
        // Calculate the required width
        let topWidth = titleElement.size.width
        let middleWidth = settingElement.size.width
        let bottomWidth = optionElement.size.width
        let width = max(topWidth, max(middleWidth, bottomWidth))
        
        // Calculate the required height
        let topHeight = max(titleElement.size.height, optionElement.size.height) + yOffset
        let middleHeight = settingElement.size.height
        let bottomHeight = topHeight
        let height = topHeight + middleHeight + bottomHeight
        
        // Check if the dimensions of all the elements fits inside the rect
        var rect = rect
        var scale: CGFloat = 1.0
        if width > rect.width || height > rect.height {
            // The elements do not fit - use a scaled up rect to place contents and scale down the final node
            scale = max(width / rect.width, height / rect.height)
            rect.origin.x *= scale
            rect.origin.y *= scale
            rect.size.width *= scale
            rect.size.height *= scale
        }
        
        // Create the root container
        let root = UIContainer(plane: .vertical, ratio: 1.0)
        
        // Divide the root in three sections
        let topRatio = (titleElement.size.height + yOffset) / rect.height
        let middleRatio = middleHeight / rect.height
        let bottomRatio = (optionElement.size.height + yOffset) / rect.height
        let topSection = UIContainer(plane: .vertical, ratio: topRatio)
        let middleSection = UIContainer(plane: .vertical, ratio: middleRatio)
        let bottomSection = UIContainer(plane: .vertical, ratio: bottomRatio)
        
        // Append the main divisions plus blank sections between top/bottom and middle sections
        let remaining = rect.height - (rect.height * (topRatio + middleRatio + bottomRatio))
        let topBlankRatio = ((1.0 - topRatio / (topRatio + bottomRatio)) * remaining) / rect.height
        let bottomBlankRatio = ((1.0 - bottomRatio / (topRatio + bottomRatio)) * remaining) / rect.height
        flag = root.appendContainer(topSection); assert(flag)
        flag = root.appendContainer(UIContainer(plane: .horizontal, ratio: topBlankRatio)); assert(flag)
        flag = root.appendContainer(middleSection); assert(flag)
        flag = root.appendContainer(UIContainer(plane: .horizontal, ratio: bottomBlankRatio)); assert(flag)
        flag = root.appendContainer(bottomSection); assert(flag)
        
        // Add the title element to the top
        topSection.addElement(titleElement)
        
        // Add the setting element to the middle
        middleSection.addElement(settingElement)
        
        // Add the option element to the bottom
        bottomSection.addElement(optionElement)
        
        // Generate the tree
        let tree = UITree(rect: rect, root: root)
        if let treeNode = tree.generate() {
            // Append the tree node to the menu node
            treeNode.zPosition = 1
            treeNode.setScale(1.0 / scale)
            node.addChild(treeNode)
        }
    }
    
    /// Set sub-settings of the given main setting.
    ///
    private func setSubSettings(of mainSetting: Setting) {
        mainSetting.subSettings.forEach { (name, value, _) in
            settingElement.subSettingOf(mainSetting: mainSetting.rawValue, named: name)?.value.text = value
        }
    }
    
    /// Sets the `UIOptionElement` based on the current `selection`.
    ///
    private func setOption() {
        let backText = "Back"
        let backButton = UIOptionElement.OptionButton.key(.back)
        let back = (backButton, backText)
        let defaults: (UIOptionElement.OptionButton, String)
        let change: (UIOptionElement.OptionButton, String)?
        
        if let main = selection.main {
            let defaultsText = "Restore \(settingEntries[main].rawValue) defaults"
            let defaultsButton = UIOptionElement.OptionButton.keyCode(.delete)
            defaults = (defaultsButton, defaultsText)
            if let sub = selection.sub {
                let changeText = "Change \(settingEntries[main].subSettings[sub].name)"
                let changeButton = UIOptionElement.OptionButton.primaryButton
                change = (changeButton, changeText)
            } else {
                change = nil
            }
        } else {
            let defaultsText = "Restore defaults"
            let defaultsButton = UIOptionElement.OptionButton.keyCode(.delete)
            defaults = (defaultsButton, defaultsText)
            change = nil
        }
        
        if let change = change {
            optionElement.replaceWith(options: [change, defaults, back])
        } else {
            optionElement.replaceWith(options: [defaults, back])
        }
    }
    
    /// Unselects the given main setting.
    ///
    /// - Parameter mainIndex: The index of the setting to unselect.
    ///
    private func unselectMainSetting(mainIndex: Int) {
        guard mainIndex >= 0 && mainIndex < settingEntries.count else { return }
        
        if mainIndex == selection.main { selection.main = nil }
        settingElement.switchTo(mainSetting: nil)
        if let mainSetting = settingElement.mainSettingNamed(settingEntries[mainIndex].rawValue) {
            mainSetting.name.restore()
        }
        setOption()
    }
    
    /// Unselects the given sub-setting.
    ///
    /// - Parameters:
    ///   - subIndex: The index of the sub-setting to unselect.
    ///   - nullifySelection: A flag stating whether or not the instance's `selection.sub` property should
    ///     be set to `nil` when it is the same as the method's parameter. The default value is `true`.
    ///
    private func unselectSubSetting(subIndex: Int, nullifySelection: Bool = true) {
        guard let mainIndex = selection.main else { return }
        let subSettings = settingEntries[mainIndex].subSettings
        guard subIndex >= 0 && subIndex < subSettings.count else { return }
        
        let mainSetting = settingEntries[mainIndex].rawValue
        let name = subSettings[subIndex].name
        if nullifySelection, subIndex == selection.sub { selection.sub = nil }
        if let subSetting = settingElement.subSettingOf(mainSetting: mainSetting, named: name) {
            subSetting.name.unflash()
            subSetting.name.restore()
            subSetting.value.unflash()
            subSetting.value.restore()
        }
        setOption()
    }
    
    /// Unselects all settings.
    ///
    private func unselectAll() {
        for i in 0..<settingEntries.count {
            unselectMainSetting(mainIndex: i)
            let subSettings = settingEntries[i].subSettings
            for j in 0..<subSettings.count {
                unselectSubSetting(subIndex: j)
            }
        }
    }
    
    /// Selects the given main setting.
    ///
    /// - Parameter mainIndex: The index of the setting to unselect.
    ///
    private func selectMainSetting(mainIndex: Int) {
        guard mainIndex >= 0 && mainIndex < settingEntries.count else { return }
        
        selection.main = mainIndex
        settingElement.switchTo(mainSetting: settingEntries[mainIndex].rawValue)
        if let mainSetting = settingElement.mainSettingNamed(settingEntries[mainIndex].rawValue) {
            mainSetting.name.enlarge()
        }
        setOption()
    }
    
    /// Selects the given sub-setting.
    ///
    /// - Parameter subIndex: The index of the setting to unselect.
    ///
    private func selectSubSetting(subIndex: Int) {
        guard let mainIndex = selection.main else { return }
        let subSettings = settingEntries[mainIndex].subSettings
        guard subIndex >= 0 && subIndex < subSettings.count else { return }
        
        let mainSetting = settingEntries[mainIndex].rawValue
        let name = subSettings[subIndex].name
        selection.sub = subIndex
        if let subSetting = settingElement.subSettingOf(mainSetting: mainSetting, named: name) {
            subSetting.name.flash()
            subSetting.name.whiten()
            subSetting.value.flash()
            subSetting.value.whiten()
        }
        setOption()
    }
    
    /// Resets to default values.
    ///
    /// - Parameter setting: An optional setting to reset. If set to `nil`, all settings are reset.
    ///
    private func resetToDefaults(setting: Setting?) {
        if setting == nil || setting == .video {
            ConfigurationData.instance.configurations.windowedMode = true
            Window.enterFullscreenMode()
            changedSettings.insert(.video)
            setSubSettings(of: .video)
        }
        
        if setting == nil || setting == .audio {
            let sfxVolume = Configurations.defaults.sfxVolume
            let bgmVolume = Configurations.defaults.bgmVolume
            ConfigurationData.instance.configurations.sfxVolume = sfxVolume
            ConfigurationData.instance.configurations.bgmVolume = bgmVolume
            SoundFX.volume = sfxVolume
            BGMPlayback.volume = bgmVolume
            changedSettings.insert(.audio)
            setSubSettings(of: .audio)
        }
        
        if setting == nil || setting == .controls {
            let defaults = Configurations.defaults.keyboardMapping
            ConfigurationData.instance.configurations.keyboardMapping = defaults
            KeyboardMapping.unmapAll()
            KeyboardMapping.mapMany(entries: defaults.map({ ($0.keyCode.rawValue, $0.modifiers, $0.InputButtons) }))
            changedSettings.insert(.controls)
            setSubSettings(of: .controls)
        }
    }
    
    /// Saves the changes, writing them to `ConfigurationsData` and then to file.
    ///
    private func saveChanges() {
        guard !changedSettings.isEmpty else { return }
        
        if changedSettings.contains(.video) {
            ConfigurationData.instance.configurations.windowedMode = Window.windowedMode
        }
        
        if changedSettings.contains(.audio) {
            ConfigurationData.instance.configurations.sfxVolume = SoundFX.volume
            ConfigurationData.instance.configurations.bgmVolume = BGMPlayback.volume
        }
        
        if changedSettings.contains(.controls) {
            let mapping = KeyboardMapping.mapping
            ConfigurationData.instance.configurations.keyboardMapping = mapping.compactMap {
                (keyCode, modifiers, buttons) in
                guard let key = KeyboardKeyCode(rawValue: keyCode) else { return nil }
                return Configurations.MappingEntry(keyCode: key, modifiers: modifiers, InputButtons: buttons)
            }
        }
        
        changedSettings = []
        let _ = ConfigurationData.instance.write()
    }
    
    func open(onClose: @escaping () -> Void) -> Bool {
        guard !isOpen else { return false }
        isOpen = true
        
        settingEntries.forEach { setSubSettings(of: $0) }
        setOption()
        
        self.onClose = onClose
        return true
    }
    
    func update(deltaTime seconds: TimeInterval) {
        
    }
    
    func close() {
        onClose?()
        onClose = nil
        isOpen = false
        unselectAll()
        undull()
        if let controllableOverlay = controllableOverlay {
            menuScene?.removeOverlay(controllableOverlay)
            self.controllableOverlay = nil
        }
        saveChanges()
    }
    
    func didReceiveEvent(_ event: Event) {
        if let controllableOverlay = controllableOverlay {
            // Update the selection property before dispatching the event to the overlay
            switch event.type {
            case .mouseEntered:
                if let event = event as? MouseEvent, let data = event.data as? SettingTrackingData {
                    switch data {
                    case .main(let index):
                        selection = (index, nil)
                    case .sub(let index):
                        // This is needed due to the two-level hierarchy of the settings menu
                        let current = settingElement.mainSetting
                        let mainIndex = settingEntries.firstIndex(where: { $0.rawValue == current })
                        selection = (mainIndex, mainIndex != nil ? index : nil)
                    }
                }
            case .mouseExited:
                if let event = event as? MouseEvent, let data = event.data as? SettingTrackingData {
                    switch data {
                    case .sub:
                        selection.sub = nil
                    default:
                        break
                    }
                }
            default:
                break
            }
            controllableOverlay.didReceiveEvent(event)
        } else {
            switch event.type {
            case .mouseDown:
                if let event = event as? MouseEvent {
                    mouseDownEvent(event)
                }
            case .mouseEntered:
                if let event = event as? MouseEvent {
                    mouseEnteredEvent(event)
                }
            case .mouseExited:
                if let event = event as? MouseEvent {
                    mouseExitedEvent(event)
                }
            case .keyDown:
                if let event = event as? KeyboardEvent {
                    keyDownEvent(event)
                }
            default:
                break
            }
        }
    }
    
    /// Handles mouse down events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseDownEvent(_ event: MouseEvent) {
        guard let mainIndex = selection.main, let subIndex = selection.sub else { return }
        guard mainIndex >= 0 && mainIndex < settingEntries.count else { return }
        
        switch settingEntries[mainIndex]{
        case .video:
            let subSettings = settingEntries[mainIndex].subSettings
            guard subIndex >= 0 && subIndex < subSettings.count else { break }
            
            let subSetting = subSettings[subIndex]
            switch subSetting.name {
            case VideoSubSettings.windowedMode.rawValue:
                Window.windowedMode ? Window.enterFullscreenMode() : Window.exitFullscreenMode()
                setSubSettings(of: .video)
                changedSettings.insert(.video)
            default:
                break
            }
            
        case .audio:
            let subSettings = settingEntries[mainIndex].subSettings
            guard subIndex >= 0 && subIndex < subSettings.count else { break }
            
            let subSetting = subSettings[subIndex]
            switch subSetting.name {
            case AudioSubSettings.sfxVolume.rawValue, AudioSubSettings.bgmVolume.rawValue:
                guard let volume = subSetting.valueData as? Float else { break }
                if controllableOverlay == nil, let menuScene = menuScene {
                    unselectSubSetting(subIndex: subIndex, nullifySelection: false)
                    dull()
                    let rect = menuScene.frame
                    controllableOverlay = PromptOverlay.volumePrompt(rect: rect, initialValue: volume) {
                        [unowned self] in
                        if let overlay = self.controllableOverlay as? PromptOverlay {
                            if overlay.confirmed, let text = overlay.promptText, let value = Float(text.dropLast()) {
                                let newVolume = value * 0.01
                                if subSetting.name == AudioSubSettings.sfxVolume.rawValue {
                                    SoundFX.volume = newVolume
                                } else {
                                    BGMPlayback.volume = newVolume
                                }
                                self.setSubSettings(of: .audio)
                                self.changedSettings.insert(.audio)
                            }
                        }
                        if let newMainIndex = self.selection.main {
                            if mainIndex != newMainIndex {
                                self.unselectMainSetting(mainIndex: mainIndex)
                                self.selectMainSetting(mainIndex: newMainIndex)
                            }
                            if let newSubIndex = self.selection.sub {
                                self.selectSubSetting(subIndex: newSubIndex)
                            }
                        }
                        self.undull()
                        self.menuScene?.removeOverlay(self.controllableOverlay!)
                        self.controllableOverlay = nil
                    }
                    menuScene.addOverlay(controllableOverlay!)
                }
            default:
                break
            }
            
        case .controls:
            let subSettings = settingEntries[mainIndex].subSettings
            guard subIndex >= 0 && subIndex < subSettings.count,
                let inputButton = subSettings[subIndex].valueData as? InputButton
                else { break }
            
            if controllableOverlay == nil, let menuScene = menuScene {
                unselectSubSetting(subIndex: subIndex, nullifySelection: false)
                dull()
                let rect = menuScene.frame
                controllableOverlay = KeyMappingOverlay(rect: rect, inputButton: inputButton) {
                    [unowned self] in
                    if let overlay = self.controllableOverlay as? KeyMappingOverlay {
                        if overlay.confirmed, let mapping = overlay.mapping {
                            // Always unmap the first non-special mapping if the button has more than one
                            let currentMapping = KeyboardMapping.mappingFor(inputButton: inputButton)
                            let current = currentMapping?.first {
                                KeyboardKeyCode(rawValue: $0.keyCode)?.isSpecialKey == false
                            }
                            if let current = current {
                                KeyboardMapping.unmap(keyCode: current.keyCode, modifiers: current.modifiers,
                                                      inputButtons: [inputButton])
                            }
                            // If the new mapping is already bound to a button, the mappings will be swapped
                            let otherMapping = KeyboardMapping.mappingFor(keyCode: mapping.keyCode,
                                                                          modifiers: mapping.modifiers)
                            // Since a button should not have more than one non-special mapping and the
                            // KeyMapppingOverlay guarantees the mapping validity, the first entry is chosen
                            if let other = otherMapping?.first {
                                KeyboardMapping.unmap(keyCode: mapping.keyCode, modifiers: mapping.modifiers,
                                                      inputButtons: [other])
                                if let current = current {
                                    KeyboardMapping.map(keyCode: current.keyCode, modifiers: current.modifiers,
                                                        inputButtons: [other])
                                }
                            }
                            // Set the new mapping
                            KeyboardMapping.map(keyCode: mapping.keyCode, modifiers: mapping.modifiers,
                                                inputButtons: [inputButton])
                            self.setSubSettings(of: .controls)
                            self.changedSettings.insert(.controls)
                        }
                    }
                    if let newMainIndex = self.selection.main {
                        if mainIndex != newMainIndex {
                            self.unselectMainSetting(mainIndex: mainIndex)
                            self.selectMainSetting(mainIndex: newMainIndex)
                        }
                        if let newSubIndex = self.selection.sub {
                            self.selectSubSetting(subIndex: newSubIndex)
                        }
                    }
                    self.undull()
                    self.menuScene?.removeOverlay(self.controllableOverlay!)
                    self.controllableOverlay = nil
                }
                menuScene.addOverlay(controllableOverlay!)
            }
        }
    }
    
    /// Handles mouse entered events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseEnteredEvent(_ event: MouseEvent) {
        if let data = event.data as? SettingTrackingData {
            switch data {
            case .main(let index):
                if let mainIndex = selection.main { unselectMainSetting(mainIndex: mainIndex) }
                selectMainSetting(mainIndex: index)
            case .sub(let index):
                if let subIndex = selection.sub { unselectSubSetting(subIndex: subIndex) }
                selectSubSetting(subIndex: index)
            }
        }
    }
    
    /// Handles mouse exited events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseExitedEvent(_ event: MouseEvent) {
        if let data = event.data as? SettingTrackingData {
            // Note: The main setting is not cleared here on purpose
            switch data {
            case .sub(let index):
                unselectSubSetting(subIndex: index)
            default:
                break
            }
        }
    }
    
    /// Handles keyboard key down events.
    ///
    /// - Parameter event: The event.
    ///
    private func keyDownEvent(_ event: KeyboardEvent) {
        // Special key (reset to defaults)
        if event.keyCode == KeyboardKeyCode.delete.rawValue {
            if controllableOverlay == nil, let menuScene = menuScene {
                let setting: Setting? = selection.main != nil ? settingEntries[selection.main!] : nil
                if let subIndex = selection.sub { unselectSubSetting(subIndex: subIndex, nullifySelection: false) }
                dull()
                let rect = menuScene.frame
                let text = "Restore default values of \(setting?.rawValue ?? "all") settings?"
                controllableOverlay = ConfirmationOverlay(rect: rect, content: text) {
                    [unowned self] in
                    if let overlay = self.controllableOverlay as? ConfirmationOverlay, overlay.confirmed {
                        self.resetToDefaults(setting: setting)
                    }
                    if let newMainIndex = self.selection.main {
                        let mainIndex = setting != nil ? self.settingEntries.firstIndex(of: setting!) : nil
                        if let mainIndex = mainIndex, mainIndex != newMainIndex {
                            self.unselectMainSetting(mainIndex: mainIndex)
                            self.selectMainSetting(mainIndex: newMainIndex)
                        }
                        if let newSubIndex = self.selection.sub {
                            self.selectSubSetting(subIndex: newSubIndex)
                        }
                    }
                    self.undull()
                    self.menuScene?.removeOverlay(self.controllableOverlay!)
                    self.controllableOverlay = nil
                }
                menuScene.addOverlay(controllableOverlay!)
            }
            return
        }
        
        guard let mapping = KeyboardMapping.mappingFor(keyCode: event.keyCode, modifiers: event.modifiers)
            else { return }

        if mapping.contains(.back) {
            if let mainIndex = selection.main {
                if let subIndex = selection.sub {
                    unselectSubSetting(subIndex: subIndex)
                }
                unselectMainSetting(mainIndex: mainIndex)
            } else {
                if let _ = LevelManager.currentLevel {
                    let _ = SceneManager.switchToScene(ofKind: .level)
                } else {
                    let _ = SceneManager.switchToScene(ofKind: .mainMenu)
                }
            }
        }
    }
}

/// A struct that defines the data associated with the `SettingsMenu` class.
///
fileprivate struct SettingsMenuData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Setting.mainBackgroundImage,
                Setting.subBackgroundImage,
                Option.primaryButtonImage,
                Option.secondaryButtonImage,
                Option.regularKeyImage,
                Option.wideKeyImage]
    }
    
    /// The vertical offset to apply between each element.
    ///
    static let elementYOffset: CGFloat = 40.0
    
    private init() {}
    
    /// The data to use for the `UISettingElement`.
    struct Setting {
        private init() {}
        static let subRows = 16
        static let entryOffset: CGFloat = 6.0
        static let contentOffset: CGFloat = 6.0
        static let mainLabelSize = CGSize(width: 150.0, height: 24.0)
        static let subLabelSize = CGSize(width: 170.0, height: 24.0)
        static let mainBackgroundImage = "UI_Default_Background_8p"
        static let mainBackgroundBorder = UIBorder(width: 8.5)
        static let mainBackgroundOffset: CGFloat = 10.0
        static let subBackgroundImage = "UI_Default_Background_8p"
        static let subBackgroundBorder = UIBorder(width: 8.5)
        static let subBackgroundOffset: CGFloat = 10.0
    }
    
    /// The data to use for the `UIOptionElement`.
    ///
    struct Option {
        private init() {}
        static let size = CGSize(width: 1280.0, height: 60.0)
        static let entryOffset: CGFloat = 38.0
        static let contentOffset: CGFloat = 6.0
        static let primaryButtonImage = "UI_Primary_Mouse_Button"
        static let secondaryButtonImage = "UI_Secondary_Mouse_Button"
        static let regularKeyImage = "UI_Keyboard_Key"
        static let wideKeyImage = "UI_Wide_Keyboard_Key"
    }
    
    /// The data to use for the `UITitleElement`.
    ///
    struct Title {
        private init() {}
        static let title = "SETTINGS"
        static let maxSize = CGSize(width: 272.0, height: 60.0)
        static let backgroundImage: String? = nil
        static let backgroundBorder: UIBorder? = nil
    }
}
