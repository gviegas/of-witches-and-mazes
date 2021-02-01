//
//  Heap.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/26/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An alias defining a key that uniquely identifies an element of the Heap.
///
typealias HeapKey = Int

/// A generic class that represents a heap of minimum.
///
class Heap<T: Comparable> {
    
    /// A struct defining a node in the Heap.
    ///
    private struct HeapNode<T>: Hashable {
        
        /// The element.
        ///
        var element: T
        
        /// The `HeapKey` associated with the element.
        ///
        let heapKey: HeapKey
        
        func hash(into hasher: inout Hasher) {
            heapKey.hash(into: &hasher)
        }
        
        static func ==(lhs: HeapNode, rhs: HeapNode) -> Bool {
            return lhs.heapKey == rhs.heapKey
        }
    }
    
    /// The heap array.
    ///
    private var heap: [HeapNode<T>?] = [nil]
    
    /// The index map.
    ///
    private var indices: [HeapKey: Int] = [:]

    /// The freed nodes, for key reuse.
    ///
    private var freed: [HeapKey] = []
    
    /// The last key generated.
    ///
    private var lastKey: HeapKey = Int.min
    
    /// The next HeapKey to use.
    ///
    private var nextKey: HeapKey {
        if let availableKey = freed.popLast() {
            return availableKey
        }
        lastKey += 1
        return lastKey
    }
    
    /// Swap indices mapped in the indices dictionary.
    ///
    /// - Parameters:
    ///   - key1: The first key.
    ///   - key2: The second key.
    ///
    private func swap(key1: HeapKey, key2: HeapKey) {
        guard let a = indices[key1], let b = indices[key2] else { return }
        indices[key1] = b
        indices[key2] = a
    }
    
    /// Given an index, retrieves its parent's index.
    ///
    /// - Parameter index: The index of a node in the heap.
    /// - Returns: The parent's index, or `nil` if it has no parent or `index` is invalid.
    ///
    private func parent(index: Int) -> Int? {
        let p = index >> 1
        if p > 0 && p < heap.endIndex { return p }
        return nil
    }
    
    /// Given an index, retrieves its left node's index.
    ///
    /// - Parameter index: The index of a node in the heap.
    /// - Returns: The left node's index, or `nil` if it has no left node or `index` is invalid.
    ///
    private func left(index: Int) -> Int? {
        let l = index << 1
        if l > 0 && l < heap.endIndex { return l }
        return nil
    }
    
    /// Given an index, retrieves its right node's index.
    ///
    /// - Parameter index: The index of a node in the heap.
    /// - Returns: The right node's index, or `nil` if it has no right node or `index` is invalid.
    ///
    private func right(index: Int) -> Int? {
        let r = (index << 1) + 1
        if r > 0 && r < heap.endIndex { return r }
        return nil
    }
    
    /// Makes the subtree at the given index a heap of minimum.
    ///
    /// - Parameter index: The index of a node in the heap.
    ///
    private func heapify(index: Int) {
        guard index > 0 && index < heap.endIndex else { return }
        
        var min = index
        if let l = left(index: index) {
            if heap[l]!.element < heap[min]!.element { min = l }
        }
        if let r = right(index: index) {
            if heap[r]!.element < heap[min]!.element { min = r }
        }
        if min != index {
            swap(key1: heap[index]!.heapKey, key2: heap[min]!.heapKey)
            heap.swapAt(index, min)
            heapify(index: min)
        }
    }
    
    /// Makes the whole tree a heap of minimum.
    ///
    private func build() {
        guard heap.count > 2 else { return }
        
        for i in stride(from: (heap.count - 1) >> 1, to: 0, by: -1) {
            heapify(index: i)
        }
    }
    
    /// Retrieves, but does not extracts, the minimum element of the heap.
    ///
    /// - Returns: A tuple consisting of the minimum element and its `HeapKey`, without extracting it,
    ///   or `nil` if the heap is empty.
    ///
    func minimum() -> (T, HeapKey)? {
        guard heap.count > 1 else { return nil }
        return (heap[1]!.element, heap[1]!.heapKey)
    }
    
    /// Decreases the element, identified by the provided `HeapKey`, to the given new value.
    ///
    /// - Parameters:
    ///   - key: The `HeapKey` that identifies the element to decrease.
    ///   - value: The new value, which must be less or equal the old value.
    ///
    func decrease(key: HeapKey, value: T) {
        guard var index = indices[key], heap[index]!.element >= value else { return }
        
        heap[index]!.element = value
        while let parent = parent(index: index), heap[parent]!.element > heap[index]!.element {
            swap(key1: heap[parent]!.heapKey, key2: heap[index]!.heapKey)
            heap.swapAt(parent, index)
            index = parent
        }
    }
    
    /// Inserts the given element in the heap.
    ///
    /// - Note: The caller must keep track of the keys returned by this method if calls to decrease(key:value)
    /// will be made, as there is no other way to identify an element of the heap but by its HeapKey.
    ///
    /// - Parameter element: The element to insert.
    /// - Returns: The element's unique `HeapKey`.
    ///
    func insert(element: T) -> HeapKey {
        let node = HeapNode(element: element, heapKey: nextKey)
        heap.append(node)
        indices[node.heapKey] = heap.endIndex - 1
        decrease(key: node.heapKey, value: node.element)
        return node.heapKey
    }
    
    /// Extracts the minimum element.
    ///
    /// - Note: The HeapKey returned by this method should be considered invalid and must not be used again to
    /// reference the same element. After being returned by extract(), the key could reference no element at all,
    /// or even worse, a different element altogether.
    ///
    /// - Returns: A tuple consisting of the extracted value and its `HeapKey`, or `nil` if the heap is empty.
    ///
    func extract() -> (T, HeapKey)? {
        guard heap.count > 1 else { return nil }
        
        let first = heap[1]
        let last = heap.popLast()!
        if heap.count > 1 {
            heap[1] = last
            indices[last!.heapKey] = 1
            heapify(index: 1)
        }
        freed.append(first!.heapKey)
        return (first!.element, first!.heapKey)
    }
}
