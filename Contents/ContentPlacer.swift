//
//  ContentPlacer.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that places content from a `ContentSet`.
///
/// This content placer will try its best to place the requested contents using one of its
/// placement methods, but since there are many variables involved, it may, in some cases,
/// become impossible to create the content as specified. So, for the best results, the
/// destination areas/positions, and the probabilities of content, should be carefully set.
///
class ContentPlacer {
    
    /// The current `ContentSet` used to place content.
    ///
    var contentSet: ContentSet
    
    /// Creates a new instance with the given content set and optional random source.
    ///
    /// - Parameter contentSet: The `ContentSet` instance to use when creating the content.
    ///
    init(contentSet: ContentSet) {
        self.contentSet = contentSet
    }
    
    /// Places the contents from this placer's `ContentSet` for the given `RoomArea`, inserting
    /// the content nodes as children of the given node. A `ContentProbability` defines how the
    /// content is created.
    ///
    /// - Parameters:
    ///   - area: The `RoomArea` to place the contents for.
    ///   - probability: The `ContentProbability` to use.
    ///   - node: The node into which the content nodes should be appended.
    /// - Returns: An array with the created contents.
    ///
    func placeContents(forArea area: RoomArea, using probability: ContentProbability,
                       onNode node: SKNode) -> [Content] {
        
        // A closure that tries to place a type of content using a rect filler
        let placeContent = { [unowned self] (type: ContentType, filler: RectRandomFiller) -> Content? in
            guard let content = self.contentSet.makeContent(ofType: type) else { return nil }
            
            let contentSize = content.size
            let cellSize = self.contentSet.cellSize
            let width = max(Int((contentSize.width / cellSize.width).rounded(.up)), 1)
            let height = max(Int((contentSize.height / cellSize.height).rounded(.up)), 1)
            
            var position: CGPoint?
            switch probability.rules[type]!.placementRule {
            case .corner: position = filler.fillCorner(width: width, height: height)
            case .edge:   position = filler.fillEdge(width: width, height: height)
            case .middle: position = filler.fillMiddle(width: width, height: height)
            case .any:    position = filler.fillAny(width: width, height: height)
            }
            if let position = position {
                let x = position.x * cellSize.width + (CGFloat(width) * cellSize.width) / 2.0
                let y = position.y * cellSize.height + (CGFloat(height) * cellSize.height) / 2.0
                content.position = CGPoint(x: x, y: y)
                node.addChild(content.node)
                return content
            }
            return nil
        }
        
        // A closure that creates a WeightedDistribution instance from an array of ContentType
        let createDistribution = { (types: [ContentType]) -> WeightedDistribution<ContentType> in
            var values: [(value: ContentType, weight: Double)] = []
            for type in types {
                if let weight = probability.weights[type] {
                    values.append((type, weight))
                }
            }
            return WeightedDistribution(values: values)
        }
        
        // A flag stating if there are any corridors in this area
        let noCorridors = (area.northCorridorArea == nil) && (area.southCorridorArea == nil)
            && (area.eastCorridorArea == nil) && (area.westCorridorArea == nil)
        
        // The contents to return
        var contents = [Content]()
        
        // Start by splitting the rules based on what must be created and where
        var roomEnsured = [ContentType]()
        var roomPossible = Set<ContentType>()
        var corridorEnsured = [ContentType]()
        var corridorPossible = Set<ContentType>()
        
        if noCorridors {
            for (type, rule) in probability.rules {
                switch rule.creationRule {
                case .noMoreThanOnce, .any:
                    switch rule.localizationRule {
                    case .mainRoom, .any: roomPossible.update(with: type)
                    default: break
                    }
                case .exactlyOnce:
                    switch rule.localizationRule {
                    case .mainRoom, .any: roomEnsured.append(type)
                    default: break
                    }
                case .atLeastOnce:
                    switch rule.localizationRule {
                    case .mainRoom, .any:
                        roomEnsured.append(type)
                        roomPossible.update(with: type)
                    default: break
                    }
                }
            }
        } else {
            for (type, rule) in probability.rules {
                switch rule.creationRule {
                case .noMoreThanOnce:
                    switch rule.localizationRule {
                    case .mainRoom: roomPossible.update(with: type)
                    case .corridor: corridorPossible.update(with: type)
                    case .any:
                        roomPossible.update(with: type)
                        corridorPossible.update(with: type)
                    }
                case .exactlyOnce:
                    switch rule.localizationRule {
                    case .mainRoom: roomEnsured.append(type)
                    case .corridor: corridorEnsured.append(type)
                    case .any: Bool.random() ? roomEnsured.append(type) : corridorEnsured.append(type)
                    }
                case .atLeastOnce:
                    switch rule.localizationRule {
                    case .mainRoom:
                        roomEnsured.append(type)
                        roomPossible.update(with: type)
                    case .corridor:
                        corridorEnsured.append(type)
                        corridorPossible.update(with: type)
                    case .any:
                        Bool.random() ? roomEnsured.append(type) : corridorEnsured.append(type)
                        roomPossible.update(with: type)
                        corridorPossible.update(with: type)
                    }
                case .any:
                    switch rule.localizationRule {
                    case .mainRoom: roomPossible.update(with: type)
                    case .corridor: corridorPossible.update(with: type)
                    case .any:
                        roomPossible.update(with: type)
                        corridorPossible.update(with: type)
                    }
                }
            }
        }
        
        // Create rect fillers for each area rect
        var roomFiller: RectRandomFiller
        var roomOpenings = Set<RectOpening>()
        var corridorFillers = [RectRandomFiller]()
        
        if !noCorridors {
            // Add openings to main room and corridors when applicable
            if let northArea = area.northCorridorArea {
                let x = Int(northArea.minX/*.rounded(.up)*/)
                let length = Int(northArea.width/* - abs(northArea.minX - northArea.minX.rounded(.towardZero))*/)
                roomOpenings.update(with: .north(x: x, length: length))
                let corridorOpenings: Set<RectOpening> = [.north(x: x, length: length), .south(x: x, length: length)]
                corridorFillers.append(RectRandomFiller(rect: northArea, openings: corridorOpenings))
            }
            if let southArea = area.southCorridorArea {
                let x = Int(southArea.minX/*.rounded(.up)*/)
                let length = Int(southArea.width/* - abs(southArea.minX - southArea.minX.rounded(.towardZero))*/)
                roomOpenings.update(with: .south(x: x, length: length))
                let corridorOpenings: Set<RectOpening> = [.north(x: x, length: length), .south(x: x, length: length)]
                corridorFillers.append(RectRandomFiller(rect: southArea, openings: corridorOpenings))
            }
            if let eastArea = area.eastCorridorArea {
                let y = Int(eastArea.minY/*.rounded(.up)*/)
                let length = Int(eastArea.height/* - abs(eastArea.minY - eastArea.minY.rounded(.towardZero))*/)
                roomOpenings.update(with: .east(y: y, length: length))
                let corridorOpenings: Set<RectOpening> = [.east(y: y, length: length), .west(y: y, length: length)]
                corridorFillers.append(RectRandomFiller(rect: eastArea, openings: corridorOpenings))
            }
            if let westArea = area.westCorridorArea {
                let y = Int(westArea.minY/*.rounded(.up)*/)
                let length = Int(westArea.height/* - abs(westArea.minY - westArea.minY.rounded(.towardZero))*/)
                roomOpenings.update(with: .west(y: y, length: length))
                let corridorOpenings: Set<RectOpening> = [.east(y: y, length: length), .west(y: y, length: length)]
                corridorFillers.append(RectRandomFiller(rect: westArea, openings: corridorOpenings))
            }
        }
        
        roomFiller = RectRandomFiller(rect: area.roomArea, openings: roomOpenings)
        
        // With the fillers set, the content can now be placed - start with the ensured content
        for type in roomEnsured {
            if let content = placeContent(type, roomFiller) {
                contents.append(content)
            }
        }
        
        for type in corridorEnsured {
            let index = Int.random(in: 0..<corridorFillers.count)
            var i = index
            for _ in 1...corridorFillers.count {
                if let content = placeContent(type, corridorFillers[i]) {
                    contents.append(content)
                    break
                }
                i = (i + 1) % corridorFillers.count
            }
        }
        
        // The ensured content was placed, now WeightedDistribution instances will be used to fill the areas
        // up to their specified densities with random content
        if (!roomPossible.isEmpty) && (roomFiller.filled < probability.roomDensity.upperBound) {
            var distr = createDistribution(Array(roomPossible))
            let rnd = Double.random(in: 0...1.0)
            let offset = (probability.roomDensity.upperBound - probability.roomDensity.lowerBound) * rnd
            let density = min(probability.roomDensity.lowerBound + offset, 1.0)
            let tries = 1 + Int(Double(roomFiller.area) * density)
            
            for _ in 1...tries {
                let type = distr.nextValue()
                if let content = placeContent(type, roomFiller) {
                    contents.append(content)
                    if probability.rules[type]!.creationRule == .noMoreThanOnce {
                        // This content type cannot be generated again
                        corridorPossible.remove(type)
                        roomPossible.remove(type)
                        distr = createDistribution(Array(roomPossible))
                    }
                }
                if roomFiller.filled >= density { break }
            }
        }
        
        if !corridorPossible.isEmpty {
            var distr = createDistribution(Array(corridorPossible))
            for filler in corridorFillers {
                if filler.filled >= probability.corridorDensity.upperBound { continue }
                let rnd = Double.random(in: 0...1.0)
                let offset = (probability.corridorDensity.upperBound - probability.corridorDensity.lowerBound) * rnd
                let density = min(probability.corridorDensity.lowerBound + offset, 1.0)
                let tries = 1 + Int(Double(filler.area) * density)
                
                for _ in 1...tries {
                    let type = distr.nextValue()
                    if let content = placeContent(type, filler) {
                        contents.append(content)
                        if probability.rules[type]!.creationRule == .noMoreThanOnce {
                            // This content type cannot be generated again
                            corridorPossible.remove(type)
                            distr = createDistribution(Array(corridorPossible))
                        }
                    }
                    if filler.filled >= density { break }
                }
            }
        }
        
        return contents
    }
    
