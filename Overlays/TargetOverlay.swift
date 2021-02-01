//
//  TargetOverlay.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/19/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Overlay` type that displays a target entity's information on a `Level` instance.
///
class TargetOverlay: Overlay, Observer, TextureUser {
    
    static var textureNames: Set<String> {
        return TargetOverlayData.textureNames
    }
    
    private var target: Entity? {
        return Game.target
    }
    
    private var portraitComponent: PortraitComponent? {
        return target?.component(ofType: PortraitComponent.self)
    }
    
    private var healthComponent: HealthComponent? {
        return target?.component(ofType: HealthComponent.self)
    }
    
    private var conditionComponent: ConditionComponent? {
        return target?.component(ofType: ConditionComponent.self)
    }
    
    let node: SKNode
    
    /// The `UITargetElement` instance.
    ///
    private let targetElement: UITargetElement
    
    /// Creates a new instance inside the given rect.
    ///
    /// - Parameter rect: The bounding rect.
    ///
    init(rect: CGRect) {
        node = SKNode()
        node.zPosition = DepthLayer.overlays.lowerBound
        
        // Create the target element
        targetElement = UITargetElement(flipped: TargetOverlayData.Target.flipped,
                                        emptyPortraitImage: TargetOverlayData.Target.emptyPortraitImage,
                                        nameBarImage: TargetOverlayData.Target.nameBarImage,
                                        healthBarImage: TargetOverlayData.Target.healthBarImage,
                                        healthImage: TargetOverlayData.Target.healthImage,
                                        healthWidth: TargetOverlayData.Target.healthWidth,
                                        nameSize: TargetOverlayData.Target.nameSize)
        
        // Set the contents
        let portrait = portraitComponent?.portrait ?? PortraitSet.question
        portrait.flipped = true
        targetElement.portrait.portrait = portrait
        portrait.flipped = false
        targetElement.nameBar.text = target?.name ?? ""
        setHealthBar()
        
        // The target overlay will be placed at the character overlay's side
        let offset: CGPoint
        if let size = SceneManager.levelScene?.characterOverlay?.size {
            offset = CGPoint(x: 32.0 + size.width, y: 8.0)
        } else {
            offset = CGPoint(x: 32.0 + targetElement.size.width, y: 8.0)
        }
        let overlayRect = CGRect(origin: CGPoint(x: rect.minX + offset.x,
                                                 y: rect.maxY - targetElement.size.height - offset.y),
                                 size: targetElement.size)
        
        // Generate the tree
        let container = UIContainer(plane: .horizontal, ratio: 1.0)
        container.addElement(targetElement)
        let tree = UITree(rect: overlayRect, root: container)
        if let treeNode = tree.generate() {
            treeNode.zPosition = 1
            node.addChild(treeNode)
        }
        
        // Register self as observer
        healthComponent?.register(observer: self)
        conditionComponent?.register(observer: self)
    }
    
    /// Sets the contents of the health bar.
    ///
    private func setHealthBar() {
        if let healthComponent = healthComponent {
            let currentHp = healthComponent.currentHP
            let totalHp = healthComponent.totalHp
            targetElement.healthBar.text = "\(currentHp)/\(totalHp)"
            targetElement.healthBar.resizeTo(normalizedValue: CGFloat(currentHp) / CGFloat(totalHp))
        } else {
            targetElement.healthBar.text = nil
            targetElement.healthBar.resizeTo(normalizedValue: 1.0/*0*/)
        }
    }
    
    func update(deltaTime seconds: TimeInterval) {
        guard target == nil, let scene = SceneManager.levelScene, scene.targetOverlay === self else { return }
        scene.targetOverlay = nil
    }
    
    func didChange(observable: Observable) {
        switch observable {
        case is HealthComponent, is ConditionComponent:
            setHealthBar()
        default:
            break
        }
    }
    
    func removeFromAllObservables() {
        healthComponent?.remove(observer: self)
        conditionComponent?.remove(observer: self)
    }
}

/// A struct that defines the data associated with the `TargetOverlay` class.
///
fileprivate struct TargetOverlayData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Target.emptyPortraitImage,
                Target.nameBarImage,
                Target.healthBarImage,
                Target.healthImage]
    }
    
    private init() {}
    
    /// The `UITargetElement` data.
    ///
    struct Target {
        private init() {}
        static let flipped = true
        static let emptyPortraitImage = "UI_Character_Empty_Portrait"
        static let nameBarImage = "UI_Character_Name_Bar"
        static let healthBarImage = "UI_Character_Health_Bar"
        static let healthImage = "UI_Character_Health"
        static let healthWidth: CGFloat = 150.0
        static let nameSize: CGSize? = nil
    }
}
