//
//  LevelID.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An enum that identifies `Levels`.
///
enum LevelID: Int {
    case glade
    case nightGlade
    case volcano
    case manor
    case shore
    case sanctum
    
    /// The metatype of the `Level` that the id identifies.
    ///
    var metatype: Level.Type {
        let t: Level.Type
        switch self {
        case .glade:
            t = GladeDungeonLevel.self
        case .nightGlade:
            t = NightGladeDungeonLevel.self
        case .volcano:
            t = VolcanoDungeonLevel.self
        case .manor:
            t = ManorDungeonLevel.self
        case .shore:
            t = ShoreDungeonLevel.self
        case .sanctum:
            t = SanctumDungeonLevel.self
        }
        return t
    }
    
    /// Retrieves the `LevelID` for the given `Level` type.
    ///
    /// - Parameter metatype: A `Level` type for which to retrieve the id.
    /// - Returns: The `LevelID` for the given type, or `nil` if the type has no id.
    ///
    static func idForType(_ metatype: Level.Type) -> LevelID? {
        let id: LevelID?
        switch metatype {
        case is GladeDungeonLevel.Type:
            id = glade
        case is NightGladeDungeonLevel.Type:
            id = nightGlade
        case is VolcanoDungeonLevel.Type:
            id = volcano
        case is ManorDungeonLevel.Type:
            id = manor
        case is ShoreDungeonLevel.Type:
            id = shore
        case is SanctumDungeonLevel.Type:
            id = sanctum
        default:
            id = nil
        }
        return id
    }
}
