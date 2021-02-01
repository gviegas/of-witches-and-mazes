//
//  MazeMinimap.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/7/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `Minimap` type able to represent the minimap of a `Maze`.
///
class MazeMinimap: Minimap, TextureUser {
    
    static var textureNames: Set<String> {
        // Note: Non-default minimaps may want to drop the MinimapTileSet textures
        let tileSet = MinimapTileSet.textureNames
        let markers = ["Minimap_Center_Marker", "Minimap_Merchant_Marker", "Minimap_Exit_Marker"]
        return tileSet.union(markers)
    }
    
    let node: SKNode
    let size: CGSize
    weak var referenceEntity: Entity?
    
    /// The x scale of the minimap cell relative to the original maze cell.
    ///
    private let xScale: CGFloat
    
    /// The y scale of the minimap cell relative to the original maze cell.
    ///
    private let yScale: CGFloat
    
    /// The sprite node representing the minimap.
    ///
    private let minimapNode: SKSpriteNode
    
    /// The crop node that will present a portion of the minimap sprite.
    ///
    private let cropNode: SKCropNode
    
    /// The marker that represents the reference entity.
    ///
    private let centerMarker: SKSpriteNode
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - maze: The `Maze` instance from which to create the minimap.
    ///   - tileSet: The `TileSet` to use when filling the minimap with tiles.
    ///   - size: The size of the minimap frame.
    ///
    init(maze: Maze, tileSet: TileSet, size: CGSize) {
        node = SKNode()
        self.size = size
        referenceEntity = Game.protagonist
        cropNode = SKCropNode()
        xScale = tileSet.cellSize.width / maze.cellSize.width
        yScale = tileSet.cellSize.height / maze.cellSize.height
        
        // Place the minimap tiles
        let tilePlacer = TilePlacer(tileSet: tileSet)
        let tileNodes = SKNode()
        for i in 0..<maze.rooms.count {
            let tileNode = SKNode()
            tilePlacer.placeTiles(forRoom: maze.rooms[i], onNode: tileNode)
            tileNodes.addChild(tileNode)
        }
        
        // Create the minimap texture from the tile nodes
        let minimapSize = CGSize(width: tileSet.cellSize.width * maze.rect.size.width,
                                 height: tileSet.cellSize.height * maze.rect.size.height)
        let minimapRect = CGRect(origin: .zero, size: minimapSize)
        let minimapTexture = SceneManager.view?.texture(from: tileNodes, crop: minimapRect)
        minimapNode = SKSpriteNode(texture: minimapTexture)
        minimapNode.anchorPoint = .zero
        
        // Create the crop node to show only a portion of the minimap
        cropNode.maskNode = SKSpriteNode(color: .black, size: size)
        cropNode.addChild(minimapNode)
        node.addChild(cropNode)
        
        let markerSize = CGSize(width: 16.0, height: 16.0)
        
        // Create the center marker
        let markerTexture = TextureSource.createTexture(imageNamed: "Minimap_Center_Marker")
        centerMarker = SKSpriteNode(texture: markerTexture, size: markerSize)
        centerMarker.zPosition = 32
        cropNode.addChild(centerMarker)
        
        // Create the merchant marker
        var merchantPosition: CGPoint? = nil
        for contents in maze.staticContents {
            if let merchant = contents.first(where: { $0.type == .merchant }) {
                merchantPosition = merchant.node.position
                break
            }
        }
        if let position = merchantPosition {
            let markerTexture = TextureSource.createTexture(imageNamed: "Minimap_Merchant_Marker")
            let merchantMarker = SKSpriteNode(texture: markerTexture, size: markerSize)
            merchantMarker.position = CGPoint(x: position.x * xScale, y: position.y * yScale)
            merchantMarker.zPosition = centerMarker.zPosition - 1
            minimapNode.addChild(merchantMarker)
        }
        
        // Create the exit marker
        if let index = maze.exitRoomIndex {
            if let position = maze.staticContents[index].first(where: { $0.type == .exit })?.node.position {
                let markerTexture = TextureSource.createTexture(imageNamed: "Minimap_Exit_Marker")
                let exitMarker = SKSpriteNode(texture: markerTexture, size: markerSize)
                exitMarker.position = CGPoint(x: position.x * xScale, y: position.y * yScale)
                exitMarker.zPosition = centerMarker.zPosition - 1
                minimapNode.addChild(exitMarker)
            }
        }
    }
    
    /// Creates a new, default instance from the given maze object.
    ///
    /// - Parameter maze: The `Maze` instance from which to create the minimap.
    ///
    convenience init(maze: Maze) {
        self.init(maze: maze, tileSet: MinimapTileSet.instance, size: CGSize(width: 144.0, height: 144.0))
    }
    
    func update(deltaTime seconds: TimeInterval) {
        guard let referenceNode = referenceEntity?.component(ofType: NodeComponent.self)?.node else { return }
        
        // Update the tile group position relative to the reference node's
        let newPosition = CGPoint(x: -(referenceNode.position.x * xScale),
                                  y: -(referenceNode.position.y * yScale))
        minimapNode.position = newPosition
        
        // ToDo: Only set marker rotation when direction changes (observe movement component)
        if let direction = referenceEntity!.component(ofType: MovementComponent.self)?.movement {
            if direction != CGVector.zero {
                let zRotation: CGFloat = atan2(direction.dy, direction.dx)
                centerMarker.zRotation = zRotation
            }
        }
    }
}
