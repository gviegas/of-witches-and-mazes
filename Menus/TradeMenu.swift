//
//  TradeMenu.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/9/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `Menu` type that defines the trade menu, enabling the protagonist to buy and
/// sell items from/to a NPC.
///
class TradeMenu: Menu, TextureUser {
    
    static var textureNames: Set<String> {
        return TradeMenuData.textureNames
    }
    
    /// An enum that defines the trade entries.
    ///
    private enum TradeEntry {
        
        /// The column and row indices of a NPC's backpack entry.
        ///
        case npcBackpack(column: Int, row: Int)
        
        /// The column and row indices of a protagonist's backpack entry.
        ///
        case protagonistBackpack(column: Int, row: Int)
    }
    
    /// The tracking data for the trade's backpack elements.
    ///
    private typealias TradeTrackingData = TradeEntry
    
    private var protagonist: Entity {
        guard let entity = Game.protagonist else {
            fatalError("TradeMenu requires Game.protagonist to be non-nil")
        }
        return entity
    }
    
    private var npc: Entity {
        guard let entity = Game.subject else {
            fatalError("TradeMenu requires Game.subject to be non-nil")
        }
        return entity
    }
    
    private var npcInventory: InventoryComponent {
        guard let component = npc.component(ofType: InventoryComponent.self) else {
            fatalError("TradeMenu requires a NPC that has an InventoryComponent")
        }
        return component
    }
    
    private var npcVendor: VendorComponent {
        guard let component = npc.component(ofType: VendorComponent.self) else {
            fatalError("TradeMenu requires a NPC that has a VendorComponent")
        }
        return component
    }
    
    private var protagonistInventory: InventoryComponent {
        guard let component = protagonist.component(ofType: InventoryComponent.self) else {
            fatalError("TradeMenu requires a protagonist that has an InventoryComponent")
        }
        return component
    }
    
    private var protagonistEquipment: EquipmentComponent {
        guard let component = protagonist.component(ofType: EquipmentComponent.self) else {
            fatalError("TradeMenu requires a protagonist that has an EquipmentComponent")
        }
        return component
    }
    
    let node: SKNode
    
    /// The `UIBackpackElement` instance for the NPC.
    ///
    private let npcBackpackElement: UIBackpackElement
    
    /// The `UIBackpackElement` instance for the protagonist.
    ///
    private let protagonistBackpackElement: UIBackpackElement
    
    /// The `UIDoublePortraitElement` instance.
    ///
    private let doublePortraitElement: UIDoublePortraitElement
    
    /// The `UIDoubleLabelElement` instance.
    ///
    private let doubleLabelElement: UIDoubleLabelElement
    
    /// The `UIOptionElement` instance.
    ///
    private let optionElement: UIOptionElement
    
    /// The `UITitleElement` instance.
    ///
    private let titleElement: UITitleElement
    
    /// The currently selected trade entry.
    ///
    private var selection: TradeEntry?
    
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
        
        // Create the NPC's backpack element
        npcBackpackElement = UIBackpackElement(columns: TradeMenuData.NpcBackpack.columns,
                                               rows: TradeMenuData.NpcBackpack.rows,
                                               slotOffset: TradeMenuData.NpcBackpack.slotOffset,
                                               backpackImage: TradeMenuData.NpcBackpack.backpackImage,
                                               emptyIconImage: TradeMenuData.NpcBackpack.emptyIconImage,
                                               backgroundImage: TradeMenuData.NpcBackpack.backgroundImage,
                                               backgroundBorder: TradeMenuData.NpcBackpack.backgroundBorder,
                                               backgroundOffset: TradeMenuData.NpcBackpack.backgroundOffset)
        
        // Create the protagonist's backpack element
        protagonistBackpackElement = UIBackpackElement(columns: TradeMenuData.ProtagonistBackpack.columns,
                                                       rows: TradeMenuData.ProtagonistBackpack.rows,
                                                       slotOffset: TradeMenuData.ProtagonistBackpack.slotOffset,
                                                       backpackImage: TradeMenuData.ProtagonistBackpack.backpackImage,
                                                       emptyIconImage: TradeMenuData.ProtagonistBackpack.emptyIconImage,
                                                       backgroundImage: TradeMenuData.ProtagonistBackpack.backgroundImage,
                                                       backgroundBorder: TradeMenuData.ProtagonistBackpack.backgroundBorder,
                                                       backgroundOffset: TradeMenuData.ProtagonistBackpack.backgroundOffset)
        
        // Create the double portrait element
        doublePortraitElement = UIDoublePortraitElement(leftEmptyImage: TradeMenuData.DoublePortrait.leftEmptyImage,
                                                        rightEmptyImage: TradeMenuData.DoublePortrait.rightEmptyImage,
                                                        contentOffset: TradeMenuData.DoublePortrait.contentOffset,
                                                        boundaryOffset: TradeMenuData.DoublePortrait.boundaryOffset)
        
        // Create the double label element
        doubleLabelElement = UIDoubleLabelElement(leftLabelSize: TradeMenuData.DoubleLabel.leftLabelSize,
                                                  rightLabelSize: TradeMenuData.DoubleLabel.rightLabelSize,
                                                  contentOffset: TradeMenuData.DoubleLabel.contentOffset,
                                                  boundaryOffset: TradeMenuData.DoubleLabel.boundaryOffset)
        
