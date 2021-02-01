//
//  LoadGameMenu.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/8/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `Menu` type that defines the load game menu, used to manage saved games.
///
class LoadGameMenu: Menu, TextureUser {
    
    static var textureNames: Set<String> {
        let portraits = [PortraitSet.fighter.imageName, PortraitSet.rogue.imageName, PortraitSet.wizard.imageName,
                         PortraitSet.cleric.imageName]
        return LoadGameMenuData.textureNames.union(portraits)
    }
    
    /// A class representing a save entry in the load menu.
    ///
    private class SaveEntry {
        
        /// The `DateFormatter` used to format the entry's dates.
        ///
        private static let dateFormatter = getDateFormatter()
        
        /// The `RawData` instance which this entry represents.
        ///
        let rawData: RawData
        
        /// Creates a new instance from the given raw data.
        ///
        /// - Parameter rawData: The `RawData` instance which the entry must represent.
        ///
        init(rawData: RawData) {
            self.rawData = rawData
        }
        
        /// Populates an `UISavesElement.SaveEntry` instance with data from this entry.
        ///
        /// - Parameter uiEntry: The UI entry to populate.
        ///
        func populateEntry(_ uiEntry: UISavesElement.SaveEntry) {
            switch rawData.characterType {
            case is Fighter.Type:
                uiEntry.portrait.portrait = PortraitSet.fighter
                uiEntry.info.text = "Level \(rawData.experience.level) Fighter"
            case is Rogue.Type:
                uiEntry.portrait.portrait = PortraitSet.rogue
                uiEntry.info.text = "Level \(rawData.experience.level) Rogue"
            case is Wizard.Type:
                uiEntry.portrait.portrait = PortraitSet.wizard
                uiEntry.info.text = "Level \(rawData.experience.level) Wizard"
            case is Cleric.Type:
                uiEntry.portrait.portrait = PortraitSet.cleric
                uiEntry.info.text = "Level \(rawData.experience.level) Cleric"
            default:
                uiEntry.portrait.portrait = PortraitSet.question
                uiEntry.info.text = nil
            }
            
            uiEntry.name.text = rawData.personaName
            uiEntry.creationDate.text = "Created:\n" + SaveEntry.dateFormatter.string(from: rawData.creationDate)
            uiEntry.saveDate.text = "Last Played:\n" + SaveEntry.dateFormatter.string(from: rawData.modificationDate)
        }
        
        /// Clears an `UISavesElement.SaveEntry` instance.
        ///
        /// - Parameter uiEntry: The UI entry to clear.
        ///
        class func clearEntry(_ uiEntry: UISavesElement.SaveEntry) {
            uiEntry.portrait.portrait = nil
            uiEntry.name.text = nil
            uiEntry.info.text = nil
            uiEntry.creationDate.text = nil
            uiEntry.saveDate.text = nil
        }
        
        /// Retrieves the date formatter used by the entries.
        ///
        /// - Returns: A `DateFormatter` instance to use when formatting an entry's dates.
        ///
        private class func getDateFormatter() -> DateFormatter {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            return dateFormatter
        }
    }
    
    /// An enum that defines the saves selection.
    ///
    private enum SavesSelection {
        case entry(rowIndex: Int), nextArrow, previousArrow
    }
    
    /// The tracking data for the saves element.
    ///
    private typealias SavesTrackingData = SavesSelection
    
    let node: SKNode
    
    /// The label displayed when fetching data.
    ///
    private let fetchNode: SKLabelNode
    
    /// The `UISavesElement` instance.
    ///
    private let savesElement: UISavesElement
    
    /// The `UIOptionElement` instance.
    ///
    private let optionElement: UIOptionElement
    
    /// The `UITitleElement` instance.
    ///
    private let titleElement: UITitleElement
    
    /// The save entries.
    ///
    private var saveEntries = [SaveEntry?]()
    
    /// The current saves selection.
    ///
    private var selection: SavesSelection?
    
    /// The index of the current page.
    ///
    private var page = 1
    
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
        
        let uiText = UIText(maxWidth: 1024.0, style: .loading, text: "Fetching Data...")
        uiText.flash()
        fetchNode = uiText.node
        fetchNode.zPosition = DepthLayer.overlays.upperBound
        
