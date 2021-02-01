//
//  MainMenu.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `Menu` type for the main menu.
///
class MainMenu: Menu, TextureUser {
    
    static var textureNames: Set<String> {
        return MainMenuData.textureNames
    }
    
    /// An enum that defines the names of the list entries.
    ///
    private enum ListEntry: String {
        case newGame = "New Game"
        case continueLast = "Continue"
        case loadGame = "Load Game"
        case settings = "Settings"
        case intro = "Intro"
        case quit = "Quit"
    }
    
    /// A struct that defines the tracking data for the list element.
    ///
    private struct ListTrackingData {
        
        /// The list entry.
        ///
        let listEntry: ListEntry
    }
    
    let node: SKNode
    
    /// The `UIListElement` instance.
    ///
    private let listElement: UIListElement
    
    /// The `UIOptionElement` instance.
    ///
    private let optionElement: UIOptionElement
    
    /// The `UIMainTitleElement` instance.
    ///
    private let mainTitleElement: UIMainTitleElement
    
    /// The names for the list entries.
    ///
    private let listEntries = [ListEntry.newGame,
                               ListEntry.continueLast,
                               ListEntry.loadGame,
                               ListEntry.settings,
                               ListEntry.intro,
                               ListEntry.quit]
    
    /// The currently selected list entry.
    ///
    private var selection: ListEntry?
    
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
        
        // Create the list element
        listElement = UIListElement(entries: listEntries.map { $0.rawValue },
                                    entryOffset: MainMenuData.List.entryOffset,
                                    labelSize: MainMenuData.List.labelSize,
                                    backgroundImage: MainMenuData.List.backgroundImage,
                                    backgroundBorder: MainMenuData.List.backgroundBorder,
                                    backgroundOffset: MainMenuData.List.backgroundOffset)
        
        // Create the option element
        optionElement = UIOptionElement(size: MainMenuData.Option.size,
                                        entryOffset: MainMenuData.Option.entryOffset,
                                        contentOffset: MainMenuData.Option.contentOffset,
                                        primaryButtonImage: MainMenuData.Option.primaryButtonImage,
                                        secondaryButtonImage: MainMenuData.Option.secondaryButtonImage,
                                        regularKeyImage: MainMenuData.Option.regularKeyImage,
                                        wideKeyImage: MainMenuData.Option.wideKeyImage)
        
        // Create the main title element
        mainTitleElement = UIMainTitleElement(titleImage: MainMenuData.MainTitle.titleImage)
        
