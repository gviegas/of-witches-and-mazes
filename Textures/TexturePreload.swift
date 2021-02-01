//
//  TexturePreload.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that manages the preloading and unloading of a set of textures.
///
class TexturePreload {
    
    /// The set holding the texture names.
    ///
    let textureNames: Set<String>
    
    /// Creates a new instance from the given set of image names.
    ///
    /// - Parameter textureNames: The set holding the names of the textures to manage.
    ///
    init(textureNames: Set<String>) {
        self.textureNames = textureNames
    }
    
    /// Preloads a list of `TexturePreload` instances.
    ///
    /// - Parameters:
    ///   - instances: A list of `TexturePreload` instances to load.
    ///   - onCompletion: A closure to call after all of the textures are loaded. The closure is
    ///     called only once.
    ///
    class func preloadMany(_ instances: [TexturePreload], onCompletion: @escaping () -> Void) {
        let textureNames = instances.reduce(Set<String>()) { (result, instance) in
            return result.union(instance.textureNames)
        }
        TextureSource.createTextures(imagesNamed: [String](textureNames))
        TextureSource.preloadTextures(onCompletion: onCompletion)
    }
    
    /// Preloads the textures.
    ///
    /// - Parameter onCompletion: A closure to call after all of the textures are loaded.
    ///
    func preloadTextures(onCompletion: @escaping () -> Void) {
        TextureSource.createTextures(imagesNamed: [String](textureNames))
        TextureSource.preloadTextures(onCompletion: onCompletion)
    }
    
    /// Unloads the textures.
    ///
    /// - Parameter namesToIgnore: A set containing names of textures that must not be unloaded.
    ///   The default value is an empty set, meaning that every texture whose name is found in the
    ///   instance's `textureNames` property will be unloaded.
    ///
    func unloadTextures(ignoringNames namesToIgnore: Set<String> = []) {
        let textureNames = self.textureNames.subtracting(namesToIgnore)
        textureNames.forEach { name in TextureSource.deleteTexture(forKey: name) }
    }
}