        // Create the saves element
        savesElement = UISavesElement(rows: LoadGameMenuData.Saves.rows,
                                      entryOffset: LoadGameMenuData.Saves.entryOffset,
                                      contentOffset: LoadGameMenuData.Saves.contentOffset,
                                      labelSize: LoadGameMenuData.Saves.labelSize,
                                      emptyPortraitImage: LoadGameMenuData.Saves.emptyPortraitImage,
                                      arrowImage: LoadGameMenuData.Saves.arrowImage,
                                      backgroundImage: LoadGameMenuData.Saves.backgroundImage,
                                      backgroundBorder: LoadGameMenuData.Saves.backgroundBorder,
                                      backgroundOffset: LoadGameMenuData.Saves.backgroundOffset)
        
        // Create the option element
        optionElement = UIOptionElement(size: LoadGameMenuData.Option.size,
                                        entryOffset: LoadGameMenuData.Option.entryOffset,
                                        contentOffset: LoadGameMenuData.Option.contentOffset,
                                        primaryButtonImage: LoadGameMenuData.Option.primaryButtonImage,
                                        secondaryButtonImage: LoadGameMenuData.Option.secondaryButtonImage,
                                        regularKeyImage: LoadGameMenuData.Option.regularKeyImage,
                                        wideKeyImage: LoadGameMenuData.Option.wideKeyImage)
        
        // Create the title element
        titleElement = UITitleElement(title: LoadGameMenuData.Title.title,
                                      maxSize: LoadGameMenuData.Title.maxSize,
                                      backgroundImage: LoadGameMenuData.Title.backgroundImage,
                                      backgroundBorder: LoadGameMenuData.Title.backgroundBorder)
        
        // Add tracking data to the saves element
        for i in 0..<savesElement.rows {
            savesElement.addTrackindDataForEntry(at: i, data: SavesTrackingData.entry(rowIndex: i))
        }
        savesElement.addTrackindDataForNextArrow(data: SavesTrackingData.nextArrow)
        savesElement.addTrackindDataForPreviousArrow(data: SavesTrackingData.previousArrow)
        
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
        let yOffset: CGFloat = LoadGameMenuData.elementYOffset
        
        // Calculate the required width
        let topWidth = titleElement.size.width
        let middleWidth = savesElement.size.width
        let bottomWidth = optionElement.size.width
        let width = max(topWidth, max(middleWidth, bottomWidth))
        
        // Calculate the required height
        let topHeight = max(titleElement.size.height, optionElement.size.height) + yOffset
        let middleHeight = savesElement.size.height
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
        
        // Add the saves element to the middle
        middleSection.addElement(savesElement)
        
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
    
    /// Replaces the `saveEntries` property with new ones loaded from disk, asynchronously.
    ///
    /// - Parameter completionHandler: A closure to call when the operation completes.
    ///
    private func loadSaveEntries(completionHandler: @escaping () -> Void) {
        saveEntries = []
        DataFileManager.instance.downloadRawData { _ in
            DataFileManager.instance.readAllRawData { [unowned self] in
                $0.forEach {
                    if let rawData = RawData(data: $0) {
                        self.saveEntries.append(SaveEntry(rawData: rawData))
                    }
                }
                self.saveEntries.sort { a, b in a!.rawData.modificationDate > b!.rawData.modificationDate }
                completionHandler()
            }
        }
    }
    
    /// Sets the `UIOptionElement` based on the current `selection`.
    ///
    private func setOption() {
        let loadOption = (UIOptionElement.OptionButton.primaryButton, "Load game")
        let deleteOption = (UIOptionElement.OptionButton.keyCode(.delete), "Delete save file")
        let nextOption = (UIOptionElement.OptionButton.primaryButton, "Next page")
        let previousOption = (UIOptionElement.OptionButton.primaryButton, "Previous page")
        let backOption = (UIOptionElement.OptionButton.key(.back), "Back")
        
        switch selection {
        case .some(let value):
            switch value {
            case .entry(let rowIndex):
                let i = (page - 1) * savesElement.rows + rowIndex
                if i >= 0 && i < saveEntries.count, saveEntries[i] != nil {
                    optionElement.replaceWith(options: [loadOption, deleteOption, backOption])
                } else {
                    optionElement.replaceWith(options: [backOption])
                }
            case .nextArrow:
                optionElement.replaceWith(options: [nextOption, backOption])
            case .previousArrow:
                optionElement.replaceWith(options: [previousOption, backOption])
            }
        case .none:
            optionElement.replaceWith(options: [backOption])
        }
    }
    
