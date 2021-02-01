//
//  DungeonLevel.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/5/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A protocol that defines the data associated with a `DungeonLevel` instance, used to
/// initialize its properties.
///
protocol DungeonLevelData {
    
    /// The cell size to use as scale factor.
    ///
    var cellSize: CGSize { get }
    
    /// The offset, in number of cells, to use for gaps.
    ///
    var cellOffset: CGFloat { get }
    
    /// A range defining the amount of rooms to create in the x axis.
    ///
    var columns: ClosedRange<Int> { get }
    
    /// The minimum number of rooms to create.
    ///
    /// When defining the dimensions of the maze, the value of this property will be divided by a random
    /// value from the `columns` range to determine the amount of rows to create.
    ///
    var rooms: Int { get }
    
    /// A rect, with dimensions given in number of cells, to use as room boundaries.
    ///
    var roomRect: CGRect { get }
    
    /// The minimum size of a room, in number of cells.
    ///
    var roomMinSize: CGSize { get }
    
    /// The maximum size of a room, in number of cells.
    ///
    var roomMaxSize: CGSize { get }
    
    /// A gap, in number of cells, to account for corner spaces.
    ///
    var roomCornerGap: CGSize { get }
    
    /// The `TileSet` to use for tile creation.
    ///
    var tileSet: TileSet { get }
    
    /// The `ContentSet` to use for content creation.
    ///
    var contentSet: ContentSet { get }
    
    /// The `ContentProbability` to use for the entrance room.
    ///
    var entranceProbability: ContentProbability { get }
    
    /// The `ContentProbability` to use for the exit room.
    ///
    var exitProbability: ContentProbability { get }
    
    /// The default `ContentProbability` to use for rooms.
    ///
    var defaultProbability: ContentProbability { get }
    
    /// The single use `ContentProbability`s.
    ///
    var oneTimeProbabilities: [ContentProbability] { get }
    
    /// A range defining the amount of sublevels in the level.
    ///
    var sublevels: ClosedRange<Int> { get }
}


/// A `Level` type that defines the Dungeon level, a random labyrinth.
///
class DungeonLevel: Level {
    
    /// The `DungeonLevelData` of the Level.
    ///
    private let data: DungeonLevelData
    
    /// The room creator.
    ///
    private let roomCreator: RandomRoomCreator
    
    /// The tile placer.
    ///
    private let tilePlacer: TilePlacer
    
    /// The content placer.
    ///
    private let contentPlacer: ContentPlacer
    
    /// The amount of sublevels that the level is allowed to create.
    ///
    private let sublevels: Int
    
    /// The current maze of a sublevel.
    ///
    private var maze: Maze?
    
    /// The current protagonist content of a sublevel.
    ///
    private var protagonist: Content?
    
    /// The current node of a sublevel.
    ///
    private var node: SKNode?
    
    /// The current room index that the protagonist is located in a sublevel.
    ///
    private var currentRoomIdx: Int?
    
    /// The previous room index that the protagonist was located in a sublevel.
    ///
    private var lastRoomIdx: Int?
    
    /// The current room being processed for a sublevel.
    ///
    /// Sublevels will only process the rooms that are adjacent to the current protagonist room.
    ///
    private var roomsIndices = [Int?](repeating: nil, count: 9)
    
    /// The entities scheduled for removal from the current sublevel.
    ///
    private var entitiesToRemove = Set<Entity>()
    
    /// The current sublevel being played, between 1 and `sublevels`. 0 means none was played yet.
    ///
    private var currentSublevel = 0
    
    /// A flag indicating that a sublevel is being played.
    ///
    private var isPlaying = false
    
    /// A callback set at the last call of `nextSublevel(onEnd:)`, to be called when the given sublevel ends.
    ///
    private var endCallback: (() -> Void)?
    
    /// Creates a new instance from the given data and optional random source.
    ///
    /// - Parameter data: A `DungeonLevelData` type defining many parameters to use in the level.
    ///
    init(data: DungeonLevelData) {
        assert(data.cellSize.width > 0 &&  data.cellSize.height > 0)
        assert(data.cellOffset > 0)
        assert(data.columns.lowerBound > 0)
        assert(data.rooms >= (2 + data.oneTimeProbabilities.count))
        assert(data.roomRect.width > 0 && data.roomRect.height > 0)
        assert(data.roomMaxSize.width <= data.roomRect.width && data.roomMaxSize.height <= data.roomRect.height)
        assert(data.roomMinSize.width <= data.roomMaxSize.width && data.roomMinSize.height <= data.roomMaxSize.height)
        assert(data.roomCornerGap.width >= 0 && data.roomCornerGap.height >= 0)
        assert(data.sublevels.lowerBound > 0)
        
        self.data = data
        
        // Create the room creator
        roomCreator = RandomRoomCreator(rect: data.roomRect, minSize: data.roomMinSize, maxSize: data.roomMaxSize,
                                        cornerGap: data.roomCornerGap)
        
        // Create the tile placer from the given tile set
        tilePlacer = TilePlacer(tileSet: data.tileSet)
        
        // Create the content placer from the given content set
        contentPlacer = ContentPlacer(contentSet: data.contentSet)
        
        // Define the amount of sublevels
        sublevels = Int.random(in: data.sublevels)
    }
    
