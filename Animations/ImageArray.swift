//
//  ImageArray.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/5/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A struct that creates arrays of image names representing a sequence of frames.
///
struct ImageArray {
    
    private init() {}
    
    /// Creates an array of image names.
    ///
    /// This function will work on a sequence of images named as follows:
    ///
    ///     "Image_Name_Goes_Here_[FRAME_NUMBER]"
    ///
    /// Where [FRAME_NUMBER] refers to the index of the frame in the animation.
    ///
    /// - Tip: When `first < last`, the sequence will be created backwards.
    ///
    /// - Parameters:
    ///   - baseName: The base name of the image.
    ///   - first: The first frame number.
    ///   - last: The last frame number.
    ///   - reversing: A flag stating whether or not the sequence should be reversed after
    ///     reaching the `last` frame number. An array created that way goes from `first` to `last`
    ///     plus `last-1` to `first-1` (but see `dropFirst` and `dropLast`), and as such is suitable for looping.
    ///     The default value is `false`.
    ///   - dropFirst: A flag stating whether or not the first image should be dropped from the array's
    ///     last position when `reversing`. The default value is `true`.
    ///   - dropLast: A flag stating whether or not the last image should be dropped from the array's
    ///     reversed sequence start when `reversing`. The default value is `true`.
    /// - Returns: An array containing the names of the images.
    ///
    static func createFrom(baseName: String, first: Int, last: Int, reversing: Bool = false,
                           dropFirst: Bool = true, dropLast: Bool = true) -> [String] {
            
        var images = [String]()
        for index in stride(from: first, through: last, by: last < first ? -1 : 1) {
            images.append(baseName + "\(index)")
        }
        if reversing {
            var slice = ArraySlice<String>()
            if dropFirst { slice = images.dropFirst() }
            if dropLast { slice = images.dropLast() }
            images.append(contentsOf: slice.reversed())
        }
        return images
    }
}