        // Create the option element
        optionElement = UIOptionElement(size: TradeMenuData.Option.size,
                                        entryOffset: TradeMenuData.Option.entryOffset,
                                        contentOffset: TradeMenuData.Option.contentOffset,
                                        primaryButtonImage: TradeMenuData.Option.primaryButtonImage,
                                        secondaryButtonImage: TradeMenuData.Option.secondaryButtonImage,
                                        regularKeyImage: TradeMenuData.Option.regularKeyImage,
                                        wideKeyImage: TradeMenuData.Option.wideKeyImage)
        
        // Create the title element
        titleElement = UITitleElement(title: TradeMenuData.Title.title,
                                      maxSize: TradeMenuData.Title.maxSize,
                                      backgroundImage: TradeMenuData.Title.backgroundImage,
                                      backgroundBorder: TradeMenuData.Title.backgroundBorder)
        
        // Add tracking data for the npc backpack element
        for i in 0..<npcBackpackElement.rows {
            for j in 0..<npcBackpackElement.columns {
                let data = TradeTrackingData.npcBackpack(column: j, row: i)
                npcBackpackElement.addTrackingDataForSlotAt(column: j, row: i, data: data)
            }
        }
        
        // Add tracking data for the protagonist backpack element
        for i in 0..<protagonistBackpackElement.rows {
            for j in 0..<protagonistBackpackElement.columns {
                let data = TradeTrackingData.protagonistBackpack(column: j, row: i)
                protagonistBackpackElement.addTrackingDataForSlotAt(column: j, row: i, data: data)
            }
        }
        
        // Set double label
        doubleLabelElement.leftLabel.style = .price
        doubleLabelElement.rightLabel.style = .price
        
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
        let xOffset: CGFloat = TradeMenuData.elementXOffset
        let yOffset: CGFloat = TradeMenuData.elementYOffset
        
        // Calculate the required width
        let topWidth = titleElement.size.width + xOffset
        var middleWidth = npcBackpackElement.size.width + xOffset
        middleWidth += max(doublePortraitElement.size.width, doubleLabelElement.size.width) + xOffset
        middleWidth += protagonistBackpackElement.size.width + xOffset
        let bottomWidth = optionElement.size.width + xOffset
        
        let width = max(topWidth, max(middleWidth, bottomWidth))
        
        // Calculate the required height
        let topHeight = max(titleElement.size.height, optionElement.size.height) + yOffset
        var middleHeight = max(npcBackpackElement.size.height, protagonistBackpackElement.size.height)
        middleHeight = max(middleHeight, doublePortraitElement.size.height + doubleLabelElement.size.height)
        middleHeight += yOffset
        let bottomHeight = topHeight
        
        let height = topHeight + middleHeight + bottomHeight
        
        // Check if the required dimensions for all the elements fits inside the rect
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
        let middleSection = UIContainer(plane: .horizontal, ratio: middleRatio)
        let bottomSection = UIContainer(plane: .vertical, ratio: bottomRatio)
        
        // Append the main divisions plus blank sections between top, bottom and middle sections
        let remaining = rect.height - (rect.height * (topRatio + middleRatio + bottomRatio))
        let topBlankRatio = ((1.0 - topRatio / (topRatio + bottomRatio)) * remaining) / rect.height
        let bottomBlankRatio = ((1.0 - bottomRatio / (topRatio + bottomRatio)) * remaining) / rect.height
        flag = root.appendContainer(topSection); assert(flag)
        flag = root.appendContainer(UIContainer(plane: .horizontal, ratio: topBlankRatio)); assert(flag)
        flag = root.appendContainer(middleSection); assert(flag)
        flag = root.appendContainer(UIContainer(plane: .horizontal, ratio: bottomBlankRatio)); assert(flag)
        flag = root.appendContainer(bottomSection); assert(flag)
        
        // Divide the middle in three sections
        let part1Ratio = (npcBackpackElement.size.width + xOffset) / rect.width
        let part2Ratio = (max(doublePortraitElement.size.width, doubleLabelElement.size.width) + xOffset) / rect.width
        let part3Ratio = (protagonistBackpackElement.size.width + xOffset) / rect.width
        let npcBackpackSection = UIContainer(plane: .vertical, ratio: part1Ratio)
        let doubleSection = UIContainer(plane: .vertical, ratio: part2Ratio)
        let protagonistBackpackSection = UIContainer(plane: .vertical, ratio: part3Ratio)
        
        // Append the element sections plus blank sections to the middle section
        let middleBlankRatio = (1.0 - middleWidth / rect.width) / 2.0
        flag = middleSection.appendContainer(UIContainer(plane: .horizontal, ratio: middleBlankRatio)); assert(flag)
        flag = middleSection.appendContainer(npcBackpackSection); assert(flag)
        flag = middleSection.appendContainer(doubleSection); assert(flag)
        flag = middleSection.appendContainer(protagonistBackpackSection); assert(flag)
        flag = middleSection.appendContainer(UIContainer(plane: .horizontal, ratio: middleBlankRatio)); assert(flag)
        
