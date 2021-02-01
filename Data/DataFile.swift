//
//  DataFile.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that defines the data file, a type suitable for storage on disk.
///
protocol DataFile {
    
    /// The name of the data file.
    ///
    var fileName: String { get }
    
    /// The contents of the data file.
    ///
    var contents: Data { get }
}
