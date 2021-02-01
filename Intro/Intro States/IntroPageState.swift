//
//  IntroPageState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/2/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllableEntityState` subclass for intro pages.
///
class IntroPageState: ControllableEntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to IntroPageState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to IntroPageState must have a SpriteComponent")
        }
        return component
    }
    
    private var subjectComponent: SubjectComponent {
        guard let component = entity.component(ofType: SubjectComponent.self) else {
            fatalError("An entity assigned to IntroPageState must have a SubjectComponent")
        }
        return component
    }
    
    /// The entries to display on the page.
    ///
    var entries: [UIPageElement.Entry] = []
    
    /// The left option text.
    ///
    var leftOption: String? = nil
    
    /// The right option text.
    ///
    var rightOption: String? = nil
    
    /// The optional callback to run when the page has just closed.
    ///
    var onClose: (() -> Void)?
    
    /// The page overlay.
    ///
    private var pageOverlay: PageOverlay?
    
    override func didEnter(from previousState: GKState?) {
        guard let scene = SceneManager.levelScene else {
            stateMachine?.enter(IntroStandardState.self)
            return
        }
        
        let rect = scene.frame
        
        movementComponent.movement = CGVector.zero
        spriteComponent.animate(name: .idle)
        
        pageOverlay = PageOverlay(entries: entries, leftOption: leftOption, rightOption: rightOption, rect: rect) {
            [unowned self] in
            SceneManager.levelScene?.removeOverlay(self.pageOverlay!)
            self.onClose?()
            self.stateMachine?.enter(IntroStandardState.self)
        }
        
        scene.addOverlay(pageOverlay!)
    }
    
    override func willExit(to nextState: GKState) {
        SceneManager.levelScene?.removeOverlay(pageOverlay!)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is IntroStandardState.Type
    }
    
    override func didReceiveEvent(_ event: Event) {
        if event.isMouseEvent { super.didReceiveEvent(event) }
        pageOverlay?.didReceiveEvent(event)
    }
}
