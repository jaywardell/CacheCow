//
//  File.swift
//  CacheCow
//
//  original at https://www.swiftbysundell.com/articles/caching-in-swift/
//  lightly modified by Joseph Wardell on 12/13/24
//

import Foundation

/// An in-memory cache backed by `NSCache`.
public final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval?
    private let keyTracker = KeyTracker()
    
    // MARK: -
    /// Creates a cache with optional expiration and count limits.
    ///
    /// - Parameters:
    ///   - dateProvider: A closure that supplies the current date when evaluating expirations.
    ///   - entryLifetime: The number of seconds that inserted entries remain valid. Pass `nil` to disable expiration.
    ///   - countLimit: The advisory maximum number of entries `NSCache` should keep in memory.
    public init(dateProvider: @escaping () -> Date = Date.init,
         entryLifetime: TimeInterval? = nil,
         countLimit: Int = 0) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        
        wrapped.countLimit = countLimit
        wrapped.delegate = keyTracker
    }
    
    /// The maximum number of objects the cache should hold.
    ///
    /// Discussion
    /// returns the countLimit for the wrapped NSCache.
    ///
    /// Note that this may or may not be enforced by NSCache.
    public var countLimit: Int { wrapped.countLimit }

    private func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
    
    private func entry(for key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }
        
        guard dateProvider() < entry.expirationDate else {
            removeValue(for: key)
            return nil
        }
        
        return entry
    }
}

// MARK: - Public API
extension Cache: Caching {
    /// The keys currently tracked by the cache.
    public var keys: some Collection<Key> { keyTracker.keys }
    /// The number of entries currently tracked by the cache.
    public var count: Int { keyTracker.keys.count }
    /// A Boolean value that indicates whether the cache has no tracked entries.
    public var isEmpty: Bool { keyTracker.keys.isEmpty }

    /// Stores a value in the cache for the given key.
    ///
    /// - Parameters:
    ///   - value: The value to cache.
    ///   - key: The key that identifies the value.
    public func insert(_ value: Value, for key: Key) {
        let date = entryLifetime.map { dateProvider().addingTimeInterval($0) } ?? .distantFuture
        let entry = Entry(key: key, value: value, expirationDate: date)
 
        insert(entry)
    }


    /// Returns the cached value for a key if it has not expired.
    ///
    /// - Parameter key: The key associated with the desired value.
    /// - Returns: The cached value, or `nil` if no value exists or the value has expired.
    public func value(for key: Key) -> Value? {

        return entry(for: key)?.value
    }

    /// Removes any cached value for the given key.
    ///
    /// - Parameter key: The key whose value should be removed.
    public func removeValue(for key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
    
    /// Removes all values from the cache.
    public func clear() {
        wrapped.removeAllObjects()
    }

    /// Accesses the cached value associated with the given key.
    public subscript(key: Key) -> Value? {
        get { return value(for: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(for: key)
                return
            }

            insert(value, for: key)
        }
    }
}

// MARK: - Private Types

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }

    // MARK: -
    final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date

        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }

    // MARK: -
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()

        func cache(_ cache: NSCache<AnyObject, AnyObject>,
                   willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }

            keys.remove(entry.key)
        }
    }
}

extension Cache.Entry: Codable where Key: Codable, Value: Codable {}
extension Cache
where Key: Codable, Value: Codable,
      Key: Sendable, Value: Sendable {
    
    struct FreezeDried: Codable, Sendable {
        let dictionary: [Key : Value]
        
        public static var empty: FreezeDried {
            FreezeDried(dictionary: [:])
        }
    }
  
    var freezeDried: FreezeDried {
        var out = [Key : Value]()
        keyTracker.keys.forEach { key in
            out[key] = value(for: key)
        }
        return FreezeDried(dictionary: out)
    }
    
    convenience init(freezeDried: FreezeDried?,
                     dateProvider: @escaping () -> Date = Date.init,
                     entryLifetime: TimeInterval? = nil,
                     countLimit: Int = 0) {

        self.init(dateProvider: dateProvider, entryLifetime: entryLifetime, countLimit: countLimit)
        
        freezeDried?.dictionary.forEach { key, value in
            insert(value, for: key)
        }
    }
}

extension Cache.FreezeDried: Equatable
where Key: Equatable, Value: Equatable
{}

extension Cache.FreezeDried {
    
    enum Error: Swift.Error {
        case pathDoesNotExist(name: String, group: String?)
    }
        
    @discardableResult
    func saveToFile(
        named name: String,
        group: String? = nil,
       using fileManager: FileManager = .default
    ) throws -> URL {
        guard let fileURL = fileManager.cacheURL(named: name, group: group) else {
            throw Error.pathDoesNotExist(name: name, group: group)
        }
        
        let directory = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        
        try saveAsJSON(to: fileURL)
        return fileURL
    }
    
    
    static func readFromFile(
        named name: String,
        group: String? = nil,
        using fileManager: FileManager = .default
    ) throws -> Self {
        guard let fileURL = fileManager.cacheURL(named: name, group: group) else {
            throw Error.pathDoesNotExist(name: name, group: group)
        }
        return try readAsJSON(from: fileURL)
    }
}

extension Cache.FreezeDried.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .pathDoesNotExist(let name, let groupID): "No file exists for name \(name) \(groupID.map { "with group id \($0)" } ?? "with no group id")"
        }
    }
}
