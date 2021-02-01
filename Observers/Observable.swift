//
//  Observable.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/4/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that defines a basic observable.
///
protocol Observable: AnyObject {
    
    /// Registers an observer.
    ///
    /// - Note: This method must always succeed.
    ///
    /// - Parameter observer: The `Observer` to register.
    ///
    func register(observer: Observer)
    
    /// Removes an observer.
    ///
    /// - Note: This method must always succeed.
    ///
    /// - Parameter observer: The `Observer` to remove.
    ///
    func remove(observer: Observer)
    
    /// Notifies all observers.
    ///
    func broadcast()
}
