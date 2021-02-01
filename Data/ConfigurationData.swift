//
//  ConfigurationData.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/3/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A struct defining the configurations for the game.
///
struct Configurations: Codable {
    
    /// A struct that wraps the parameters required for a mapping entry.
    ///
    struct MappingEntry: Codable {
        let keyCode: KeyboardKeyCode
        let modifiers: UInt
        let InputButtons: Set<InputButton>
    }
    
    /// The default configurations, equal to `Configurations.init()`.
    ///
    static let defaults = Configurations()
    
    /// The name of the last save file loaded.
    ///
    var lastSaveFileLoaded = ""
    
    /// The Intro recommendation flag, for new users.
    ///
    var shouldRecommendIntro = true
    
    /// The windowed mode flag.
    ///
    var windowedMode = false
    
    /// The volume for sound effects.
    ///
    var sfxVolume: Float = 1.0
    
    /// The volume for background music.
    ///
    var bgmVolume: Float = 1.0
    
    /// The keyboard mapping.
    ///
    var keyboardMapping: [MappingEntry] = [
        MappingEntry(keyCode: .c, modifiers: 0, InputButtons: [.character]),
        MappingEntry(keyCode: .q, modifiers: 0, InputButtons: [.interact]),
        MappingEntry(keyCode: .w, modifiers: 0, InputButtons: [.up]),
        MappingEntry(keyCode: .s, modifiers: 0, InputButtons: [.down]),
        MappingEntry(keyCode: .a, modifiers: 0, InputButtons: [.left]),
        MappingEntry(keyCode: .d, modifiers: 0, InputButtons: [.right]),
        MappingEntry(keyCode: .e, modifiers: 0, InputButtons: [.item1]),
        MappingEntry(keyCode: .r, modifiers: 0, InputButtons: [.item2]),
        MappingEntry(keyCode: .t, modifiers: 0, InputButtons: [.item3]),
        MappingEntry(keyCode: .f, modifiers: 0, InputButtons: [.item4]),
        MappingEntry(keyCode: .g, modifiers: 0, InputButtons: [.item5]),
        MappingEntry(keyCode: .x, modifiers: 0, InputButtons: [.item6]),
        MappingEntry(keyCode: .num1, modifiers: 0, InputButtons: [.skill1]),
        MappingEntry(keyCode: .num2, modifiers: 0, InputButtons: [.skill2]),
        MappingEntry(keyCode: .num3, modifiers: 0, InputButtons: [.skill3]),
        MappingEntry(keyCode: .num4, modifiers: 0, InputButtons: [.skill4]),
        MappingEntry(keyCode: .num5, modifiers: 0, InputButtons: [.skill5]),
        MappingEntry(keyCode: .enter, modifiers: 0, InputButtons: [.confirm]),
        MappingEntry(keyCode: .escape, modifiers: 0, InputButtons: [.pause, .back, .cancel]),
        MappingEntry(keyCode: .space, modifiers: 0, InputButtons: [.cycleTargets]),
        MappingEntry(keyCode: .tab, modifiers: 0, InputButtons: [.clearTarget]),
        MappingEntry(keyCode: .arrowUp, modifiers: 0, InputButtons: [.up]),
        MappingEntry(keyCode: .arrowDown, modifiers: 0, InputButtons: [.down]),
        MappingEntry(keyCode: .arrowLeft, modifiers: 0, InputButtons: [.left]),
        MappingEntry(keyCode: .arrowRight, modifiers: 0, InputButtons: [.right])]
}

/// A class that manipulates configuration options data for the game.
///
class ConfigurationData: DataFile {
    
    var fileName: String {
        return "Configurations.plist"
    }
    
    var contents: Data {
        return data ?? Data()
    }
    
    /// The instance of the class.
    ///
    static let instance = ConfigurationData()
    
    /// The encoded configuration data.
    ///
    private var data: Data?
    
    /// The configurations.
    ///
    /// - Note: Attempting to set this property to `nil` will cause the default values to be set instead.
    ///
    var configurations: Configurations! {
        didSet {
            if configurations == nil { configurations = Configurations.defaults }
            data = nil
        }
    }
    
    /// Creates a new instance.
    ///
    /// If the configurations file cannot be found, the instance will be initialized with the default
    /// configuration values.
    ///
    private init() {
        let sem = DispatchSemaphore(value: 0)
        DataFileManager.instance.read(configurationDataNamed: fileName) { [unowned self] in
            self.data = $0
            sem.signal()
        }
        sem.wait()
        if !decode() {
            configurations = Configurations.defaults
            write()
        }
    }
    
    /// Encodes the configurations, setting the `data` property.
    ///
    /// - Returns: `true` if the data could be encoded, `false` otherwise.
    ///
    private func encode() -> Bool {
        let encoder = PropertyListEncoder()
        do {
            data = try encoder.encode(configurations)
            return true
        } catch {
            return false
        }
    }
    
    /// Decodes the configuration data, setting the `configurations` property.
    ///
    /// - Note: If the data cannot be decoded, the `data` property will be set to `nil`.
    ///
    /// - Returns: `true` if the data could be decoded, `false` otherwise.
    ///
    private func decode() -> Bool {
        guard let data = data else { return false }
        
        let decoder = PropertyListDecoder()
        do {
            configurations = try decoder.decode(Configurations.self, from: data)
            return true
        } catch {
            self.data = nil
            return false
        }
    }
    
    /// Writes the data to disk.
    ///
    func write() {
        guard data != nil || encode() else { return }
        DataFileManager.instance.write(configurationData: self, completionHandler: { _ in })
    }
    
    /// Reads the data from disk.
    ///
    func read() {
        let sem = DispatchSemaphore(value: 0)
        DataFileManager.instance.read(configurationDataNamed: fileName) { [unowned self] in
            self.data = $0
            sem.signal()
        }
        sem.wait()
        let _ = decode()
    }
    
    /// Applies the current configurations to the game.
    ///
    /// - Note: This method cannot be called prior to game launch.
    ///
    func apply() {
        KeyboardMapping.mapMany(entries: configurations.keyboardMapping.map({
            ($0.keyCode.rawValue, $0.modifiers, $0.InputButtons)
        }))
        if !configurations.windowedMode { Window.enterFullscreenMode() }
        SoundFX.volume = configurations.sfxVolume
        BGMPlayback.volume = configurations.bgmVolume
    }
}
