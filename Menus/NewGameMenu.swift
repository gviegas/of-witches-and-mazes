//
//  NewGameMenu.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `Menu` type that defines the new game menu, used to select a protagonist class.
///
class NewGameMenu: Menu, TextureUser {
    
    static var textureNames: Set<String> {
        let portraits = [PortraitSet.fighter.imageName, PortraitSet.rogue.imageName, PortraitSet.wizard.imageName,
                         PortraitSet.cleric.imageName]
        return NewGameMenuData.textureNames.union(portraits)
    }
    
    /// An enum that defines the class choice names.
    ///
    private enum ClassChoice: String {
        case fighter = "Fighter"
        case rogue = "Rogue"
        case wizard = "Wizard"
        case cleric = "Cleric"
        
        /// Creates the information text for the class choice.
        ///
        /// - Returns: The information to use for the class choice.
        ///
        func info() -> String {
            var text = ""
            switch self {
            case .fighter:
                text = "A tireless warrior who excels at sword fighting"
            case .rogue:
                text = "A resourceful thief who can quickly eliminate unsuspecting enemies"
            case .wizard:
                text = "A mysterious spellcaster who wields forbidden sorcery"
            case .cleric:
                text = "A devotee who uses divine powers to heal allies and punish foes"
            }
            return text
        }
        
        /// Creates the portrait for the class choice.
        ///
        /// - Returns: The `Portrait` that represents the class choice.
        ///
        func portrait() -> Portrait {
            var portrait: Portrait
            switch self {
            case .fighter:
                portrait = PortraitSet.fighter
            case .rogue:
                portrait = PortraitSet.rogue
            case .wizard:
                portrait = PortraitSet.wizard
            case .cleric:
                portrait = PortraitSet.cleric
            }
            return portrait
        }
    }
    
    /// A struct that defines the tracking data for the `UIClassChoiceElement`.
    ///
    private struct ClassChoiceTrackingData {
        
        /// The class choice entry.
        ///
        let classChoice: ClassChoice
    }
    
    let node: SKNode
    
    /// The  `UIClassChoiceElement` instance.
    ///
    private let classChoiceElement: UIClassChoiceElement
    
    /// The `UIOptionElement` instance.
    ///
    private let optionElement: UIOptionElement
    
    /// The `UITitleElement` instance.
    ///
    private let titleElement: UITitleElement
    
    /// The names for the class choices.
    ///
    private let classEntries = [ClassChoice.fighter,
                                ClassChoice.rogue,
                                ClassChoice.wizard,
                                ClassChoice.cleric]
    
    /// The currently selected class choice.
    ///
    private var selection: ClassChoice?
    
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
        
        // Create the class choice element
        classChoiceElement = UIClassChoiceElement(choices: classEntries.map { $0.rawValue },
                                                  entryOffset: NewGameMenuData.ClassChoice.entryOffset,
                                                  contentOffset: NewGameMenuData.ClassChoice.contentOffset,
                                                  nameLabelSize: NewGameMenuData.ClassChoice.nameLabelSize,
                                                  infoLabelSize: NewGameMenuData.ClassChoice.infoLabelSize,
                                                  emptyPortraitImage: NewGameMenuData.ClassChoice.emptyPortraitImage,
                                                  backgroundImage: NewGameMenuData.ClassChoice.backgroundImage,
                                                  backgroundBorder: NewGameMenuData.ClassChoice.backgroundBorder,
                                                  backgroundOffset: NewGameMenuData.ClassChoice.backgroundOffset)
        
        // Create the option element
        optionElement = UIOptionElement(size: NewGameMenuData.Option.size,
                                        entryOffset: NewGameMenuData.Option.entryOffset,
                                        contentOffset: NewGameMenuData.Option.contentOffset,
                                        primaryButtonImage: NewGameMenuData.Option.primaryButtonImage,
                                        secondaryButtonImage: NewGameMenuData.Option.secondaryButtonImage,
                                        regularKeyImage: NewGameMenuData.Option.regularKeyImage,
                                        wideKeyImage: NewGameMenuData.Option.wideKeyImage)
        
        // Create the title element
        titleElement = UITitleElement(title: NewGameMenuData.Title.title,
                                      maxSize: NewGameMenuData.Title.maxSize,
                                      backgroundImage: NewGameMenuData.Title.backgroundImage,
                                      backgroundBorder: NewGameMenuData.Title.backgroundBorder)
        
        for entry in classEntries {
            // Set contents
            classChoiceElement.entryNamed(entry.rawValue)?.portrait.portrait = entry.portrait()
            classChoiceElement.entryNamed(entry.rawValue)?.name.text = entry.rawValue
            // Unselect
            unselectEntry(entry)
            // Add tracking data to the class choice element
            classChoiceElement.addTrackingDataForEntry(named: entry.rawValue,
                                                       data: ClassChoiceTrackingData(classChoice: entry))
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
        let yOffset: CGFloat = NewGameMenuData.elementYOffset
        
        // Calculate the required width
        let topWidth = titleElement.size.width
        let middleWidth = classChoiceElement.size.width
        let bottomWidth = optionElement.size.width
        let width = max(topWidth, max(middleWidth, bottomWidth))
        
        // Calculate the required height
        let topHeight = max(titleElement.size.height, optionElement.size.height) + yOffset
        let middleHeight = classChoiceElement.size.height
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
        
        // Add the class choice element to the middle
        middleSection.addElement(classChoiceElement)
        
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
            text = "Create a \(value.rawValue) character"
        case .none:
            text = nil
        }
        
