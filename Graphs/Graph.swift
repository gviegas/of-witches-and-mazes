//
//  Graph.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/2/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A generic graph class.
///
class Graph<Vertex: Hashable, Cost: Numeric & Comparable> {
    
    /// A class that defines an edge for the graph.
    ///
    private class Edge: Hashable, Comparable {
        
        /// The destination vertex of the edge.
        ///
        let vertex: Vertex
        
        /// The cost to reach this edge's vertex.
        ///
        let cost: Cost
        
        /// The estimate set for this edge.
        ///
        let estimate: Cost
        
        /// Creates a new instance.
        ///
        /// - Parameters:
        ///   - vertex: The vertex at the end of the edge.
        ///   - cost: The cost to reach vertex through this edge.
        ///   - estimate: An optional estimate to be summed with the cost on comparisons.
        ///     The default value is `0`.
        ///
        init(vertex: Vertex, cost: Cost, estimate: Cost = 0) {
            self.vertex = vertex
            self.cost = cost
            self.estimate = estimate
        }
        
        func hash(into hasher: inout Hasher) {
            vertex.hash(into: &hasher)
        }
        
        static func <(lhs: Graph<Vertex, Cost>.Edge, rhs: Graph<Vertex, Cost>.Edge) -> Bool {
            return (lhs.cost + lhs.estimate) < (rhs.cost + rhs.estimate)
        }
        
        // Note that, intentionally, the edge cost is not considered for equality.
        static func ==(lhs: Graph<Vertex, Cost>.Edge, rhs: Graph<Vertex, Cost>.Edge) -> Bool {
            return lhs.vertex == rhs.vertex
        }
    }
    
    /// The graph.
    ///
    private var graph: [Vertex: [Edge]] = [:]
    
    /// The number of vertices in the graph.
    ///
    var totalVertices: Int {
        return graph.count
    }
    
    /// The number of edges in the graph.
    ///
    var totalEdges: Int {
        return graph.reduce(0, { $0 + $1.value.count } )
    }
    
    /// The vertices present in the graph.
    ///
    var vertices: [Vertex] {
        return [Vertex](graph.keys)
    }
    
    /// Adds a new vertex to the graph.
    ///
    /// If the given vertex is already in the graph, this method has no effect.
    ///
    /// - Parameter vertex: The vertex to add.
    ///
    func addVertex(_ vertex: Vertex) {
        guard graph[vertex] == nil else { return }
        graph[vertex] = [Edge]()
    }
    
    /// Removes a vertex from the graph.
    ///
    /// Every adjacency from and to this vertex is also removed from the graph, so it is not necessary
    /// to make any additional calls to removeAdjacencyFor(vertex:adjacency).
    ///
    /// - Parameter vertex: The vertex to remove.
    ///
    func removeVertex(_ vertex: Vertex) {
        guard let _ = graph[vertex] else { return }
        for other in graph where other.key != vertex {
            removeAdjacencyFor(vertex: other.key, adjacency: vertex)
        }
        graph.removeValue(forKey: vertex)
    }
    
    /// Adds a new adjacency to the given vertex.
    ///
    /// Note that this method will insert the given vertices into the graph if they were not added previously.
    /// If bidirectional is true, then an adjacency will be created on both ways.
    /// For example, given an empty graph of type Graph<String, Int>, calling:
    ///
    ///     addAjacencyFor(vertex: "a", adjacency "b", cost: 5, bidirectional: true)
    ///
    /// Would add the vertices "a" and "b" to the graph, each with an adjacency to one another with
    /// cost of 5:
    ///
    ///     "a" --- (5) --- "b"
    ///
    /// This is equivalent to the following sequence of calls:
    ///
    ///     addVertex("a")
    ///     addVertex("b")
    ///     addAjacencyFor(vertex: "a", adjacency: "b", cost: 5)
    ///     addAjacencyFor(vertex: "b", adjacency: "a", cost: 5)
    ///
    /// So, for the most part, addAdjacencyFor(vertex:adjacency:cost:bidirectional) is enough
    /// to build the whole graph.
    ///
    /// - Parameters:
    ///   - vertex: The `Vertex` to which the adjacency will be added.
    ///   - adjacency: The `Vertex` that the adjacency reaches.
    ///   - cost: The cost of the adjacency.
    ///   - bidirectional:  A flag that defines if a two-way adjacency must be created. The default value is `false`.
    ///
    func addAdjacencyFor(vertex: Vertex, adjacency: Vertex, cost: Cost, bidirectional: Bool = false) {
        if graph[vertex] == nil {
            addVertex(vertex)
        }
        if graph[adjacency] == nil {
            addVertex(adjacency)
        }
        
        graph[vertex]!.append(Edge(vertex: adjacency, cost: cost))
        
        if bidirectional {
            graph[adjacency]!.append(Edge(vertex: vertex, cost: cost))
        }
    }
    