    /// Places the specific content from this placer's `ContentSet` at the given position,
    /// inserting the content node as child of the given node and returning the created content.
    ///
    /// - Parameters:
    ///   - type: The type of the content to place.
    ///   - position: The position to place the content at.
    ///   - node: The node into which the content node should be appended.
    /// - Returns: The created content, or `nil` if content of the given type could not be created.
    ///
    func placeSpecificContent(ofType type: ContentType, at position: CGPoint, onNode node: SKNode) -> Content? {
        if let content = contentSet.makeContent(ofType: type) {
            content.position = position
            node.addChild(content.node)
            return content
        }
        return nil
    }
}

/// A helper enum that represents the openings of a rect.
///
fileprivate enum RectOpening: Hashable {
    
    case north(x: Int, length: Int)
    case south(x: Int, length: Int)
    case east(y: Int, length: Int)
    case west(y: Int, length: Int)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .north: 0.hash(into: &hasher)
        case .south: 1.hash(into: &hasher)
        case .east: 2.hash(into: &hasher)
        case .west: 3.hash(into: &hasher)
        }
    }
    
    static func == (lhs: RectOpening, rhs: RectOpening) -> Bool {
        switch lhs {
        case .north:
            switch rhs {
            case .north: return true
            default : return false
            }
        case .south:
            switch rhs {
            case .south: return true
            default : return false
            }
        case .east:
            switch rhs {
            case .east: return true
            default : return false
            }
        case .west:
            switch rhs {
            case .west: return true
            default : return false
            }
        }
    }
}