    /// Sets the saves with the contents of the given page.
    ///
    /// - Note: This method will not check if the page index is valid or not.
    ///
    /// - Parameter page: The number of the page to set.
    ///
    private func setPage(_ page: Int) {
        self.page = page
        for i in 0..<savesElement.rows {
            guard let uiEntry = savesElement.entryAt(index: i) else { continue }
            let j = (page - 1) * savesElement.rows + i
            if j >= 0 && j < saveEntries.count, saveEntries[j] != nil {
                saveEntries[j]!.populateEntry(uiEntry)
            } else {
                SaveEntry.clearEntry(uiEntry)
            }
        }
    }
    
    /// Sets the previous/next arrows.
    ///
    private func setArrows() {
        let firstPage = 1
        let lastPage = max((saveEntries.count - 1) / savesElement.rows, 0) + 1
        if firstPage == lastPage {
            savesElement.previousArrow.conceal()
            savesElement.nextArrow.conceal()
        } else {
            switch page {
            case firstPage:
                savesElement.previousArrow.conceal()
                savesElement.nextArrow.reveal()
            case lastPage:
                savesElement.previousArrow.reveal()
                savesElement.nextArrow.conceal()
            default:
                savesElement.previousArrow.reveal()
                savesElement.nextArrow.reveal()
            }
        }
    }
    
    /// Switches to the next page.
    ///
    private func nextPage() {
        if page < (1 + saveEntries.count / savesElement.rows) {
            setPage(page + 1)
            setArrows()
        }
    }
    
    /// Switches to the previous page.
    ///
    private func previousPage() {
        if page > 1 {
            setPage(page - 1)
            setArrows()
        }
    }
    
    /// Unselects the save entry under the given row index.
    ///
    /// - Parameters:
    ///   - entry: The row index of the entry to unselect.
    ///   - nullifySelection: A flag stating whether or not the instance's `selection` property should
    ///     be set to `nil` when it is the same as the method's parameter. The default value is `true`.
    ///
    private func unselectEntry(rowIndex: Int, nullifySelection: Bool = true) {
        guard let entry = savesElement.entryAt(index: rowIndex) else { return }
        
        if nullifySelection, let selection = selection {
            switch selection {
            case .entry(let currentRowIndex):
                if rowIndex == currentRowIndex { self.selection = nil }
            default:
                break
            }
        }
        entry.portrait.unflash()
        entry.background?.unflash()
        setOption()
    }
    
    /// Unselects the next arrow.
    ///
    private func unselectNextArrow() {
        if let selection = selection {
            switch selection {
            case .nextArrow:
                self.selection = nil
            default:
                break
            }
        }
//        savesElement.nextArrow.dull()
        savesElement.nextArrow.steady()
        setOption()
    }
    
    /// Unselects the previous arrow.
    ///
    private func unselectPreviousArrow() {
        if let selection = selection {
            switch selection {
            case .previousArrow:
                self.selection = nil
            default:
                break
            }
        }
//        savesElement.previousArrow.dull()
        savesElement.previousArrow.steady()
        setOption()
    }
    
    /// Unselects all entries and arrows.
    ///
    private func unselectAll() {
        for i in 0..<savesElement.rows {
            unselectEntry(rowIndex: i)
        }
        unselectNextArrow()
        unselectPreviousArrow()
    }
    
