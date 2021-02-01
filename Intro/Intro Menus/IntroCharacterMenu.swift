//
//  IntroCharacterMenu.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/9/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `CharacterMenu` subclass used in the intro.
///
class IntroCharacterMenu: CharacterMenu {
    
    /// The flag stating whether or not to show the intro page the first time the menu is opened.
    ///
    /// - Note: This flag is set to `false` after the page is displayed.
    ///
    var introPageOnOpen: Bool = true
    
    /// Displays the intro page.
    ///
    private func displayIntroPage() {
        guard let menuScene = menuScene else { return }
        
        let title = "- Character -"
        let text = """
        The character stats are located at the left side. By defeating enemies, new levels are attained and \
        the character becomes more powerful.

        The inventory is located at the center. The topmost row represents the equipped items, while the \
        remaining slots represent the stashed items. Stashed items cannot be used in dungeons and will not \
        provide bonuses to the character - they must be equipped to do so.

        The skills are located at the right side. Attaining new levels will award skill points, which can then \
        be used to unlock new skills. Skills may differ in cost, and they can be unlocked in any order.

        The available options are show in the bottom.
        """
        
        let entries: [UIPageElement.Entry] = [.label(style: .title, text: title), .space(4.0),
                                              .label(style: .text, text: text), .space(4.0)]
        let callback: () -> Void = {
            [unowned self] in
            self.menuScene?.removeOverlay(self.controllableOverlay!)
            self.introPageOnOpen = false
            self.controllableOverlay = nil
            self.undull()
        }
        controllableOverlay = PageOverlay(entries: entries, leftOption: nil, rightOption: "CLOSE",
                                          rect: menuScene.frame, onEnd: callback)
        menuScene.addOverlay(controllableOverlay!)
        dull()
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if introPageOnOpen {
            introPageOnOpen = false
            displayIntroPage()
        }
        super.update(deltaTime: seconds)
    }
}