        if let text = text {
            optionElement.replaceWith(options: [(.primaryButton, text), (.key(.back), "Back")])
        } else {
            optionElement.replaceWith(options: [(.key(.back), "Back")])
        }
    }
    
    /// Unselects the given entry.
    ///
    /// - Parameters:
    ///   - entry: The entry to unselect.
    ///   - nullifySelection: A flag stating whether or not the instance's `selection` property should
    ///     be set to `nil` when it is the same as the method's parameter. The default value is `true`.
    ///
    private func unselectEntry(_ entry: ClassChoice, nullifySelection: Bool = true) {
        if nullifySelection, entry == selection { selection = nil }
        let choice = classChoiceElement.entryNamed(entry.rawValue)!
        choice.name.dull()
        choice.info.text = nil
        choice.portrait.unflash()
        choice.portrait.darken()
        setOption()
    }
    
    /// Unselects all entries.
    ///
    private func unselectAll() {
        for entry in classEntries {
            unselectEntry(entry)
        }
    }
    
    /// Selects the given entry.
    ///
    /// - Parameter entry: The entry to select.
    ///
    private func selectEntry(_ entry: ClassChoice) {
        selection = entry
        let choice = classChoiceElement.entryNamed(entry.rawValue)!
        choice.name.undull()
        choice.info.text = entry.info()
        choice.portrait.undarken()
        choice.portrait.flash()
        setOption()
    }
    
    /// Chooses a character class.
    ///
    /// - Parameters:
    ///   - choice: The `ClassChoice` that represents the class to be chosen.
    ///   - persona: The character's persona name.
    ///
    private func chooseCharacterClass(_ choice: ClassChoice, persona: String) {
        let protagonist: Protagonist
        let level = 1
        switch choice {
        case .fighter:
            protagonist = Fighter(levelOfExperience: level, personaName: persona)
        case .rogue:
            protagonist = Rogue(levelOfExperience: level, personaName: persona)
        case .wizard:
            protagonist = Wizard(levelOfExperience: level, personaName: persona)
        case .cleric:
            protagonist = Cleric(levelOfExperience: level, personaName: persona)
        }
        let _ = Session.startAsNewGame(protagonist: protagonist)
    }
    
    func open(onClose: @escaping () -> Void) -> Bool {
        guard !isOpen else { return false }
        isOpen = true
    
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
                if let event = event as? MouseEvent, let data = event.data as? ClassChoiceTrackingData {
                    selection = data.classChoice
                }
            case .mouseExited:
                if let event = event as? MouseEvent, let _ = event.data as? ClassChoiceTrackingData {
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
        guard event.button == .left, let selection = selection else { return }

        // Create a prompt overlay to enter the name and confirm/cancel
        if controllableOverlay == nil, let menuScene = menuScene {
            unselectEntry(selection, nullifySelection: false)
            dull()
            let rect = menuScene.frame
            controllableOverlay = PromptOverlay.personaNamePrompt(rect: rect) {
                [unowned self] in
                if let overlay = self.controllableOverlay as? PromptOverlay {
                    if overlay.confirmed, let persona = overlay.promptText {
                        self.chooseCharacterClass(selection, persona: persona)
                    }
                }
                if let selection = self.selection { self.selectEntry(selection) }
                self.undull()
                self.menuScene?.removeOverlay(self.controllableOverlay!)
                self.controllableOverlay = nil
            }
            menuScene.addOverlay(controllableOverlay!)
        }
    }
    
    /// Handles mouse entered events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseEnteredEvent(_ event: MouseEvent) {
        if let data = event.data as? ClassChoiceTrackingData {
            if let selection = selection { unselectEntry(selection) }
            selectEntry(data.classChoice)
        }
    }
    
    /// Handles mouse exited events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseExitedEvent(_ event: MouseEvent) {
        if let data = event.data as? ClassChoiceTrackingData {
            unselectEntry(data.classChoice)
        }
    }
    
    /// Handles keyboard key down events.
    ///
    /// - Parameter event: The event.
    ///
    private func keyDownEvent(_ event: KeyboardEvent) {
        guard let mapping = KeyboardMapping.mappingFor(keyCode: event.keyCode, modifiers: event.modifiers)
            else { return }

        if mapping.contains(.back) {
            let _ = SceneManager.switchToScene(ofKind: .mainMenu)
        }
    }
}

/// A struct that defines the data associated with the `NewGameMenu` class.
///
fileprivate struct NewGameMenuData: TextureUser {
    
    static var textureNames: Set<String> {
        return [ClassChoice.emptyPortraitImage,
                Option.primaryButtonImage,
                Option.secondaryButtonImage,
                Option.regularKeyImage,
                Option.wideKeyImage]
    }
    
    /// The vertical offset to apply between each element.
    ///
    static let elementYOffset: CGFloat = 40.0
    
    private init() {}
    
    /// The data to use for the `UIClassChoiceElement`.
    ///
    struct ClassChoice {
        private init() {}
        static let entryOffset: CGFloat = 48.0
        static let contentOffset: CGFloat = 6.0
        static let nameLabelSize = CGSize(width: 150.0, height: 56.0)
        static let infoLabelSize = CGSize(width: 170.0, height: 90.0)
        static let emptyPortraitImage = "UI_Default_Empty_Portrait"
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
    
    /// The data to use for the `UITitleElement`.
    ///
    struct Title {
        private init() {}
        static let title = "NEW GAME"
        static let maxSize = CGSize(width: 272.0, height: 60.0)
        static let backgroundImage: String? = nil
        static let backgroundBorder: UIBorder? = nil
    }
}
