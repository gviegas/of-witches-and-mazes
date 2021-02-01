//
//  RawData.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/19/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that manipulates persistent game data as raw bytes.
///
class RawData: DataFile {
    
    var fileName: String {
        return "\(creationDate.timeIntervalSinceReferenceDate.bitPattern).rawdata"
    }
    
    var contents: Data {
        return buffer
    }
    
    /// The raw data members.
    ///
    private var members: [Member: [UInt8]]
    
    /// The byte buffer.
    ///
    private var buffer: Data
    
    /// The data file version, matching the game version under which the data was created/modified.
    ///
    var version: String {
        return DataConversion.versionFrom(bytes: members[.version]!)
    }
    
    /// The creation date.
    ///
    var creationDate: Date {
        return DataConversion.dateFrom(bytes: members[.creation]!)
    }
    
    /// The modification date.
    ///
    var modificationDate: Date {
        return DataConversion.dateFrom(bytes: members[.modification]!)
    }
    
    /// The stage info.
    ///
    var stageInfo: StageInfo {
        return DataConversion.stageFrom(bytes: members[.stage]!)
    }
    
    /// The persona name.
    ///
    var personaName: String {
        return DataConversion.personaFrom(bytes: members[.persona]!)!
    }
    
    /// The character type.
    ///
    var characterType: Protagonist.Type {
        return DataConversion.characterTypeFrom(bytes: members[.character]!)!
    }
    
    /// The experience progression.
    ///
    var experience: (level: Int, amount: Int) {
        return DataConversion.progressionFrom(bytes: members[.progression]!)
    }
    
    /// The unlocked skills, holding a list of flags stating whether or not a given skill is unlocked.
    ///
    var unlockedSkills: [Bool] {
        return DataConversion.skillFrom(bytes: members[.skill]!)
    }
    
    /// The equipped items, holding inventory indices of items equipped on a given slot.
    ///
    var equippedItems: [Int?] {
        return DataConversion.equipmentFrom(bytes: members[.equipment]!)
    }
    
    /// The inventory contents.
    ///
    var inventory: [Item?] {
        return DataConversion.inventoryFrom(bytes: members[.inventory]!)
    }
    
    /// Creates a new instance from the given `Protagonist` and saves the data to disk.
    ///
    /// - Parameter protagonist: The protagonist from which to create the raw data.
    ///
    init(creatingNewFileFor protagonist: Protagonist) {        
        members = Member.createMembers()
        buffer = Data(capacity: Member.byteCount)
        
        // Set metadata members - this values won`t change during game sessions
        members[.signature] = DataConversion.rawSignature()
        members[.version] = DataConversion.rawVersion()
        members[.creation] = DataConversion.rawDate()
        members[.ending] = DataConversion.rawEnding()
        
        // Set protagonist-related members
        updateProtagonistData(using: protagonist)
        
        // Write the new data to disk
        write()
    }
    
    /// Creates a new instance from an existing data file.
    ///
    /// - Parameter fileName: The name of the file from which to load the raw data.
    ///
    convenience init?(loadingFromFileNamed fileName: String) {
        let sem = DispatchSemaphore(value: 0)
        var data: Data?
        DataFileManager.instance.read(rawDataNamed: fileName) {
            data = $0
            sem.signal()
        }
        sem.wait()
        if let data = data {
            self.init(data: data)
        } else {
            return nil
        }
    }
    
    /// Creates a new instance from a byte buffer.
    ///
    /// - Parameter data: The byte buffer from which to initialize the instance.
    ///
    init?(data: Data) {
        guard RawData.validate(fileContents: data) else { return nil }
        
        buffer = data
        members = Member.createMembers()
        for (member, _) in members {
            let layout = Member.layoutOf(member: member)
            members[member] = [UInt8](buffer[layout.offset..<layout.offset+layout.size])
        }
    }
    
    /// Updates protagonist-related raw data, using the given `Protagonist` as source.
    ///
    /// - Parameter protagonist: A `Protagonist` to use as source of data.
    ///
    func updateProtagonistData(using protagonist: Protagonist) {
        guard let progressionComponent = protagonist.component(ofType: ProgressionComponent.self) else {
            fatalError("RawData requires a protagonist with ProgressionComponent")
        }
        guard let skillComponent = protagonist.component(ofType: SkillComponent.self) else {
            fatalError("RawData requires a protagonist with SkillComponent")
        }
        guard let equipmentComponent = protagonist.component(ofType: EquipmentComponent.self) else {
            fatalError("RawData requires a protagonist with EquipmentComponent")
        }
        guard let personaComponent = protagonist.component(ofType: PersonaComponent.self) else {
            fatalError("RawData requires a protagonist with PersonaComponent")
        }
        guard let stageComponent = protagonist.component(ofType: StageComponent.self) else {
            fatalError("RawData requires a protagonist with StageComponent")
        }
        guard let inventoryComponent = protagonist.component(ofType: InventoryComponent.self) else {
            fatalError("RawData requires a protagonist with InventoryComponent")
        }
        
        // Set the members
        members[.stage] = DataConversion.rawStageFrom(stageComponent: stageComponent)
        members[.persona] = DataConversion.rawPersonaFrom(personaComponent: personaComponent)
        members[.character] = DataConversion.rawCharacterTypeFrom(metatype: type(of: protagonist))
        members[.progression] = DataConversion.rawProgressionFrom(progressionComponent: progressionComponent)
        members[.skill] = DataConversion.rawSkillFrom(skillComponent: skillComponent)
        members[.equipment] = DataConversion.rawEquipmentFrom(equipmentComponent: equipmentComponent,
                                                              inventoryComponent: inventoryComponent)
        members[.inventory] = DataConversion.rawInventoryFrom(inventoryComponent: inventoryComponent)
    }
    
