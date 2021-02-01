//
//  Maze.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/3/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that represents a maze.
///
/// This class offers many functionalities to create mazes, including structure, tiles and contents.
/// Since this class is intended to offer great flexibility, it requires a considerable number of
/// function calls and setup before anything useful is built, and many validation checks are not
/// performed where care ensures correctness.
///
class Maze {
    
    /// An enum that identifies a type of maze connection.
    ///
    private enum MazeConnection {
        case north(origin: Int, length: Int)
        case south(origin: Int, length: Int)
        case east(origin: Int, length: Int)
        case west(origin: Int, length: Int)
    }
    
    /// An enum that idetifies a maze room adjacency.
    ///
    enum RoomAdjacency {
        case north, south, east, west, northEast, northWest, southEast, southWest
    }
    
    /// The maze graph.
    ///
    private var graph: Graph<GridVertex, UInt>?
    
    /// The origin vertex of the maze graph.
    ///
    private var originVertex: GridVertex?
    
    /// The number of columns used to create the graph.
    ///
    private var columns = 0
    
    /// The number of rows used to creaate the graph.
    ///
    private var rows = 0
    
    /// The boundary (maximum) size, in cells, used to create the rooms.
    ///
    private var roomSize = CGSize.zero
    
    /// The cell size used for this maze.
    ///
    let cellSize: CGSize
    
    /// The cell offset used for this maze.
    ///
    let cellOffset: CGFloat

    /// The maze rooms.
    ///
    /// The rooms created by createRooms(roomCreator:) are inserted into this array in column-major order.
    ///
    var rooms = [Room]()
    
    /// The static contents.
    ///
    /// Note that the indices matches those of the rooms array (i.e., contents at index N belong to
    /// the room found at index N of the rooms array).
    ///
    var staticContents = [[Content]]()
    
    /// The dynamic contents.
    ///
    /// Note that the indices matches those of the rooms array (i.e., contents at index N belong to
    /// the room found at index N of the rooms array).
    ///
    var dynamicContents = [[Content]]()
    
    /// The room paths.
    ///
    /// Note that the indices matches those of the rooms array (i.e., path at index N belong to
    /// the room found at index N of the rooms array).
    ///
    var paths = [RoomPath?]()
    
    /// The nodes holding the tiles of each room.
    ///
    /// Note that the indices matches those of the rooms array (i.e., tile node at index N
    /// belongs to the room found at index N of the rooms array).
    ///
    var tileNodes = [SKNode]()
    
    /// The nodes holding the collision bounds for each room.
    ///
    /// Note that the indices matches those of the rooms array (i.e., collision node at index N
    /// belongs to the room found at index N of the rooms array).
    ///
    var collisionNodes = [SKNode]()
    
    /// The nodes holding the contents of each room.
    ///
    /// Note that the indices matches those of the rooms array (i.e., node at index N belongs to
    /// the room found at index N of the rooms array).
    ///
    var contentNodes = [SKNode]()
    
    /// The index of the chosen entrance room.
    ///
    var entranceRoomIndex: Int?
    
    /// The index of the chosen exit room.
    ///
    var exitRoomIndex: Int?
    
    /// The effect node, meant to be used for temporary, unmanaged nodes.
    ///
    /// It is expected that this node will always be available, regardless of which
    /// rooms are being processed at a given time. It should be added as a sibling of
    /// the other nodes, and use the same contents' depth range.
    ///
    let effectNode = SKNode()
    
    /// The rect defining the dimensions of the maze, in cells.
    ///
    /// If accessed before room creation, this property will produce a rect of size zero.
    ///
    var rect: CGRect {
        let size = CGSize(width: CGFloat(columns) * roomSize.width, height: CGFloat(rows) * roomSize.height)
        return CGRect(origin: .zero, size: size)
    }
    
    /// Creates a new instance from the given cell size and cell offset.
    ///
    /// - Parameters:
    ///   - cellSize: The size of a single cell, used as a scale factor.
    ///   - cellOffset: The offset, in cells, used to compute gaps in the maze.
    ///
    init(cellSize: CGSize, cellOffset: CGFloat) {
        self.cellSize = cellSize
        self.cellOffset = cellOffset
    }
    
    /// Creates the maze graph, a minimum spanning tree.
    ///
    /// - Parameters:
    ///   - columns: The number of columns in the graph, which will dictate the amount of rooms in the x axis.
    ///   - rows: The number of rows in the graph, which will dictate the amount of rooms in the y axis.
    ///
    func createGraph(columns: Int, rows: Int) {
        guard columns > 0 && rows > 0 else {
            fatalError("Values of columns and rows on createMazeGraph(columns:rows) must be greater than zero")
        }
        
        let graph = GridGraph()
        
        for column in 0..<columns {
            for row in 0..<rows {
                let vertex = GridVertex(point: CGPoint(x: column, y: row))
                graph.addVertex(vertex)
                if column < columns - 1 {
                    let adjacency = GridVertex(point: CGPoint(x: column + 1, y: row))
                    let cost = UInt.random(in: 0...UInt.max)
                    graph.addAdjacencyFor(vertex: vertex, adjacency: adjacency, cost: cost, bidirectional: true)
                }
                if row < rows - 1 {
                    let adjacency = GridVertex(point: CGPoint(x: column, y: row + 1))
                    let cost = UInt.random(in: 0...UInt.max)
                    graph.addAdjacencyFor(vertex: vertex, adjacency: adjacency, cost: cost, bidirectional: true)
                }
            }
        }
        
        // ToDo: Random root
        originVertex = GridVertex(point: CGPoint.zero)
        self.graph = graph.minimumSpanningTree(root: originVertex!)
        self.columns = columns
        self.rows = rows
    }
    
