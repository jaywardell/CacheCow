//
//  File.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/16/24.
//

import Foundation

/// A file archiver that stores raw data for string keys.
public protocol FileSystemBackedArchiver: Sendable {
    /// The keys currently archived on disk.
    var keys: any Collection<String> { get }
    /// Writes data for a key.
    ///
    /// - Parameters:
    ///   - data: The data to archive.
    ///   - key: The key used to identify the archived data.
    func archive(_ data: Data, for key: String)
    /// Reads archived data for a key.
    ///
    /// - Parameter key: The key associated with the archived data.
    /// - Returns: The archived data, or `nil` if it cannot be read.
    func data(at key: String) -> Data?
    /// Deletes archived data for a key.
    ///
    /// - Parameter key: The key to delete.
    func delete(key: String)
    /// Deletes all archived data.
    func deleteAll()
}

/// A type that can produce a stable string representation for file-backed caching.
public protocol CacheKey: Sendable {
    /// Returns the string value used as the cache key on disk.
    func cacheKey() -> String
}

func cacheValue(of key: CacheKey) -> String {
    return key.cacheKey()
        .components(separatedBy: .removedFromCacheKey)
        .reversed()
        .joined()
}

/// A cache implementation that persists encoded values through a `FileSystemBackedArchiver`.
public final class FileSystemBackedCache<Key: CacheKey, Value: Sendable>: Sendable {
    
    private let encode: @Sendable (Value) -> Data?
    private let decode: @Sendable (Data) -> Value?
    private let dateProvider: @Sendable () -> Date
    private let archiver: FileSystemBackedArchiver
    
    /// Creates a file-backed cache.
    ///
    /// - Parameters:
    ///   - encode: A closure that converts a value into archived data.
    ///   - decode: A closure that converts archived data back into a value.
    ///   - dateProvider: A date supplier reserved for parity with other cache implementations.
    ///   - archiver: The archiver responsible for storing and retrieving the encoded data.
    public init(encode: @Sendable @escaping (Value) -> Data?,
                decode: @Sendable @escaping (Data) -> Value?,
                dateProvider: @Sendable @escaping () -> Date = Date.init,
                archiver: FileSystemBackedArchiver) {
        
        self.encode = encode
        self.decode = decode
        self.dateProvider = dateProvider
        self.archiver = archiver
    }
}

extension FileSystemBackedCache: Caching {
    
    
    /// Stores a value in the cache for the given key.
    ///
    /// - Parameters:
    ///   - value: The value to cache.
    ///   - key: The key that identifies the value.
    public func insert(_ value: Value, for key: Key) {
        // if this fails, it's a cache, it's okay
        guard let data = encode(value) else { return }
 
        archiver.archive(data, for: cacheValue(of: key))
    }
    
    /// Returns the cached value for a key.
    ///
    /// - Parameter key: The key associated with the desired value.
    /// - Returns: The decoded cached value, or `nil` if no data exists or decoding fails.
    public func value(for key: Key) -> Value? {

        guard let archived = archiver.data(at: cacheValue(of: key)) else { return nil }
        
        return decode(archived)
    }
    
    /// Removes any cached value for the given key.
    ///
    /// - Parameter key: The key whose value should be removed.
    public func removeValue(for key: Key) {
        archiver.delete(key: cacheValue(of: key))
    }
    
    /// Accesses the cached value associated with the given key.
    public subscript(key: Key) -> Value? {
        get {
            value(for: key)
        }
        set {
            if let newValue {
                insert(newValue, for: key)
            }
            else {
                removeValue(for: key)
            }
        }
    }
    
    /// The number of archived entries currently reported by the archiver.
    public var count: Int {
        archiver.keys.count
    }
    
    /// A Boolean value that indicates whether the archiver reports any cached entries.
    public var isEmpty: Bool {
        archiver.keys.isEmpty
    }
    
    /// Removes all archived values from the cache.
    public func clear() {
        archiver.deleteAll()
    }
}

extension URL: CacheKey {
    /// Returns the URL's absolute string for use as a cache key.
    public func cacheKey() -> String {
        absoluteString
    }
}

@available(iOS 16.0, macOS 13.0, *)
extension FileSystemBackedCache where Key == URL {
    
    enum Error: Swift.Error, LocalizedError {
        case noDirectory(name: String, group: String?)
        
        var errorDescription: String? {
            switch self {
            case .noDirectory(let name, let group): "There is no directory that can be used as a FileSystemBackedCache with name \(name) and \(group.map { "group: \($0)" } ?? "no group id")"
            }
        }
    }
    
    /// Creates a file-backed cache rooted at a specific directory URL.
    ///
    /// - Parameters:
    ///   - directory: The directory used to store archived values.
    ///   - encode: A closure that converts a value into archived data.
    ///   - decode: A closure that converts archived data back into a value.
    /// - Returns: A file-backed cache that uses the provided directory.
    public static func urlDirectoryCache(
        at directory: URL,
        encode: @Sendable @escaping (Value) -> Data?,
        decode: @Sendable @escaping (Data) -> Value?
    ) async throws -> FileSystemBackedCache<URL, Value> {
        let archiver = try await DirectoryBackedArchiver(at: directory)
        return FileSystemBackedCache(encode: encode, decode: decode, archiver: archiver)
    }
    
    /// Creates a file-backed cache rooted in the system caches directory.
    ///
    /// - Parameters:
    ///   - name: The cache directory name without the `.cache` extension.
    ///   - group: An optional app group identifier to resolve the cache directory from.
    ///   - encode: A closure that converts a value into archived data.
    ///   - decode: A closure that converts archived data back into a value.
    /// - Returns: A file-backed cache that uses the resolved cache directory.
    public static func urlDirectoryCache(
        named name: String,
        in group: String? = nil,
        encode: @Sendable @escaping (Value) -> Data?,
        decode: @Sendable @escaping (Data) -> Value?
    ) async throws -> FileSystemBackedCache<URL, Value> {
        guard let directory = FileManager.default.cacheURL(named: name, group: group) else { throw Error.noDirectory(name: name, group: group) }
        let archiver = try await DirectoryBackedArchiver(at: directory)
        return FileSystemBackedCache(encode: encode, decode: decode, archiver: archiver)
    }
}

extension String: CacheKey {
    /// Returns the string itself for use as a cache key.
    public func cacheKey() -> String {
        self
    }
}

fileprivate extension CharacterSet {
    static let removedFromCacheKey: CharacterSet = {
        CharacterSet.whitespacesAndNewlines
            .union(.punctuationCharacters)
    }()
}
