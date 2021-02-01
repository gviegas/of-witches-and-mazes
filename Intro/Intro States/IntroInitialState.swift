//
//  IntroInitialState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/10/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllabeEntityState` subclass representing the initial state during the introduction.
///
class IntroInitialState: ControllableEntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to IntroInitialState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to IntroInitialState must have a SpriteComponent")
        }
        return component
    }
    
    /// The page overlay.
    ///
    private var pageOverlay: PageOverlay?
    
    /// The time spent in this state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The time it takes to finish the spawn process.
    ///
    private var spawnDuration: TimeInterval = 5.0
    
    /// The entries to display on the page.
    ///
    var entries: [UIPageElement.Entry] = []
    
    /// The left option text.
    ///
    var leftOption: String? = nil
    
    /// The right option text.
    ///
    var rightOption: String? = nil
    
    override func didEnter(from previousState: GKState?) {
        elapsedTime = 0
        movementComponent.movement = CGVector.zero
        spriteComponent.animate(name: .idle)
        if let pageOverlay = pageOverlay {
            SceneManager.levelScene?.removeOverlay(pageOverlay)
            self.pageOverlay = nil
        }
    }
    
    override func willExit(to nextState: GKState) {
        if let pageOverlay = pageOverlay {
            SceneManager.levelScene?.removeOverlay(pageOverlay)
            self.pageOverlay = nil
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is IntroStandardState.Type || stateClass is IntroPageState.Type
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        
        if pageOverlay == nil, elapsedTime >= spawnDuration, let scene = SceneManager.levelScene {
            let callback: () -> Void = {
                [unowned self] in
                SceneManager.levelScene?.removeOverlay(self.pageOverlay!)
                self.stateMachine?.enter(IntroStandardState.self)
            }
            
            pageOverlay = PageOverlay(entries: entries, leftOption: leftOption, rightOption: rightOption,
                                      rect: scene.frame, onEnd: callback)
            
            scene.addOverlay(pageOverlay!)
        }
    }
    
    override func didReceiveEvent(_ event: Event) {
        super.didReceiveEvent(event)
        pageOverlay?.didReceiveEvent(event)
    }
}

