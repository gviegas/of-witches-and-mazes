//
//  RoomPath.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that represents the navigable path of a `Room`.
///
class RoomPath {
    
    /// An enum that names the possible locations in the path area.
    ///
    enum Location {
        case mainRoom, northCorridor, southCorridor, eastCorridor, westCorridor
    }
    
    /// The area that the path refers to.
    ///
    private let area: RoomArea
    
    /// The obstacles of the area.
    ///
    private let obstacles: RoomObstacle
    
    /// The graph of the path.
    ///
    private let graph: PositionGraph
    
    /// The north waypoint leading out of the area, scaled by cellSize.
    ///
    private let northWaypoint: CGPoint?
    
    /// The south waypoint leading out of the area, scaled by cellSize.
    ///
    private let southWaypoint: CGPoint?
    
    /// The east waypoint leading out of the area, scaled by cellSize.
    ///
    private let eastWaypoint: CGPoint?
    
    /// The west waypoint leading out of the area, scaled by cellSize.
    ///
    private let westWaypoint: CGPoint?
    
    /// The cell size (i.e., the scale factor).
    ///
    let cellSize: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - area: The `RoomArea` from which to create the path.
    ///   - obstacles: The `RoomObstacle` of the area.
    ///   - cellSize: The cell size to use as scale factor.
    ///
    init(area: RoomArea, obstacles: RoomObstacle, cellSize: CGSize) {
        self.area = area
        self.obstacles = obstacles
        self.cellSize = cellSize
        self.graph = PositionGraph()
        
        if let corridor = area.northCorridorArea {
            self.northWaypoint = CGPoint(x: corridor.midX * cellSize.width, y: corridor.maxY * cellSize.height)
        } else {
            self.northWaypoint = nil
        }
        if let corridor = area.southCorridorArea {
            self.southWaypoint = CGPoint(x: corridor.midX * cellSize.width, y: corridor.minY * cellSize.height)
        } else {
            self.southWaypoint = nil
        }
        if let corridor = area.eastCorridorArea {
            self.eastWaypoint = CGPoint(x: corridor.maxX * cellSize.width, y: corridor.midY * cellSize.height)
        } else {
            self.eastWaypoint = nil
        }
        if let corridor = area.westCorridorArea {
            self.westWaypoint = CGPoint(x: corridor.minX * cellSize.width, y: corridor.midY * cellSize.height)
        } else {
            self.westWaypoint = nil
        }
        
        createVisibilityGraph()
    }
    
    /// Computes the linear interpolation of two points.
    ///
    /// - Parameters:
    ///   - a: The start point.
    ///   - b: The end point.
    ///   - t: The scale, in the range 0...1.0.
    /// - Returns: An interpolated point.
    ///
    private func lerp(a: CGPoint, b: CGPoint, t: CGFloat) -> CGPoint {
        assert(t >= 0 && t <= 1.0)
        
        return CGPoint(x: a.x + t * (b.x - a.x), y: a.y + t * (b.y - a.y))
    }
    
    /// Checks if two vertices are visible to each other.
    ///
    /// - Parameters:
    ///   - vertexA: The first vertex.
    ///   - vertexB: The second vertex.
    /// - Returns: `true` if the vertices are visible from one another, `false` otherwise.
    ///
    private func hasVisibility(_ vertexA: PositionVertex, _ vertexB: PositionVertex) -> Bool {
        let a = vertexA.point
        let b = vertexB.point
        let c = CGPoint(x: b.x - a.x, y: b.y - a.y)
        let len = (c.x * c.x + c.y * c.y).squareRoot()
        
        if len < 1.0 { return true }
        
        // Cast a ray from one vertex to another, checking a set of interpolated points along the ray
        let factor: CGFloat = 3.0
        var t: CGFloat = 0
        for i in 1..<Int(len * factor) {
            t = CGFloat(i) / (len * factor)
            let d = lerp(a: a, b: b, t: t)
            
            if area.roomArea.contains(d) {
                if obstacles.roomObstacles.allSatisfy({ !$0.contains(d) }) { continue }
            } else if let corridor = area.northCorridorArea, corridor.contains(d) {
                if obstacles.northCorridorObstacles!.allSatisfy({ !$0.contains(d) }) { continue }
            } else if let corridor = area.southCorridorArea, corridor.contains(d) {
                if obstacles.southCorridorObstacles!.allSatisfy({ !$0.contains(d) }) { continue }
            } else if let corridor = area.eastCorridorArea, corridor.contains(d) {
                if obstacles.eastCorridorObstacles!.allSatisfy({ !$0.contains(d) }) { continue }
            } else if let corridor = area.westCorridorArea, corridor.contains(d) {
                if obstacles.westCorridorObstacles!.allSatisfy({ !$0.contains(d) }) { continue }
            }
            
            return false
        }
        
        return true
    }
    
