//
//  GameOverState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/23/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllableEntityState` subclass for the game over.
///
class GameOverState: ControllableEntityState {
    
    /// The game over overlay.
    ///
    private var gameOverOverlay: GameOverOverlay?
    
    override func didEnter(from previousState: GKState?) {
        guard let scene = SceneManager.levelScene else {
            // Note: This should never happen
            let _ = Session.restart(andSave: true)
            return
        }
        
        gameOverOverlay = GameOverOverlay(rect: scene.frame) {
            [unowned self] in
            SceneManager.levelScene?.removeOverlay(self.gameOverOverlay!)
        }
        
        scene.addOverlay(gameOverOverlay!)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
    
    override func didReceiveEvent(_ event: Event) {
        if event.isMouseEvent { super.didReceiveEvent(event) }
        gameOverOverlay?.didReceiveEvent(event)
    }
}