        // Divide the double section in two sections
        let upperDoubleRatio = (doublePortraitElement.size.height) / middleHeight
        let lowerDoubleRatio = (doubleLabelElement.size.height) / middleHeight
        let upperDoubleSection = UIContainer(plane: .horizontal, ratio: upperDoubleRatio)
        let lowerDoubleSection = UIContainer(plane: .horizontal, ratio: lowerDoubleRatio)
        
        // Append the upper and lower sections plus blank sections to the double section
        let doubleBlankRatio = (1.0 - middleHeight / rect.height) / 2.0
        flag = doubleSection.appendContainer(UIContainer(plane: .vertical, ratio: doubleBlankRatio)); assert(flag)
        flag = doubleSection.appendContainer(upperDoubleSection); assert(flag)
        flag = doubleSection.appendContainer(lowerDoubleSection); assert(flag)
        flag = doubleSection.appendContainer(UIContainer(plane: .vertical, ratio: doubleBlankRatio)); assert(flag)
        
        // Add the title element to the top
        topSection.addElement(titleElement)
        
        // Add the NPC backpack element to the middle-left
        npcBackpackSection.addElement(npcBackpackElement)
        
        // Add the double portrait and double label elements to the NPC backpack's side
        upperDoubleSection.addElement(doublePortraitElement)
        lowerDoubleSection.addElement(doubleLabelElement)
        
        // Add the protagonist backpack element to the double portrait's side
        protagonistBackpackSection.addElement(protagonistBackpackElement)
        
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
    
    /// Converts the given column and row indices of the `UIBackpackElement` to a single
    /// index that can be used in the `InventoryComponent`.
    ///
    /// - Parameters:
    ///   - column: The column index to convert from.
    ///   - row: The row index to convert from.
    ///   - backpack: The source `UIBackpackElement`.
    ///   - inventory: The target `InventoryComponent`.
    /// - Returns: The single array index if successful, `nil` if out of bounds.
    ///
    private func arrayIndexFor(column: Int, row: Int, backpack: UIBackpackElement, inventory: InventoryComponent) -> Int? {
        let index = row * backpack.columns + column
        
        if index >= 0 && index < inventory.capacity {
            return index
        }
        return nil
    }
    
    /// Converts the given index of the `InventoryComponent` to column and row indices
    /// that can be used in the `UIBackpackElement`.
    ///
    /// - Parameters:
    ///   - index: The index to convert from.
    ///   - backpack: The target `UIBackpackElement`.
    /// - Returns: The grid index as a (column, row) pair if successful, `nil` if out of bounds.
    ///
    private func gridIndexFor(index: Int, backpack: UIBackpackElement) -> (column: Int, row: Int)? {
        let column = index % backpack.columns
        let row = index / backpack.columns
        
        if column >= 0 && row >= 0 && column < backpack.columns && row < backpack.rows {
            return (column, row)
        }
        return nil
    }
    
    /// Computes the reference rect for a given `UIIcon`.
    ///
    /// - Parameter slot: The icon slot.
    /// - Returns: The reference rect.
    ///
    private func referenceRectFor(slot: UIIcon) -> CGRect {
        let origin = node.convert(slot.node.position, from: slot.node.parent!)
        let size = slot.node.size
        return CGRect(x: origin.x - size.width / 2.0, y: origin.y - size.height / 2.0,
                      width: size.width, height: size.height)
    }
    
    /// Sets the given `UIBackpackElement` index based on `InventoryComponent` data.
    ///
    /// - Parameters:
    ///   - column: The column index of the backpack.
    ///   - row: The row index of the backpack.
    ///   - backpack: The target backpack.
    ///   - inventory: The target inventory.
    ///   - equipment: An optional `EquipmentComponent` to use.
    ///   - andSetDoubleLabel: A flag stating if `setDoubleLabel()` must be called. The default value is `true`.
    ///
    private func setBackpack(column: Int, row: Int, backpack: UIBackpackElement, inventory: InventoryComponent,
                             equipment: EquipmentComponent?, andSetDoubleLabel: Bool = true) {
        
        guard let index = arrayIndexFor(column: column, row: row, backpack: backpack, inventory: inventory),
            let slot = backpack.slotAt(column: column, row: row) else { return }
        
        let item = inventory.itemAt(index: index)
        
        slot.icon = item?.icon
        slot.text = nil
        slot.undarken()
        
        if let item = item, let equipment = equipment {
            if equipment.isEquipped(item) {
                slot.darken()
            } else if item is StackableItem, equipment.isEquipped(itemNamed: item.name) {
                slot.darken()
            }
        }
        if let stack = (item as? StackableItem)?.stack {
            slot.text = String(stack.count)
        }
        
        if andSetDoubleLabel { setDoubleLabel() }
    }
    
    /// Sets the whole `UIBackpackElement` based on `InventoryComponent` data.
    ///
    /// - Parameters:
    ///   - backpack: The target backpack.
    ///   - inventory: The target inventory.
    ///   - equipment: An optional `EquipmentComponent` to use.
    ///
    private func setBackpack(backpack: UIBackpackElement, inventory: InventoryComponent,
                             equipment: EquipmentComponent?) {
        
        for column in 0..<backpack.columns {
            for row in 0..<backpack.rows {
                setBackpack(column: column, row: row, backpack: backpack, inventory: inventory,
                            equipment: equipment, andSetDoubleLabel: false)
                setDoubleLabel()
            }
        }
    }
    