    /// Removes an existing adjacency from the given vertex.
    ///
    /// If vertex is not in the graph or is not adjacent to adjacency, this method has no effect.
    ///
    /// - Parameters:
    ///   - vertex: The `Vertex` from which the adjacency will be removed.
    ///   - adjacency: The `Vertex` reached through the adjacency.
    ///
    func removeAdjacencyFor(vertex: Vertex, adjacency: Vertex) {
        if let _ = graph[vertex] {
            if let index = graph[vertex]!.firstIndex(where: { $0.vertex == adjacency }) {
                graph[vertex]!.remove(at: index)
            }
        }
    }
    
    /// Retrieves all the adjacencies of the given vertex.
    ///
    /// - Parameter vertex: The target vertex.
    /// - Returns: The adjacencies of the given vertex as an array of (Vertex, Cost) pairs.
    ///
    func adjacenciesOf(vertex: Vertex) -> [(Vertex, Cost)] {
        if let adjacencies = graph[vertex] {
            return adjacencies.compactMap({ ($0.vertex, $0.cost) })
        }
        return []
    }
    
    /// Checks if the given vertex has the given adjacency.
    ///
    /// - Parameters:
    ///   - vertex: The vertex to check.
    ///   - other: The adjacency to check.
    /// - Returns: `true` if a given vertex has an adjacency to another vertex, `false` otherwise.
    ///
    func hasAdjacency(_ vertex: Vertex, to other: Vertex) -> Bool {
        guard let edges = graph[vertex] else { return false }
        return edges.contains(where: { $0.vertex == other })
    }
    
    /// Combines this graph with another graph.
    ///
    /// - Note: Since duplicate adjacencies are allowed, this method may cause the graph to become needlessly big.
    ///   And although this should not change the final result of most algorithms, they may become slower.
    ///
    /// - Parameter other: The graph to combine with.
    ///
    func combineWith(_ other: Graph) {
        for vertex in other.vertices {
            for (adjacency, cost) in other.adjacenciesOf(vertex: vertex) {
                addAdjacencyFor(vertex: vertex, adjacency: adjacency, cost: cost)
            }
        }
    }
    
    /// Finds a path from the origin vertex to the goal vertex. The adjacencies costs are ignored
    /// in the search.
    ///
    /// - Parameters:
    ///   - origin: The start `Vertex` of the path.
    ///   - goal: The final `Vertex` of the path.
    /// - Returns: A sorted array containing the path from the origin to the goal, excluding both ends.
    ///   An empty array is returned if the vertices are equal or the origin is adjacent to the goal. A
    ///   `nil` value is returned if there is no path from the origin to the goal.
    ///
    func findPathIgnoringCosts(from origin: Vertex, to goal: Vertex) -> [Vertex]? {
        guard let _ = graph[origin], let _ = graph[goal] else {
            fatalError("The vertices on findPathIgnoringCosts(from:to:) must exist in the graph")
        }

        var from: [Vertex: Vertex] = [:]
        var visited: Set<Vertex> = [origin]
        var queue: ArraySlice = [origin]
        
        while !queue.isEmpty {
            let vertex = queue.first!
            queue = queue.dropFirst()
            if vertex == goal {
                // Reached the goal vertex, exit early
                var path = [Vertex]()
                var u = vertex
                while let v = from[u], v != origin {
                    path.append(v)
                    u = v
                }
                return path.reversed()
            }
            for (adjacency, _) in adjacenciesOf(vertex: vertex) {
                if visited.contains(adjacency) { continue }
                from[adjacency] = vertex
                visited.insert(adjacency)
                queue.append(adjacency)
            }
        }
        
        // The goal is unreachable from the origin
        return nil
    }
    
