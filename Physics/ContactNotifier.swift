//
//  ContactNotifier.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/3/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A protocol that contact responders should conform to.
///
protocol Contactable: AnyObject {
    
    /// A callback called when a contact has begun.
    ///
    /// - Parameter contact: The `Contact` instance with information about the interaction.
    ///
    func contactDidBegin(_ contact: Contact)
    
    /// A callback called when a contact has ended.
    ///
    /// - Parameter contact: The `Contact` instance with information about the interaction.
    ///
    func contactDidEnd(_ contact: Contact)
}

/// A class responsible for the management of contact notifications.
///
class ContactNotifier {
    
    /// The registered callbacks.
    ///
    private static var callbacks: [String: [Contactable]] = [:]
    
    /// The registrations made, with `Contactable` identifiers as keys.
    ///
    private static var registrations: [ObjectIdentifier: Set<String>] = [:]
    
    private init() {}
    
    /// Registers a callback for the given name.
    ///
    /// - Parameters:
    ///   - name: The name of the node to register the callback for.
    ///   - callback: The `Contactable` instance to be registered as callback.
    ///
    class func registerCallbackFor(nodeNamed name: String, callback: Contactable) {
        let id = ObjectIdentifier(callback)
        if let _ = callbacks[name], let _ = registrations[id] {
            if !callbacks[name]!.contains(where: { $0 === callback }) {
                callbacks[name]!.append(callback)
                registrations[id]!.insert(name)
            }
        } else {
            callbacks[name] = [callback]
            registrations[id] = [name]
        }
    }
    
    /// Removes the given callback under the given name.
    ///
    /// - Parameters:
    ///   - name: The name of the node to remove the callback for.
    ///   - callback: The `Contactable` instance to be removed as callback.
    ///
    class func removeCallbackFor(nodeNamed name: String, callback: Contactable) {
        guard let entries = callbacks[name] else { return }
        
        for (index, entry) in entries.enumerated() {
            if entry === callback {
                callbacks[name]!.remove(at: index)
                let id = ObjectIdentifier(callback)
                registrations[id]?.remove(name)
                if callbacks[name]!.isEmpty { callbacks[name] = nil }
                if registrations[id]?.isEmpty ?? false { registrations[id] = nil }
                break
            }
        }
    }
    
    /// Removes all callbacks under the given name.
    ///
    /// - Parameter name: The name of the node to remove the callbacks for.
    ///
    class func removeAllCallbacksFor(nodeNamed name: String) {
        callbacks[name]?.forEach { registrations[ObjectIdentifier($0)] = nil }
        callbacks[name] = nil
    }
    
    /// Removes all registrations made for the given callback.
    ///
    /// - Parameter callback: The `Contactable` instance to be removed.
    ///
    class func removeAllRegistrationsFor(callback: Contactable) {
        let id = ObjectIdentifier(callback)
        registrations[id]?.forEach { name in
            if let index = callbacks[name]?.firstIndex(where: { $0 === callback }) {
                callbacks[name]!.remove(at: index)
                if callbacks[name]!.isEmpty { callbacks[name] = nil }
            }
        }
        registrations[id] = nil
    }
    
    /// Removes all callbacks.
    ///
    class func removeAll() {
        callbacks = [:]
        registrations = [:]
    }
    
    /// Notifies the beginning of a contact for all registered callbacks under the given name.
    ///
    /// - Parameters:
    ///   - name: The name of the node to be notified.
    ///   - contact: The `Contact` instance to be sent in the notification.
    /// - Returns: `true` if there were any callbacks registered to call, `false` otherwise.
    ///
    @discardableResult
    class func notifyBeginning(nodeNamed name: String, contact: Contact) -> Bool {
        if let contactables = callbacks[name] {
            for contactable in contactables {
                contactable.contactDidBegin(contact)
            }
            return true
        }
        return false
    }
    
    /// Notifies the ending of a contact for all registered callbacks under the given name.
    ///
    /// - Parameters:
    ///   - name: The name of the node to be notified.
    ///   - contact: The `Contact` instance to be sent in the notification.
    /// - Returns: `true` if there were any callbacks registered to call, `false` otherwise.
    ///
    @discardableResult
    class func notifyEnding(nodeNamed name: String, contact: Contact) -> Bool {
        if let contactables = callbacks[name] {
            for contactable in contactables {
                contactable.contactDidEnd(contact)
            }
            return true
        }
        return false
    }
    
    #if DEBUG
    class func DEBUGDescription() {
        print("---------------------------------------------------------------")
        print("--ContactNotifier #\(callbacks.count)--")
        callbacks.forEach { print("\($0.key) #(\($0.value.count))") }
        print("--------")
        registrations.forEach { print("\($0.key) #(\($0.value.count))") }
        print("---------------------------------------------------------------", terminator: "\n\n")
    }
    #endif
}
