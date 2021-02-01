//
//  LevelScene.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/20/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `Scene` subclass that holds `Level` state.
///
class LevelScene: Scene {
    
    /// The protagonist currently set in the `Game`'s global data.
    ///
    private var protagonist: Protagonist? {
        return Game.protagonist as? Protagonist
    }
    
    /// The current state of the protagonist, as a `ControllableEntityState` type.
    ///
    private var protagonistState: ControllableEntityState? {
        let component = protagonist?.component(ofType: StateComponent.self)
        return component?.currentState as? ControllableEntityState
    }
    
    /// The `StageInfo` of the protagonist.
    ///
    private var stageInfo: StageInfo? {
        get {
            return protagonist?.component(ofType: StageComponent.self)?.stageInfo
        }
        set {
            if newValue != nil {
                protagonist?.component(ofType: StageComponent.self)?.stageInfo = newValue!
            }
        }
    }
    
    /// The last update time.
    ///
    private var lastUpdateTime: TimeInterval
    
    /// The flag stating whether or not a sublevel is running.
    ///
    private var isRunning: Bool
    
    /// The flag stating whether or not a stage transition is taking place.
    ///
    private var isTransitioning: Bool
    
    /// The node of the current sublevel.
    ///
    private var sublevelNode: SKNode?
    
    /// The overlays.
    ///
    private var overlays: [ObjectIdentifier: Overlay]
    
    /// The overlay queue of the level.
    ///
    private let overlayQueue: OverlayQueue

    /// The character overlay.
    ///
    /// - Note: Replaced overlays must not be used any further.
    ///
    var characterOverlay: CharacterOverlay? {
        willSet {
            guard characterOverlay !== newValue else { return }
            if let characterOverlay = characterOverlay {
                characterOverlay.node.removeFromParent()
                characterOverlay.removeFromAllObservables()
                overlays[ObjectIdentifier(characterOverlay)] = nil
            }
            if let newValue = newValue {
                newValue.node.position = CGPoint(x: -frame.width / 2.0, y: -frame.height / 2.0)
                camera?.addChild(newValue.node)
                overlays[ObjectIdentifier(newValue)] = newValue
            }
        }
    }
    
    /// The target overlay.
    ///
    /// - Note: Replaced overlays must not be used any further.
    ///
    var targetOverlay: TargetOverlay? {
        willSet {
            guard targetOverlay !== newValue else { return }
            if let targetOverlay = targetOverlay {
                targetOverlay.node.removeFromParent()
                targetOverlay.removeFromAllObservables()
                overlays[ObjectIdentifier(targetOverlay)] = nil
            }
            if let newValue = newValue {
                newValue.node.position = CGPoint(x: -frame.width / 2.0, y: -frame.height / 2.0)
                camera?.addChild(newValue.node)
                overlays[ObjectIdentifier(newValue)] = newValue
            }
        }
    }
    
    /// The minimap overlay.
    ///
    /// - Note: Replaced overlays must not be used any further.
    ///
    var minimapOverlay: MinimapOverlay? {
        willSet {
            guard minimapOverlay !== newValue else { return }
            if let minimapOverlay = minimapOverlay {
                minimapOverlay.node.removeFromParent()
                overlays[ObjectIdentifier(minimapOverlay)] = nil
            }
            if let newValue = newValue {
                newValue.node.position = CGPoint(x: -frame.width / 2.0, y: -frame.height / 2.0)
                camera?.addChild(newValue.node)
                overlays[ObjectIdentifier(newValue)] = newValue
            }
        }
    }
    
    /// The option overlay.
    ///
    /// - Note: Replaced overlays must not be used any further.
    ///
    var optionOverlay: OptionOverlay? {
        willSet {
            guard optionOverlay !== newValue else { return }
            if let optionOverlay = optionOverlay {
                optionOverlay.node.removeFromParent()
                optionOverlay.removeFromAllObservables()
                overlays[ObjectIdentifier(optionOverlay)] = nil
            }
            if let newValue = newValue {
                newValue.node.position = CGPoint(x: -frame.width / 2.0, y: -frame.height / 2.0)
                camera?.addChild(newValue.node)
                overlays[ObjectIdentifier(newValue)] = newValue
            }
        }
    }
    