    /// Sets the `UIDoubleLableElement` based on the curent gold/funds.
    ///
    private func setDoubleLabel() {
        doubleLabelElement.leftLabel.text = "\(npcVendor.fundsAvailable) GP"
        doubleLabelElement.rightLabel.text = "\(protagonistInventory.quantityOf(itemsNamed: "Gold Pieces")) GP"
    }
    
    /// Sets the `UIOptionElement` based on the current `selection`.
    ///
    private func setOption() {
        let buyOption = (UIOptionElement.OptionButton.primaryButton, "Buy item")
        let sellOption = (UIOptionElement.OptionButton.primaryButton, "Sell item")
        let backOption = (UIOptionElement.OptionButton.key(.back), "Back")
        
        switch selection {
        case .some(let value):
            switch value {
            case .npcBackpack(let column, let row):
                let index = arrayIndexFor(column: column, row: row, backpack: npcBackpackElement, inventory: npcInventory)
                if let index = index, let item = npcInventory.itemAt(index: index),
                    let _ = item as? TradableItem {
                    optionElement.replaceWith(options: [buyOption, backOption])
                } else {
                    optionElement.replaceWith(options: [backOption])
                }
            case .protagonistBackpack(let column, let row):
                let index = arrayIndexFor(column: column, row: row, backpack: protagonistBackpackElement, inventory: protagonistInventory)
                if let index = index, let item = protagonistInventory.itemAt(index: index),
                    let _ = item as? TradableItem {
                    optionElement.replaceWith(options: [sellOption, backOption])
                } else {
                    optionElement.replaceWith(options: [backOption])
                }
            }
        case .none:
            optionElement.replaceWith(options: [backOption])
        }
    }
    
    /// Sets the `TooltipOverlay` of the `MenuScene` based on the current `selection`.
    ///
    private func setTooltip() {
        var item: Item?
        var price: Int?
        var referenceRect: CGRect!
        
        if let selection = selection {
            switch selection {
            case .npcBackpack(let column, let row):
                let backpack = npcBackpackElement
                let inventory = npcInventory
                if let index = arrayIndexFor(column: column, row: row, backpack: backpack, inventory: inventory) {
                    item = inventory.itemAt(index: index)
                    if let item = item {
                        price = npcVendor.sellPriceFor(item: item)
                        referenceRect = referenceRectFor(slot: backpack.slotAt(column: column, row: row)!)
                    }
                }
            
            case .protagonistBackpack(let column, let row):
                let backpack = protagonistBackpackElement
                let inventory = protagonistInventory
                if let index = arrayIndexFor(column: column, row: row, backpack: backpack, inventory: inventory) {
                    item = inventory.itemAt(index: index)
                    if let item = item {
                        price = npcVendor.buyPriceFor(item: item)
                        referenceRect = referenceRectFor(slot: backpack.slotAt(column: column, row: row)!)
                    }
                }
            }
        }
        
        if let item = item {
            if let rect = menuScene?.frame {
                let tooltip = TooltipOverlay.itemTooltip(boundingRect: rect, referenceRect: referenceRect,
                                                         item: item, entity: protagonist, price: price)
                menuScene!.tooltipOverlay = tooltip
            }
        } else {
            menuScene?.tooltipOverlay = nil
        }
    }
    
    /// Unselects a trade entry.
    ///
    /// - Parameters:
    ///   - entry: The entry to unselect.
    ///   - nullifySelection: A flag stating whether or not the instance's `selection` property should
    ///     be set to `nil` when it is the same as the method's parameter. The default value is `true`.
    ///
    private func unselectEntry(_ entry: TradeEntry, nullifySelection: Bool = true) {
        if nullifySelection, let selection = selection {
            switch selection {
            case .npcBackpack(let column, let row):
                switch entry {
                case .npcBackpack(let otherColumn, let otherRow):
                    if column == otherColumn && row == otherRow { self.selection = nil }
                default:
                    break
                }
            case .protagonistBackpack(let column, let row):
                switch entry {
                case .protagonistBackpack(let otherColumn, let otherRow):
                    if column == otherColumn && row == otherRow { self.selection = nil }
                default:
                    break
                }
            }
        }
        
        switch entry {
        case .npcBackpack(let column, let row):
            npcBackpackElement.slotAt(column: column, row: row)?.unflash()
        case .protagonistBackpack(let column, let row):
            protagonistBackpackElement.slotAt(column: column, row: row)?.unflash()
        }
        
        setOption()
        setTooltip()
    }
    
    /// Unselects all entries from both backpacks.
    ///
    private func unselectAll() {
        let unselectEach = {
            [unowned self] (backpack: UIBackpackElement, entry: (_ col: Int, _ row: Int) -> TradeEntry) in
            for i in 0..<backpack.rows {
                for j in 0..<backpack.columns {
                    self.unselectEntry(entry(j, i))
                }
            }
        }
        
        unselectEach(npcBackpackElement) {
            TradeEntry.npcBackpack(column: $0, row: $1)
        }
        unselectEach(protagonistBackpackElement) {
            TradeEntry.protagonistBackpack(column: $0, row: $1)
        }
    }
    
