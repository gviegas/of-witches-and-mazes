//
//  SoundFX.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/30/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation
import AVFoundation

/// A class that defines a sound effect.
///
class SoundFX {
    
    /// The dispatch queue.
    ///
    private static let queue = DispatchQueue(label: "SoundFX.queue")
    
    /// The audio engine.
    ///
    private static let audioEngine = createAudioEngine()
    
    /// The mixer node.
    ///
    private static let mixerNode = createMixerNode()
    
    /// The playback volume, between `0` (mute) and `1.0` (full).
    ///
    static var volume: Float = 1.0 {
        didSet {
            volume = max(0, min(volume, 1.0))
            mixerNode.outputVolume = volume
        }
    }
    
    /// The audio buffer.
    ///
    private let audioBuffer: AVAudioPCMBuffer
    
    /// The duration of the audio, in nanoseconds.
    ///
    private let duration: UInt64
    
    /// Creates a new instance from the given `URL`.
    ///
    /// - Parameter url: The `URL` of the audio asset.
    ///
    init(url: URL) {
        do {
            let audioFile = try AVAudioFile(forReading: url,
                                            commonFormat: .pcmFormatFloat32,
                                            interleaved: false)
            audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                           frameCapacity: AVAudioFrameCount(audioFile.length))!
            try audioFile.read(into: audioBuffer)
            duration = UInt64(Double(audioFile.length) / audioFile.fileFormat.sampleRate * pow(10, 9))
        } catch {
            fatalError("Failed to create SoundFX from URL '\(url.absoluteString)'")
        }
    }
    
    /// Creates a new instance from the given file name and extension.
    ///
    /// - Parameters:
    ///   - fileName: The name of the audio file.
    ///   - fileExtension: The file extension. The default value is "mp3".
    ///
    convenience init(fileName: String, fileExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            fatalError("Failed to create SoundFX from name '\(fileName)' and extension '\(fileExtension)'")
        }
        self.init(url: url)
    }
    
    /// Plays the sound effect.
    ///
    /// - Parameters:
    ///   - position: The position at which the sound effect should be played. If this parameter is
    ///     not `nil`, the sound effect will be spatialized relative to the current `Protagonist`.
    ///   - sceneKind: An optional `SceneKind` defining in which scene of the `SceneManager` the sound
    ///     effect is expected to play. If this parameter is not `nil` and the current scene is not of
    ///     the specified kind, the sound effect will not be played.
    ///
    func play(at position: CGPoint?, sceneKind: SceneKind?) {
        guard sceneKind == nil || sceneKind == SceneManager.currentSceneKind else { return }
        
        let isPositional: Bool
        let sourcePosition: AVAudio3DPoint!
        if let p = position, let o = Game.protagonist?.component(ofType: NodeComponent.self)?.node.position {
            isPositional = true
            sourcePosition = .init(x: Float(p.x - o.x), y: Float(p.y - o.y), z: 0)
        } else {
            isPositional = false
            sourcePosition = nil
        }
        
        SoundFX.queue.async { [unowned self] in
            let audioNode = AVAudioPlayerNode()
            SoundFX.audioEngine.attach(audioNode)
            if isPositional {
                audioNode.position = sourcePosition
                SoundFX.spatialize(source: audioNode)
            }
            SoundFX.audioEngine.connect(audioNode, to: SoundFX.mixerNode, format: self.audioBuffer.format)
            audioNode.scheduleBuffer(self.audioBuffer, at: nil)
            audioNode.play()
            
            let now = mach_absolute_time()
            SoundFX.queue.asyncAfter(deadline: .init(uptimeNanoseconds: now + self.duration)) {
                SoundFX.audioEngine.detach(audioNode)
            }
        }
    }
    
    /// Creates the audio engine.
    ///
    /// - Returns: The `AVAudioEngine` object to be used by the SoundFX class.
    ///
    private class func createAudioEngine() -> AVAudioEngine {
        let audioEngine = AVAudioEngine()
        audioEngine.attach(mixerNode)
        let sampleRate = audioEngine.outputNode.outputFormat(forBus: 0).sampleRate
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)
        audioEngine.connect(mixerNode, to: audioEngine.outputNode, format: format)
        try! audioEngine.start()
        return audioEngine
    }
    
    /// Creates the environment mixer node.
    ///
    /// - Returns: The `AVAudioEnvironmentNode` object to be used by the SoundFX class.
    ///
    private class func createMixerNode() -> AVAudioEnvironmentNode {
        let mixerNode = AVAudioEnvironmentNode()
        mixerNode.listenerPosition = .init(x: 0, y: 0, z: 0)
        return mixerNode
    }
    
    /// Spatializes a source audio node.
    ///
    /// - Note: This method assumes that the source's `position` was previously set relative
    ///   to a listener whose location is at the origin.
    ///
    /// - Parameter source: The node to be spatialized.
    ///
    private class func spatialize(source: AVAudioMixing) {
        let threshold: Float = 1260.0 // 36m
        let p = source.position
        let len = max(1.0, (p.x * p.x + p.y * p.y + p.z * p.z).squareRoot())
        let c = p.x / len
        source.pan = c < 0 ? max(c, c * (len / threshold)) : min(c, c * (len / threshold))
        source.volume = 1.0 - (min(len, threshold) / threshold)
    }
}