    /// Creates a visibility graph for this path.
    ///
    private func createVisibilityGraph() {
        let offset: CGFloat = 0.5
        
        // Create vertices for each corridor
        if let corridor = area.northCorridorArea {
            let left = PositionVertex(point: CGPoint(x: corridor.minX + offset, y: corridor.minY - offset))
            let right = PositionVertex(point: CGPoint(x: corridor.maxX - offset, y: corridor.minY - offset))
            graph.addVertex(left)
            graph.addVertex(right)
        }
        if let corridor = area.southCorridorArea {
            let left = PositionVertex(point: CGPoint(x: corridor.minX + offset, y: corridor.maxY + offset))
            let right = PositionVertex(point: CGPoint(x: corridor.maxX - offset, y: corridor.maxY + offset))
            graph.addVertex(left)
            graph.addVertex(right)
        }
        if let corridor = area.eastCorridorArea {
            let bottom = PositionVertex(point: CGPoint(x: corridor.minX - offset, y: corridor.minY + offset))
            let top = PositionVertex(point: CGPoint(x: corridor.minX - offset, y: corridor.maxY - offset))
            graph.addVertex(bottom)
            graph.addVertex(top)
        }
        if let corridor = area.westCorridorArea {
            let bottom = PositionVertex(point: CGPoint(x: corridor.maxX + offset, y: corridor.minY + offset))
            let top = PositionVertex(point: CGPoint(x: corridor.maxX + offset, y: corridor.maxY - offset))
            graph.addVertex(bottom)
            graph.addVertex(top)
        }
        
        // Create vertices for the area's obstacles
        let pointsForObstacle: (_ obstacle: CGRect, _ location: Location) -> [CGPoint] = {
            [unowned self] obstacle, location in
            
            let offset = CGFloat(0.25)
            let points = [CGPoint(x: obstacle.minX - offset, y: obstacle.minY - offset),
                          CGPoint(x: obstacle.minX - offset, y: obstacle.maxY + offset),
                          CGPoint(x: obstacle.maxX + offset, y: obstacle.maxY + offset),
                          CGPoint(x: obstacle.maxX + offset, y: obstacle.minY - offset)]
            let rects: [CGRect]
            
            switch location {
            case .mainRoom:
                var roomRects = [self.area.roomArea]
                let extent = offset * 2.5
                if let area = self.area.northCorridorArea {
                    let rect = CGRect(x: area.minX, y: area.minY, width: area.width, height: extent)
                    roomRects.append(rect)
                }
                if let area = self.area.southCorridorArea {
                    let rect = CGRect(x: area.minX, y: area.maxY - extent, width: area.width, height: extent)
                    roomRects.append(rect)
                }
                if let area = self.area.eastCorridorArea {
                    let rect = CGRect(x: area.minX, y: area.minY, width: extent, height: area.height)
                    roomRects.append(rect)
                }
                if let area = self.area.westCorridorArea {
                    let rect = CGRect(x: area.maxX - extent, y: area.minY, width: extent, height: area.height)
                    roomRects.append(rect)
                }
                rects = roomRects
            case .northCorridor, .southCorridor:
                let area = location == .northCorridor ? self.area.northCorridorArea! : self.area.southCorridorArea!
                let rect = CGRect(x: area.minX, y: area.minY - offset * 2.5,
                                  width: area.width, height: area.height + offset * 5.0)
                rects = [rect]
            case .eastCorridor, .westCorridor:
                let area = location == .eastCorridor ? self.area.eastCorridorArea! : self.area.westCorridorArea!
                let rect = CGRect(x: area.minX - offset * 2.5, y: area.minY,
                                  width: area.width + offset * 5.0, height: area.height)
                rects = [rect]
            }
            
            return points.filter { point in
                let corners = [CGPoint(x: point.x - offset, y: point.y - offset),
                               CGPoint(x: point.x - offset, y: point.y + offset),
                               CGPoint(x: point.x + offset, y: point.y + offset),
                               CGPoint(x: point.x + offset, y: point.y - offset)]
                return corners.allSatisfy { corner in
                    !rects.allSatisfy({ !$0.contains(corner) })
                }
            }
        }
        
        for obstacle in obstacles.roomObstacles {
            pointsForObstacle(obstacle, .mainRoom).forEach { graph.addVertex(PositionVertex(point: $0)) }
        }
        if let corridorObstacles = obstacles.northCorridorObstacles {
            for obstacle in corridorObstacles {
                pointsForObstacle(obstacle, .northCorridor).forEach { graph.addVertex(PositionVertex(point: $0)) }
            }
        }
        if let corridorObstacles = obstacles.southCorridorObstacles {
            for obstacle in corridorObstacles {
                pointsForObstacle(obstacle, .southCorridor).forEach { graph.addVertex(PositionVertex(point: $0)) }
            }
        }
        if let corridorObstacles = obstacles.eastCorridorObstacles {
            for obstacle in corridorObstacles {
                pointsForObstacle(obstacle, .eastCorridor).forEach { graph.addVertex(PositionVertex(point: $0)) }
            }
        }
        if let corridorObstacles = obstacles.westCorridorObstacles {
            for obstacle in corridorObstacles {
                pointsForObstacle(obstacle, .westCorridor).forEach { graph.addVertex(PositionVertex(point: $0)) }
            }
        }
        
        // Remove redundant vertices
        let verticesIntersect: (PositionVertex, PositionVertex) -> Bool = { a, b in
            let offset = CGFloat(0.33)
            let r = CGRect(x: a.point.x - offset, y: a.point.y - offset, width: offset * 2.0, height: offset * 2.0)
            return r.contains(b.point)
        }
        var verticesExplored = Set<PositionVertex>()
        var verticesToRemove = Set<PositionVertex>()
        for vertex in graph.vertices where verticesExplored.insert(vertex).inserted {
            for other in graph.vertices where !verticesExplored.contains(other) && !verticesToRemove.contains(other) {
                if verticesIntersect(vertex, other) { verticesToRemove.insert(other) }
            }
        }
        verticesToRemove.forEach { graph.removeVertex($0) }
        
        // Create adjacencies between visible nodes
        for vertex in graph.vertices {
            for other in graph.vertices where other != vertex {
                if !graph.hasAdjacency(vertex, to: other) && hasVisibility(vertex, other) {
                    let p = CGPoint(x: vertex.point.x - other.point.x, y: vertex.point.y - other.point.y)
                    let len = (p.x * p.x + p.y * p.y).squareRoot()
                    graph.addAdjacencyFor(vertex: vertex, adjacency: other, cost: UInt(len), bidirectional: true)
                }
            }
        }
    }
    
