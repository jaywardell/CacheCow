//
//  File.swift
//  CacheCow
//
//  original at https://www.swiftbysundell.com/articles/caching-in-swift/
//  lightly modified by Joseph Wardell on 12/13/24
//

import Foundation

public final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval?
    private let keyTracker = KeyTracker()
    
    // MARK: -
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
    public var keys: some Collection<Key> { keyTracker.keys }
    public var count: Int { keyTracker.keys.count }
    public var isEmpty: Bool { keyTracker.keys.isEmpty }

    public func insert(_ value: Value, for key: Key) {
        let date = entryLifetime.map { dateProvider().addingTimeInterval($0) } ?? .distantFuture
        let entry = Entry(key: key, value: value, expirationDate: date)
 
        insert(entry)
    }


    public func value(for key: Key) -> Value? {

        return entry(for: key)?.value
    }

    public func removeValue(for key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
    
    public func clear() {
        wrapped.removeAllObjects()
    }

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
    
    private static func cacheURL(named name: String,
                                 group: String?,
                                 using fileManager: FileManager) -> URL? {
        let folderURL: URL?
        
        if let group {
            guard let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) else { return nil }
            
            folderURL = directory
                .appendingPathComponent("Library")
                .appendingPathComponent("Caches")
        }
        else {
            let folderURLs = fileManager.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            )
            folderURL = folderURLs.first
        }
        
        guard let folderURL else { return nil }
        
        return folderURL.appendingPathComponent(name + ".cache")
    }
    
    @discardableResult
    func saveToFile(
        named name: String,
        group: String? = nil,
       using fileManager: FileManager = .default
    ) throws -> URL {
        guard let fileURL = Self.cacheURL(named: name, group: group, using: fileManager) else {
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
        guard let fileURL = cacheURL(named: name, group: group, using: fileManager) else {
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