    /// Writes the data to disk.
    ///
    /// - Note: This method updates the `modificationDate` member before writing contents to disk.
    ///
    func write() {
        // Update modification date
        members[.modification] = DataConversion.rawDate()
        
        // Populate the buffer
        buffer.removeAll(keepingCapacity: true)
        for (_, value) in members.sorted(by: { a, b in a.key.rawValue < b.key.rawValue }) {
            buffer.append(contentsOf: value)
        }
        
        // Let the DataFileManager handle the writing
        return DataFileManager.instance.write(rawData: self, completionHandler: { _ in })
    }
    
    /// Deletes the data from disk.
    ///
    func delete() {
        DataFileManager.instance.delete(rawData: self, completionHandler: { _ in })
    }
    
    /// Validates the given file as a raw data file.
    ///
    /// - Parameter fileName: The name of the file to validate.
    /// - Returns: `true` if the file contents represent valid raw data, `false` otherwise.
    ///
    static func validate(fileNamed fileName: String) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var contents: Data?
        DataFileManager.instance.read(rawDataNamed: fileName) {
            contents = $0
            sem.signal()
        }
        sem.wait()
        return contents != nil ? validate(fileContents: contents!) : false
    }
    
    /// Validates the given file contents for use as raw data.
    ///
    /// - Parameter contents: The contents to validate.
    /// - Returns: `true` if the contents represent valid raw data, `false` otherwise.
    ///
    /// - ToDo: Consider doing further validation.
    ///
    static func validate(fileContents contents: Data) -> Bool {
        guard contents.count == Member.byteCount else { return false }
        
        var layout: (size: Int, offset: Int) = (0, 0)
        var bytes = [UInt8]()
        
        layout = Member.layoutOf(member: .signature)
        bytes = [UInt8](contents[layout.offset..<layout.offset+layout.size])
        guard bytes == DataConversion.rawSignature() else { return false }
        
        layout = Member.layoutOf(member: .ending)
        bytes = [UInt8](contents[layout.offset..<layout.offset+layout.size])
        guard bytes == DataConversion.rawEnding() else { return false }
        
        return true
    }
}

/// An enum representing the raw data members.
///
fileprivate enum Member: Int {
    case signature
    case version
    case creation
    case modification
    case stage
    case persona
    case character
    case progression
    case skill
    case equipment
    case inventory
    case ending
    
    static var byteCount: Int {
        let (size, offset) = layoutOf(member: .ending)
        return size + offset
    }
    
    // ToDo: Share subdata sizes between Member and DataConversion
    static func layoutOf(member: Member) -> (size: Int, offset: Int) {
        let t: (size: Int, offset: Int)
        
        switch member {
        case signature:
            t = (20, 0)
        case version:
            let prev = layoutOf(member: Member(rawValue: member.rawValue - 1)!)
            t = (4, prev.size + prev.offset)
        case creation:
            let prev = layoutOf(member: Member(rawValue: member.rawValue - 1)!)
            t = (8, prev.size + prev.offset)
        case modification:
            let prev = layoutOf(member: Member(rawValue: member.rawValue - 1)!)
            t = (8, prev.size + prev.offset)
        case stage:
            let prev = layoutOf(member: Member(rawValue: member.rawValue - 1)!)
            let size = 4 + 8 + 1 + 2
            t = (size, prev.size + prev.offset)
        case persona:
            let prev = layoutOf(member: Member(rawValue: member.rawValue - 1)!)
            t = (PersonaComponent.maxLength, prev.size + prev.offset)
        case character:
            let prev = layoutOf(member: Member(rawValue: member.rawValue - 1)!)
            t = (1, prev.size + prev.offset)
        case progression:
            let prev = layoutOf(member: Member(rawValue: member.rawValue - 1)!)
            let size = 2 + 8
            t = (size, prev.size + prev.offset)
        case skill:
            let prev = layoutOf(member: Member(rawValue: member.rawValue - 1)!)
            t = (2, prev.size + prev.offset)
        case equipment:
            let prev = layoutOf(member: Member(rawValue: member.rawValue - 1)!)
            t = (EquipmentComponent.maxItems, prev.size + prev.offset)
        case inventory:
            let prev = layoutOf(member: Member(rawValue: member.rawValue - 1)!)
            let valuesSize = Alteration.maxStats * 8
            let entrySize = 2 + 2 + 2 + 4 + valuesSize
            t = (entrySize * InventoryComponent.maxCapacity, prev.size + prev.offset)
        case ending:
            let prev = layoutOf(member: Member(rawValue: member.rawValue - 1)!)
            t = (13, prev.size + prev.offset)
        }
        
        return t
    }
    
    static func createMembers() -> [Member: [UInt8]] {
        var members = [Member: [UInt8]]()
        var i = 0
        while let member = Member(rawValue: i) {
            members[member] = []
            i += 1
        }
        return members
    }
}