    /// Connects the given vertex to other visible vertices of the graph.
    ///
    /// - Parameter vertex: The vertex to connect.
    ///
    private func connectVertex(_ vertex: PositionVertex) {
        graph.addVertex(vertex)
        for other in graph.vertices where other != vertex {
            if hasVisibility(vertex, other) {
                let p = CGPoint(x: vertex.point.x - other.point.x, y: vertex.point.y - other.point.y)
                let len = (p.x * p.x + p.y * p.y).squareRoot()
                graph.addAdjacencyFor(vertex: vertex, adjacency: other, cost: UInt(len), bidirectional: true)
            }
        }
    }
    
    /// Finds a path from the origin to the goal.
    ///
    /// - Note: The input positions are considered to be scaled by `cellSize`. This method will
    /// return the positions already scaled by `cellSize`.
    ///
    /// - Parameters:
    ///   - origin: The point to start the search from.
    ///   - goal: The point to end the search at.
    /// - Returns: A sequence of points to follow, an empty sequence if origin and goal are visible to
    ///   each other, or `nil` if there is no path.
    ///
    func findPathFrom(_ origin: CGPoint, to goal: CGPoint) -> [CGPoint]? {
        let vertexA = PositionVertex(point: CGPoint(x: origin.x / cellSize.width, y: origin.y / cellSize.height))
        let vertexB = PositionVertex(point: CGPoint(x: goal.x / cellSize.width, y: goal.y / cellSize.height))
        
        // If the goal is visible from the origin, it is done
        if hasVisibility(vertexA, vertexB) { return [] }
        
        connectVertex(vertexA)
        connectVertex(vertexB)
        
        let path = graph.findPathUsingHeuristic(from: vertexA, to: vertexB) {
            current, goal in
            let p = CGPoint(x: current.point.x - goal.point.x, y: current.point.y - goal.point.y)
            return UInt((p.x * p.x + p.y * p.y).squareRoot())
        }
        
        graph.removeVertex(vertexA)
        graph.removeVertex(vertexB)
        
        return path?.map({ CGPoint(x: $0.point.x * cellSize.width, y: $0.point.y * cellSize.height) })
    }
    