    /// Finds a path from the origin vertex to the goal vertex.
    ///
    /// - Note: Costs cannot be negative values.
    ///
    /// - Parameters:
    ///   - origin: The start `Vertex` of the path.
    ///   - goal: The final `Vertex` of the path.
    /// - Returns: A sorted array containing the path from the origin to the goal, excluding both ends.
    ///   An empty array is returned if the vertices are equal or the origin is adjacent to the goal. A nil value
    ///   is returned if there is no path from the origin to the goal.
    ///
    func findPathFrom(_ origin: Vertex, to goal: Vertex) -> [Vertex]? {
        guard let _ = graph[origin], let _ = graph[goal] else {
            fatalError("The vertices on findPathFrom(_:to:) must exist in the graph")
        }
        
        var from: [Vertex: Vertex] = [:]
        var costs: [Vertex: Cost] = [:]
        var keys: [Edge: HeapKey] = [:]
        var done: Set<Vertex> = []
        let queue = Heap<Edge>()
        
        // Set the initial state
        let originEdge = Edge(vertex: origin, cost: 0)
        costs[origin] = 0
        keys[originEdge] = queue.insert(element: originEdge)
        
        // Find the shortest path
        while let (u, _) = queue.extract() {
            if u.vertex == goal {
                // Reached the goal vertex, exit early
                var path = [Vertex]()
                var s = u.vertex
                while let t = from[s], t != origin {
                    path.append(t)
                    s = t
                }
                return path.reversed()
            }
            for v in graph[u.vertex]! where !done.contains(v.vertex) {
                // Calculate the accumulated cost to reach v from u
                let cost = costs[u.vertex]! + v.cost
                // If already in the queue with lower or equal cost, skip
                if keys[v] != nil && costs[v.vertex]! <= cost { continue }
                from[v.vertex] = u.vertex
                costs[v.vertex] = cost
                if let key = keys[v] {
                    // In the queue, update priority
                    queue.decrease(key: key, value: Edge(vertex: v.vertex, cost: cost))
                } else {
                    // Not in the queue, insert
                    keys[v] = queue.insert(element: Edge(vertex: v.vertex, cost: cost))
                }
            }
            // Shortest path to u already found, don't check it anymore
            done.insert(u.vertex)
        }
        
        // The goal is unreachable from the origin
        return nil
    }
    