/// A struct that handles conversions from/to raw data.
///
fileprivate struct DataConversion {
    
    /// Creates the raw bytes representing the signature.
    ///
    /// - Note: There is no formatted version of the signature.
    ///
    /// - Returns: The byte array that represents the game's signature.
    ///
    static func rawSignature() -> [UInt8] {
        return [79, 87, 65, 77, 46, 114, 97, 119, 100, 97, 116, 97, 45, 109, 97, 99, 111, 115, 0, 0]
    }
    
    /// Creates the raw bytes representing the ending of the data.
    ///
    /// - Note: There is no formatted version of the ending.
    ///
    /// - Returns: The byte array that represents the data's ending.
    ///
    static func rawEnding() -> [UInt8] {
        return [255, 255, 114, 97, 119, 100, 97, 116, 97, 45, 101, 111, 102]
    }
    
    /// Creates raw game version.
    ///
    /// - Returns: The game version as a byte array.
    ///
    static func rawVersion() -> [UInt8] {
        let str = Version.current
        let values = str.split(separator: ".").map( { UInt32($0)} )
        let offsets = [0, 16, 24]
        var version = UInt32(0)
        for i in 0..<min(3, values.count) {
            guard let value = values[i] else { continue }
            version |= value << offsets[i]
        }
        return [UInt8](Data(bytes: &version, count: 4))
    }
    
    /// Creates the game version from raw data.
    ///
    /// - Note: The raw data must have been created using `rawVersion()`.
    ///
    /// - Parameter rawValue: A byte array returned from `rawVersion()`.
    /// - Returns: A string that describes the version.
    ///
    static func versionFrom(bytes: [UInt8]) -> String {
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: 4, alignment: 4)
        ptr.copyMemory(from: bytes, byteCount: 4)
        let value = ptr.load(as: UInt32.self)
        ptr.deallocate()
        let offsets = [0, 16, 24]
        let masks: [UInt32] = [0xffff, 0xff, 0xff]
        var version = ""
        for i in 0..<3 {
            version += "\((value >> offsets[i]) & masks[i])"
            if i < 2 { version += "." }
        }
        return version
    }
    
    /// Creates raw date from the current time.
    ///
    /// - Returns: The current date as a byte array.
    ///
    static func rawDate() -> [UInt8] {
        var now = Date.timeIntervalSinceReferenceDate
        return [UInt8](Data(bytes: &now, count: 8))
    }
    
    /// Creates a date from raw data.
    ///
    /// - Note: The raw data must have been created using `rawDate()`.
    ///
    /// - Parameter bytes: A byte array returned from `rawDate()`.
    /// - Returns: A `Date` instance representing the date.
    ///
    static func dateFrom(bytes: [UInt8]) -> Date {
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: 8, alignment: 8)
        ptr.copyMemory(from: bytes, byteCount: 8)
        let interval = ptr.load(as: TimeInterval.self)
        ptr.deallocate()
        return Date(timeIntervalSinceReferenceDate: interval)
    }
    
    /// Creates raw stage data from a `StageComponent`.
    ///
    /// - Parameter stageComponent: The `StageComponent` instance from which to create the data.
    /// - Returns: The stage data as a byte array.
    ///
    static func rawStageFrom(stageComponent: StageComponent) -> [UInt8] {
        var buffer = [UInt8]()
        
        var run = UInt32(stageComponent.stageInfo.run)
        buffer.append(contentsOf: Data(bytes: &run, count: 4))
        
        var completion = UInt64(0)
        for i in 0..<64 {
            guard let levelID = LevelID(rawValue: i) else { break }
            if stageComponent.stageInfo.completion.contains(levelID) {
                completion |= 1 << i
            }
        }
        buffer.append(contentsOf: Data(bytes: &completion, count: 8))
        
        let currentLevel = UInt8(stageComponent.stageInfo.currentLevel.rawValue)
        buffer.append(currentLevel)
        
        var currentSublevel = UInt16(stageComponent.stageInfo.currentSublevel)
        buffer.append(contentsOf: Data(bytes: &currentSublevel, count: 2))
        
        return buffer
    }
    
    /// Creates a stage from raw data.
    ///
    /// - Note: The raw data must have been created using `rawStageFrom(stageComponent:)`.
    ///
    /// - Parameter bytes: A byte array returned from `rawStageFrom(stageComponent:)`.
    /// - Returns: A `StageInfo` instance.
    ///
    static func stageFrom(bytes: [UInt8]) -> StageInfo {
        var buffer: [UInt8]
        var ptr: UnsafeMutableRawPointer
        var offset = 0
        
        // Run
        buffer = [UInt8](bytes[offset..<offset+4])
        ptr = .allocate(byteCount: 4, alignment: 4)
        ptr.copyMemory(from: buffer, byteCount: 4)
        let run = Int(ptr.load(as: UInt32.self))
        ptr.deallocate()
        offset += 4
        
        // Completion
        buffer = [UInt8](bytes[offset..<offset+8])
        ptr = .allocate(byteCount: 8, alignment: 8)
        ptr.copyMemory(from: buffer, byteCount: 8)
        let mask = ptr.load(as: UInt64.self)
        ptr.deallocate()
        var completion = Set<LevelID>()
        for i in 0..<64 {
            guard let levelID = LevelID(rawValue: i) else { break }
            if mask & (1 << i) != 0 {
                completion.insert(levelID)
            }
        }
        offset += 8
        
        // Current Level
        let currentLevel = LevelID(rawValue: Int(bytes[offset])) ?? LevelID.nightGlade
        offset += 1
        
        // Current Sublevel
        buffer = [UInt8](bytes[offset..<offset+2])
        ptr = .allocate(byteCount: 2, alignment: 2)
        ptr.copyMemory(from: buffer, byteCount: 2)
        let currentSublevel = Int(ptr.load(as: UInt16.self))
        ptr.deallocate()
        
        return StageInfo(run: run, completion: completion,
                         currentLevel: currentLevel, currentSublevel: currentSublevel)
    }
    
    /// Creates raw persona data from a `PersonaComponent`.
    ///
    /// - Parameter personaComponent: The `PersonaComponent` instance from which to create the data.
    /// - Returns: The persona name as an UTF-8 byte array.
    ///
    static func rawPersonaFrom(personaComponent: PersonaComponent) -> [UInt8] {
        var persona = [UInt8](repeating: 0, count: PersonaComponent.maxLength)
        persona.replaceSubrange(0..<personaComponent.personaName.count, with: personaComponent.personaName.utf8)
        return persona
    }
    
    /// Creates a persona name from raw data.
    ///
    /// - Note: The raw data must have been created using `rawPersonaFrom(personaComponent:)`.
    ///
    /// - Parameter bytes: A byte array returned from `rawPersonaFrom(personaComponent:)`.
    /// - Returns: A `String` representing the persona name, or `nil` if the data could not be converted.
    ///
    static func personaFrom(bytes: [UInt8]) -> String? {
        if let utf8 = String(bytes: bytes, encoding: .utf8) {
            return String(utf8.prefix(while: { $0 != "\0" }))
        }
        return nil
    }
    
    /// Creates raw character type data from a metatype.
    ///
    /// - Parameter metatype: A `Protagonist.Type` subtype for which to create the data.
    /// - Returns: A byte that identifies the character type.
    ///
    static func rawCharacterTypeFrom(metatype: Protagonist.Type) -> [UInt8] {
        let t = (CharacterType.metatypes.first { $0.value == metatype })?.key.rawValue
        assert(t != nil)
        return [t!]
    }
    
    /// Creates `Protagonist` metatype from raw data.
    ///
    /// - Note: The raw data must have been created using `rawCharacterTypeFrom(metatype:)`.
    ///
    /// - Parameter bytes: A byte array returned from `rawCharacterTypeFrom(metatype:)`.
    /// - Returns: The `Protagonist.Type` that the character type represents, or `nil` if no
    ///   metatype is represented by the given raw character type.
    ///
    static func characterTypeFrom(bytes: [UInt8]) -> Protagonist.Type? {
        assert(!bytes.isEmpty)
        if let characterType = CharacterType(rawValue: bytes.first!) {
            return CharacterType.metatypes[characterType]
        }
        return nil
    }
    
    /// Creates raw progression data from a `ProgressionComponent`.
    ///
    /// - Parameter progressionComponent: The `ProgressionComponent` instance from which to create the data.
    /// - Returns: The progression data as a byte array.
    ///
    static func rawProgressionFrom(progressionComponent: ProgressionComponent) -> [UInt8] {
        var level = UInt16(progressionComponent.levelOfExperience)
        var amount = UInt64(progressionComponent.experience)
        return [UInt8](Data(bytes: &level, count: 2)) + [UInt8](Data(bytes: &amount, count: 8))
    }
    
    /// Creates progression data from raw data.
    ///
    /// - Note: The raw data must have been created using `rawXPFrom(progressionComponent:)`.
    ///
    /// - Parameter bytes: A byte array returned from `rawXPFrom(progressionComponent:)`.
    /// - Returns: A `(Int, Int)` tuple containing the level and amount of experience, respectively.
    ///
    static func progressionFrom(bytes: [UInt8]) -> (level: Int, amount: Int) {
        assert(bytes.count >= 10)
        
        var ptr: UnsafeMutableRawPointer
        
        ptr = .allocate(byteCount: 2, alignment: 2)
        ptr.copyMemory(from: bytes, byteCount: 2)
        let level = ptr.load(as: UInt16.self)
        ptr.deallocate()
        
        ptr = .allocate(byteCount: 8, alignment: 8)
        ptr.copyMemory(from: [UInt8](bytes[2..<bytes.count]), byteCount: 8)
        let amount = ptr.load(as: UInt64.self)
        ptr.deallocate()
        
        return (Int(level), Int(amount))
    }
    
    /// Creates raw skill information data.
    ///
    /// - Parameter skillComponent: The `SkillComponent` instance from which to create the data.
    /// - Returns: The skill data as byte array.
    ///
    static func rawSkillFrom(skillComponent: SkillComponent) -> [UInt8] {
        var unlocked: UInt16 = 0
        for i in 0..<min(16, skillComponent.skills.count) {
            if skillComponent.skills[i].unlocked {
                unlocked |= 1 << i
            }
        }
        return [UInt8](Data(bytes: &unlocked, count: 2))
    }
    
    /// Creates skill information from raw data.
    ///
    /// - Note: The raw data must have been created using `rawSkillFrom(skillComponent:)`.
    ///
    /// - Parameter bytes: A byte array returned from `rawSkillFrom(skillComponent:)`.
    /// - Returns: A bool array stating the unlocked skills in a set.
    ///
    static func skillFrom(bytes: [UInt8]) -> [Bool] {
        var unlocked = [Bool]()
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: 2, alignment: 2)
        ptr.copyMemory(from: bytes, byteCount: 2)
        let value = ptr.load(as: UInt16.self)
        ptr.deallocate()
        for i in 0..<16 {
            unlocked.append((value & (1 << i)) != 0)
        }
        return unlocked
    }
    
    /// Creates raw equipment data from equipment and inventory components.
    ///
    /// - Parameters:
    ///   - equipmentComponent: The `EquipmentComponent` from which to create the data.
    ///   - inventoryComponent: The `InventoryComponent` from which to create the data.
    /// - Returns: The equipment data as a byte array.
    ///
    static func rawEquipmentFrom(equipmentComponent: EquipmentComponent,
                                 inventoryComponent: InventoryComponent) -> [UInt8] {
        
        var equipped = [UInt8](repeating: 0xff, count: EquipmentComponent.maxItems)
        for i in 0...EquipmentComponent.maxItems {
            if let item = equipmentComponent.itemAt(index: i), let index = inventoryComponent.indexOf(item: item) {
                equipped[i] = UInt8(index)
            }
        }
        return equipped
    }
    
    /// Creates equipment data from raw data.
    ///
    /// - Note: The raw data must have been created using `rawEquipmentFrom(equipmentComponent:inventorycomponent:)`.
    ///
    /// - Parameter bytes: A byte array returned from `rawEquipmentFrom(equipmentComponent:inventorycomponent:)`.
    /// - Returns: An array of indices representing which item of the inventory is equipped for a given
    ///   equipment slot. `nil` values means that nothing is equipped for a given slot.
    ///
    static func equipmentFrom(bytes: [UInt8]) -> [Int?] {
        return bytes.map { $0 == 0xff ? nil : Int($0) }
    }
    
    /// Creates raw inventory data from an `InventoryComponent`.
    ///
    /// - Parameter inventoryComponent: The `InventoryComponent` instance from which to create the data.
    /// - Returns: The inventory data as a byte array.
    ///
    static func rawInventoryFrom(inventoryComponent: InventoryComponent) -> [UInt8] {
        let valuesSize = Alteration.maxStats * 8
        let entrySize = 2 + 2 + 2 + 4 + valuesSize
        var inventory = [UInt8](repeating: 0, count: entrySize * InventoryComponent.maxCapacity)
        
        for i in 0..<inventoryComponent.capacity {
            if let item = inventoryComponent.itemAt(index: i) {
                var metatype = rawItemTypeFrom(metatype: type(of: item)) ?? 0
                var iLevel = UInt16((item as? LevelItem)?.itemLevel ?? 0)
                var stack = UInt16((item as? StackableItem)?.stack.count ?? 0)
                var altData = rawAlterationFrom(item: item)
                
                var offset = entrySize * i
                inventory.replaceSubrange(offset..<offset+2, with: Data(bytes: &metatype, count: 2))
                offset += 2
                inventory.replaceSubrange(offset..<offset+2, with: Data(bytes: &iLevel, count: 2))
                offset += 2
                inventory.replaceSubrange(offset..<offset+2, with: Data(bytes: &stack, count: 2))
                offset += 2
                inventory.replaceSubrange(offset..<offset+4, with: Data(bytes: &altData.mask, count: 4))
                offset += 4
                inventory.replaceSubrange(offset..<offset+valuesSize, with: Data(bytes: altData.values,
                                                                                 count: valuesSize))
            }
        }
        
        return inventory
    }
    
    /// Creates inventory data from raw data.
    ///
    /// - Note: The raw data must have been created using `rawInventoryFrom(inventoryComponent:)`.
    ///
    /// - Parameters:
    ///   - bytes: A byte array returned from `rawInventoryFrom(inventoryComponent:)`.
    ///   - capacity: The size of the array to return. The amount of items created by
    ///     `rawInventoryFrom(inventoryComponent:)` is always equal to `InventoryComponent.maxCapacity`. This
    ///     parameter allows for smaller inventories to be created. The default value is the same as `maxCapacity`.
    /// - Returns: An array of optional `Item` instances that represents an inventory's contents.
    ///
    static func inventoryFrom(bytes: [UInt8], capacity: Int = InventoryComponent.maxCapacity) -> [Item?] {
        let valuesSize = Alteration.maxStats * 8
        let entrySize = 2 + 2 + 2 + 4 + valuesSize
        let totalSize = min(entrySize * capacity, bytes.count)
        var inventory = [Item?](repeating: nil, count: capacity)
        
        for i in stride(from: 0, to: totalSize, by: entrySize) {
            let buffer = [UInt8](bytes[i..<totalSize])
            var offset = 0
            var ptr: UnsafeMutableRawPointer
            var sub: [UInt8]
            
            // Metatype
            sub = [UInt8](buffer[0..<2])
            ptr = .allocate(byteCount: 2, alignment: 2)
            ptr.copyMemory(from: sub, byteCount: 2)
            guard let metatype = itemTypeFrom(rawType: ptr.load(as: UInt16.self)) else {
                ptr.deallocate()
                continue
            }
            offset += 2
            
            // Item level
            sub = [UInt8](buffer[offset..<offset+2])
            ptr.copyMemory(from: sub, byteCount: 2)
            let iLevel = ptr.load(as: UInt16.self)
            offset += 2
            
            // Stack count
            sub = [UInt8](buffer[offset..<offset+2])
            ptr.copyMemory(from: sub, byteCount: 2)
            let stack = ptr.load(as: UInt16.self)
            offset += 2
            
            // Alteration mask
            sub = [UInt8](buffer[offset..<offset+4])
            ptr.deallocate()
            ptr = .allocate(byteCount: 4, alignment: 4)
            ptr.copyMemory(from: sub, byteCount: 4)
            let mask = ptr.load(as: UInt32.self)
            offset += 4
            
            // Alteration values
            var values = [Int64](repeating: 0, count: Alteration.maxStats)
            ptr.deallocate()
            ptr = .allocate(byteCount: 8, alignment: 8)
            for i in 0..<values.count {
                sub = [UInt8](buffer[offset..<offset+8])
                ptr.copyMemory(from: sub, byteCount: 8)
                values[i] = ptr.load(as: Int64.self)
                offset += 8
            }
            ptr.deallocate()
            let alteration = alterationFrom(mask: mask, values: values)
            
            // Create the item
            let item: Item?
            if let itemType = metatype as? LevelItem.Type {
                item = itemType.init(level: Int(iLevel))
                if let item = item as? StackableItem {
                    let newStack = ItemStack(capacity: item.stack.capacity, count: Int(stack))
                    item.stack = newStack
                }
                if let item = item as? AlterationItem {
                    item.alteration = Alteration(stats: alteration)
                }
            } else if let itemType = metatype as? StackableItem.Type {
                item = itemType.init(quantity: Int(stack))
            } else if let itemType = metatype as? InitializableItem.Type {
                item = itemType.init()
            } else {
                item = nil
            }
            inventory[i/entrySize] = item
        }
        
        return inventory
    }
    
    /// Creates raw item type data from a metatype.
    ///
    /// - Parameter metatype: An `Item.Type` subtype for which to create the data.
    /// - Returns: A byte that identifies the item type, or `nil` if the given metatype
    ///   has no identifier.
    ///
    private static func rawItemTypeFrom(metatype: Item.Type) -> UInt16? {
        return (ItemType.metatypes.first { $0.value == metatype })?.key.rawValue
    }
    
    /// Creates `Item` metatype from raw data.
    ///
    /// - Note: The raw data must have been created using `rawItemTypeFrom(metatype:)`.
    ///
    /// - Parameter rawType: The item type returned from `rawItemTypeFrom(metatype:)`.
    /// - Returns: The `Item.Type` that the item type represents, or `nil` if no
    ///   metatype is represented by the given item type.
    ///
    private static func itemTypeFrom(rawType: UInt16) -> Item.Type? {
        if let itemType = ItemType(rawValue: rawType) {
            return ItemType.metatypes[itemType]
        }
        return nil
    }
    
    /// Creates raw alteration data from an `Item` instance.
    ///
    /// - Parameter item: The `Item` instance for which to create the data.
    /// - Returns: A `(UInt32, [Int64])` tuple where the first member represents a mask
    ///   identifying the alteration stats, and the second member stores the literal value
    ///   for each stat as fixed width integers.
    ///
    private static func rawAlterationFrom(item: Item) -> (mask: UInt32, values: [Int64]) {
        var mask: UInt32 = 0
        var values = [Int64](repeating: 0, count: Alteration.maxStats)
        
        if let item = item as? AlterationItem {
            var pairs = [(UInt32, Int64)]()
            for (stat, value) in item.alteration.stats {
                let statMask = AlterationMask.maskForStat(stat)
                pairs.append((statMask.rawValue, Int64(value)))
            }
            
            if !pairs.isEmpty {
                pairs.sort { a, b -> Bool in a.0 < b.0 }
                for i in 0..<pairs.count {
                    mask |= pairs[i].0
                    values[i] = pairs[i].1
                }
            }
        }
        
        return (mask, values)
    }
    
    /// Creates alteration data from raw data.
    ///
    /// - Note: The raw data must have been created using `rawAlterationFrom(item:)`.
    ///
    /// - Parameters:
    ///   - mask: The alteration mask returned from `rawAlterationFrom(item:)`.
    ///   - values: The alteration values returned from `rawAlterationFrom(item:)`.
    /// - Returns: A dictionary representing the alteration.
    ///
    private static func alterationFrom(mask: UInt32, values: [Int64]) -> [AlterableStat: Int] {
        var stats = [AlterableStat: Int]()
        var valuesIdx = 0
        
        for i in 0..<32 {
            guard mask >= (1 << i), valuesIdx < values.count else { break }
            
            if let statMask = AlterationMask(rawValue: 1 << i), statMask.rawValue & mask != 0 {
                let stat = AlterationMask.statForMask(statMask)
                stats[stat] = Int(values[valuesIdx])
                valuesIdx += 1
            }
        }
        
        return stats
    }
    
    /// An enum that represents the raw character types.
    ///
    private enum CharacterType: UInt8 {
        case fighter = 0x01
        case rogue
        case wizard
        case cleric
        
        static let metatypes: [CharacterType: Protagonist.Type] = [.fighter: Fighter.self, .rogue: Rogue.self,
                                                                   .wizard: Wizard.self, .cleric: Cleric.self]
    }
    
    /// An enum that represents the raw item types.
    ///
    private enum ItemType: UInt16 {
        // General
        case goldPieces = 0x01
        case key
        case arrow
        case spellComponents
        case yarn
        case toy
        // Consumables
        case healingPotion = 0x08_00
        case restorativePotion
        case panacea
        case antidote
        case elixir
        case deadlyDraught
        case antiMagicPotion
        case potionOfCelerity
        case potionOfInvisibility
        // Gadgets
        case bomb = 0x10_00
        // Throwing Weapons
        case dagger = 0x18_00
        // Melee Weapons
        case commonSword = 0x20_00
        case rapier
        case cutlass
        case spatha
        case royalSword
        case bastardSword
        case uncommonSword
        // Ranged Weapons
        case recurveBow = 0x28_00
        case longBow
        case huntingBow
        case ashenBow
        case ocherBow
        // Armors
        case tunic = 0x30_00
        case leatherVest
        case noblesAttire
        case hauberk
        case brigandine
        case chainMail
        case breastplate
        case cuirass
        case plateArmor
        case exoticOutfit
        // Shields
        case heaterShield = 0x38_00
        case ovalShield
        case roundShield
        case knightsShield
        case emeraldShield
        case ancientShield
        // Jewels
        case goldRing = 0x40_00
        case silverRing
        case copperRing
        case amethystRing
        case aquamarineRing
        case coralRing
        // Spell Books
        case grimoireOfPrismaticMissile = 0x48_00
        case grimoireOfColdRay
        case grimoireOfPoisonOrb
        case grimoireOfLightningBolt
        case grimoireOfEnergyBarrier
        case grimoireOfDaze
        case grimoireOfWeakness
        case grimoireOfDispelMagic
        case grimoireOfCurse
        
        static let metatypes: [ItemType: Item.Type] = [
            // General
            .goldPieces: GoldPiecesItem.self,
            .key: KeyItem.self,
            .arrow: ArrowItem.self,
            .spellComponents: SpellComponentsItem.self,
            .yarn: YarnItem.self,
            .toy: ToyItem.self,
            // Consumables
            .healingPotion: HealingPotionItem.self,
            .restorativePotion: RestorativePotionItem.self,
            .panacea: PanaceaItem.self,
            .antidote: AntidoteItem.self,
            .elixir: ElixirItem.self,
            .deadlyDraught: DeadlyDraughtItem.self,
            .antiMagicPotion: AntiMagicPotionItem.self,
            .potionOfCelerity: PotionOfCelerityItem.self,
            .potionOfInvisibility: PotionOfInvisibilityItem.self,
            // Gadgets
            .bomb: BombItem.self,
            // Throwing Weapons
            .dagger: DaggerItem.self,
            // Melee Weapons
            .commonSword: CommonSwordItem.self,
            .rapier: RapierItem.self,
            .cutlass: CutlassItem.self,
            .spatha: SpathaItem.self,
            .royalSword: RoyalSwordItem.self,
            .bastardSword: BastardSwordItem.self,
            .uncommonSword: UncommonSwordItem.self,
            // Ranged Weapons
            .recurveBow: RecurveBowItem.self,
            .longBow: LongBowItem.self,
            .huntingBow: HuntingBowItem.self,
            .ashenBow: AshenBowItem.self,
            .ocherBow: OcherBowItem.self,
            // Armors
            .tunic: TunicItem.self,
            .leatherVest: LeatherVestItem.self,
            .noblesAttire: NoblesAttireItem.self,
            .hauberk: HauberkItem.self,
            .brigandine: BrigandineItem.self,
            .chainMail: ChainMailItem.self,
            .breastplate: BreastplateItem.self,
            .cuirass: CuirassItem.self,
            .plateArmor: PlateArmorItem.self,
            .exoticOutfit: ExoticOutfitItem.self,
            // Shields
            .heaterShield: HeaterShieldItem.self,
            .ovalShield: OvalShieldItem.self,
            .roundShield: RoundShieldItem.self,
            .knightsShield: KnightsShieldItem.self,
            .emeraldShield: EmeraldShieldItem.self,
            .ancientShield: AncientShieldItem.self,
            // Jewels
            .goldRing: GoldRingItem.self,
            .silverRing: SilverRingItem.self,
            .copperRing: CopperRingItem.self,
            .amethystRing: AmethystRingItem.self,
            .aquamarineRing: AquamarineRingItem.self,
            .coralRing: CoralRingItem.self,
            // Spell Books
            .grimoireOfPrismaticMissile: GrimoireOfPrismaticMissileItem.self,
            .grimoireOfColdRay: GrimoireOfColdRayItem.self,
            .grimoireOfPoisonOrb: GrimoireOfPoisonOrbItem.self,
            .grimoireOfLightningBolt: GrimoireOfLightningBoltItem.self,
            .grimoireOfEnergyBarrier: GrimoireOfEnergyBarrierItem.self,
            .grimoireOfDaze: GrimoireOfDazeItem.self,
            .grimoireOfWeakness: GrimoireOfWeaknessItem.self,
            .grimoireOfDispelMagic: GrimoireOfDispelMagicItem.self,
            .grimoireOfCurse: GrimoireOfCurseItem.self]
    }
    
    /// An enum that represents the raw alteration mask.
    ///
    private enum AlterationMask: UInt32 {
        case strength = 0x01
        case agility = 0x02
        case intellect = 0x04
        case faith = 0x08
        case health = 0x10
        case critical = 0x20
        case damageCaused = 0x40
        case damageTaken = 0x80
        case meleeCrit = 0x01_00
        case rangedCrit = 0x02_00
        case spellCrit = 0x04_00
        case powerCrit = 0x08_00
        case gadgetCrit = 0x10_00
        case physicalCaused = 0x20_00
        case magicalCaused = 0x40_00
        case spiritualCaused = 0x80_00
        case naturalCaused = 0x01_00_00
        case physicalTaken = 0x02_00_00
        case magicalTaken = 0x04_00_00
        case spiritualTaken = 0x08_00_00
        case naturalTaken = 0x10_00_00
        case defense = 0x20_00_00
        case resistance = 0x40_00_00
        case mitigation = 0x80_00_00
        
        static func maskForStat(_ stat: AlterableStat) -> AlterationMask {
            let mask: AlterationMask
            
            switch stat {
            case .ability(let ability):
                switch ability {
                case .strength: mask = strength
                case .agility: mask = agility
                case .intellect: mask = intellect
                case .faith: mask = faith
                }
            case .critical(let medium):
                switch medium {
                case .none: mask = critical
                case .some(let medium):
                    switch medium {
                    case .melee: mask = meleeCrit
                    case .ranged: mask = rangedCrit
                    case .spell: mask = spellCrit
                    case .power: mask = powerCrit
                    case .gadget: mask = gadgetCrit
                    case .none: mask = critical
                    }
                }
            case .damageCaused(let damage):
                switch damage {
                case .none: mask = damageCaused
                case .some(let damage):
                    switch damage {
                    case .physical: mask = physicalCaused
                    case .magical: mask = magicalCaused
                    case .spiritual: mask = spiritualCaused
                    case .natural: mask = naturalCaused
                    }
                }
            case .damageTaken(let damage):
                switch damage {
                case .none: mask = damageTaken
                case .some(let damage):
                    switch damage {
                    case .physical: mask = physicalTaken
                    case .magical: mask = magicalTaken
                    case .spiritual: mask = spiritualTaken
                    case .natural: mask = naturalTaken
                    }
                }
            case.defense: mask = defense
            case .resistance: mask = resistance
            case .mitigation: mask = mitigation
            case .health: mask = health
            }
            
            return mask
        }
        
        static func statForMask(_ mask: AlterationMask) -> AlterableStat {
            let stat: AlterableStat
            
            switch mask {
            case .strength: stat = .ability(.strength)
            case .agility: stat = .ability(.agility)
            case .intellect: stat = .ability(.intellect)
            case .faith: stat = .ability(.faith)
            case .critical: stat = .critical(nil)
            case damageCaused: stat = .damageCaused(nil)
            case damageTaken: stat = .damageTaken(nil)
            case meleeCrit: stat = .critical(.melee)
            case rangedCrit: stat = .critical(.ranged)
            case spellCrit: stat = .critical(.spell)
            case powerCrit: stat = .critical(.power)
            case gadgetCrit: stat = .critical(.gadget)
            case physicalCaused: stat = .damageCaused(.physical)
            case magicalCaused: stat = .damageCaused(.magical)
            case spiritualCaused: stat = .damageCaused(.spiritual)
            case naturalCaused: stat = .damageCaused(.natural)
            case physicalTaken: stat = .damageTaken(.physical)
            case magicalTaken: stat = .damageTaken(.magical)
            case spiritualTaken: stat = .damageTaken(.spiritual)
            case naturalTaken: stat = .damageTaken(.natural)
            case .defense: stat = .defense
            case .resistance: stat = .resistance
            case .mitigation: stat = .mitigation
            case .health: stat = .health
            }
            
            return stat
        }
    }
}
