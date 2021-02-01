//
//  TextureSource.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/1/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that represents the source of textures for a game.
///
/// The purpose of this class is to allow the sharing and reuse of textures. It is responsible
/// for the creation and storage of textures. Textures for the game should only be created using
/// this class.
///
class TextureSource {
    
    /// The created textures.
    ///
    private static var textures: [String: SKTexture] = [:]
    
    /// The loaded textures.
    ///
    /// - Note: This property only knows about textures that were loaded using the `preload(onCompletion:)`
    ///   method - if the textures were loaded by any other means, it will not be known to `loadedTextures`.
    ///
    private static var loadedTextures: Set<String> = []
    
    private init() {}
    
    /// Creates a new texture from the given image.
    ///
    /// If a key is provided, it may later be used to retrieve the texture. Otherwise, the image name
    /// is used instead. It is worth noting that this method will not replace an existing key. Thus, it
    /// may be useful to create all the textures using its image/path name as key, since calling this
    /// function multiple times for the same key will not cause the texture to be recreated
    /// (`createTextures(imagesNamed:)` may be used to create many textures this way).
    /// To replace a texture for an existing key, one must first call the `deleteTexture(forKey:)` method.
    ///
    /// - Parameters:
    ///   - name: The name of the image file to create the texture from.
    ///   - key: An optional key that can later be used to retrieve the texture. The default value is the same
    ///     as the image name.
    /// - Returns: The texture.
    ///
    @discardableResult
    class func createTexture(imageNamed name: String, forKey key: String? = nil) -> SKTexture {
        let key = key == nil ? name : key!
        var texture = textures[key]
        if texture == nil {
            texture = SKTexture(imageNamed: name)
            textures[key] = texture
        }
        return texture!
    }
    
    /// Creates a new texture for each image name, ignoring the ones already created. The image name is
    /// used as key.
    ///
    /// - Parameter names: An array containing the image names.
    ///
    class func createTextures(imagesNamed names: [String]) {
        for name in names {
            if let _ = textures[name] { continue }
            textures[name] = SKTexture(imageNamed: name)
        }
    }
    
    /// Retrieves the texture stored under the given key.
    ///
    /// - Parameter key: The key that identifies the texture.
    /// - Returns: The texture identified by the given key, or nil if not found.
    ///
    class func getTexture(forKey key: String) -> SKTexture? {
        return textures[key]
    }
    
    /// Retrieves multiple textures.
    ///
    /// - Parameter keys: An array containing the keys of the textures to retrieve.
    /// - Returns: The array of textures, or nil if even a single one is not found.
    ///
    class func getTextures(forKeys keys: [String]) -> [SKTexture]? {
        var textures = [SKTexture]()
        for key in keys {
            if let texture = self.textures[key] {
                textures.append(texture)
            } else {
                return nil
            }
        }
        return textures
    }
    
    /// Deletes the texture identified by the given key.
    ///
    /// - Parameter key: The key that identifies the texture.
    ///
    class func deleteTexture(forKey key: String) {
        textures.removeValue(forKey: key)
        loadedTextures.remove(key)
    }
    
    /// Preloads all created textures.
    ///
    /// - Parameter onCompletion: A closure to call after all of the textures are loaded.
    ///
    class func preloadTextures(onCompletion: @escaping () -> Void) {
        let textures = self.textures.filter { key, _ in !loadedTextures.contains(key) }
        textures.forEach { key, _ in loadedTextures.insert(key) }
        SKTexture.preload([SKTexture](textures.values), withCompletionHandler: onCompletion)
    }
    
    #if DEBUG
    class func DEBUGDescription() {
        print("---------------------------------------------------------------")
        print("--TextureSource #\(textures.count)--")
        textures.forEach { print($0.key) }
        print("---------------------------------------------------------------", terminator: "\n\n")
    }
    #endif
}