    /// Creates the maze rooms.
    ///
    /// - Parameter roomCreator: The `RoomCreator` to use for room creation.
    ///
    func createRooms(roomCreator: RoomCreator) {
        guard let _ = graph, let origin = originVertex else {
            fatalError("A graph must be created with a call to createMazeGraph(columns:rows:) before calling this method")
        }
        
        // Update the roomSize with the new boundary size
        roomSize = roomCreator.rect.size
        
        // Allocate space in the rooms array with a temporary room (the indices will be used to identify the rooms)
        // Note: Since this value will be replaced, it does not matter that all indices refer to the same object
        rooms = [Room](repeating: Room(roomRect: CGRect.zero), count: columns * rows)
        
        // Also, allocate space for everything that depends upon room indices for identification
        for _ in 0..<(columns * rows) {
            staticContents.append([])
            dynamicContents.append([])
            paths.append(nil)
            tileNodes.append(SKNode())
            collisionNodes.append(SKNode())
            contentNodes.append(SKNode())
            
            // Set z positions
            tileNodes.last!.zPosition = DepthLayer.tiles.lowerBound
            collisionNodes.last!.zPosition = 0
            contentNodes.last!.zPosition = DepthLayer.tiles.upperBound
        }
        
        // The effect and content nodes will share the contents depth range
        effectNode.zPosition = DepthLayer.tiles.upperBound
        
        createRooms(roomCreator: roomCreator, vertex: origin, connection: nil)
    }
    
    /// Creates the maze rooms recursively.
    ///
    private func createRooms(roomCreator: RoomCreator, vertex: GridVertex, connection: MazeConnection?) {
        // Reset the roomCreator properties
        roomCreator.rect.origin = CGPoint(x: vertex.point.x * roomCreator.rect.width,
                                          y: vertex.point.y * roomCreator.rect.height)
        roomCreator.northConnection = false
        roomCreator.southConnection = false
        roomCreator.eastConnection = false
        roomCreator.westConnection = false
        roomCreator.northConnectionXAndLength = nil
        roomCreator.southConnectionXAndLength = nil
        roomCreator.eastConnectionYAndLength = nil
        roomCreator.westConnectionYAndLength = nil
        
        // Set the predefined connection if not nil
        if let connection = connection {
            switch connection {
            case .north(let origin, let length):
                roomCreator.northConnection = true
                roomCreator.northConnectionXAndLength = (origin, length)
            case .south(let origin, let length):
                roomCreator.southConnection = true
                roomCreator.southConnectionXAndLength = (origin, length)
            case .east(let origin, let length):
                roomCreator.eastConnection = true
                roomCreator.eastConnectionYAndLength = (origin, length)
            case .west(let origin, let length):
                roomCreator.westConnection = true
                roomCreator.westConnectionYAndLength = (origin, length)
            }
        }
        
        var northChild: GridVertex?
        var southChild: GridVertex?
        var eastChild: GridVertex?
        var westChild: GridVertex?
        
        // For each child, identifies a connection that must be created
        for (child, _) in graph!.adjacenciesOf(vertex: vertex) {
            if child.point.x < vertex.point.x {
                roomCreator.westConnection = true
                westChild = child
            } else if child.point.x > vertex.point.x {
                roomCreator.eastConnection = true
                eastChild = child
            } else if child.point.y < vertex.point.y {
                roomCreator.southConnection = true
                southChild = child
            } else if child.point.y > vertex.point.y {
                roomCreator.northConnection = true
                northChild = child
            } else {
                continue
            }
        }
        
        // Now that the roomCreator is set, create the room and insert it in the correct array index
        let room = roomCreator.makeRoom()
        let index = Int(vertex.point.y) * columns + Int(vertex.point.x)
        rooms[index] = room
        
        // Recursively call this method for each child of vertex
        if let northChild = northChild {
            let newConn = MazeConnection.south(origin: Int(room.northCorridorRect!.minX),
                                               length: Int(room.northCorridorRect!.width))
            createRooms(roomCreator: roomCreator, vertex: northChild, connection: newConn)
        }
        if let southChild = southChild {
            let newConn = MazeConnection.north(origin: Int(room.southCorridorRect!.minX),
                                               length: Int(room.southCorridorRect!.width))
            createRooms(roomCreator: roomCreator, vertex: southChild, connection: newConn)
        }
        if let eastChild = eastChild {
            let newConn = MazeConnection.west(origin: Int(room.eastCorridorRect!.minY),
                                              length: Int(room.eastCorridorRect!.height))
            createRooms(roomCreator: roomCreator, vertex: eastChild, connection: newConn)
        }
        if let westChild = westChild {
            let newConn = MazeConnection.east(origin: Int(room.westCorridorRect!.minY),
                                              length: Int(room.westCorridorRect!.height))
            createRooms(roomCreator: roomCreator, vertex: westChild, connection: newConn)
        }
    }
    
    /// Creates the maze tiles.
    ///
    /// - Parameter tilePlacer: The `TilePlacer` instance to use for tile creation.
    ///
    func createTiles(tilePlacer: TilePlacer) {
        guard !rooms.isEmpty else {
            fatalError("There are no rooms to be created (rooms array is empty)")
        }
        
        for room in rooms {
            createTilesFor(room: room, tilePlacer: tilePlacer)
        }
    }
    
    /// Creates the tiles for a single room.
    ///
    /// - Parameters:
    ///   - room: The `Room` instance to create the tiles for.
    ///   - tilePlacer: The `TilePlacer` instance to use for tile creation.
    ///
    func createTilesFor(room: Room, tilePlacer: TilePlacer) {
        guard tilePlacer.tileSet.cellSize == cellSize && tilePlacer.tileSet.cellOffset == cellOffset else {
            fatalError("TileSet used by tilePlacer is not compatible with this maze (cell size/offset differs)")
        }
        guard let index = indexOf(room: room) else {
            fatalError("Specified room is out of bunds")
        }
        
        tilePlacer.placeTiles(forRoom: room, onNode: tileNodes[index])
    }
    