    /// Selects a trade entry.
    ///
    /// - Parameter entry: The entry to select.
    ///
    private func selectEntry(_ entry: TradeEntry) {
        self.selection = entry
        switch entry {
        case .npcBackpack(let column, let row):
            npcBackpackElement.slotAt(column: column, row: row)?.flash()
        case .protagonistBackpack(let column, let row):
            protagonistBackpackElement.slotAt(column: column, row: row)?.flash()
        }
        
        setOption()
        setTooltip()
    }
    
    /// Buys the item found at the current `selection`.
    ///
    /// - Note: This method assumes that no item costs more than the `GoldPieces` stack capacity.
    ///
    private func buySelection() {
        guard let selection = selection else { return }

        switch selection {
        case .npcBackpack(let column, let row):
            guard let index = arrayIndexFor(column: column, row: row, backpack: npcBackpackElement,
                                            inventory: npcInventory) else { return }
            guard let item = npcInventory.itemAt(index: index) else { return }

            if let price = npcVendor.sellPriceFor(item: item) {
                if let item = item as? StackableItem, item.stack.count > 1 {
                    buyMany(item, unitPrice: price, index: index, column: column, row: row)
                } else {
                    buyOne(item, price: price, index: index, column: column, row: row)
                }
            } else {
                // Inform that the item cannot be bought
                if let menuScene = menuScene {
                    let note = NoteOverlay(rect: menuScene.frame, text: "This item is not for sale")
                    menuScene.presentNote(note)
                }
            }
        default:
            break
        }
    }
    
    /// Buys one unit from a single stackable item.
    ///
    /// - Parameters:
    ///   - item: The item to buy.
    ///   - price: The unit price for the item.
    ///   - index: The index of the item in the NPC's inventory component.
    ///   - column: The column index in the NPC's backpack where the item is located.
    ///   - row: The row index in the NPC's backpack where the item is located.
    ///
    private func buyOne(_ item: Item, price: Int, index: Int, column: Int, row: Int) {
        let goldName = "Gold Pieces"
        
        guard protagonistInventory.quantityOf(itemsNamed: goldName) >= price  else {
            // Inform that the item is too expensive
            if let menuScene = menuScene {
                let note = NoteOverlay(rect: menuScene.frame, text: "Not enough gold to buy that")
                menuScene.presentNote(note)
            }
            return
        }
        
        var mergeGold = false
        if protagonistInventory.isFull {
            var canProceed = false
            // Check if there is room for the item in another's stack
            if item is StackableItem, protagonistInventory.canStack(itemNamed: item.name, quantity: 1) {
                canProceed = true
            } else {
                // Check if gold spent would free up a slot before finally giving up
                if protagonistInventory.canReduceSpace(itemNamed: goldName, decreasingBy: price) {
                    // A slot will be freed, merging gold stacks should guarantee that
                    mergeGold = true
                    canProceed = true
                }
            }
            guard canProceed else {
                // Inform that the inventory is full and return
                if let menuScene = menuScene {
                    let note = NoteOverlay(rect: menuScene.frame, text: "Inventory is full")
                    menuScene.presentNote(note)
                }
                return
            }
        }
        
        npcVendor.earn(amount: price)
        let _ = npcInventory.removeItem(at: index)
        let _ = protagonistInventory.removeMany(itemsNamed: goldName, quantity: price)
        if mergeGold { protagonistInventory.mergeStacks(itemsNamed: goldName) }
        let newItem = item is StackableItem ? (item as! StackableItem).copy(stackCount: 1) : item.copy()
        let _ = protagonistInventory.addItem(newItem)
        
        // Play sound effect
        SoundFXSet.FX.gold.play(at: nil, sceneKind: .tradeMenu)
        
        // Reset elements
        setBackpack(column: column, row: row, backpack: npcBackpackElement, inventory: npcInventory, equipment: nil)
        setBackpack(backpack: protagonistBackpackElement, inventory: protagonistInventory,
                    equipment: protagonistEquipment)
        setOption()
        setTooltip()
    }
    
