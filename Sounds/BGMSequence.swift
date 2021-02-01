//
//  BGMSequence.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/29/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation
import AVFoundation

/// A protocol indicating that a type can provide a `BGMSequence`.
///
protocol BGMSequenceSource {
    
    /// The `BGMSequence`.
    ///
    var bgmSequence: BGMSequence { get }
}

/// A struct that represents a single track for a `BGMSequence`, which can be played by
/// the `BGMPlayback`.
///
struct BGMTrack {
    
    /// The `URL` of the track.
    ///
    let url: URL
    
    /// The number of times to repeat the track. `0` means it will play only once.
    ///
    let numberOfLoops: Int
    
    /// The time to wait before playing the track.
    ///
    let initialDelay: ClosedRange<TimeInterval>
}

/// A struct that represents a sequence of `BGMTrack`s for playback.
///
struct BGMSequence {
    
    /// The sequence of `BGMTrack`s.
    ///
    let tracks: [BGMTrack]
    
    /// The number of times to repeat the sequence. `0` means it will play only once,
    /// and `nil` means it will repeat indefinitely.
    ///
    let numberOfLoops: Int?
    
    /// The time to wait before starting the sequence.
    ///
    let initialDelay: ClosedRange<TimeInterval>
    
    /// The time to wait before repeating the whole sequence.
    ///
    let loopDelay: ClosedRange<TimeInterval>
    
    /// The time to wait before playing the next track in the sequence.
    ///
    let nextDelay: ClosedRange<TimeInterval>
    
    /// The flag stating whether the sequence should be shuffled before a new loop starts playing.
    ///
    let shuffle: Bool
}
