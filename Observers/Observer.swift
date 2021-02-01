//
//  Observer.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/4/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that defines a basic observer.
///
protocol Observer: AnyObject {
    
    /// A method to be called by an observable to notify the observer that
    /// change(s) did occur.
    ///
    /// - Note: To be notified of changes on a given observable, the observer
    ///   must first register itself on the observable of interest.
    ///
    func didChange(observable: Observable)
    
    /// Removes itself from all observables it was registered on.
    ///
    /// - Note: This method must always succeed.
    ///
    func removeFromAllObservables()
}