    /// Buys many units from a single stackable item.
    ///
    /// - Parameters:
    ///   - item: The item to buy.
    ///   - unitPrice: The unit price for the item.
    ///   - index: The index of the item in the NPC's inventory component.
    ///   - column: The column index in the NPC's backpack where the item is located.
    ///   - row: The row index in the NPC's backpack where the item is located.
    ///
    private func buyMany(_ item: StackableItem, unitPrice: Int, index: Int, column: Int, row: Int) {
        let goldName = "Gold Pieces"
        
        assert(unitPrice > 0)
        let maxQuantity = protagonistInventory.quantityOf(itemsNamed: goldName) / unitPrice
        
        guard maxQuantity > 0  else {
            // Inform that the item is too expensive
            if let menuScene = menuScene {
                let note = NoteOverlay(rect: menuScene.frame, text: "Not enough gold to buy that")
                menuScene.presentNote(note)
            }
            return
        }
        
        if controllableOverlay == nil, let menuScene = menuScene {
            unselectEntry(.npcBackpack(column: column, row: row), nullifySelection: false)
            dull()
            let rect = menuScene.frame
            controllableOverlay = PromptOverlay.purchasePrompt(rect: rect, item: item, maxQuantity: maxQuantity) {
                [unowned self] in
                if let overlay = self.controllableOverlay as? PromptOverlay {
                    if overlay.confirmed, let text = overlay.promptText, let quantity = Int(text) {
                        let price = unitPrice * quantity
                        
//                        guard self.protagonistInventory.quantityOf(itemsNamed: goldName) >= price  else {
//                            // Inform that the item is too expensive
//                            if let menuScene = self.menuScene {
//                                let note = NoteOverlay(rect: menuScene.frame, text: "Not enough gold to buy that")
//                                menuScene.presentNote(note)
//                            }
//                            if let selection = self.selection { self.selectEntry(selection) }
//                            self.undull()
//                            self.menuScene?.removeOverlay(self.controllableOverlay!)
//                            self.controllableOverlay = nil
//                            return
//                        }
                        
                        var mergeGold = false
                        if self.protagonistInventory.isFull {
                            var canProceed = false
                            // Check if there is room for the item in another's stack
                            if self.protagonistInventory.canStack(itemNamed: item.name, quantity: quantity) {
                                canProceed = true
                            } else {
                                // Check if gold spent would free up a slot before finally giving up
                                if self.protagonistInventory.canReduceSpace(itemNamed: goldName, decreasingBy: price) {
                                    // One or more slots will be freed, merging gold stacks should guarantee that
                                    mergeGold = true
                                    canProceed = true
                                }
                            }
                            guard canProceed else {
                                // Inform that the inventory is full and return
                                if let menuScene = self.menuScene {
                                    let note = NoteOverlay(rect: menuScene.frame, text: "Inventory is full")
                                    menuScene.presentNote(note)
                                }
                                if let selection = self.selection { self.selectEntry(selection) }
                                self.undull()
                                self.menuScene?.removeOverlay(self.controllableOverlay!)
                                self.controllableOverlay = nil
                                return
                            }
                        }
                        
                        self.npcVendor.earn(amount: price)
                        let _ = self.npcInventory.reduceStack(at: index, quantity: quantity)
                        let _ = self.protagonistInventory.removeMany(itemsNamed: goldName, quantity: price)
                        if mergeGold { self.protagonistInventory.mergeStacks(itemsNamed: goldName) }
                        let newItem = item.copy(stackCount: quantity)
                        let _ = self.protagonistInventory.addItem(newItem)
                        
                        // Play sound effect
                        SoundFXSet.FX.gold.play(at: nil, sceneKind: .tradeMenu)
                        
                        // Reset elements
                        self.setBackpack(column: column, row: row, backpack: self.npcBackpackElement,
                                    inventory: self.npcInventory, equipment: nil)
                        self.setBackpack(backpack: self.protagonistBackpackElement,
                                         inventory: self.protagonistInventory, equipment: self.protagonistEquipment)
                        self.setOption()
                        self.setTooltip()
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
    
    /// Sells the item found at the current `selection`.
    ///
    /// - Note: This method assumes that no item costs more than the `GoldPieces` stack capacity.
    ///
    private func sellSelection() {
        guard let selection = selection else { return }
        
        switch selection {
        case .protagonistBackpack(let column, let row):
            guard let index = arrayIndexFor(column: column, row: row, backpack: protagonistBackpackElement,
                                            inventory: protagonistInventory) else { return }
            guard let item = protagonistInventory.itemAt(index: index) else { return }
            
            if let price = npcVendor.buyPriceFor(item: item) {
                if let item  = item as? StackableItem, item.stack.count > 1 {
                    sellMany(item, unitPrice: price, index: index, column: column, row: row)
                } else{
                    sellOne(item, price: price, index: index)
                }
            } else {
                // Inform that the item cannot be sold
                if let menuScene = menuScene {
                    let note = NoteOverlay(rect: menuScene.frame, text: "This item cannot be sold")
                    menuScene.presentNote(note)
                }
            }
        default:
            break
        }
    }
    
    /// Sells one unit from a single item.
    ///
    /// - Parameters:
    ///   - item: The item to sell.
    ///   - price: The price for the item.
    ///   - index: The index of the item in the protagonist's inventory component.
    ///
    private func sellOne(_ item: Item, price: Int, index: Int) {
        let goldName = "Gold Pieces"
        let goldCapacity = GoldPiecesItem.capacity
        
        guard npcVendor.canSpend(amount: price)  else {
            // Inform that the item is too expensive
            if let menuScene = menuScene {
                let note = NoteOverlay(rect: menuScene.frame, text: "This item is too expensive")
                menuScene.presentNote(note)
            }
            return
        }
        
        if npcInventory.isFull {
            // Check if there is room for the item in another's stack
            guard item is StackableItem, npcInventory.canStack(itemNamed: item.name, quantity: 1) else {
                // Cannot be stacked, inform that the inventory is full and return
                if let menuScene = menuScene {
                    let note = NoteOverlay(rect: menuScene.frame, text: "Inventory is full")
                    menuScene.presentNote(note)
                }
                return
            }
        }
        
        if protagonistInventory.isFull {
            var canProceed = false
            if protagonistInventory.canStack(itemNamed: goldName, quantity: price) {
                // There is room in a gold pieces' stack for the amount to be earned, proceed
                canProceed = true
            } else if !(item is StackableItem) || (item as! StackableItem).stack.count == 1 {
                // Selling the item would free up a slot, check if this additional slot can
                // hold the gold pieces to be earned
                let occupied = protagonistInventory.quantityOf(itemsNamed: goldName) % goldCapacity
                let available = occupied != 0 ? goldCapacity - occupied : 0
                if goldCapacity + available >= price {
                    canProceed = true
                }
            }
            guard canProceed else {
                // Inform that the inventory is full and return
                if let menuScene = menuScene {
                    let note = NoteOverlay(rect: menuScene.frame, text: "Inventory is full")
                    menuScene.presentNote(note)
                }
                return
            }
        }
        
        let _ = npcVendor.spend(amount: price)
        let _ = protagonistInventory.removeItem(at: index)
        let newItem = (item is StackableItem) ? (item as! StackableItem).copy(stackCount: 1) : item.copy()
        let _ = npcInventory.addItem(newItem)
        var toEarn = price
        while toEarn > 0 {
            let amount = min(toEarn, goldCapacity)
            let _ = protagonistInventory.addItem(GoldPiecesItem(quantity: amount))
            toEarn -= amount
        }
        
        // Play sound effect
        SoundFXSet.FX.gold.play(at: nil, sceneKind: .tradeMenu)
        
        // Reset elements
        setBackpack(backpack: protagonistBackpackElement, inventory: protagonistInventory,
                    equipment: protagonistEquipment)
        setBackpack(backpack: npcBackpackElement, inventory: npcInventory, equipment: nil)
        setOption()
        setTooltip()
    }
    
    /// Sells many units from a single stackable item.
    ///
    /// - Parameters:
    ///   - item: The item to sell.
    ///   - unitPrice: The unit price for the item.
    ///   - index: The index of the item in the protagonist's inventory component.
    ///   - column: The column index in the protagonist's backpack where the item is located.
    ///   - row: The row index in the protagonist's backpack where the item is located.
    ///
    private func sellMany(_ item: StackableItem, unitPrice: Int, index: Int, column: Int, row: Int) {
        let goldName = "Gold Pieces"
        let goldCapacity = GoldPiecesItem.capacity
        
        assert(unitPrice > 0)
        let maxQuantity = npcVendor.fundsAvailable / unitPrice
        
        guard npcVendor.canSpend(amount: unitPrice)  else {
            // Inform that the item is too expensive
            if let menuScene = menuScene {
                let note = NoteOverlay(rect: menuScene.frame, text: "This item is too expensive")
                menuScene.presentNote(note)
            }
            return
        }
        
        if controllableOverlay == nil, let menuScene = menuScene {
            unselectEntry(.protagonistBackpack(column: column, row: row), nullifySelection: false)
            dull()
            let rect = menuScene.frame
            controllableOverlay = PromptOverlay.sellingPrompt(rect: rect, item: item, maxQuantity: maxQuantity) {
                [unowned self] in
                if let overlay = self.controllableOverlay as? PromptOverlay {
                    if overlay.confirmed, let text = overlay.promptText, let quantity = Int(text) {
                        let price = unitPrice * quantity
                        
                        if self.npcInventory.isFull {
                            // Check if there is room for the item in another's stack
                            guard self.npcInventory.canStack(itemNamed: item.name, quantity: quantity) else {
                                // Cannot be stacked, inform that the inventory is full and return
                                if let menuScene = self.menuScene {
                                    let note = NoteOverlay(rect: menuScene.frame, text: "Inventory is full")
                                    menuScene.presentNote(note)
                                }
                                if let selection = self.selection { self.selectEntry(selection) }
                                self.undull()
                                self.menuScene?.removeOverlay(self.controllableOverlay!)
                                self.controllableOverlay = nil
                                return
                            }
                        }
                        
                        if self.protagonistInventory.isFull {
                            var canProceed = false
                            if self.protagonistInventory.canStack(itemNamed: goldName, quantity: price) {
                                // There is room in a gold pieces' stack for the amount to be earned, proceed
                                canProceed = true
                            } else if item.stack.count == 1 {
                                // Selling the item would free up a slot, check if this additional slot can
                                // hold the gold pieces to be earned
                                let occupied = self.protagonistInventory.quantityOf(itemsNamed: goldName) % goldCapacity
                                let available = occupied != 0 ? goldCapacity - occupied : 0
                                if goldCapacity + available >= price {
                                    canProceed = true
                                }
                            }
                            guard canProceed else {
                                // Inform that the inventory is full and return
                                if let menuScene = self.menuScene {
                                    let note = NoteOverlay(rect: menuScene.frame, text: "Inventory is full")
                                    menuScene.presentNote(note)
                                }
                                if let selection = self.selection { self.selectEntry(selection) }
                                self.undull()
                                self.menuScene?.removeOverlay(self.controllableOverlay!)
                                self.controllableOverlay = nil
                                return
                            }
                        }
                        
                        if self.npcVendor.spend(amount: price) {
                            let _ = self.protagonistInventory.reduceStack(at: index, quantity: quantity)
                            let newItem = item.copy(stackCount: quantity)
                            let _ = self.npcInventory.addItem(newItem)
                            var toEarn = price
                            while toEarn > 0 {
                                let amount = min(toEarn, goldCapacity)
                                let _ = self.protagonistInventory.addItem(GoldPiecesItem(quantity: amount))
                                toEarn -= amount
                            }
                            // Play sound effect
                            SoundFXSet.FX.gold.play(at: nil, sceneKind: .tradeMenu)
                            // Reset elements
                            self.setBackpack(backpack: self.protagonistBackpackElement,
                                             inventory: self.protagonistInventory,
                                             equipment: self.protagonistEquipment)
                            self.setBackpack(backpack: self.npcBackpackElement,
                                             inventory: self.npcInventory,
                                             equipment: nil)
                            self.setOption()
                            self.setTooltip()
                        } else {
                            // Inform that the item is too expensive
                            if let menuScene = self.menuScene {
                                let note = NoteOverlay(rect: menuScene.frame, text: "This item is too expensive")
                                menuScene.presentNote(note)
                            }
                        }
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
    
    func open(onClose: @escaping () -> Void) -> Bool {
        guard !isOpen else { return false }
        isOpen = true
        
        let npcPortrait = Game.subject?.component(ofType: PortraitComponent.self)?.portrait
        doublePortraitElement.leftPortrait.portrait = npcPortrait
        let protagonistPortrait = Game.protagonist?.component(ofType: PortraitComponent.self)?.portrait
        protagonistPortrait?.flipped = true
        doublePortraitElement.rightPortrait.portrait = protagonistPortrait
        protagonistPortrait?.flipped = false
        
        setBackpack(backpack: npcBackpackElement, inventory: npcInventory, equipment: nil)
        setBackpack(backpack: protagonistBackpackElement, inventory: protagonistInventory,
                    equipment: protagonistEquipment)
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
                if let event = event as? MouseEvent, let data = event.data as? TradeTrackingData {
                    selection = data
                }
            case .mouseExited:
                if let event = event as? MouseEvent, let _ = event.data as? TradeTrackingData {
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
        guard let selection = selection else { return }
        
        switch event.button {
        case .left:
            switch selection {
            case .npcBackpack:
                buySelection()
            case .protagonistBackpack:
                sellSelection()
            }
        default:
            break
        }
    }
    
    /// Handles mouse entered events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseEnteredEvent(_ event: MouseEvent) {
        if let data = event.data as? TradeTrackingData {
            if let selection = selection { unselectEntry(selection) }
            selectEntry(data)
        }
    }
    
    /// Handles mouse exited events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseExitedEvent(_ event: MouseEvent) {
        if let data = event.data as? TradeTrackingData {
            unselectEntry(data)
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
            let _ = SceneManager.switchToScene(ofKind: .level)
        }
    }
}

/// A struct that defines the data associated with the `TradeMenu` class.
///
fileprivate struct TradeMenuData: TextureUser {
    
    static var textureNames: Set<String> {
        return [NpcBackpack.backpackImage,
                NpcBackpack.emptyIconImage,
                NpcBackpack.backgroundImage,
                ProtagonistBackpack.backpackImage,
                ProtagonistBackpack.emptyIconImage,
                ProtagonistBackpack.backgroundImage,
                DoublePortrait.leftEmptyImage,
                DoublePortrait.rightEmptyImage,
                Option.primaryButtonImage,
                Option.secondaryButtonImage,
                Option.regularKeyImage,
                Option.wideKeyImage]
    }
    
    /// The horizontal offset to apply between each element.
    ///
    static let elementXOffset: CGFloat = 30.0
    
    /// The vertical offset to apply between each element.
    ///
    static let elementYOffset: CGFloat = 40.0
    
    private init() {}
    
    /// The data to use for the `UIBackpackElement` of the NPC.
    ///
    struct NpcBackpack {
        private init() {}
        static let columns = 10
        static let rows = 9
        static let slotOffset: CGFloat = 4.0
        static let backpackImage = "UI_Backpack"
        static let emptyIconImage = "UI_Default_Item_Empty_Icon"
        static let backgroundImage = "UI_Default_Background_8p"
        static let backgroundBorder = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat = 0
    }
    
    /// The data to use for the `UIBackpackElement` of the protagonist.
    ///
    struct ProtagonistBackpack {
        private init() {}
        static let columns = 10
        static let rows = 9
        static let slotOffset: CGFloat = 4.0
        static let backpackImage = "UI_Backpack"
        static let emptyIconImage = "UI_Default_Item_Empty_Icon"
        static let backgroundImage = "UI_Default_Background_8p"
        static let backgroundBorder = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat = 0
    }
    
    /// The data to use for the `UIDoublePortraitElement`.
    ///
    struct DoublePortrait {
        private init() {}
        static let leftEmptyImage = "UI_Default_Empty_Portrait"
        static let rightEmptyImage = "UI_Default_Empty_Portrait"
        static let contentOffset: CGFloat = 60.0
        static let boundaryOffset: CGFloat = 14.0
    }
    
    /// The data to use for the `UIDoubleLabelElement`.
    ///
    struct DoubleLabel {
        private init() {}
        static let leftLabelSize = CGSize(width: 100.0, height: 48.0)
        static let rightLabelSize = CGSize(width: 100.0, height: 48.0)
        static let contentOffset: CGFloat = 30.0
        static let boundaryOffset: CGFloat = 0
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
        static let title = "TRADE"
        static let maxSize = CGSize(width: 272.0, height: 60.0)
        static let backgroundImage: String? = nil
        static let backgroundBorder: UIBorder? = nil
    }
}
