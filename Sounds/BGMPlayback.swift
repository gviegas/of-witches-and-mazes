//
//  BGMPlayback.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation
import AVFoundation

/// A class that plays background music.
///
class BGMPlayback {
    
    /// A class that represents the current state of the playback.
    ///
    private class State: NSObject, AVAudioPlayerDelegate {
        
        /// The audio players.
        ///
        private let players: [AVAudioPlayer]
        
        /// The interval to fill with silence before the sequence starts playing.
        ///
        private let initialSilence: ClosedRange<TimeInterval>
        
        /// The interval to fill with silence between sequence loops.
        ///
        private let endSilence: ClosedRange<TimeInterval>
        
        /// The interval to fill with silence before the next track starts playing.
        ///
        private let nextSilence: ClosedRange<TimeInterval>
        
        /// The flag stating whether the sequence must be shuffled before a new loop.
        ///
        private let shuffle: Bool
        
        /// The track sequence.
        ///
        private var tracks: [BGMTrack]
        
        /// The values of the current and maximum sequence loops. The playback ends when
        /// `current > 0` (`nil` means repeat forever).
        ///
        private var sequenceLoop: (current: Int, max: Int?)
        
        /// The current loop for each track, which resets when the sequence ends.
        ///
        private var trackLoop: [Int]
        
        /// The index of the current track in the `players`/`sequence`.
        ///
        private var currentIdx: Int
        
        /// The current status.
        ///
        var status: Status {
            didSet {
                switch status {
                case .playing:
                    switch oldValue {
                    case .stopped:
                        let player = players[currentIdx]
                        let track = tracks[currentIdx]
                        player.volume = BGMPlayback.volume
                        let sequenceSilence = TimeInterval.random(in: initialSilence)
                        let trackSilence = TimeInterval.random(in: track.initialDelay)
                        player.play(atTime: player.deviceCurrentTime + sequenceSilence + trackSilence)
                    case .paused:
                        let player = players[currentIdx]
                        player.volume = BGMPlayback.volume
                        if player.currentTime > 0.0001 {
                            player.play()
                        } else {
                            player.play(atTime: player.deviceCurrentTime + TimeInterval.random(in: nextSilence))
                        }
                    default:
                        break
                    }
                
                case .stopped:
                    switch oldValue {
                    case .playing, .paused:
                        let player = players[currentIdx]
                        player.pause()
                        trackLoop = Array(repeating: 0, count: tracks.count)
                        currentIdx = 0
                    default:
                        break
                    }
                
                case .paused:
                    switch oldValue {
                    case .playing:
                        let player = players[currentIdx]
                        player.pause()
                    default:
                        break
                    }
                
                case .notSet:
                    break
                }
            }
        }
        
        /// Creates a new instance from the given values.
        ///
        /// - Parameters:
        ///   - tracks: A sequence of tracks to set.
        ///   - numberOfLoops: An optional number of times to loop through the whole sequence.
        ///     If this value is `nil`, the sequence will play indefinitely.
        ///   - initialDelay: An optional interval to fill with silence before the sequence starts playing.
        ///   - loopDelay: An optional interval to fill with silence between sequence loops.
        ///   - nextDelay: An optional interval to fill with silence before the next track starts playing.
        ///   - shuffle: An optional flag stating whether to shuffle the sequence before starting a new loop.
        ///
        init?(tracks: [BGMTrack], numberOfLoops: Int?, initialDelay: ClosedRange<TimeInterval>?,
              loopDelay: ClosedRange<TimeInterval>?, nextDelay: ClosedRange<TimeInterval>?, shuffle: Bool?) {
            
            guard !tracks.isEmpty else { return nil }
            
            var players = [AVAudioPlayer]()
            for track in tracks {
                guard let player = try? AVAudioPlayer(contentsOf: track.url) else { return nil }
                player.prepareToPlay()
                players.append(player)
            }
            self.players = players
            self.tracks = tracks
            self.shuffle = shuffle ?? false
            initialSilence = initialDelay ?? 0...0
            endSilence = loopDelay ?? 0...0
            nextSilence = nextDelay ?? 0...0
            sequenceLoop = (0, numberOfLoops)
            trackLoop = [Int](repeating: 0, count: tracks.count)
            currentIdx = 0
            status = .stopped
            
            super.init()
            self.players.forEach { $0.delegate = self }
        }
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            let nextPlayTime: TimeInterval?
            