    /// Creates the next sublevel.
    ///
    /// This method randomly generates a new sublevel, based on the parameters set in the `DungeonLevelData`
    /// used to initialize the class. After calling this method and receiving a non-nil node, the caller must
    /// add the node to its tree and keep calling the update(deltaTime:) method until the given callback is
    /// notified of the end of the sublevel.
    ///
    /// - Parameter onEnd: A callback to be called when the sublevel ends.
    /// - Returns: A node where all the sublevel drawable content will be appended, or nil if there are no more
    ///   sublevels to play or one is already playing.
    ///
    func nextSublevel(onEnd: @escaping () -> Void) -> SKNode? {
        guard (currentSublevel < sublevels) && !isPlaying else { return nil }
        
        currentSublevel += 1
        isPlaying = true
        
        // Create a maze for the new sublevel
        maze = Maze(cellSize: data.cellSize, cellOffset: data.cellOffset)
        
        // Define the amount of rooms to create
        let columns = Int.random(in: data.columns)
        let rows = (data.rooms % columns) != 0 ? (data.rooms / columns + 1) : (data.rooms / columns)
        
        // Create the graph
        maze!.createGraph(columns: columns, rows: rows)
        
        // Create the rooms
        maze!.createRooms(roomCreator: roomCreator)
        
        // Create the tiles
        maze!.createTiles(tilePlacer: tilePlacer)
        
        // Create collision detection
        maze!.createCollisionDetection()
        
        // Choose entrance & exit rooms
        maze!.chooseEntranceAndExitRooms()
        
        // Create the contents
        maze!.createContents(entranceProbability: data.entranceProbability,
                             exitProbability: data.exitProbability,
                             defaultProbability: data.defaultProbability,
                             oneTimeProbabilities: data.oneTimeProbabilities,
                             contentPlacer: contentPlacer)
        
        // Create paths
        maze!.createPaths()
        
        // Notify content entities about been added to a new level
        for room in maze!.rooms {
            for content in maze!.contentsOf(room: room) where content.entity != nil {
                content.entity!.room = room
                content.entity!.didAddToLevel(self)
            }
        }
        
        // Retrieve the protagonist from the contents of the entrance room
        for content in maze!.dynamicContents[maze!.entranceRoomIndex!] {
            if content.type == .protagonist {
                protagonist = content
                break
            }
        }
        
        assert(protagonist != nil)
        
        // Create a new main node
        if node != nil { node!.removeFromParent() }
        node = SKNode()
        
        // Add the effect node to the main node
        node!.addChild(maze!.effectNode)
        
        // Set the current room as the entrance
        currentRoomIdx = maze!.entranceRoomIndex
        
        // Reset the last room index
        lastRoomIdx = nil
        
        // Reset the room indices
        roomsIndices = [Int?](repeating: nil, count: 9)
        
        // Set the ending callback
        endCallback = onEnd
        
        return node
    }

