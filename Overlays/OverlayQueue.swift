//
//  OverlayQueue.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/16/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that manages `NotificatioOverlay` and `NoteOverlay` instances in a scene.
///
class OverlayQueue {
    
    /// A class that defines the state of a note overlay under update.
    ///
    private class NoteState {
        
        /// The overlay being updated.
        ///
        let overlay: NoteOverlay
        
        /// The time spent being updated.
        ///
        var elapsedTime: TimeInterval = 0
        
        /// Creates a new instance representing the given `NoteOverlay`.
        ///
        /// - Parameter overlay: The `NoteOverlay` that the state represents.
        ///
        init(overlay: NoteOverlay) {
            self.overlay = overlay
        }
    }
    
    /// A class that defines the state of a pick up overlay under update.
    ///
    private class PickUpState {
        
        /// The movement speed to use when sliding down overlays to make room for others.
        ///
        static let speed: CGFloat = 100.0
        
        /// The offset to apply between state entries.
        ///
        static let offset: CGFloat = 10.0
        
        /// The overlay being updated.
        ///
        let overlay: PickUpOverlay
        
        /// The time spent being updated.
        ///
        var elapsedTime: TimeInterval = 0
        
        /// The total amount that the overlay should move down in the `y` axis.
        ///
        var toMove: CGFloat = 0
        
        /// The total amount that the overlay already moved down in the `y` axis.
        ///
        var moved: CGFloat = 0
        
        /// Creates a new instance representing the given `PickUpOverlay`.
        ///
        /// - Parameter overlay: The `PickUpOverlay` that the state represents.
        ///
        init(overlay: PickUpOverlay) {
            self.overlay = overlay
        }
    }
    
    /// The animation to run during the note overlay update.
    ///
    private let noteAnimation: SKAction
    
    /// The animation to run during the pick up overlay update.
    ///
    private let pickUpAnimation: SKAction
    
    /// The duration of the note overlay animation.
    ///
    private let noteAnimationTime: TimeInterval
    
    /// The duration of the pick up overlay animation.
    ///
    private let pickUpAnimationTime: TimeInterval
    
    /// The state of the current note overlay.
    ///
    private var noteState: NoteState?
    
    /// The states of the current pick up overlays.
    ///
    private var pickUpStates: [PickUpState?]
    
    /// A queue of pick up overlays awaiting to be presented.
    ///
    private var pickUpQueue: [PickUpOverlay]
    
    /// The most recent pick up overlay being presented.
    ///
    private weak var currentPickUp: PickUpOverlay?
    
    /// The next pick up overlay to be presented.
    ///
    private weak var nextPickUp: PickUpOverlay?
    
    /// The parent node of the overlays being updated.
    ///
    let node: SKNode
    
    /// Creates a new instance.
    ///
    /// - Parameter maxPickUpEntries: The maximum number of pick up overlays to display at the same time.
    ///   The default value is `6`.
    ///
    init(maxPickUpEntries: Int = 6) {
        assert(maxPickUpEntries > 0)
        
        pickUpStates = Array(repeating: nil, count: maxPickUpEntries)
        pickUpQueue = []
        node = SKNode()
        
        let noteFadeInDuration: TimeInterval = 0.1
        let noteFadeOutDuration: TimeInterval = 0.9
        let noteWaitDuration: TimeInterval = 4.0
        noteAnimation = SKAction.sequence([SKAction.fadeIn(withDuration: noteFadeInDuration),
                                           SKAction.wait(forDuration: noteWaitDuration),
                                           SKAction.fadeOut(withDuration: noteFadeOutDuration)])
        noteAnimationTime = noteFadeInDuration + noteFadeOutDuration + noteWaitDuration
        
        let pickUpFadeInDuration: TimeInterval = 0.3
        let pickUpFadeOutDuration: TimeInterval = 0.3
        let pickUpWaitDuration: TimeInterval = 4.4
        pickUpAnimation = SKAction.sequence([SKAction.fadeIn(withDuration: pickUpFadeInDuration),
                                             SKAction.wait(forDuration: pickUpWaitDuration),
                                             SKAction.fadeOut(withDuration: pickUpFadeOutDuration)])
        pickUpAnimationTime = pickUpFadeInDuration + pickUpFadeOutDuration + pickUpWaitDuration
    }
    
