//
//  Version.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A struct that provides version information.
///
struct Version {
    
    private init() {}
    
    /// The current version of the build.
    ///
    static var current: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
    
    /// The release/version number of the bundle.
    ///
    static var release: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
}