    /// Creates collision detection nodes for the maze rooms.
    ///
    func createCollisionDetection() {
        for room in rooms {
            createCollisionDetectionFor(room: room)
        }
    }
    
    /// Creates collision detection node for the given room.
    ///
    /// - Note: This method uses the `cellSize` and `cellOffset` properties to scale the collision nodes.
    ///   Some collision nodes overlap on purpose.
    ///
    /// - Parameter room: The `Room` instance to create the collison node for.
    ///
    func createCollisionDetectionFor(room: Room) {
        guard let index = indexOf(room: room) else {
            fatalError("Specified room is out of bounds")
        }
        
        // Create a collision node
        let makeCollisionNode = { (size: CGSize) -> SKNode in
            let node = SKNode()
            let physicsBody = SKPhysicsBody(rectangleOf: size)
            physicsBody.isDynamic = false
            Interaction.obstacle.updateInteractions(onPhysicsBody: physicsBody)
            node.physicsBody = physicsBody
            return node
        }
        
        // The parent of all collision nodes for this room
        let parentNode = collisionNodes[index]
        
        // The amount to overlap the physics bodies, to avoid space between walls
        let overlapAmount = cellOffset * min(cellSize.width, cellSize.height)
        
        // North edge and corridor
        if let corridor = room.northCorridorRect {
            let height = (corridor.height + cellOffset) * cellSize.height + overlapAmount
            
            let leftCorridorNode = makeCollisionNode(CGSize(width: cellSize.width * cellOffset, height: height))
            leftCorridorNode.position.x = (corridor.minX + cellOffset / 2.0) * cellSize.width
            leftCorridorNode.position.y = (corridor.minY - cellOffset) * cellSize.height + height / 2.0
            parentNode.addChild(leftCorridorNode)
            
            let rightCorridorNode = makeCollisionNode(CGSize(width: cellSize.width * cellOffset, height: height))
            rightCorridorNode.position.x = (corridor.maxX - cellOffset / 2.0) * cellSize.width
            rightCorridorNode.position.y = (corridor.minY - cellOffset) * cellSize.height + height / 2.0
            parentNode.addChild(rightCorridorNode)
            
            if corridor.minX != room.roomRect.minX {
                let width = (corridor.minX + cellOffset - room.roomRect.minX) * cellSize.width
                let leftRoomNode = makeCollisionNode(CGSize(width: width, height: cellSize.height * cellOffset))
                leftRoomNode.position = CGPoint(x: room.roomRect.minX * cellSize.width + width / 2.0,
                                                y: (room.roomRect.maxY - cellOffset / 2.0) * cellSize.height)
                parentNode.addChild(leftRoomNode)
            }
            
            if corridor.maxX != room.roomRect.maxX {
                let width = (room.roomRect.maxX - corridor.maxX + cellOffset) * cellSize.width
                let rightRoomNode = makeCollisionNode(CGSize(width: width, height: cellSize.height * cellOffset))
                rightRoomNode.position = CGPoint(x: (corridor.maxX - cellOffset) * cellSize.width + width / 2.0,
                                                 y: (room.roomRect.maxY - cellOffset / 2.0) * cellSize.height)
                parentNode.addChild(rightRoomNode)
            }
        } else {
            let width = room.roomRect.width * cellSize.width
            let roomNode = makeCollisionNode(CGSize(width: width, height: cellSize.height * cellOffset))
            roomNode.position = CGPoint(x: room.roomRect.midX * cellSize.width,
                                        y: (room.roomRect.maxY - cellOffset / 2.0) * cellSize.height)
            parentNode.addChild(roomNode)
        }
 
        // South edge and corridor
        if let corridor = room.southCorridorRect {
            let height = (corridor.height + cellOffset) * cellSize.height + overlapAmount
            
            let leftCorridorNode = makeCollisionNode(CGSize(width: cellSize.width * cellOffset, height: height))
            leftCorridorNode.position.x = (corridor.minX + cellOffset / 2.0) * cellSize.width
            leftCorridorNode.position.y = corridor.minY * cellSize.height + height / 2.0 - overlapAmount
            parentNode.addChild(leftCorridorNode)
            
            let rightCorridorNode = makeCollisionNode(CGSize(width: cellSize.width * cellOffset, height: height))
            rightCorridorNode.position.x = (corridor.maxX - cellOffset / 2.0) * cellSize.width
            rightCorridorNode.position.y = corridor.minY * cellSize.height + height / 2.0 - overlapAmount
            parentNode.addChild(rightCorridorNode)
            
            if corridor.minX != room.roomRect.minX {
                let width = (corridor.minX + cellOffset - room.roomRect.minX) * cellSize.width
                let leftRoomNode = makeCollisionNode(CGSize(width: width, height: cellSize.height * cellOffset))
                leftRoomNode.position = CGPoint(x: room.roomRect.minX * cellSize.width + width / 2.0,
                                                y: (room.roomRect.minY + cellOffset / 2.0) * cellSize.height)
                parentNode.addChild(leftRoomNode)
            }
            
            if corridor.maxX != room.roomRect.maxX {
                let width = (room.roomRect.maxX - corridor.maxX + cellOffset) * cellSize.width
                let rightRoomNode = makeCollisionNode(CGSize(width: width, height: cellSize.height * cellOffset))
                rightRoomNode.position = CGPoint(x: (corridor.maxX - cellOffset) * cellSize.width + width / 2.0,
                                                 y: (room.roomRect.minY + cellOffset / 2.0) * cellSize.height)
                parentNode.addChild(rightRoomNode)
            }
        } else {
            let width = room.roomRect.width * cellSize.width
            let roomNode = makeCollisionNode(CGSize(width: width, height: cellSize.height * cellOffset))
            roomNode.position = CGPoint(x: room.roomRect.midX * cellSize.width,
                                        y: (room.roomRect.minY + cellOffset / 2.0) * cellSize.height)
            parentNode.addChild(roomNode)
        }
        
        // East edge and corridor
        if let corridor = room.eastCorridorRect {
            let width = (corridor.width + cellOffset) * cellSize.width + overlapAmount
            
            let downCorridorNode = makeCollisionNode(CGSize(width: width, height: cellSize.height * cellOffset))
            downCorridorNode.position.x = (corridor.minX - cellOffset) * cellSize.width + width / 2.0
            downCorridorNode.position.y = (corridor.minY + cellOffset / 2.0) * cellSize.height
            parentNode.addChild(downCorridorNode)
            
            let upCorridorNode = makeCollisionNode(CGSize(width: width, height: cellSize.height * cellOffset))
            upCorridorNode.position.x = (corridor.minX - cellOffset) * cellSize.width + width / 2.0
            upCorridorNode.position.y = (corridor.maxY - cellOffset / 2.0) * cellSize.height
            parentNode.addChild(upCorridorNode)
            
            if corridor.minY != room.roomRect.minY {
                let height = (corridor.minY + cellOffset /*- 1*/ - room.roomRect.minY) * cellSize.height
                let downRoomNode = makeCollisionNode(CGSize(width: cellSize.width * cellOffset, height: height))
                downRoomNode.position = CGPoint(x: (room.roomRect.maxX - cellOffset / 2.0) * cellSize.width,
                                                y: room.roomRect.minY * cellSize.height + height / 2.0)
                parentNode.addChild(downRoomNode)
            }
            
            if corridor.maxY != room.roomRect.maxY {
                let height = (room.roomRect.maxY - corridor.maxY + cellOffset /*- 1*/) * cellSize.height
                let upRoomNode = makeCollisionNode(CGSize(width: cellSize.width * cellOffset, height: height))
                upRoomNode.position = CGPoint(x: (room.roomRect.maxX - cellOffset / 2.0) * cellSize.width,
                                              y: (corridor.maxY - cellOffset) * cellSize.height + height / 2.0)
                parentNode.addChild(upRoomNode)
            }
        } else {
            let height = room.roomRect.height * cellSize.height
            let roomNode = makeCollisionNode(CGSize(width: cellSize.width * cellOffset, height: height))
            roomNode.position = CGPoint(x: (room.roomRect.maxX - cellOffset / 2.0) * cellSize.width,
                                        y: room.roomRect.midY * cellSize.height)
            parentNode.addChild(roomNode)
        }
 
        // West edge and corridor
        if let corridor = room.westCorridorRect {
            let width = (corridor.width + cellOffset) * cellSize.width + overlapAmount
            
            let downCorridorNode = makeCollisionNode(CGSize(width: width, height: cellSize.height * cellOffset))
            downCorridorNode.position.x = corridor.minX * cellSize.width + width / 2.0 - overlapAmount
            downCorridorNode.position.y = (corridor.minY + cellOffset / 2.0) * cellSize.height
            parentNode.addChild(downCorridorNode)
            
            let upCorridorNode = makeCollisionNode(CGSize(width: width, height: cellSize.height * cellOffset))
            upCorridorNode.position.x = corridor.minX * cellSize.width + width / 2.0 - overlapAmount
            upCorridorNode.position.y = (corridor.maxY - cellOffset / 2.0) * cellSize.height
            parentNode.addChild(upCorridorNode)
            
            if corridor.minY != room.roomRect.minY {
                let height = (corridor.minY + cellOffset /*- 1*/ - room.roomRect.minY) * cellSize.height
                let downRoomNode = makeCollisionNode(CGSize(width: cellSize.width * cellOffset, height: height))
                downRoomNode.position = CGPoint(x: (room.roomRect.minX + cellOffset / 2.0) * cellSize.width,
                                                y: room.roomRect.minY * cellSize.height + height / 2.0)
                parentNode.addChild(downRoomNode)
            }
            
            if corridor.maxY != room.roomRect.maxY {
                let height = (room.roomRect.maxY - corridor.maxY + cellOffset /*- 1*/) * cellSize.height
                let upRoomNode = makeCollisionNode(CGSize(width: cellSize.width * cellOffset, height: height))
                upRoomNode.position = CGPoint(x: (room.roomRect.minX + cellOffset / 2.0) * cellSize.width,
                                              y: (corridor.maxY - cellOffset) * cellSize.height + height / 2.0)
                parentNode.addChild(upRoomNode)
            }
        } else {
            let height = room.roomRect.height * cellSize.height
            let roomNode = makeCollisionNode(CGSize(width: cellSize.width * cellOffset, height: height))
            roomNode.position = CGPoint(x: (room.roomRect.minX + cellOffset / 2.0) * cellSize.width,
                                        y: room.roomRect.midY * cellSize.height)
            parentNode.addChild(roomNode)
        }
        
        // Note: Constraints must be added to the collision nodes because, when assigned a physics body,
        // they tend to move slightly (due to their global positions, most likely)
        for child in parentNode.children {
            let constraint = SKConstraint.positionX(SKRange(constantValue: child.position.x),
                                                    y: SKRange(constantValue: child.position.y))
            constraint.referenceNode = parentNode
            child.constraints = [constraint]
        }
    }
    
