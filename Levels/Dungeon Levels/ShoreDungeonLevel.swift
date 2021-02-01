//
//  ShoreDungeonLevel.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/17/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// The Shore `DungeonLevel`.
///
class ShoreDungeonLevel: DungeonLevel, SublevelInitializable, BGMSequenceSource, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        let contents = ShoreContentSet.animationKeys
        return contents
    }
    
    static var textureNames: Set<String> {
        let tiles = ShoreTileSet.textureNames
        let contents = ShoreContentSet.textureNames
        return tiles.union(contents)
    }
    
    var bgmSequence: BGMSequence {
        return ShoreSound.makeBGMSequence()
    }
    
    required init?(currentSublevel: Int) {
        super.init(data: ShoreDungeonLevelData(currentSublevel: currentSublevel))
    }
}

/// The `DungeonLevelData` of the Shore dungeon.
///
fileprivate class ShoreDungeonLevelData: DungeonLevelData {
    
    /// Creates a new instance starting from the given sublevel.
    ///
    /// - Parameter currentSublevel: The sublevel to start at.
    ///
    init(currentSublevel: Int) {
        assert(currentSublevel > 0)
        let maxSublevels = Int.random(in: 9...11)
        let remainingSublevels = max(1, maxSublevels - (currentSublevel - 1))
        sublevels = remainingSublevels...remainingSublevels
    }
    
    let cellSize: CGSize = CGSize(width: 64.0, height: 64.0)
    
    let cellOffset: CGFloat = 4.0
    
    let columns: ClosedRange<Int> = 2...8
    
    let rooms: Int = 60
    
    let roomRect: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16)
    
    let roomMinSize: CGSize = CGSize(width: 11, height: 11)
    
    let roomMaxSize: CGSize = CGSize(width: 16, height: 16)
    
    let roomCornerGap: CGSize = CGSize(width: 4, height: 4)
    
    let tileSet: TileSet = ShoreTileSet.instance
    
    let contentSet: ContentSet = ShoreContentSet.instance
    
    let entranceProbability: ContentProbability = ShoreContentProbability.entrance
    
    let exitProbability: ContentProbability = ShoreContentProbability.exit
    
    let defaultProbability: ContentProbability = ShoreContentProbability.default
    
    let oneTimeProbabilities: [ContentProbability] = ShoreContentProbability.oneTime
    
    let sublevels: ClosedRange<Int>
}

/// The sound data of the `ShoreDungeonLevel`.
///
fileprivate struct ShoreSound {
    
    /// Makes a `BGMSequence` for the level.
    ///
    /// - Returns: A `BGMSequence` for playback.
    ///
    static func makeBGMSequence() -> BGMSequence {
        let url1: URL! = Bundle.main.url(forResource: "Music_This_Ocean_Sings_No_More", withExtension: "mp3")
        let url2: URL! = Bundle.main.url(forResource: "Ambience_7", withExtension: "mp3")
        let url3: URL! = Bundle.main.url(forResource: "Ambience_8", withExtension: "mp3")
        
        assert(url1 != nil && url2 != nil && url3 != nil)
        
        let track1 = BGMTrack(url: url1!, numberOfLoops: 0, initialDelay: 0.0...0.0)
        let track2 = BGMTrack(url: url2!, numberOfLoops: 0, initialDelay: 0.0...0.0)
        let track3 = BGMTrack(url: url3!, numberOfLoops: 0, initialDelay: 0.0...0.0)
        
        let tracks = Bool.random() ? [track1, track2, track3] : [track1, track3, track2]
        return BGMSequence(tracks: tracks, numberOfLoops: nil, initialDelay: 60.0...90.0,
                           loopDelay: 240.0...300.0, nextDelay: 180.0...210.0, shuffle: true)
    }
}