            if tracks[currentIdx].numberOfLoops > trackLoop[currentIdx] {
                // Repeat the current track
                trackLoop[currentIdx] += 1
                nextPlayTime = TimeInterval.random(in: nextSilence) + TimeInterval.random(in: tracks[currentIdx].initialDelay)
            } else if currentIdx < players.count - 1 {
                // Play the next track
                currentIdx += 1
                nextPlayTime = TimeInterval.random(in: nextSilence) + TimeInterval.random(in: tracks[currentIdx].initialDelay)
            } else if (sequenceLoop.max == nil) || (sequenceLoop.current < sequenceLoop.max!) {
                // Repeat the whole sequence
                sequenceLoop.current += 1
                trackLoop = Array(repeating: 0, count: tracks.count)
                currentIdx = 0
                if shuffle { tracks.shuffle() }
                nextPlayTime = TimeInterval.random(in: endSilence) + TimeInterval.random(in: tracks[currentIdx].initialDelay)
            } else {
                // End playback
                nextPlayTime = nil
            }
            
            if let nextPlayTime = nextPlayTime {
                let player = players[currentIdx]
                player.volume = BGMPlayback.volume
                player.play(atTime: player.deviceCurrentTime + nextPlayTime)
            } else {
                dropSequence()
            }
        }
        
        /// Informs the state that the `BGMPlayback` volume has been changed.
        ///
        func volumeDidChange() {
            players[currentIdx].volume = BGMPlayback.volume
        }
    }
    
    /// An enum that identifies the current status of the playback.
    ///
    enum Status {
        case playing, stopped, paused, notSet
    }
    
    /// The current state set for playback.
    ///
    private static var state: State?

    /// The playback status.
    ///
    static var status: Status {
        return state?.status ?? .notSet
    }
    
    /// The playback volume, between `0` (mute) and `1.0` (full).
    ///
    static var volume: Float = 1.0 {
        didSet {
            volume = max(0, min(volume, 1.0))
            state?.volumeDidChange()
        }
    }
    
    private init() {}
    
    /// Sets a track sequence.
    ///
    /// After being set, the playback has it status defined as `.stopped`. Thus, `play()` must be
    /// called for the sequence to start playing.
    ///
    /// - Note: Calling this method will cause the current sequence, if set, to be dropped.
    ///
    /// - Parameter sequence: A `BGMSequence` defining the sequence of tracks to set.
    /// - Returns: `true` if the sequence could be set, `false` otherwise.
    ///
    class func setSequence(_ sequence: BGMSequence) -> Bool {
        dropSequence()
        state = State(tracks: sequence.tracks, numberOfLoops: sequence.numberOfLoops,
                      initialDelay: sequence.initialDelay, loopDelay: sequence.loopDelay,
                      nextDelay: sequence.nextDelay, shuffle: sequence.shuffle)
        return state != nil
    }
    
    /// Drops the current track sequence.
    ///
    class func dropSequence() {
        state?.status = .notSet
        state = nil
    }
    
    /// Plays the track sequence.
    ///
    /// Calling this method makes the playback start a `.stopped` sequence from the beginning, or
    /// resume a `.paused` sequence from where it left off.
    ///
    class func play() {
        state?.status = .playing
    }
    
    /// Stops playback.
    ///
    /// If no sequence is being played or the playback is already stopped, this method has no effect.
    ///
    class func stop() {
        state?.status = .stopped
    }
    
    /// Pauses the playback.
    ///
    /// If no sequence is being played or the playback is already paused, this method has no effect.
    ///
    class func pause() {
        state?.status = .paused
    }
}
