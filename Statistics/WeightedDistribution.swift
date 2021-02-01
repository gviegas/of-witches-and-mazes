//
//  WeightedDistribution.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/26/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A generic class that represents a weighted random distribution.
///
/// This distribution randomly generates values of a type `T`, where the probability of
/// a given value being chosen is given by its weight relative to others'.
///
class WeightedDistribution<T> {

    /// The distribution.
    ///
    private var distr: [(range: Range<Double>, value: T)]
    
    /// The values that the distribution can generate.
    ///
    var values: [T] {
        return distr.map { $0.value }
    }
    
    /// Creates a new instance from the given (`T`, `Double`) pairs.
    ///
    /// - Parameter values: An array of (`T`, `Double`) pairs associating a type with its weight.
    ///
    init(values: [(value: T, weight: Double)]) {
        assert(!values.isEmpty)
        
        distr = []
        distr.reserveCapacity(values.count)
        
        // Sum the weights
        let total = values.reduce(0.0) { a, v in
            assert(v.weight > 0)
            return a + v.weight
        }
        
        // Create a probability range for each value
        var upperBound = 0.0
        for value in values {
            let lowerBound = upperBound
            upperBound = lowerBound + value.weight / total
            distr.append((range: lowerBound..<upperBound, value: value.value))
        }
    }
    
    /// Generates a random value from this distribution.
    ///
    /// - Returns: A random value.
    ///
    func nextValue() -> T {
        let rnd = Double.random(in: 0...1.0)
        
        var min = 0
        var max = distr.count - 1
        var mid = (min + max) / 2
        
        repeat {
            if distr[mid].range.contains(rnd) { break }
            if distr[mid].range.lowerBound > rnd {
                max = mid - 1
            } else {
                min = mid + 1
            }
            mid = (min + max) / 2
        } while min < max
        
        return distr[mid].value
    }
}