    /// Finds a path leading out of this area through the north. The last point of the resulting array,
    /// the waypoint, is guaranteed to be outside of this path's area.
    ///
    /// - Note: The input position is considered to be scaled by `cellSize`. This method will return
    /// the positions already scaled by `cellSize`.
    ///
    /// - Parameter origin: The start point of the search.
    /// - Returns: A sequence of points to follow, or `nil` if there is no path.
    ///
    func findPathToNorthWaypoint(from origin: CGPoint) -> [CGPoint]? {
        guard let northWaypoint = northWaypoint else { return nil }
        
        var path = findPathFrom(origin, to: northWaypoint)
        // Append to the path a point that leads out of this area and into the next one
        path?.append(CGPoint(x: northWaypoint.x, y: northWaypoint.y + cellSize.height))
        return path
    }
    
    /// Finds a path leading out of this area through the south. The last point of the resulting array,
    /// the waypoint, is guaranteed to be outside of this path's area.
    ///
    /// - Note: The input position is considered to be scaled by `cellSize`. This method will return
    /// the positions already scaled by `cellSize`.
    ///
    /// - Parameter origin: The start point of the search.
    /// - Returns: A sequence of points to follow, or `nil` if there is no path.
    ///
    func findPathToSouthWaypoint(from origin: CGPoint) -> [CGPoint]? {
        guard let southWaypoint = southWaypoint else { return nil }
        
        var path = findPathFrom(origin, to: southWaypoint)
        // Append to the path a point that leads out of this area and into the next one
        path?.append(CGPoint(x: southWaypoint.x, y: southWaypoint.y - cellSize.height))
        return path
    }
    
    /// Finds a path leading out of this area through the east. The last point of the resulting array,
    /// the waypoint, is guaranteed to be outside of this path's area.
    ///
    /// - Note: The input position is considered to be scaled by `cellSize`. This method will return
    /// the positions already scaled by `cellSize`.
    ///
    /// - Parameter origin: The start point of the search.
    /// - Returns: A sequence of points to follow, or `nil` if there is no path.
    ///
    func findPathToEastWaypoint(from origin: CGPoint) -> [CGPoint]? {
        guard let eastWaypoint = eastWaypoint else { return nil }
        
        var path = findPathFrom(origin, to: eastWaypoint)
        // Append to the path a point that leads out of this area and into the next one
        path?.append(CGPoint(x: eastWaypoint.x + cellSize.width, y: eastWaypoint.y))
        return path
    }
    
    /// Finds a path leading out of this area through the west. The last point of the resulting array,
    /// the waypoint, is guaranteed to be outside of this path's area.
    ///
    /// - Note: The input position is considered to be scaled by `cellSize`. This method will return
    /// the positions already scaled by `cellSize`.
    ///
    /// - Parameter origin: The start point of the search.
    /// - Returns: A sequence of points to follow, or `nil` if there is no path.
    ///
    func findPathToWestWaypoint(from origin: CGPoint) -> [CGPoint]? {
        guard let westWaypoint = westWaypoint else { return nil }
        
        var path = findPathFrom(origin, to: westWaypoint)
        // Append to the path a point that leads out of this area and into the next one
        path?.append(CGPoint(x: westWaypoint.x - cellSize.width, y: westWaypoint.y))
        return path
    }
    
    /// Checks the location of the given point inside the path's area.
    ///
    /// - Note: The point is considered to be scaled by `cellSize`.
    ///
    /// - Parameter point: The point to check.
    /// - Returns: The location of the point inside this path's area, or `nil` if the point lies outside.
    ///
    func locationOf(point: CGPoint) -> Location? {
        let p = CGPoint(x: point.x / cellSize.width, y: point.y / cellSize.height)
        if area.roomArea.contains(p) { return .mainRoom }
        if let corridor = area.northCorridorArea, corridor.contains(p) { return .northCorridor }
        if let corridor = area.southCorridorArea, corridor.contains(p) { return .southCorridor }
        if let corridor = area.eastCorridorArea, corridor.contains(p) { return .eastCorridor }
        if let corridor = area.westCorridorArea, corridor.contains(p) { return .westCorridor }
        return nil
    }
    