    /// Creates the room contents.
    ///
    /// Note that this method requires that the rooms array contains enough rooms for the
    /// entrance, exit and one-time contents (i.e., 2 + oneTimeProbabilities.count rooms or more).
    ///
    /// - Parameters:
    ///   - entranceProbability: The `ContentProbability` instance to use for the maze entrance room.
    ///   - exitProbability: The `ContentProbability` instance to use for the maze exit room.
    ///   - defaultProbability: The default `ContentProbability` instance to use.
    ///   - oneTimeProbability: An array of `ContentProbability` that should be used for a single room each.
    ///   - contentPlacer: The `ContentPlacer` instance to use for content creation.
    ///
    func createContents(entranceProbability: ContentProbability, exitProbability: ContentProbability,
                        defaultProbability: ContentProbability, oneTimeProbabilities: [ContentProbability],
                        contentPlacer: ContentPlacer) {
        
        guard rooms.count >= 2 + oneTimeProbabilities.count else {
            fatalError("Not enough rooms to create contents with the requested probabilites")
        }
        
        var done = Set<Int>()
        
        // Create contents for the entrance and exit rooms
        if entranceRoomIndex == nil || exitRoomIndex == nil { chooseEntranceAndExitRooms() }
        createContentsForRoomWithIndex(entranceRoomIndex!, probability: entranceProbability,
                                       contentPlacer: contentPlacer)
        createContentsForRoomWithIndex(exitRoomIndex!, probability: exitProbability,
                                       contentPlacer: contentPlacer)
        done.insert(entranceRoomIndex!)
        done.insert(exitRoomIndex!)
        
        // Create one-time contents
        for probability in oneTimeProbabilities {
            let i = Int.random(in: 0..<rooms.endIndex)
            var j = i
            while done.contains(j) { j = (j + 1) % rooms.count }
            createContentsForRoomWithIndex(j, probability: probability, contentPlacer: contentPlacer)
            done.insert(j)
        }
        
        // Create contents for the remaining rooms
        for i in 0..<rooms.endIndex {
            if done.contains(i) { continue }
            createContentsForRoomWithIndex(i, probability: defaultProbability, contentPlacer: contentPlacer)
        }
    }
    