        // Add tracking data to the list element
        for entry in listEntries {
            listElement.addTrackindDataForEntry(named: entry.rawValue,
                                                data: ListTrackingData(listEntry: entry))
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
        let yOffset: CGFloat = MainMenuData.elementYOffset
        
        // Calculate the required width
        let topWidth = mainTitleElement.size.width
        let middleWidth = listElement.size.width
        let bottomWidth = optionElement.size.width
        let width = max(topWidth, max(middleWidth, bottomWidth))
        
        // Calculate the required height
        let topHeight = max(mainTitleElement.size.height, optionElement.size.height) + yOffset
        let middleHeight = listElement.size.height
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
        let topRatio = (mainTitleElement.size.height + yOffset) / rect.height
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
        
        // Add the main title element to the top
        topSection.addElement(mainTitleElement)
        
        // Add the list element to the middle
        middleSection.addElement(listElement)
        
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
    
    /// Sets the `UIOptionElement` based on the current `selection`.
    ///
    private func setOption() {
        let text: String?
        
        switch selection {
        case .some(let value):
            switch value {
            case .newGame:
                text = "Start a new game"
            case .continueLast:
                    text = "Continue from last save"
            case .loadGame:
                text = "Load a saved game"
            case .settings:
                text = "Change game settings"
            case .intro:
                text = "Learn how to play"
            case .quit:
                text = "Quit game"
            }
        case .none:
            text = nil
        }
        
        if let text = text {
            optionElement.replaceWith(options: [(.primaryButton, text)])
        } else {
            optionElement.replaceWith(options: [])
        }
    }
    
    /// Checks if there are last save data to continue from.
    ///
    /// - Note: The value returned by `hasLastSaveData()` must not change
    ///   while the menu is open.
    ///
    /// - Returns: `true` if last save data were found, `false` otherwise.
    ///
    private func hasLastSaveData() -> Bool {
        let fileName = ConfigurationData.instance.configurations.lastSaveFileLoaded
        guard fileName != "" else { return false }
        
        if RawData.validate(fileNamed: fileName) {
            return true
        } else {
            ConfigurationData.instance.configurations.lastSaveFileLoaded = ""
            let _ = ConfigurationData.instance.write()
            return false
        }
    }
    
    /// Checks if there are any save data.
    ///
    /// - Note: The value returned by `hasAnySaveData()` must not change
    ///   while the menu is open.
    ///
    /// - Returns: `true` if save data were found, `false` otherwise.
    ///
    private func hasAnySaveData() -> Bool {
        guard !hasLastSaveData() else { return true }
        
        let sem = DispatchSemaphore(value: 0)
        var isEmpty = true
        DataFileManager.instance.isSavesDirectoryEmpty {
            isEmpty = $0 ?? false
            sem.signal()
        }
        sem.wait()
        return !isEmpty
    }
    
    /// Unselects the given list entry.
    ///
    /// - Parameters:
    ///   - entry: The entry to unselect.
    ///   - nullifySelection: A flag stating whether or not the instance's `selection` property should
    ///     be set to `nil` when it is the same as the method's parameter. The default value is `true`.
    ///
    private func unselectEntry(_ entry: ListEntry, nullifySelection: Bool = true) {
        if nullifySelection, entry == selection { selection = nil }
        if let entry = listElement.entryNamed(entry.rawValue) {
            entry.unflash()
            entry.restore()
            setOption()
        }
    }
    
    /// Unselects all entries.
    ///
    private func unselectAll() {
        for entry in listEntries {
            unselectEntry(entry)
        }
    }
    
    /// Selects the given list entry.
    ///
    /// - Parameter entry: The entry to select.
    ///
    private func selectEntry(_ entry: ListEntry) {
        guard entry != selection else { return }
        guard entry != .continueLast || hasLastSaveData() else { return }
        guard entry != .loadGame || hasAnySaveData() else { return }
        
        selection = entry
        if let entry = listElement.entryNamed(entry.rawValue) {
            entry.flash()
            entry.whiten()
        }
        setOption()
    }
    
    func open(onClose: @escaping () -> Void) -> Bool {
        guard !isOpen else { return false }
        isOpen = true
        
        if hasLastSaveData() {
            listElement.entryNamed(ListEntry.continueLast.rawValue)?.undull()
        } else {
            listElement.entryNamed(ListEntry.continueLast.rawValue)?.dull()
        }
        
        if hasAnySaveData() {
            listElement.entryNamed(ListEntry.loadGame.rawValue)?.undull()
        } else {
            listElement.entryNamed(ListEntry.loadGame.rawValue)?.dull()
        }
        
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
    }
    
    func didReceiveEvent(_ event: Event) {
        if let _ = controllableOverlay {
            // Update the selection property before dispatching the event to the overlay
            switch event.type {
            case .mouseEntered:
                if let event = event as? MouseEvent, let data = event.data as? ListTrackingData {
                    selection = data.listEntry
                }
            case .mouseExited:
                if let event = event as? MouseEvent, let _ = event.data as? ListTrackingData {
                    selection = nil
                }
            default:
                break
            }
            controllableOverlay!.didReceiveEvent(event)
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
        guard event.button == .left, let selection = selection else { return }
        
        switch selection {
        case .newGame:
            if !ConfigurationData.instance.configurations.shouldRecommendIntro {
                let _ = SceneManager.switchToScene(ofKind: .newGameMenu)
            } else if let menuScene = menuScene {
                ConfigurationData.instance.configurations.shouldRecommendIntro = false
                let _ = ConfigurationData.instance.write()
                unselectEntry(selection, nullifySelection: false)
                dull()
                let rect = menuScene.frame
                let content = "If you are new to the game, it is recommended that you play the Intro first."
                let overlay = ConfirmationOverlay(rect: rect, content: content) {
                    [unowned self] in
                    if let selection = self.selection { self.selectEntry(selection) }
                    self.undull()
                    self.menuScene?.removeOverlay(self.controllableOverlay!)
                    if let overlay = self.controllableOverlay as? ConfirmationOverlay {
                        if overlay.confirmed {
                            let _ = Session.startAsIntro(protagonist: IntroProtagonist(levelOfExperience: 60))
                        } else {
                            let _ = SceneManager.switchToScene(ofKind: .newGameMenu)
                        }
                    }
                    self.controllableOverlay = nil
                }
                overlay.optionText = ("Play Intro", "Skip Intro")
                controllableOverlay = overlay
                menuScene.addOverlay(controllableOverlay!)
            }
        case .loadGame:
            let _ = SceneManager.switchToScene(ofKind: .loadGameMenu)
        case .continueLast:
            let fileName = ConfigurationData.instance.configurations.lastSaveFileLoaded
            let _ = Session.startFromSaveFile(fileName: fileName)
        case .settings:
            let _ = SceneManager.switchToScene(ofKind: .settingsMenu)
        case .intro:
            if ConfigurationData.instance.configurations.shouldRecommendIntro {
                ConfigurationData.instance.configurations.shouldRecommendIntro = false
                let _ = ConfigurationData.instance.write()
            }
            let _ = Session.startAsIntro(protagonist: IntroProtagonist(levelOfExperience: 60))
        case .quit:
            close()
            NSApp.terminate(self)
        }
    }
    
    /// Handles mouse entered events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseEnteredEvent(_ event: MouseEvent) {
        if let data = event.data as? ListTrackingData {
            if let selection = selection { unselectEntry(selection) }
            selectEntry(data.listEntry)
        }
    }
    
    /// Handles mouse exited events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseExitedEvent(_ event: MouseEvent) {
        if let data = event.data as? ListTrackingData {
            unselectEntry(data.listEntry)
        }
    }
}

/// A struct that defines the data associated with the `MainMenu` class.
///
fileprivate struct MainMenuData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Option.primaryButtonImage,
                Option.secondaryButtonImage,
                Option.regularKeyImage,
                Option.wideKeyImage,
                MainTitle.titleImage]
    }
    
    /// The vertical offset to apply between each element.
    ///
    static let elementYOffset: CGFloat = 40.0
    
    private init() {}
    
    /// The data to use for the `UIListElement`.
    ///
    struct List {
        private init() {}
        static let entryOffset: CGFloat = 6.0
        static let labelSize = CGSize(width: 160.0, height: 34.0)
        static let backgroundImage: String? = nil
        static let backgroundBorder: UIBorder? = nil
        static let backgroundOffset: CGFloat = 0
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
    
    /// The data to use for the `UIMainTitleElement`.
    ///
    struct MainTitle {
        private init() {}
        static let titleImage = "Main_Title"
    }
}