    /// Selects the save entry under the given row index.
    ///
    /// - Parameters:
    ///   - rowIndex: The row index of the entry to select.
    ///   - ignoreCurrent: A flag stating whether or not the instance's `selection` property should
    ///     be overriden when it is the same as the method's parameter. The default value is `false`.
    ///
    private func selectEntry(rowIndex: Int, ignoreCurrent: Bool = false) {
        guard let entry = savesElement.entryAt(index: rowIndex) else { return }
        
        if !ignoreCurrent, let selection = selection {
            switch selection {
            case .entry(let currentRowIndex):
                if rowIndex == currentRowIndex { return }
            default:
                break
            }
        }
        selection = .entry(rowIndex: rowIndex)
        entry.portrait.flash()
        entry.background?.flash()
        setOption()
    }
    
    /// Selects the next arrow.
    ///
    private func selectNextArrow() {
        if let selection = selection {
            switch selection {
            case .nextArrow:
                return
            default:
                break
            }
        }
        selection = .nextArrow
        savesElement.nextArrow.undull()
        savesElement.nextArrow.pulsate()
        setOption()
    }
    
    /// Selects the previous arrow.
    ///
    private func selectPreviousArrow() {
        if let selection = selection {
            switch selection {
            case .previousArrow:
                return
            default:
                break
            }
        }
        selection = .previousArrow
        savesElement.previousArrow.undull()
        savesElement.previousArrow.pulsate()
        setOption()
    }
    
    func open(onClose: @escaping () -> Void) -> Bool {
        guard !isOpen else { return false }
        isOpen = true
        
        dull()
        if let scene = SceneManager.scene(ofKind: .loadGameMenu) {
            fetchNode.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
            scene.addChild(fetchNode)
        }
        loadSaveEntries { [unowned self] in
            self.fetchNode.removeFromParent()
            self.undull()
            self.setPage(1)
            self.setArrows()
            self.setOption()
            switch self.selection {
            case .some(let selection):
                switch selection {
                case .entry(let rowIndex):
                    self.selectEntry(rowIndex: rowIndex, ignoreCurrent: true)
                case .nextArrow:
                    self.selectNextArrow()
                case .previousArrow:
                    self.selectPreviousArrow()
                }
            case .none:
                break
            }
        }
        
        self.onClose = onClose
        return true
    }
    
    func update(deltaTime seconds: TimeInterval) {
        
    }
    
    func close() {
        onClose?()
        onClose = nil
        isOpen = false
        saveEntries = []
        unselectAll()
        undull()
        if let controllableOverlay = controllableOverlay {
            menuScene?.removeOverlay(controllableOverlay)
            self.controllableOverlay = nil
        }
        fetchNode.removeFromParent()
    }
    
    func didReceiveEvent(_ event: Event) {
        if fetchNode.parent != nil || controllableOverlay != nil {
            // Update the selection property
            switch event.type {
            case .mouseEntered:
                if let event = event as? MouseEvent, let data = event.data as? SavesTrackingData {
                    selection = data
                }
            case .mouseExited:
                if let event = event as? MouseEvent, let _ = event.data as? SavesTrackingData {
                    selection = nil
                }
            default:
                break
            }
            // Dispatch the event to the overlay when applicable
            controllableOverlay?.didReceiveEvent(event)
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
        if event.button == .left, let selection = selection {
            switch selection {
            case .entry(let rowIndex):
                let i = (page - 1) * savesElement.rows + rowIndex
                guard i >= 0 && i < saveEntries.count, let entry = saveEntries[i] else { break }
                let _ = Session.startFromRawData(rawData: entry.rawData)
            case .nextArrow:
                nextPage()
            case .previousArrow:
                previousPage()
            }
        }
    }
    
    /// Handles mouse entered events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseEnteredEvent(_ event: MouseEvent) {
        if let data = event.data as? SavesTrackingData {
            if let selection = selection {
                switch selection {
                case .entry(let rowIndex):
                    unselectEntry(rowIndex: rowIndex)
                case .nextArrow:
                    unselectNextArrow()
                case .previousArrow:
                    unselectPreviousArrow()
                }
            }
            switch data {
            case .entry(let rowIndex):
                selectEntry(rowIndex: rowIndex)
            case .nextArrow:
                selectNextArrow()
            case .previousArrow:
                selectPreviousArrow()
            }
        }
    }
    