    /// Creates the contents for a single room.
    ///
    /// - Parameters:
    ///   - room: The `Room` instance to create the contents for.
    ///   - probability: The `ContentProbability` instance to use.
    ///   - contentPlacer: The `ContentPlacer` instance to use for content creation.
    ///
    func createContentsFor(room: Room, probability: ContentProbability, contentPlacer: ContentPlacer) {
        guard let index = indexOf(room: room) else {
            fatalError("Invalid room")
        }
        
        createContentsForRoomWithIndex(index, probability: probability, contentPlacer: contentPlacer)
    }
    
    /// Creates the specific content at the given position.
    ///
    /// - Parameters:
    ///   - type: The `ContentType` that identifies the content to create.
    ///   - position: The position to create the content at.
    ///   - contentPlacer: The `ContentPlacer` instance to use for content creation.
    ///
    func createSpecificContent(type: ContentType, position: CGPoint, contentPlacer: ContentPlacer) {
        guard let room = roomAt(position: position) else {
            fatalError("No room at the specified position in createSpecificContent(type:position:contentPlacer:)")
        }
        
        let index = indexOf(room: room)!
        let content = contentPlacer.placeSpecificContent(ofType: type, at: position, onNode: contentNodes[index])
        if let content = content {
            if content.isDynamic {
                dynamicContents[index].append(content)
            } else {
                staticContents[index].append(content)
            }
        }
    }
    
    /// Creates the specific content at the given position.
    ///
    /// - Note: This method does not use a content placer to place the content, thus there are no
    ///   guarantees that content positions will not overlap (the content will be added regardless).
    ///
    /// - Parameters:
    ///   - content: The content to place.
    ///   - position: The position to create the content at.
    ///
    func createSpecificContent(_ content: Content, position: CGPoint) {
        guard let room = roomAt(position: position) else {
            fatalError("No room at the specified position in createSpecificContent(_:position:)")
        }
        
        let index = indexOf(room: room)!
        content.position = position
        contentNodes[index].addChild(content.node)
        if content.isDynamic {
            dynamicContents[index].append(content)
        } else {
            staticContents[index].append(content)
        }
    }
    
    /// Creates the contents for the room identified by roomIndex.
    ///
    /// - Note: This method does not check if `index` is valid.
    ///
    /// - Parameters:
    ///   - index: The index of the room to create the contents for.
    ///   - probability: The `ContentProbability` instance to use.
    ///   - contentPlacer: The `ContentPlacer` instance to use for content creation.
    ///
    private func createContentsForRoomWithIndex(_ index: Int, probability: ContentProbability,
                                                contentPlacer: ContentPlacer) {
        
        let contents = contentPlacer.placeContents(forArea: calculateAreasFor(room: rooms[index]),
                                                   using: probability, onNode: contentNodes[index])
        for content in contents {
            if content.isDynamic {
                dynamicContents[index].append(content)
            } else {
                staticContents[index].append(content)
            }
        }
    }
    
    /// Creates the paths for every room.
    ///
    func createPaths() {
        for i in 0..<rooms.endIndex {
            createPathForRoomWithIndex(i)
        }
    }
    
    /// Creates the path for a single room.
    ///
    /// - Parameter room: The `Room` instance to create the path for.
    ///
    func createPathFor(room: Room) {
        guard let index = indexOf(room: room) else {
            fatalError("The room in createPathFor(room:) is not on this maze")
        }
        
        createPathForRoomWithIndex(index)
    }
    
    /// Creates the maze path for a single room.
    ///
    /// - Note: This method does not check if `index` is valid.
    ///
    /// - Parameter index: The index of the room to create the path for.
    ///
    private func createPathForRoomWithIndex(_ index: Int) {
        let area = calculateAreasFor(room: rooms[index])
        let obstacles = RoomObstacle(roomArea: area, roomContents: staticContents[index], cellSize: cellSize)
        paths[index] = RoomPath(area: area, obstacles: obstacles, cellSize: cellSize)
    }
    