    /// Finds a path from the origin vertex to the goal vertex. A heuristic function is used, together
    /// with the cost, to determine the priority of a vertex during exploration.
    ///
    /// - Note: Costs cannot be negative values.
    ///
    /// - Parameters:
    ///   - origin: The start `Vertex` of the path.
    ///   - goal: The final `Vertex` of the path.
    ///   - heuristic: The heuristic function to use.
    /// - Returns: A sorted array containing the path from the origin to the goal, excluding both ends.
    ///   An empty array is returned if the vertices are equal or the origin is adjacent to the goal. A nil value
    ///   is returned if there is no path from the origin to the goal.
    ///
    func findPathUsingHeuristic(from origin: Vertex, to goal: Vertex,
                                heuristic: (_ current: Vertex, _ goal: Vertex) -> Cost) -> [Vertex]? {
        
        guard let _ = graph[origin], let _ = graph[goal] else {
            fatalError("The vertices on findPathUsingHeuristic(from:to:heuristic:) must exist in the graph")
        }
        
        var from: [Vertex: Vertex] = [:]
        var costs: [Vertex: Cost] = [:]
        var keys: [Edge: HeapKey] = [:]
        var done: Set<Vertex> = []
        let queue = Heap<Edge>()
        
        // Set the initial state
        let originEdge = Edge(vertex: origin, cost: 0)
        costs[origin] = 0
        keys[originEdge] = queue.insert(element: originEdge)
        
        // Find the shortest path
        while let (u, _) = queue.extract() {
            if u.vertex == goal {
                // Reached the goal vertex, exit early
                var path = [Vertex]()
                var s = u.vertex
                while let t = from[s], t != origin {
                    path.append(t)
                    s = t
                }
                return path.reversed()
            }
            for v in graph[u.vertex]! where !done.contains(v.vertex) {
                // Calculate the accumulated cost to reach v from u
                let cost = costs[u.vertex]! + v.cost
                // If already in the queue with lower or equal cost, skip
                if keys[v] != nil && costs[v.vertex]! <= cost { continue }
                from[v.vertex] = u.vertex
                costs[v.vertex] = cost
                let estimate = heuristic(v.vertex, goal)
                if let key = keys[v] {
                    // In the queue, update priority
                    queue.decrease(key: key, value: Edge(vertex: v.vertex, cost: cost, estimate: estimate))
                } else {
                    // Not in the queue, insert
                    keys[v] = queue.insert(element: Edge(vertex: v.vertex, cost: cost, estimate: estimate))
                }
            }
            // Shortest path to u already found, don't check it anymore
            done.insert(u.vertex)
        }
        
        // The goal is unreachable from the origin
        return nil
    }
    
    /// Creates a minimum spanning tree from the graph's data.
    ///
    /// - Note: This method does not verify the suitableness of the graph (the caller would be
    ///   well advised to do so, though).
    ///
    /// - Parameter root: The `Vertex` to be used as the tree's root.
    /// - Returns: A new graph representing a minimum spanning tree of this graph.
    ///
    func minimumSpanningTree(root: Vertex) -> Graph {
        guard graph[root] != nil else {
            fatalError("The root vertex is not present in the graph")
        }
        
        var from: [Edge: Vertex] = [:]
        var costs: [Vertex: Cost] = [:]
        var keys: [Edge: HeapKey] = [:]
        let tree = Graph()
        let queue = Heap<Edge>()
        
        // Set the initial state
        for edge in graph[root]! {
            from[edge] = root
            costs[edge.vertex] = edge.cost
            keys[edge] = queue.insert(element: edge)
        }
        // A root is a (rather small) tree
        tree.addVertex(root)
        
        // Create the tree
        while let (u, _) = queue.extract() {
            // Edge u is a light edge, add it to the tree
            tree.addAdjacencyFor(vertex: from[u]!, adjacency: u.vertex, cost: u.cost)
            for v in graph[u.vertex]! {
                // If this edge's vertex is already in the tree, skip
                if tree.graph[v.vertex] != nil { continue }
                if let key = keys[v] {
                    // Edge already in the queue, update it if needed
                    if costs[v.vertex]! > v.cost {
                        from[v] = u.vertex
                        costs[v.vertex] = v.cost
                        queue.decrease(key: key, value: v)
                    }
                } else {
                    // Edge not inserted yet, insert it into the queue
                    from[v] = u.vertex
                    costs[v.vertex] = v.cost
                    keys[v] = queue.insert(element: v)
                }
            }
        }
        
        return tree
    }
    
    /// Prints the graph.
    ///
    func printGraph() {
        guard !graph.isEmpty else {
            print("Graph is empty.")
            return
        }
        
        var str = "Graph:\n"
        for (vertex, edges) in graph {
            if edges.isEmpty {
                str += "\(vertex) ->\n"
            } else {
                for edge in edges {
                    str += "\(vertex) -> \(edge.vertex) #\(edge.cost)\n"
                }
            }
        }
        str += "\nTotal vertices: \(totalVertices)\nTotal edges: \(totalEdges)"
        print(str)
    }
}