    /// Check if the given point is inside of the area's main room.
    ///
    /// - Note: The point is considered to be scaled by `cellSize`.
    ///
    /// - Parameter point: The point to check.
    /// - Returns: `true` if the point is located within the area's main room, `false` otherwise.
    ///
    func onMainRoom(point: CGPoint) -> Bool {
        let p = CGPoint(x: point.x / cellSize.width, y: point.y / cellSize.height)
        return area.roomArea.contains(p)
    }
    
    /// Check if the given point is inside of the area's north corridor.
    ///
    /// - Note: The point is considered to be scaled by `cellSize`.
    ///
    /// - Parameter point: The point to check.
    /// - Returns: `true` if the point is located within the area's north corridor, `false` otherwise.
    ///
    func onNorthCorridor(point: CGPoint) -> Bool {
        guard let corridor = area.northCorridorArea else { return false }
        
        let p = CGPoint(x: point.x / cellSize.width, y: point.y / cellSize.height)
        return corridor.contains(p)
    }
    
    /// Check if the given point is inside of the area's south corridor.
    ///
    /// - Note: The point is considered to be scaled by `cellSize`.
    ///
    /// - Parameter point: The point to check.
    /// - Returns: `true` if the point is located within the area's south corridor, `false` otherwise.
    ///
    func onSouthCorridor(point: CGPoint) -> Bool {
        guard let corridor = area.southCorridorArea else { return false }
        
        let p = CGPoint(x: point.x / cellSize.width, y: point.y / cellSize.height)
        return corridor.contains(p)
    }
    
    /// Check if the given point is inside of the area's east corridor.
    ///
    /// - Note: The point is considered to be scaled by `cellSize`.
    ///
    /// - Parameter point: The point to check.
    /// - Returns: `true` if the point is located within the area's east corridor, `false` otherwise.
    ///
    func onEastCorridor(point: CGPoint) -> Bool {
        guard let corridor = area.eastCorridorArea else { return false }
        
        let p = CGPoint(x: point.x / cellSize.width, y: point.y / cellSize.height)
        return corridor.contains(p)
    }
    
    /// Check if the given point is inside of the area's west corridor.
    ///
    /// - Note: The point is considered to be scaled by `cellSize`.
    ///
    /// - Parameter point: The point to check.
    /// - Returns: `true` if the point is located within the area's west corridor, `false` otherwise.
    ///
    func onWestCorridor(point: CGPoint) -> Bool {
        guard let corridor = area.westCorridorArea else { return false }
        
        let p = CGPoint(x: point.x / cellSize.width, y: point.y / cellSize.height)
        return corridor.contains(p)
    }
    