    /// Creates a new instance.
    ///
    override init() {
        lastUpdateTime = 0
        isRunning = false
        isTransitioning = false
        overlays = [:]
        overlayQueue = OverlayQueue()
        super.init()
        backgroundColor = .black
        alpha = 0
        
        // Create the camera node
        let cameraNode = SKCameraNode()
        let range = SKRange(constantValue: 0)
        let constraint = SKConstraint.positionX(range, y: range)
        constraint.referenceNode = protagonist?.component(ofType: NodeComponent.self)?.node
        cameraNode.constraints = [constraint]
        cameraNode.position = constraint.referenceNode!.position
        camera = cameraNode
        addChild(cameraNode)
        
        let rect = CGRect(origin: CGPoint(x: -frame.width / 2.0, y: -frame.height / 2.0), size: frame.size)
        
        // Create the character overlay
        characterOverlay = CharacterOverlay(rect: rect)
        cameraNode.addChild(characterOverlay!.node)
        overlays[ObjectIdentifier(characterOverlay!)] = characterOverlay
        
        // Add the overlay queue node
        cameraNode.addChild(overlayQueue.node)
        // The camera has its origin at the center, so the overlay queue position must be adjusted
        overlayQueue.node.position = rect.origin
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        lastUpdateTime = 0
        if !isRunning { moveToNextStage() }
        protagonistState?.didGetControlBack()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        guard !isTransitioning else { return }
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let dt = currentTime - lastUpdateTime
        
        if isRunning {
            // Update the level
            LevelManager.currentLevel?.update(deltaTime: dt)
            // Update the overlays
            for (_, overlay) in overlays { overlay.update(deltaTime: dt) }
            // Update the overlay queue
            overlayQueue.update(deltaTime: dt)
        } else {
            // Not running, load the next stage
            targetOverlay = nil
            minimapOverlay = nil
            optionOverlay = nil
            moveToNextStage()
        }
        
        lastUpdateTime = currentTime
    }
    