/// A helper class to control the random filling of an integral rect.
///
fileprivate class RectRandomFiller {
    
    /// The rect.
    ///
    private let rect: CGRect
    
    /// The rect openings.
    ///
    private let openings: Set<RectOpening>
    
    /// The view of the rect, stating if a given unitary position has been filled or not.
    ///
    private var rectView: [Bool]
    
    /// The current amount of units filled in the rect view.
    ///
    private var unitsFilled = 0
    
    /// The total area of the rect being filled.
    ///
    let area: Int
    
    /// The amount of area filled (between 0.0 and 1.0).
    ///
    var filled: Double {
        return Double(unitsFilled) / Double(area)
    }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - rect: The rect to fill.
    ///   - openings: The openings to avoid.
    ///
    init(rect: CGRect, openings: Set<RectOpening>) {
        self.area = Int(rect.width) * Int(rect.height)
        
        guard area > 0 else {
            fatalError("Rect does not have enough area")
        }
        
        self.rect = rect
        self.openings = openings
        self.rectView = [Bool](repeating: false, count: area)
    }
    
    /// Checks if the given subrect is empty.
    ///
    /// - Note: This method does not verify if the given subrect is valid.
    ///
    /// - Parameters:
    ///   - x: The x coordinate of the origin.
    ///   - y: The y coordinate of the origin.
    ///   - width: The width of the subrect.
    ///   - height: The height of the subrect.
    /// - Returns: `true` if all positions inside the given bounds are available for filling, `false` otherwise.
    ///
    private func isSubrectEmpty(x: Int, y: Int, width: Int, height: Int) -> Bool {
        for i in x..<(x + width) {
            for j in y..<(y + height) {
                let index = j * Int(rect.width) + i
                if rectView[index] {
                    return false
                }
            }
        }
        return true
    }
    
    /// Fills the given subrect.
    ///
    /// - Note: This method does not verify if the given subrect is valid nor if the positions are already filled.
    ///
    /// - Parameters:
    ///   - x: The x coordinate of the origin.
    ///   - y: The y coordinate of the origin.
    ///   - width: The width of the subrect.
    ///   - height: The height of the subrect.
    ///
    private func fillSubrect(x: Int, y: Int, width: Int, height: Int) {
        for i in x..<(x + width) {
            for j in y..<(y + height) {
                let index = j * Int(rect.width) + i
                rectView[index] = true
                unitsFilled += 1
            }
        }
    }
    
    /// Tries to fill any space of the rect, including the ones adjacent to openings.
    ///
    /// - Parameters:
    ///   - width: The width of the subrect to fill.
    ///   - height: The height of the subrect to fill.
    /// - Returns: The origin of the filled subrect, or `nil` if no space could be filled.
    ///
    func fillAny(width: Int, height: Int) -> CGPoint? {
        guard unitsFilled < rectView.count else { return nil }
        guard width <= Int(rect.width) && height <= Int(rect.height) else { return nil }
        
        // The maximum x and y
        let maxX = Int(rect.width) - width
        let maxY = Int(rect.height) - height
        
        // First, try random positions
        let tries = 1 + Int(Double(area - width * height) * filled * 1.33)
        for _ in 1...tries {
            let x = Int.random(in: 0...maxX)
            let y = Int.random(in: 0...maxY)
            
            if isSubrectEmpty(x: x, y: y, width: width, height: height) {
                fillSubrect(x: x, y: y, width: width, height: height)
                return CGPoint(x: rect.origin.x + CGFloat(x), y: rect.origin.y + CGFloat(y))
            }
        }
        
        // Random trying did not work, try all available positions
        for x in 0...maxX {
            for y in 0...maxY {
                if isSubrectEmpty(x: x, y: y, width: width, height: height) {
                    fillSubrect(x: x, y: y, width: width, height: height)
                    return CGPoint(x: rect.origin.x + CGFloat(x), y: rect.origin.y + CGFloat(y))
                }
            }
        }
        
        return nil
    }
    
    /// Tries to fill space in one of the four corners of the rect.
    ///
    /// A rect may have less than four corners available when openings are adjacent to it.
    /// This method will not fill positions adjacent to openings.
    ///
    /// - Parameters:
    ///   - width: The width of the subrect to fill.
    ///   - height: The height of the subrect to fill.
    /// - Returns: The origin of the filled subrect, or `nil` if no space could be filled.
    ///
    func fillCorner(width: Int, height: Int) -> CGPoint? {
        guard unitsFilled < rectView.count else { return nil }
        guard width <= Int(rect.width) && height <= Int(rect.height) else { return nil }
        
        // A closure that tries to fill the bottom left corner
        let tryBottomLeft = { [unowned self] () -> CGPoint? in
            if self.isSubrectEmpty(x: 0, y: 0, width: width, height: height) {
                // The space is available, now check if there are any openings in the way
                for opening in self.openings {
                    switch opening {
                    case .north(let x, _):
                        if height == Int(self.rect.height) {
                            if (Int(self.rect.minX) + width - 1) >= x { return nil }
                        }
                    case .south(let x, _):
                        if (Int(self.rect.minX) + width - 1) >= x { return nil }
                    case .east(let y, _):
                        if width == Int(self.rect.width) {
                            if (Int(self.rect.minY) + height - 1) >= y { return nil }
                        }
                    case .west(let y, _):
                        if (Int(self.rect.minY) + height - 1) >= y { return nil }
                    }
                }
                // No openings in the way, fill the corner
                self.fillSubrect(x: 0, y: 0, width: width, height: height)
                return self.rect.origin
            }
            return nil
        }
        
        // A closure that tries to fill the bottom right corner
        let tryBottomRight = { [unowned self] () -> CGPoint? in
            let origin: (x: Int, y: Int) = (Int(self.rect.width) - width, 0)
            if self.isSubrectEmpty(x: origin.x, y: origin.y, width: width, height: height) {
                // The space is available, now check if there are any openings in the way
                for opening in self.openings {
                    switch opening {
                    case .north(let x, let length):
                        if height == Int(self.rect.height) {
                            if Int(self.rect.minX) + origin.x <= (x + length - 1) { return nil }
                        }
                    case .south(let x, let length):
                        if Int(self.rect.minX) + origin.x <= (x + length - 1) { return nil }
                    case .east(let y, _):
                        if Int(self.rect.minY) + origin.y >= y { return nil }
                    case .west(let y, _):
                        if width == Int(self.rect.width) {
                            if Int(self.rect.minY) + origin.y >= y { return nil }
                        }
                    }
                }
                // No openings in the way, fill the corner
                self.fillSubrect(x: origin.x, y: origin.y, width: width, height: height)
                return CGPoint(x: self.rect.origin.x + CGFloat(origin.x), y: self.rect.origin.y + CGFloat(origin.y))
            }
            return nil
        }
        
        // A closure that tries to fill the top right corner
        let tryTopRight = { [unowned self] () -> CGPoint? in
            let origin: (x: Int, y: Int) = (Int(self.rect.width) - width, Int(self.rect.height) - height)
            if self.isSubrectEmpty(x: origin.x, y: origin.y, width: width, height: height) {
                // The space is available, now check if there are any openings in the way
                for opening in self.openings {
                    switch opening {
                    case .north(let x, let length):
                        if Int(self.rect.minX) + origin.x <= (x + length - 1) { return nil }
                    case .south(let x, let length):
                        if height == Int(self.rect.height) {
                            if Int(self.rect.minX) + origin.x <= (x + length - 1) { return nil }
                        }
                    case .east(let y, let length):
                        if Int(self.rect.minY) + origin.y <= (y + length - 1) { return nil }
                    case .west(let y, let length):
                        if width == Int(self.rect.width) {
                            if Int(self.rect.minY) + origin.y <= (y + length - 1) { return nil }
                        }
                    }
                }
                // No openings in the way, fill the corner
                self.fillSubrect(x: origin.x, y: origin.y, width: width, height: height)
                return CGPoint(x: self.rect.origin.x + CGFloat(origin.x), y: self.rect.origin.y + CGFloat(origin.y))
            }
            return nil
        }
        
        // A closure that tries to fill the top left corner
        let tryTopLeft = { [unowned self] () -> CGPoint? in
            let origin: (x: Int, y: Int) = (0, Int(self.rect.height) - height)
            if self.isSubrectEmpty(x: origin.x, y: origin.y, width: width, height: height) {
                // The space is available, now check if there are any openings in the way
                for opening in self.openings {
                    switch opening {
                    case .north(let x, _):
                        if (Int(self.rect.minX) + origin.x + width - 1) >= x { return nil }
                    case .south(let x, _):
                        if height == Int(self.rect.height) {
                            if (Int(self.rect.minX) + origin.x + width - 1) >= x { return nil }
                        }
                    case .east(let y, let length):
                        if width == Int(self.rect.width) {
                            if Int(self.rect.minY) + origin.y <= (y + length - 1) { return nil }
                        }
                    case .west(let y, let length):
                        if Int(self.rect.minY) + origin.y <= (y + length - 1) { return nil }
                    }
                }
                // No openings in the way, fill the corner
                self.fillSubrect(x: origin.x, y: origin.y, width: width, height: height)
                return CGPoint(x: self.rect.origin.x + CGFloat(origin.x), y: self.rect.origin.y + CGFloat(origin.y))
            }
            return nil
        }
        
        // Try every corner in counter-clockwise order, randomly selecting which one to start
        let cornerFillers = [tryBottomLeft, tryBottomRight, tryTopRight, tryTopLeft]
        let start = Int.random(in: 0..<cornerFillers.count)
        var i = start
        for _ in 1...cornerFillers.count {
            if let position = cornerFillers[i]() { return position }
            i = (i + 1) % cornerFillers.count
        }
        
        return nil
    }
    
    /// Tries to fill space along the edges of the rect.
    ///
    /// Edges are any positions located in the rect boundaries.
    /// This method will not fill positions adjacent to openings.
    ///
    /// - Parameters:
    ///   - width: The width of the subrect to fill.
    ///   - height: The height of the subrect to fill.
    /// - Returns: The origin of the filled subrect, or `nil` if no space could be filled.
    ///
    func fillEdge(width: Int, height: Int) -> CGPoint? {
        guard unitsFilled < rectView.count else { return nil }
        guard width <= Int(rect.width) && height <= Int(rect.height) else { return nil }
        
        // The maximum x and y positions
        let maxX = Int(rect.width) - width
        let maxY = Int(rect.height) - height
        
        // A closure that tries to fill edge positions along the horizontal axis
        let tryHorizontalEdge = { [unowned self] (x: Int, fixedY: Int) -> CGPoint? in
            // The y coordinate will define if this refers to the bottom or top edges
            assert(fixedY == 0 || fixedY == maxY)
            let y = fixedY
            if self.isSubrectEmpty(x: x, y: y, width: width, height: height) {
                // Found space along the bottom or top edges, check openings
                let firstX = Int(self.rect.minX) + x
                let lastX = Int(self.rect.minX) + x + width - 1
                for opening in self.openings {
                    switch opening {
                    case .north(let a, let length):
                        if (y == maxY) || (height == Int(self.rect.height)) {
                            let lastA = a + length - 1
                            if (firstX >= a && firstX <= lastA) || (lastX >= a && lastX <= lastA) { return nil }
                        }
                    case .south(let a, let length):
                        if y == 0 {
                            let lastA = a + length - 1
                            if (firstX >= a && firstX <= lastA) || (lastX >= a && lastX <= lastA) { return nil }
                        }
                    case .east(let b, let length):
                        if x == maxX {
                            if y == 0 {
                                if (Int(self.rect.minY) + height - 1) >= b { return nil }
                            } else {
                                if (Int(self.rect.minY) + maxY) <= (b + length - 1) { return nil }
                            }
                        }
                    case .west(let b, let length):
                        if x == 0 {
                            if y == 0 {
                                if (Int(self.rect.minY) + height - 1) >= b { return nil }
                            } else {
                                if (Int(self.rect.minY) + maxY) <= (b + length - 1) { return nil }
                            }
                        }
                    }
                }
                // No adjacent openings, fill the edge space
                self.fillSubrect(x: x, y: y, width: width, height: height)
                return CGPoint(x: self.rect.origin.x + CGFloat(x), y: self.rect.origin.y + CGFloat(y))
            }
            return nil
        }
        
        // A closure that tries to fill edge positions along the vertical axis
        let TryVerticalEdge = { [unowned self] (fixedX: Int, y: Int) -> CGPoint? in
            // The x coordinate will define if this refers to the left or right edges
            assert(fixedX == 0 || fixedX == maxX)
            let x = fixedX
            if self.isSubrectEmpty(x: x, y: y, width: width, height: height) {
                // Found space along the left or right edges, check openings
                let firstY = Int(self.rect.minY) + y
                let lastY = Int(self.rect.minY) + y + height - 1
                for opening in self.openings {
                    switch opening {
                    case .north(let a, let length):
                        if y == maxY {
                            if x == 0 {
                                if (Int(self.rect.minX) + width - 1) >= a { return nil }
                            } else {
                                if (Int(self.rect.minX) + maxX) <= (a + length - 1) { return nil }
                            }
                        }
                    case .south(let a, let length):
                        if y == 0 {
                            if x == 0 {
                                if (Int(self.rect.minX) + width - 1) >= a { return nil }
                            } else {
                                if (Int(self.rect.minX) + maxX) <= (a + length - 1) { return nil }
                            }
                        }
                    case .east(let b, let length):
                        if (x == maxX) || (width == Int(self.rect.width)) {
                            let lastB = b + length - 1
                            if (firstY >= b && firstY <= lastB) || (lastY >= b && lastY <= lastB) { return nil }
                        }
                    case .west(let b, let length):
                        if x == 0 {
                            let lastB = b + length - 1
                            if (firstY >= b && firstY <= lastB) || (lastY >= b && lastY <= lastB) { return nil }
                        }
                    }
                }
                // No adjacent openings, fill the edge space
                self.fillSubrect(x: x, y: y, width: width, height: height)
                return CGPoint(x: self.rect.origin.x + CGFloat(x), y: self.rect.origin.y + CGFloat(y))
            }
            return nil
        }
        
        // First, try random positions
        let tries = 1 + Int(Double(area - width * height) * filled * 1.33)
        for _ in 1...tries {
            let randomEdge = Int.random(in: 0..<4)
            switch randomEdge {
            case 0, 1:
                // Set the y coordinate as the bottom or top edges and try a random x
                let y = randomEdge == 0 ? 0 : maxY
                let x = Int.random(in: 0...maxX)
                if let position = tryHorizontalEdge(x, y) { return position }
            case 2, 3:
                // Set the x coordinate as the left or right edges and try a random y
                let x = randomEdge == 2 ? 0 : maxX
                let y = Int.random(in: 0...maxY)
                if let position = TryVerticalEdge(x, y) { return position }
            default:
                break
            }
        }
        
        // Random trying did not work, try all available positions along the edges
        let bottomFiller =  { () -> CGPoint? in
            for x in 0...maxX {
                if let position = tryHorizontalEdge(x, 0) { return position }
            }
            return nil
        }
        let topFiller = { () -> CGPoint? in
            for x in 0...maxX {
                if let position = tryHorizontalEdge(x, maxY) { return position }
            }
            return nil
        }
        let leftFiller = { () -> CGPoint? in
            for y in 0...maxY {
                if let position = TryVerticalEdge(0, y) { return position }
            }
            return nil
        }
        let rightFiller = { () -> CGPoint? in
            for y in 0...maxY {
                if let position = TryVerticalEdge(maxX, y) { return position }
            }
            return nil
        }
        
        let edgeFillers = [bottomFiller, topFiller, leftFiller, rightFiller]
        let start = Int.random(in: 0..<edgeFillers.count)
        var i = start
        for _ in 1...edgeFillers.count {
            if let position = edgeFillers[i]() { return position }
            i = (i + 1) % edgeFillers.count
        }
        
        return nil
    }
    
    /// Tries to fill space in the middle of the rect.
    ///
    /// A middle position is any position not adjacent to the rect boundaries. So, a rect must have
    /// both dimensions higher than two to actually have any middle positions.
    ///
    /// - Parameters:
    ///   - width: The width of the subrect to fill.
    ///   - height: The height of the subrect to fill.
    /// - Returns: The origin of the filled subrect, or `nil` if no space could be filled.
    ///
    func fillMiddle(width: Int, height: Int) -> CGPoint? {
        assert(width > 0 && height > 0)
        
        guard unitsFilled < rectView.count else { return nil }
        guard (width + 2) <= Int(rect.width) && (height + 2) <= Int(rect.height) else { return nil }
        
        // The maximum x and y to offset from the origin without hitting any edges
        // Note that, in this case, the origin is considered to be at (1, 1) rather than (0, 0)
        let maxXOffset = Int(rect.width) - width - 2
        let maxYOffset = Int(rect.height) - height - 2
        
        // First, try random positions
        let tries = 1 + Int(Double(area - width * height) * filled * 1.33)
        for _ in 1...tries {
            let x = 1 + Int.random(in: 0...maxXOffset)
            let y = 1 + Int.random(in: 0...maxYOffset)
            
            if isSubrectEmpty(x: x, y: y, width: width, height: height) {
                fillSubrect(x: x, y: y, width: width, height: height)
                return CGPoint(x: rect.origin.x + CGFloat(x), y: rect.origin.y + CGFloat(y))
            }
        }
        
        // Random trying did not work, try all available positions
        for x in 1...(1 + maxXOffset) {
            for y in 1...(1 + maxYOffset) {
                if isSubrectEmpty(x: x, y: y, width: width, height: height) {
                    fillSubrect(x: x, y: y, width: width, height: height)
                    return CGPoint(x: rect.origin.x + CGFloat(x), y: rect.origin.y + CGFloat(y))
                }
            }
        }
        
        return nil
    }
}