    /// Chooses, randomly, two previously created rooms to be used as entrance and exit areas.
    ///
    func chooseEntranceAndExitRooms() {
        guard rooms.count >= 2 else {
            fatalError("chooseEntranceAndExit() requires that the rooms array contains two or more rooms")
        }
        
        if columns == 1 || rows == 1 {
            // The maze does not branch, use first and last rooms
            if Bool.random() {
                entranceRoomIndex = rooms.startIndex
                exitRoomIndex = rooms.endIndex - 1
            } else {
                entranceRoomIndex = rooms.endIndex - 1
                exitRoomIndex = rooms.startIndex
            }
            // Done
            return
        }
        
        // Define if the choice should be column or row biased (i.e., along the top/bottom or sides)
        var columnBiased: Bool
        if columns > rows {
            let ratio = Double(columns) / Double(rows)
            columnBiased = (Double.random(in: 0...1.0) * ratio * ratio) < 0.5 ? true : false
        } else if rows > columns {
            let ratio = Double(rows) / Double(columns)
            columnBiased = (Double.random(in: 0...1.0) * ratio * ratio) < 0.5 ? false : true
        } else {
            columnBiased = Bool.random()
        }
        
        var column1: Int
        var row1: Int
        var column2: Int
        var row2: Int
        
        if columnBiased {
            // Choose rooms along the top/bottom
            column1 = Int.random(in: 0...(columns - 1))
            row1 = Int.random(in: 0...(rows / 6))
            if column1 > (columns - 1 - column1) {
                column2 = Int.random(in: 0...(column1 / 4))
            } else {
                column2 = columns - 1 - Int.random(in: 0...((columns - 1 - column1) / 4))
            }
            row2 = rows - 1 - Int.random(in: 0...(rows / 6 - row1))
        } else {
            // Choose rooms along the sides
            column1 = Int.random(in: 0...(columns / 6))
            row1 = Int.random(in: 0...(rows - 1))
            column2 = columns - 1 - Int.random(in: 0...(columns / 6 - column1))
            if row1 > (rows - 1 - row1) {
                row2 = Int.random(in: 0...(row1 / 4))
            } else {
                row2 = rows - 1 - Int.random(in: 0...((rows - 1 - row1) / 4))
            }
        }
        
        // Set the entrance and exit indices
        if Bool.random() {
            entranceRoomIndex = row1 * columns + column1
            exitRoomIndex = row2 * columns + column2
        } else {
            entranceRoomIndex = row2 * columns + column2
            exitRoomIndex = row1 * columns + column1
        }
    }
    
    /// Calculates the valid room positions (i.e., not walls nor corners, only floor).
    ///
    /// - Returns: An array of `RoomPosition` containing the positions of every room.
    ///
    func calculatePositions() -> [RoomPosition] {
        var positions = [RoomPosition]()
        for room in rooms {
            positions.append(calculatePositionsFor(room: room))
        }
        return positions
    }
    
    /// Calculates the valid room positions for a single room (i.e., not walls nor corners, only floor).
    ///
    /// - Parameter room: The `Room` instance to calculate the positions for.
    /// - Returns: The `RoomPosition` of the given room.
    ///
    func calculatePositionsFor(room: Room) -> RoomPosition {
        var roomPositions = [CGPoint]()
        var northCorridorPositions: [CGPoint]?
        var southCorridorPositions: [CGPoint]?
        var eastCorridorPositions: [CGPoint]?
        var westCorridorPositions: [CGPoint]?
        
        // Main room positions
        for i in Int(room.roomRect.minX + cellOffset)..<Int(room.roomRect.maxX - cellOffset) {
            for j in Int(room.roomRect.minY + cellOffset)..<Int(room.roomRect.maxY - cellOffset) {
                roomPositions.append(CGPoint(x: i, y: j))
            }
        }
        // Corridor and connection area positions
        if let corridor = room.northCorridorRect {
            northCorridorPositions = [CGPoint]()
            for i in Int(corridor.minX + cellOffset)..<Int(corridor.maxX - cellOffset) {
                for j in Int(corridor.minY - cellOffset)..<Int(corridor.maxY) {
                    northCorridorPositions!.append(CGPoint(x: i, y: j))
                }
            }
        }
        if let corridor = room.southCorridorRect {
            southCorridorPositions = [CGPoint]()
            for i in Int(corridor.minX + cellOffset)..<Int(corridor.maxX - cellOffset) {
                for j in Int(corridor.minY)..<Int(corridor.maxY + cellOffset) {
                    southCorridorPositions!.append(CGPoint(x: i, y: j))
                }
            }
        }
        if let corridor = room.eastCorridorRect {
            eastCorridorPositions = [CGPoint]()
            for i in Int(corridor.minX - cellOffset)..<Int(corridor.maxX) {
                for j in Int(corridor.minY + cellOffset)..<Int(corridor.maxY - cellOffset) {
                    eastCorridorPositions!.append(CGPoint(x: i, y: j))
                }
            }
        }
        if let corridor = room.westCorridorRect {
            westCorridorPositions = [CGPoint]()
            for i in Int(corridor.minX)..<Int(corridor.maxX + cellOffset) {
                for j in Int(corridor.minY + cellOffset)..<Int(corridor.maxY - cellOffset) {
                    westCorridorPositions!.append(CGPoint(x: i, y: j))
                }
            }
        }
        
        return RoomPosition(roomPositions: roomPositions,
                            northCorridorPositions: northCorridorPositions,
                            southCorridorPositions: southCorridorPositions,
                            eastCorridorPositions: eastCorridorPositions,
                            westCorridorPositions: westCorridorPositions)
    }
    
    /// Calculates the valid room areas (i.e., not walls nor corners, only floor).
    ///
    /// - Returns: An array of `RoomArea` containing the areas of every room.
    ///
    func calculateAreas() -> [RoomArea] {
        var areas = [RoomArea]()
        for room in rooms {
            areas.append(calculateAreasFor(room: room))
        }
        return areas
    }
    
