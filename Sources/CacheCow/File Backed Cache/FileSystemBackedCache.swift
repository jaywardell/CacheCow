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
    
    /// Errors thrown while creating a URL-keyed file-backed cache.
    enum Error: Swift.Error, LocalizedError {
        /// Indicates that no directory URL was supplied to a factory method.
        case noDirectoryProvided

        public var errorDescription: String? {
            switch self {
            case .noDirectoryProvided:
                "no directory was provided"
            }
        }
    }

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

extension FileSystemBackedCache where Value: Codable {
    /// Creates a file-backed cache that encodes and decodes values as JSON.
    ///
    /// - Parameters:
    ///   - dateProvider: A date supplier reserved for parity with other cache implementations.
    ///   - archiver: The archiver responsible for storing and retrieving the encoded data.
    public convenience init(
        dateProvider: @Sendable @escaping () -> Date = Date.init,
        archiver: FileSystemBackedArchiver
    ) {
        self.init(
            encode: { try? JSONEncoder().encode($0) },
            decode: { try? JSONDecoder().decode(Value.self, from: $0) },
            dateProvider: dateProvider,
            archiver: archiver
        )
    }
    
    /// Creates a file-backed cache rooted at a specific directory URL and uses JSON for encoding.
    ///
    /// - Parameters:
    ///   - dateProvider: A date supplier reserved for parity with other cache implementations.
    ///   - directory: The directory used to store archived values. Pass a concrete URL, or `nil` to fail with ``FileSystemBackedCache/Error/noDirectoryProvided``.
    /// - Returns: A file-backed cache that uses the provided directory.
    /// - Throws: ``FileSystemBackedCache/Error/noDirectoryProvided`` if `directory` is `nil`.
    public static func directoryCache(
        dateProvider: @Sendable @escaping () -> Date = Date.init,
        at directory: URL?
    ) async throws -> Self {
        guard let directory else { throw Error.noDirectoryProvided }
        let archiver = try await DirectoryBackedArchiver(at: directory)
        return .init(
            encode: { try? JSONEncoder().encode($0) },
            decode: { try? JSONDecoder().decode(Value.self, from: $0) },
            dateProvider: dateProvider,
            archiver: archiver
        )
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
    
    /// Creates a file-backed cache rooted at a specific directory URL.
    ///
    /// - Parameters:
    ///   - directory: The directory used to store archived values. Pass a concrete URL
    ///   - encode: A closure that converts a value into archived data.
    ///   - decode: A closure that converts archived data back into a value.
    /// - Returns: A file-backed cache that uses the provided directory.
    /// - throws: ``Error/noDirectoryProvided`` if directory is nil
    public static func urlDirectoryCache(
        at directory: URL?,
        encode: @Sendable @escaping (Value) -> Data?,
        decode: @Sendable @escaping (Data) -> Value?
    ) async throws -> FileSystemBackedCache<URL, Value> {
        guard let directory else { throw Error.noDirectoryProvided }
        let archiver = try await DirectoryBackedArchiver(at: directory)
        return FileSystemBackedCache(encode: encode, decode: decode, archiver: archiver)
    }
}

@available(iOS 16.0, macOS 13.0, *)
extension FileSystemBackedCache where Value: Codable, Key == URL {
    /// Creates a file-backed cache rooted at a specific directory URL and uses JSON for encoding.
    ///
    /// - Parameter directory: The directory used to store archived values. Pass a concrete URL
    /// - Returns: A file-backed cache that uses the provided directory.
    /// - Throws: ``FileSystemBackedCache/Error/noDirectoryProvided`` if `directory` is `nil`.
    public static func urlDirectoryCache(
        at directory: URL?
    ) async throws -> FileSystemBackedCache<URL, Value> {
        guard let directory else { throw Error.noDirectoryProvided }
        let archiver = try await DirectoryBackedArchiver(at: directory)
        return FileSystemBackedCache(archiver: archiver)
    }
}

extension URL {
    /// Resolves a cache directory URL for a named cache location.
    ///
    /// - Parameters:
    ///   - name: The cache directory name without the `.cache` extension.
    ///   - group: An optional app group identifier used to resolve a shared caches directory.
    /// - Returns: The resolved cache directory URL, or `nil` if no cache directory can be resolved.
    /// - Note: The current declaration is `throws`, so call sites use `try` even though this implementation simply forwards `FileManager` lookup.
    public static func cacheDirectoryURL(
        named name: String,
        in group: String? = nil
    ) throws -> URL? {
        FileManager.default.cacheURL(named: name, group: group)
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