    /// Handles mouse exited events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseExitedEvent(_ event: MouseEvent) {
        if let data = event.data as? SavesTrackingData {
            if let selection = selection {
                switch selection {
                case .entry(let rowIndex):
                    unselectEntry(rowIndex: rowIndex)
                case .nextArrow:
                    unselectNextArrow()
                case .previousArrow:
                    unselectPreviousArrow()
                }
            }
            switch data {
            case .entry(let rowIndex):
                unselectEntry(rowIndex: rowIndex)
            case .nextArrow:
                unselectNextArrow()
            case .previousArrow:
                unselectPreviousArrow()
            }
        }
    }
    
    /// Handles keyboard key down events.
    ///
    /// - Parameter event: The event.
    ///
    private func keyDownEvent(_ event: KeyboardEvent) {
        // Special key (delete save data)
        if event.keyCode == KeyboardKeyCode.delete.rawValue {
            if let selection = selection {
                switch selection {
                case .entry(let rowIndex):
                    let i = (page - 1) * savesElement.rows + rowIndex
                    guard i >= 0 && i < saveEntries.count, let entry = saveEntries[i] else { break }
                    guard let menuScene = menuScene else { break }
                    
                    unselectEntry(rowIndex: rowIndex, nullifySelection: false)
                    dull()
                    let rect = menuScene.frame
                    let content = """
                    Delete '\(entry.rawData.personaName)' save data?
                    This operation cannot be undone.
                    """
                    controllableOverlay = ConfirmationOverlay(rect: rect, content: content) {
                        [unowned self] in
                        switch self.selection {
                        case .some(let selection):
                            switch selection {
                            case .entry(let rowIndex):
                                self.selectEntry(rowIndex: rowIndex, ignoreCurrent: true)
                            case .nextArrow:
                                self.selectNextArrow()
                            case .previousArrow:
                                self.selectPreviousArrow()
                            }
                        case .none:
                            break
                        }
                        self.undull()
                        self.menuScene?.removeOverlay(self.controllableOverlay!)
                        if let overlay = self.controllableOverlay as? ConfirmationOverlay {
                            if overlay.confirmed {
                                entry.rawData.delete()
                                let lastSave = ConfigurationData.instance.configurations.lastSaveFileLoaded
                                if lastSave == entry.rawData.fileName {
                                    ConfigurationData.instance.configurations.lastSaveFileLoaded = ""
                                }
                                self.saveEntries[i] = nil
                                self.setPage(self.page)
                            }
                        }
                        self.controllableOverlay = nil
                    }
                    menuScene.addOverlay(controllableOverlay!)
                    
                default:
                    break
                }
            }
            return
        }
        
        guard let mapping = KeyboardMapping.mappingFor(keyCode: event.keyCode, modifiers: event.modifiers)
            else { return }
        
        if mapping.contains(.back) {
            let _ = SceneManager.switchToScene(ofKind: .mainMenu)
        }
    }
}

/// A struct that defines the data associated with the `LoadGAmeMenu` class.
///
fileprivate struct LoadGameMenuData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Saves.emptyPortraitImage,
                Saves.arrowImage,
                Saves.backgroundImage,
                Option.primaryButtonImage,
                Option.secondaryButtonImage,
                Option.regularKeyImage,
                Option.wideKeyImage]
    }
    
    /// The vertical offset to apply between each element.
    ///
    static let elementYOffset: CGFloat = 40.0
    
    private init() {}
    
    /// The data to use for the `UISavesElement`.
    ///
    struct Saves {
        private init() {}
        static let rows = 4
        static let entryOffset: CGFloat = 16.0
        static let contentOffset: CGFloat = 6.0
        static let labelSize = CGSize(width: 212.0, height: 40.0)
        static let emptyPortraitImage = "UI_Default_Empty_Portrait"
        static let arrowImage = "UI_Arrow"
        static let backgroundImage = "UI_Default_Background_8p"
        static let backgroundBorder = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat = 10.0
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
        static let title = "LOAD GAME"
        static let maxSize = CGSize(width: 272.0, height: 60.0)
        static let backgroundImage: String? = nil
        static let backgroundBorder: UIBorder? = nil
    }
}