    override func mouseDown(with event: NSEvent) {
        guard let protagonistState = protagonistState else { return }
        
        if let event = createEvent(ofType: .mouseDown, fromNSEvent: event) {
            protagonistState.didReceiveEvent(event)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        guard let protagonistState = protagonistState else { return }
        
        if let event = createEvent(ofType: .mouseUp, fromNSEvent: event) {
            protagonistState.didReceiveEvent(event)
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        guard let protagonistState = protagonistState else { return }
        
        if let event = createEvent(ofType: .mouseDown, fromNSEvent: event) {
            protagonistState.didReceiveEvent(event)
        }
    }
    
    override func rightMouseUp(with event: NSEvent) {
        guard let protagonistState = protagonistState else { return }
        
        if let event = createEvent(ofType: .mouseUp, fromNSEvent: event) {
            protagonistState.didReceiveEvent(event)
        }
    }
    
    override func mouseEnteredTrackingArea(event: MouseEvent) {
        protagonistState?.didReceiveEvent(event)
    }
    
    override func mouseExitedTrackingArea(event: MouseEvent) {
        protagonistState?.didReceiveEvent(event)
    }
    
    override func keyDown(with event: NSEvent) {
        guard let protagonistState = protagonistState else { return }
        
        if let event = createEvent(ofType: .keyDown, fromNSEvent: event) {
            protagonistState.didReceiveEvent(event)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        guard let protagonistState = protagonistState else { return }
        
        if let event = createEvent(ofType: .keyUp, fromNSEvent: event) {
            protagonistState.didReceiveEvent(event)
        }
    }
    
    /// Moves to the next stage.
    ///
    /// This method first attempts to load the next sublevel relative to the current level in the
    /// `LevelManager`. If successful, the sublevel is started, otherwise a new level is retrieved
    /// from the `LevelManager` to provide a sublevel. When the `LevelManager` is exhausted, a new
    /// sequence is created to provide levels and sublevels, thus creating an infinite amount of stages.
    ///
    private func moveToNextStage() {
        guard stageInfo != nil else { return }
        
        sublevelNode?.removeFromParent()
        
        sublevelNode = LevelManager.currentLevel?.nextSublevel {
            [unowned self] in
            self.isRunning = false
            self.stageInfo?.currentSublevel += 1
        }
        
        if let newSublevelNode = sublevelNode {
            addChild(newSublevelNode)
            if let minimap = LevelManager.currentLevel?.provideMinimap() {
                minimapOverlay = MinimapOverlay(rect: frame, minimap: minimap)
            }
            isRunning = true
            isTransitioning = true
            run(.fadeIn(withDuration: 0.1)) { [unowned self] in
                self.isTransitioning = false
            }
        } else {
            let newLevel: Level
            if let _ = LevelManager.nextLevel() {
                newLevel = LevelManager.currentLevel!
                assert(LevelID.idForType(type(of: newLevel)) != nil)
                stageInfo!.completion.insert(stageInfo!.currentLevel)
                stageInfo!.currentLevel = LevelID.idForType(type(of: newLevel))!
                stageInfo!.currentSublevel = 1
            } else {
                guard stageInfo!.currentLevel != .glade else {
                    let _ = Session.end(andSave: false)
                    let _ = SceneManager.switchToScene(ofKind: .mainMenu)
                    return
                }
                stageInfo!.completion = []
                stageInfo!.currentLevel = .nightGlade
                stageInfo!.currentSublevel = 1
                stageInfo!.run += 1
                LevelManager.setLevels(levels: LevelPreparer.fromStageInfo(stageInfo!))
                LevelManager.start()
                newLevel = LevelManager.currentLevel!
            }
            if let newLevel = newLevel as? BGMSequenceSource {
                BGMPlayback.setSequence(newLevel.bgmSequence) ? BGMPlayback.play() : BGMPlayback.dropSequence()
            }
            let protagonistType = type(of: protagonist!)
            let levelID = stageInfo!.currentLevel
            let _ = SceneManager.switchToScene(ofKind: .loading)
            AnimationReleaseManager.retainGameAnimations(protagonistType: protagonistType, levelID: levelID)
            TexturePreloadManager.preloadGameTextures(protagonistType: protagonistType, levelID: levelID) {
                DispatchQueue.main.async {
                    let _ = SceneManager.switchToScene(ofKind: .level)
                }
            }
        }
    }
    
    /// Completes the current stage.
    ///
    func completeCurrentStage() {
        isTransitioning = true
        children.forEach {  $0.isPaused = true }
        run(.fadeOut(withDuration: 0.1)) { [unowned self] in
            let _ = Session.save()
            self.isTransitioning = false
            self.children.forEach { $0.isPaused = false }
            LevelManager.currentLevel?.finishSublevel()
        }
    }
    
    /// Adds a new `Overlay` instance to the scene.
    ///
    /// - Parameter overlay: The overlay to add.
    ///
    func addOverlay(_ overlay: Overlay) {
        let key = ObjectIdentifier(overlay)
        if let _ = overlays[key] { return }
        // The camera has its origin at the center, so the overlay position must be adjusted
        overlay.node.position = CGPoint(x: -frame.width / 2.0, y: -frame.height / 2.0)
        camera!.addChild(overlay.node)
        overlays[key] = overlay
    }

    /// Removes an `Overlay` instance from the scene.
    ///
    /// - Parameter overlay: The overlay to remove.
    ///
    func removeOverlay(_ overlay: Overlay) {
        let key = ObjectIdentifier(overlay)
        if let _ = overlays[key] {
            overlay.node.removeFromParent()
            (overlays[key] as? Observer)?.removeFromAllObservables()
            overlays[key] = nil
        }
    }
    
    /// Presents a new, temporary, `NoteOverlay` instance using the scene's `OverlayQueue`.
    ///
    /// - Parameter note: The note to present.
    ///
    func presentNote(_ note: NoteOverlay) {
        overlayQueue.presentNote(note)
    }
    
    /// Enqueues a new, temporary, `PickUpOverlay` instance to the scene's `OverlayQueue`.
    ///
    /// - Parameter notification: The notification overlay to enqueue.
    ///
    func enqueuePickUp(_ pickUp: PickUpOverlay) {
        overlayQueue.enqueuePickUp(pickUp)
    }
    
    override func willDeallocate() {
        overlays.forEach { ($0.value as? Observer)?.removeFromAllObservables() }
    }
}