    /// Presents the given `NoteOverlay`.
    ///
    /// If a note is currently being presented, it will be replaced by the new one.
    ///
    /// - Parameter note: The `NoteOverlay` instance to present.
    ///
    func presentNote(_ note: NoteOverlay) {
        note.node.alpha = 0
        note.node.run(noteAnimation)
        noteState?.overlay.node.removeFromParent()
        noteState = NoteState(overlay: note)
        node.addChild(note.node)
        SoundFXSet.FX.alert.play(at: nil, sceneKind: nil)
    }
    
    /// Inserts the given `PickUpOverlay` in the queue.
    ///
    /// - Parameter pickUp: The `PickUpOverlay` instance to insert.
    ///
    func enqueuePickUp(_ pickUp: PickUpOverlay) {
        pickUp.node.alpha = 0
        pickUp.node.run(pickUpAnimation)
        pickUpQueue.append(pickUp)
    }
    
    /// Updates the note state.
    ///
    /// - Parameter seconds: The elapsed time since last update.
    ///
    func updateNote(deltaTime seconds: TimeInterval) {
        if let noteState = noteState {
            noteState.elapsedTime += seconds
            noteState.overlay.update(deltaTime: seconds)
            if noteState.elapsedTime >= noteAnimationTime {
                // Done, remove the current note
                noteState.overlay.node.removeFromParent()
                self.noteState = nil
            }
        }
    }
    
    /// Updates the pick up states.
    ///
    /// - Parameter seconds: The elapsed time since last update.
    ///
    func updatePickUp(deltaTime seconds: TimeInterval) {
        for (index, state) in zip(pickUpStates.indices, pickUpStates) {
            if let state = state {
                state.elapsedTime += seconds
                state.overlay.update(deltaTime: seconds)
                if state.elapsedTime >= pickUpAnimationTime {
                    // Done, remove the pick up
                    state.overlay.node.removeFromParent()
                    pickUpStates[index] = nil
                } else if state.toMove > state.moved {
                    // Move down the state's overlay node
                    let amount = CGFloat(seconds) * PickUpState.speed
                    let movement = state.moved + amount > state.toMove ? state.toMove - state.moved : amount
                    state.moved += movement
                    state.overlay.node.position.y -= movement
                }
            }
        }
        
        if let next = nextPickUp {
            let current = currentPickUp
            if current == nil || !next.node.frame.intersects(current!.node.frame) {
                // There's no current overlay or it has already moved out of the way, present the next
                pickUpStates[0] = PickUpState(overlay: next)
                pickUpQueue.removeFirst()
                node.addChild(next.node)
                currentPickUp = nextPickUp
                nextPickUp = nil
            }
        } else if !pickUpQueue.isEmpty && pickUpStates.last! == nil {
            // The nextPickUp now points to the head of the queue
            nextPickUp = pickUpQueue.first!
            // Start moving down all states to make room for the new one
            var toMove: CGFloat = 0
            for (index, state) in zip(pickUpStates.indices, pickUpStates) {
                guard let state = state else { break }
                let next = index == 0 ? nextPickUp! : pickUpStates[index-1]!.overlay
                // Update the state's distance to move
                if next.size.height >= state.overlay.size.height {
                    toMove += (next.size.height - state.overlay.size.height) / 2.0
                    toMove += PickUpState.offset + state.overlay.size.height
                } else {
                    toMove += (state.overlay.size.height - next.size.height) / 2.0
                    toMove += PickUpState.offset + next.size.height
                }
                state.toMove = toMove
            }
            // Make room for the head of the queue in the pick up state list
            for i in stride(from: pickUpStates.count - 1, to: 0, by: -1) {
                // Note: Consider to start swaping from the first nil state
                pickUpStates.swapAt(i, i-1)
            }
        }
    }
    
    /// Updates the queue.
    ///
    /// - Parameter seconds: The elapsed time since last update.
    ///
    func update(deltaTime seconds: TimeInterval) {
        updateNote(deltaTime: seconds)
        updatePickUp(deltaTime: seconds)
    }
}