    func update(deltaTime seconds: TimeInterval) {
        guard isPlaying else { return }
        
        // Update the locations and z positions of dynamic contents
        for roomIdx in roomsIndices where roomIdx != nil {
            var i = 0
            while i < maze!.dynamicContents[roomIdx!].endIndex {
                let content = maze!.dynamicContents[roomIdx!][i]
                // For each content, check if it moved to another room
                let newRoom = maze!.roomAt(position: content.node.position)!
                let newIdx = maze!.indexOf(room: newRoom)!
                if  newIdx != roomIdx {
                    // The content moved to another room, update the maze properties
                    maze!.dynamicContents[roomIdx!].remove(at: i)
                    maze!.dynamicContents[newIdx].append(content)
                    content.entity?.room = newRoom
                    content.node.removeFromParent()
                    maze!.contentNodes[newIdx].addChild(content.node)
                } else {
                    i += 1
                }
            }
        }
        
        // Update the elements that must be processed
        // ToDo: Do not assume that the protagonist will always be inside a valid room
        let currentRoom = maze!.roomAt(position: protagonist!.node.position)!
        currentRoomIdx = maze!.indexOf(room: currentRoom)
        if (lastRoomIdx == nil) || (currentRoomIdx != lastRoomIdx) {
            // The protagonist is at a different room from last time, set new rooms to be processed
            var roomsToProcess: [Int?] = [currentRoomIdx]
            roomsToProcess.append(contentsOf: [Int](maze!.adjacentRoomsIndices(relativeTo: currentRoom).values))
            // Remove previous rooms elements that will not be processed this time
            for i in roomsIndices.indices where roomsIndices[i] != nil {
                let roomIdx = roomsIndices[i]
                let j = roomsToProcess.firstIndex(of: roomIdx)
                if j == nil {
                    // This room should not be processed any longer, remove its nodes
                    maze!.tileNodes[roomIdx!].removeFromParent()
                    maze!.collisionNodes[roomIdx!].removeFromParent()
                    maze!.contentNodes[roomIdx!].removeFromParent()
                    // Remove it from the roomsIndices array
                    roomsIndices[i] = nil
                } else {
                    // This room is already being processed, remove it from the roomsToProcess array
                    roomsToProcess[j!] = nil
                }
            }
            for roomIdx in roomsToProcess where roomIdx != nil {
                // Add the nodes of each new room to be processed
                node!.addChild(maze!.tileNodes[roomIdx!])
                node!.addChild(maze!.collisionNodes[roomIdx!])
                node!.addChild(maze!.contentNodes[roomIdx!])
                // Insert it into the roomsIndices array
                roomsIndices.insert(roomIdx, at: roomsIndices.firstIndex(where: { $0 == nil })!)
            }
        }
        
        // Process entities scheduled for removal in the current sublevel
        processRemovals()
        
        // Update the components of every content being processed
        let componentSystem = ComponentSystem()
        for roomIdx in roomsIndices where roomIdx != nil {
            for content in maze!.contentsOf(room: maze!.rooms[roomIdx!]) where content.entity != nil {
                componentSystem.addEntity(content.entity!)
            }
        }
        componentSystem.update(deltaTime: seconds)
        
        // Update the effect nodes
        for node in maze!.effectNode.children {
            (node as? UpdateNode)?.update(deltaTime: seconds)
        }
        
        // Update the lastRoomIndex
        lastRoomIdx = currentRoomIdx
    }

    func findPathFrom(_ origin: CGPoint, to goal: CGPoint) -> [CGPoint]? {
        guard isPlaying else { return nil }
        return maze?.findPathFrom(origin, to: goal)
    }
    
    func addContent(_ content: Content, at position: CGPoint) {
        guard isPlaying, let room = maze?.roomAt(position: position) else { return }
        
        maze!.createSpecificContent(content, position: position)
        content.entity?.room = room
        content.entity?.didAddToLevel(self)
    }

    func addNode(_ node: SKNode) {
        guard isPlaying else { return }
        maze?.effectNode.addChild(node)
    }
    
    func removeFromSublevel(entity: Entity) {
        guard isPlaying else { return }
        entitiesToRemove.insert(entity)
    }
    
    func finishSublevel() {
        guard isPlaying else { return }
        isPlaying = false
        
        for room in maze!.rooms {
            for content in maze!.contentsOf(room: room) {
                content.entity?.willRemoveFromLevel(self)
            }
        }
        
        for node in maze!.effectNode.children {
            (node as? UpdateNode)?.terminate()
        }
        
        endCallback?()
    }
    
    func provideMinimap() -> Minimap? {
        guard let maze = maze else { return nil }
        return MazeMinimap(maze: maze)
    }
    
    /// Removes all entities contained in the `entitiesToRemove` set from the current sublevel.
    ///
    /// Entities are scheduled for removal with calls to `removeFromSublevel(entity:)`. Removals
    /// are processed every `update(deltaTime:)` call.
    ///
    private func processRemovals() {
        guard isPlaying else { return }
        
        while let entity = entitiesToRemove.popFirst() {
            let room: Room! = entity.room
            assert(room != nil)
            
            let index: Int! = maze!.indexOf(room: room)
            assert(index != nil)
            
            for (i, content) in zip(maze!.dynamicContents[index].indices, maze!.dynamicContents[index]) {
                if content.entity === entity {
                    maze!.dynamicContents[index].remove(at: i)
                    entity.willRemoveFromLevel(self)
                    return
                }
            }
            
            for (i, content) in zip(maze!.staticContents[index].indices, maze!.staticContents[index]) {
                if content.entity === entity {
                    maze!.staticContents[index].remove(at: i)
                    entity.willRemoveFromLevel(self)
                    return
                }
            }
            
            assert(false, "Failed to remove entity named \(entity.name) from room \(index!))")
        }
    }
}