    /// Calculates the valid room areas for a single room (i.e., not walls nor corners, only floor).
    ///
    /// - Parameter room: The `Room` instance to calculate the areas for.
    /// - Returns: The `RoomArea` of the given room.
    ///
    func calculateAreasFor(room: Room) -> RoomArea {
        var northCorridorArea: CGRect?
        var southCorridorArea: CGRect?
        var eastCorridorArea: CGRect?
        var westCorridorArea: CGRect?
        
        // Main room area
        let roomArea = CGRect(x: room.roomRect.minX + cellOffset, y: room.roomRect.minY + cellOffset,
                              width: room.roomRect.width - cellOffset * 2.0, height: room.roomRect.height - cellOffset * 2.0)
        
        // Corridor + connection areas
        if let corridor = room.northCorridorRect {
            northCorridorArea = CGRect(x: corridor.minX + cellOffset, y: corridor.minY - cellOffset,
                                       width: corridor.width - cellOffset * 2, height: corridor.height + cellOffset)
        }
        if let corridor = room.southCorridorRect {
            southCorridorArea = CGRect(x: corridor.minX + cellOffset, y: corridor.minY,
                                       width: corridor.width - cellOffset * 2.0, height: corridor.height + cellOffset)
        }
        if let corridor = room.eastCorridorRect {
            eastCorridorArea = CGRect(x: corridor.minX - cellOffset, y: corridor.minY + cellOffset,
                                      width: corridor.width + cellOffset, height: corridor.height - cellOffset * 2.0)
        }
        if let corridor = room.westCorridorRect {
            westCorridorArea = CGRect(x: corridor.minX, y: corridor.minY + cellOffset,
                                      width: corridor.width + cellOffset, height: corridor.height - cellOffset * 2.0)
        }
        
        return RoomArea(roomArea: roomArea,
                        northCorridorArea: northCorridorArea,
                        southCorridorArea: southCorridorArea,
                        eastCorridorArea: eastCorridorArea,
                        westCorridorArea: westCorridorArea)
    }
    
    /// Retrieves the index of the given room in the `rooms` array.
    ///
    /// - Parameter room: The `Room` instance which index must be retrieved.
    /// - Returns: The index in the `rooms` array where the given room is referenced.
    ///
    func indexOf(room: Room) -> Int? {
        guard !rooms.isEmpty else { return nil }
        
        let roomX = room.roomRect.midX
        let roomY = room.roomRect.midY
        
        let x = Int((roomX / roomSize.width).rounded(.towardZero))
        let y = Int((roomY / roomSize.height).rounded(.towardZero))
        let index = y * columns + x
        
        guard index >= rooms.startIndex && index < rooms.endIndex else { return nil }
        
        return index
    }
    
    /// Checks which room is located at the given point.
    ///
    /// - Note: The position is considered to be scaled by `cellSize`.
    ///
    /// - Parameter position: The point to check.
    /// - Returns: The room found at the given position.
    ///
    func roomAt(position: CGPoint) -> Room? {
        guard !rooms.isEmpty else { return nil }
        
        let x = Int((position.x / cellSize.width / roomSize.width).rounded(.towardZero))
        let y = Int((position.y / cellSize.height / roomSize.height).rounded(.towardZero))
        let index = y * columns + x
        
        guard index >= rooms.startIndex && index < rooms.endIndex else { return nil }
        
        return rooms[index]
    }
    
    /// Retrieves all the contents of the given room.
    ///
    /// - Parameter room: The `Room` instance for which the contents must be retrieved.
    /// - Returns: An array holding all the contents of the room.
    ///
    func contentsOf(room: Room) -> [Content] {
        let index = indexOf(room: room)
        
        assert(index != nil)
        
        var contents = staticContents[index!]
        contents.append(contentsOf: dynamicContents[index!])
        return contents
    }
    
    /// Retrieves the rooms adjacent to the given room.
    ///
    /// - Parameters:
    ///   - room: The `Room` instance to check for adjacencies.
    ///   - diagonals: A flag that defines if diagonal rooms must be considered. The default value is `true`.
    /// - Returns: A dictionary with `RoomAdjacency` as keys and the adjacent rooms as values.
    ///
    func adjacentRooms(relativeTo room: Room, diagonals: Bool = true) -> [RoomAdjacency: Room] {
        let index = indexOf(room: room)
        
        assert(index != nil)
        
        var adjacentRooms = [RoomAdjacency: Room]()
        
        let northIdx = index! + columns
        let southIdx = index! - columns
        let eastIdx = index! + 1
        let westIdx = index! - 1
        let northEastIdx = northIdx + 1
        let northWestIdx = northIdx - 1
        let southEastIdx = southIdx + 1
        let southWestIdx = southIdx - 1
        
        if northIdx < rooms.endIndex {
            adjacentRooms[.north] = rooms[northIdx]
        }
        if southIdx >= rooms.startIndex {
            adjacentRooms[.south] = rooms[southIdx]
        }
        if (index! + 1) % columns != 0 {
            adjacentRooms[.east] = rooms[eastIdx]
        }
        if index! % columns != 0 {
            adjacentRooms[.west] = rooms[westIdx]
        }
        
        if diagonals {
            if (northEastIdx < rooms.endIndex) && ((index! + 1) % columns != 0) {
                adjacentRooms[.northEast] = rooms[northEastIdx]
            }
            if (northWestIdx < rooms.endIndex) && (index! % columns != 0) {
                adjacentRooms[.northWest] = rooms[northWestIdx]
            }
            if (southEastIdx >= rooms.startIndex) && ((index! + 1) % columns != 0) {
                adjacentRooms[.southEast] = rooms[southEastIdx]
            }
            if (southWestIdx >= rooms.startIndex) && (index! % columns != 0) {
                adjacentRooms[.southWest] = rooms[southWestIdx]
            }
        }
        
        return adjacentRooms
    }
    
