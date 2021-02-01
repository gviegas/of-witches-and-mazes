//
//  GladeDungeonLevel.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// The introductory `DungeonLevel`.
///
class GladeDungeonLevel: DungeonLevel, BGMSequenceSource, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        let contents = GladeContentSet.animationKeys
        return contents
    }
    
    static var textureNames: Set<String> {
        let tiles = GladeTileSet.textureNames
        let contents = GladeContentSet.textureNames
        return tiles.union(contents)
    }
    
    var bgmSequence: BGMSequence {
        return GladeSound.makeBGMSequence()
    }
    
    /// Creates a new instance as the first or second intro.
    ///
    /// - Parameter isFirst: A flag stating whether or not the instance is the first part of the intro.
    ///   If set to `true`, the first part of the intro is created. Otherwise, the second part is created.
    ///
    init(isFirst: Bool) {
        super.init(data: isFirst ? FirstIntroDungeonLevelData.instance : SecondIntroDungeonLevelData.instance)
    }
}

/// The `DungeonLevelData` of the first part of the `GladeDungeonLevel`.
///
fileprivate class FirstIntroDungeonLevelData: DungeonLevelData {
    
    /// The instance of the class.
    ///
    static let instance = FirstIntroDungeonLevelData()
    
    private init() {
        if Bool.random() {
            columns = 1...1
        } else {
            columns = 3...3
        }
        rooms = 3
    }
    
    let cellSize: CGSize = CGSize(width: 64.0, height: 64.0)

    let cellOffset: CGFloat = 4.0
    
    let columns: ClosedRange<Int>
    
    let rooms: Int
    
    let roomRect: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16)
    
    let roomMinSize: CGSize = CGSize(width: 13, height: 13)
    
    let roomMaxSize: CGSize = CGSize(width: 16, height: 16)
    
    let roomCornerGap: CGSize = CGSize(width: 4, height: 4)
    
    let tileSet: TileSet = GladeTileSet.instance
    
    let contentSet: ContentSet = GladeContentSet.firstIntro
    
    let entranceProbability: ContentProbability = GladeContentProbability.firstEntrance
    
    let exitProbability: ContentProbability = GladeContentProbability.firstExit
    
    let defaultProbability: ContentProbability = GladeContentProbability.firstDefault
    
    let oneTimeProbabilities: [ContentProbability] = GladeContentProbability.firstOneTime
    
    let sublevels: ClosedRange<Int> = 1...1
}

/// The `DungeonLevelData` of the second part of the `GladeDungeonLevel`.
///
fileprivate class SecondIntroDungeonLevelData: DungeonLevelData {
    
    /// The instance of the class.
    ///
    static let instance = SecondIntroDungeonLevelData()
    
    private init() {}
    
    let cellSize: CGSize = CGSize(width: 64.0, height: 64.0)
    
    let cellOffset: CGFloat = 4.0
    
    let columns: ClosedRange<Int> = 3...3
    
    let rooms: Int = 9
    
    let roomRect: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16)
    
    let roomMinSize: CGSize = CGSize(width: 13, height: 13)
    
    let roomMaxSize: CGSize = CGSize(width: 16, height: 16)
    
    let roomCornerGap: CGSize = CGSize(width: 4, height: 4)
    
    let tileSet: TileSet = GladeTileSet.instance
    
    let contentSet: ContentSet = GladeContentSet.secondIntro
    
    let entranceProbability: ContentProbability = GladeContentProbability.secondEntrance
    
    let exitProbability: ContentProbability = GladeContentProbability.secondExit
    
    let defaultProbability: ContentProbability = GladeContentProbability.secondDefault
    
    let oneTimeProbabilities: [ContentProbability] = GladeContentProbability.secondOneTime
    
    let sublevels: ClosedRange<Int> = 1...1
}

/// The sound data of the `GladeDungeonLevel`.
///
fileprivate struct GladeSound {
    
    /// Makes a `BGMSequence` for the level.
    ///
    /// - Returns: A `BGMSequence` for playback.
    ///
    static func makeBGMSequence() -> BGMSequence {
        let url1: URL! = Bundle.main.url(forResource: "Music_Awakening", withExtension: "mp3")
        let url2: URL! = Bundle.main.url(forResource: "Ambience_5", withExtension: "mp3")
        
        assert(url1 != nil && url2 != nil)
        
        let track1 = BGMTrack(url: url1!, numberOfLoops: 0, initialDelay: 0.0...0.0)
        let track2 = BGMTrack(url: url2!, numberOfLoops: 0, initialDelay: 0.0...0.0)
        
        return BGMSequence(tracks: [track1, track2].shuffled(), numberOfLoops: nil, initialDelay: 15.0...20.0,
                           loopDelay: 120.0...180.0, nextDelay: 40.0...60.0, shuffle: true)
    }
}