    /// Checks if there is a straight path from a given point inside a corridor that leads out of the room.
    ///
    /// - Note: The points are considered to be scaled by `cellSize`.
    ///
    /// - Parameters:
    ///   - insidePoint: A point, inside one of the room's corridors, defining the origin of the path.
    ///   - outsidePoint: A point, outside of the room, defining the destination.
    /// - Returns: This method will return `true` if and only if all of the following conditions apply:
    ///   * `insidePoint` is contained by one of the room's corridors;
    ///   * The direction towards `outsidePoint` produces a path that leads out of the corridor and to the next room;
    ///   * There are no obstacles in the way.
    ///
    func canExitFromCorridor(insidePoint: CGPoint, outsidePoint: CGPoint) -> Bool {
        let noObstacles: (Location, CGPoint, CGPoint) -> Bool = { [unowned self] location, a, b in
            let obstacles: [CGRect]!
            let area: CGRect!
            switch location {
            case .northCorridor:
                obstacles = self.obstacles.northCorridorObstacles
                area = self.area.northCorridorArea
            case .southCorridor:
                obstacles = self.obstacles.southCorridorObstacles
                area = self.area.southCorridorArea
            case .eastCorridor:
                obstacles = self.obstacles.eastCorridorObstacles
                area = self.area.eastCorridorArea
            case .westCorridor:
                obstacles = self.obstacles.westCorridorObstacles
                area = self.area.westCorridorArea
            default:
                obstacles = nil
                area = nil
            }
            
            guard obstacles != nil, area != nil else { return true }
            
            let c = CGPoint(x: b.x - a.x, y: b.y - a.y)
            let len = (c.x * c.x + c.y * c.y).squareRoot()
            
            guard len >= 1.0 else { return true }
            
            // Cast a ray from one vertex to another, checking a set of interpolated points along the ray
            let factor: CGFloat = 3.0
            var t: CGFloat = 0
            for i in 1..<Int(len * factor) {
                t = CGFloat(i) / (len * factor)
                let d = self.lerp(a: a, b: b, t: t)
                
                guard area.contains(d) else { break }
                
                guard obstacles.allSatisfy({ !$0.contains(d) }) else { return false }
            }
            
            return true
        }
        
        if onNorthCorridor(point: insidePoint) {
            let p = CGPoint(x: outsidePoint.x - insidePoint.x, y: outsidePoint.y - insidePoint.y)
            let angle = atan2(p.y, p.x)
            
            let left = CGPoint(x: area.northCorridorArea!.minX, y: area.northCorridorArea!.maxY)
            let right = CGPoint(x: area.northCorridorArea!.maxX, y: left.y)
            let inside = CGPoint(x: insidePoint.x / cellSize.width, y: insidePoint.y / cellSize.height)
            let q = CGPoint(x: left.x - inside.x, y: left.y - inside.y)
            let r = CGPoint(x: right.x - inside.x, y: right.y - inside.y)
            let angleRange = atan2(r.y, r.x)...atan2(q.y, q.x)
            
            if angleRange.contains(angle) {
                let outside = CGPoint(x: outsidePoint.x / cellSize.width, y: outsidePoint.y / cellSize.height)
                return noObstacles(.northCorridor, inside, outside)
            } else {
                return false
            }
        } else if onSouthCorridor(point: insidePoint) {
            let p = CGPoint(x: outsidePoint.x - insidePoint.x, y: outsidePoint.y - insidePoint.y)
            let angle = atan2(p.y, p.x)
            
            let left = CGPoint(x: area.southCorridorArea!.minX, y: area.southCorridorArea!.minY)
            let right = CGPoint(x: area.southCorridorArea!.maxX, y: left.y)
            let inside = CGPoint(x: insidePoint.x / cellSize.width, y: insidePoint.y / cellSize.height)
            let q = CGPoint(x: left.x - inside.x, y: left.y - inside.y)
            let r = CGPoint(x: right.x - inside.x, y: right.y - inside.y)
            let angleRange = atan2(q.y, q.x)...atan2(r.y, r.x)
            
            if angleRange.contains(angle) {
                let outside = CGPoint(x: outsidePoint.x / cellSize.width, y: outsidePoint.y / cellSize.height)
                return noObstacles(.southCorridor, inside, outside)
            } else {
                return false
            }
        } else if onEastCorridor(point: insidePoint) {
            let p = CGPoint(x: outsidePoint.x - insidePoint.x, y: outsidePoint.y - insidePoint.y)
            let angle = atan2(p.y, p.x)
            
            let top = CGPoint(x: area.eastCorridorArea!.maxX, y: area.eastCorridorArea!.maxY)
            let bottom = CGPoint(x: top.x, y: area.eastCorridorArea!.minY)
            let inside = CGPoint(x: insidePoint.x / cellSize.width, y: insidePoint.y / cellSize.height)
            let q = CGPoint(x: top.x - inside.x, y: top.y - inside.y)
            let r = CGPoint(x: bottom.x - inside.x, y: bottom.y - inside.y)
            let angleRange = atan2(r.y, r.x)...atan2(q.y, q.x)
            
            if angleRange.contains(angle) {
                let outside = CGPoint(x: outsidePoint.x / cellSize.width, y: outsidePoint.y / cellSize.height)
                return noObstacles(.eastCorridor, inside, outside)
            } else {
                return false
            }
        } else if onWestCorridor(point: insidePoint) {
            let p = CGPoint(x: outsidePoint.x - insidePoint.x, y: outsidePoint.y - insidePoint.y)
            let angle = atan2(p.y, p.x)
            
            let top = CGPoint(x: area.westCorridorArea!.minX, y: area.westCorridorArea!.maxY)
            let bottom = CGPoint(x: top.x, y: area.westCorridorArea!.minY)
            let inside = CGPoint(x: insidePoint.x / cellSize.width, y: insidePoint.y / cellSize.height)
            let q = CGPoint(x: top.x - inside.x, y: top.y - inside.y)
            let r = CGPoint(x: bottom.x - inside.x, y: bottom.y - inside.y)
            let angleRange1 = atan2(q.y, q.x)...(.pi)
            let angleRange2 = (-.pi)...atan2(r.y, r.x)
            
            if angleRange1.contains(angle) || angleRange2.contains(angle) {
                let outside = CGPoint(x: outsidePoint.x / cellSize.width, y: outsidePoint.y / cellSize.height)
                return noObstacles(.westCorridor, inside, outside)
            } else {
                return false
            }
        } else {
            return false
        }
    }
}