    /// Retrieves the indices of the rooms adjacent to the given room.
    ///
    /// - Parameters:
    ///   - room: The `Room` instance to check for adjacencies.
    ///   - diagonals: A flag that defines if diagonal rooms must be considered. The default value is `true`.
    /// - Returns: A dictionary with `RoomAdjacency` as keys and the indices of the adjacent rooms as values.
    ///
    func adjacentRoomsIndices(relativeTo room: Room, diagonals: Bool = true) -> [RoomAdjacency: Int] {
        let index = indexOf(room: room)
        
        assert(index != nil)
        
        var indices = [RoomAdjacency: Int]()
        
        let northIdx = index! + columns
        let southIdx = index! - columns
        let eastIdx = index! + 1
        let westIdx = index! - 1
        let northEastIdx = northIdx + 1
        let northWestIdx = northIdx - 1
        let southEastIdx = southIdx + 1
        let southWestIdx = southIdx - 1
        
        if northIdx < rooms.endIndex {
            indices[.north] = northIdx
        }
        if southIdx >= rooms.startIndex {
            indices[.south] = southIdx
        }
        if (index! + 1) % columns != 0 {
            indices[.east] = eastIdx
        }
        if index! % columns != 0 {
            indices[.west] = westIdx
        }
        
        if diagonals {
            if (northEastIdx < rooms.endIndex) && ((index! + 1) % columns != 0) {
                indices[.northEast] = northEastIdx
            }
            if (northWestIdx < rooms.endIndex) && (index! % columns != 0) {
                indices[.northWest] = northWestIdx
            }
            if (southEastIdx >= rooms.startIndex) && ((index! + 1) % columns != 0) {
                indices[.southEast] = southEastIdx
            }
            if (southWestIdx >= rooms.startIndex) && (index! % columns != 0) {
                indices[.southWest] = southWestIdx
            }
        }
        
        return indices
    }
    
    /// Finds a path from the origin to the goal.
    ///
    /// - Note: The input positions are considered to be scaled by `cellSize`. This method will
    /// return the positions already scaled by `cellSize`.
    ///
    /// - Parameters:
    ///   - origin: The point to start the search from.
    ///   - goal: The point to end the search at.
    /// - Returns: A sequence of points to follow, an empty array if there are no obstacles in the way,
    ///   or `nil` if no path could be found.
    ///
    func findPathFrom(_ origin: CGPoint, to goal: CGPoint) -> [CGPoint]? {
        guard let originRoom = roomAt(position: origin), let goalRoom = roomAt(position: goal) else {
            fatalError("Origin or Goal positions are oustide of any available rooms")
        }
        
        // The indices of the rooms where origin and goal are located
        let originIndex = indexOf(room: originRoom)!
        let goalIndex = indexOf(room: goalRoom)!
        
        guard let originPath = paths[originIndex], let goalPath = paths[goalIndex] else { return nil }
        
        if originIndex == goalIndex {
            // Origin and goal are inside the same room, find the path using this room's RoomPath
            return originPath.findPathFrom(origin, to: goal)
        }
        
        let adjacencies = adjacentRoomsIndices(relativeTo: originRoom, diagonals: false)
        var path: [CGPoint]?
        
        for (type, _) in adjacencies {
            switch type {
            case .north:
                let near = originPath.onNorthCorridor(point: origin) && goalPath.onSouthCorridor(point: goal)
                if near && originPath.canExitFromCorridor(insidePoint: origin, outsidePoint: goal) {
                    // On connected corridors and has visibility
                    path = []
                } else {
                    if let pathA = originPath.findPathToNorthWaypoint(from: origin) {
                        // The last point of pathA is guaranteed to be inside the goal's room
                        if let pathB = goalPath.findPathFrom(pathA.last!, to: goal) {
                            // The final path is the combination of both paths
                            path = pathA + pathB
                        }
                    }
                }
            case .south:
                let near = originPath.onSouthCorridor(point: origin) && goalPath.onNorthCorridor(point: goal)
                if near && originPath.canExitFromCorridor(insidePoint: origin, outsidePoint: goal) {
                    // On connected corridors and has visibility
                    path = []
                } else {
                    if let pathA = originPath.findPathToSouthWaypoint(from: origin) {
                        // The last point of pathA is guaranteed to be inside the goal's room
                        if let pathB = goalPath.findPathFrom(pathA.last!, to: goal) {
                            // The final path is the combination of both paths
                            path = pathA + pathB
                        }
                    }
                }
            case .east:
                let near = originPath.onEastCorridor(point: origin) && goalPath.onWestCorridor(point: goal)
                if near && originPath.canExitFromCorridor(insidePoint: origin, outsidePoint: goal) {
                    // On connected corridors and has visibility
                    path = []
                } else {
                    if let pathA = originPath.findPathToEastWaypoint(from: origin) {
                        // The last point of pathA is guaranteed to be inside the goal's room
                        if let pathB = goalPath.findPathFrom(pathA.last!, to: goal) {
                            // The final path is the combination of both paths
                            path = pathA + pathB
                        }
                    }
                }
            case .west:
                let near = originPath.onWestCorridor(point: origin) && goalPath.onEastCorridor(point: goal)
                if near && originPath.canExitFromCorridor(insidePoint: origin, outsidePoint: goal) {
                    // On connected corridors and has visibility
                    path = []
                } else {
                    if let pathA = originPath.findPathToWestWaypoint(from: origin) {
                        // The last point of pathA is guaranteed to be inside the goal's room
                        if let pathB = goalPath.findPathFrom(pathA.last!, to: goal) {
                            // The final path is the combination of both paths
                            path = pathA + pathB
                        }
                    }
                }
            default: break
            }
        }
        
        return path
    }
    
    deinit {
        collisionNodes.forEach { node in node.children.forEach { child in child.constraints = nil } }
    }
}
