//
//  Caching.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/13/24.
//

import Foundation

/// A common interface for cache types that store values by key.
public protocol Caching {
    /// The type used to identify cached values.
    associatedtype Key
    /// The type of values stored in the cache.
    associatedtype Value
            
    /// The number of entries currently stored in the cache.
    var count: Int { get }
    /// A Boolean value that indicates whether the cache has no entries.
    var isEmpty: Bool { get }

    /// Stores a value in the cache for the given key.
    ///
    /// - Parameters:
    ///   - value: The value to cache.
    ///   - key: The key that identifies the value.
    func insert(_ value: Value, for key: Key)

    /// Returns the cached value for a key.
    ///
    /// - Parameter key: The key associated with the desired value.
    /// - Returns: The cached value, or `nil` if no value exists for the key.
    func value(for key: Key) -> Value?

    /// Removes any cached value for the given key.
    ///
    /// - Parameter key: The key whose value should be removed.
    func removeValue(for key: Key)
    
    /// Removes all cached values.
    func clear()

    /// Accesses the cached value associated with the given key.
    subscript(key: Key) -> Value? { get set }
}
