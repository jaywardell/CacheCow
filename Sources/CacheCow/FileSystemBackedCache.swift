//
//  File.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/16/24.
//

import Foundation

public protocol FileSystemBackedArchiver {
    var keys: any Collection<String> { get }
    func archive(_ data: Data, for key: String)
    func data(at key: String) -> Data?
    func delete(key: String)
    func deleteAll()
}

public protocol CacheKey {
    func cacheKey() -> String
}

public func cacheValue(of cacheKey: CacheKey) -> String {
        let charactersToRemoved = CharacterSet.whitespacesAndNewlines
            .union(.punctuationCharacters)
    return cacheKey.cacheKey().components(separatedBy: charactersToRemoved)
            .reversed()
            .joined()
}

public final class FileSystemBackedCache<Key: CacheKey, Value> {
    
    private let encode: (Value) -> Data?
    private let decode: (Data) -> Value?
    private let dateProvider: () -> Date
    private let archiver: FileSystemBackedArchiver
    
    public init(encode: @escaping (Value) -> Data?,
                decode: @escaping (Data) -> Value?,
                dateProvider: @escaping () -> Date = Date.init,
                archiver: FileSystemBackedArchiver) {
        
        self.encode = encode
        self.decode = decode
        self.dateProvider = dateProvider
        self.archiver = archiver
    }
}

extension FileSystemBackedCache: Caching {
    
    
    public func insert(_ value: Value, for key: Key) {
        // if this fails, it's a cache, it's okay
        guard let data = encode(value) else { return }
 
        archiver.archive(data, for: cacheValue(of: key))
    }
    
    public func value(for key: Key) -> Value? {

        guard let archived = archiver.data(at: cacheValue(of: key)) else { return nil }
        
        return decode(archived)
    }
    
    public func removeValue(for key: Key) {
        archiver.delete(key: cacheValue(of: key))
    }
    
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
    
    
    public var count: Int {
        archiver.keys.count
    }
    
    public var isEmpty: Bool {
        archiver.keys.isEmpty
    }
    
    public func clear() {
        archiver.deleteAll()
    }
    
    
}

extension URL: CacheKey {
    public func cacheKey() -> String {
        absoluteString
    }
}

@available(macOS 13.0, *)
extension FileSystemBackedCache where Key == URL {
    
    enum Error: Swift.Error, LocalizedError {
        case noDirectory(name: String, group: String?)
        
        var errorDescription: String? {
            switch self {
            case .noDirectory(let name, let group): "There is no directory that can be used as a FileSystemBackedCache with name \(name) and \(group.map { "group: \($0)" } ?? "no group id")"
            }
        }
    }
    
    static func urlDirectoryCache(
        at directory: URL,
        encode: @escaping (Value) -> Data?,
        decode: @escaping (Data) -> Value?
    ) async throws -> FileSystemBackedCache<URL, Value> {
        let archiver = try await DirectoryBackedArchiver(at: directory)
        return FileSystemBackedCache(encode: encode, decode: decode, archiver: archiver)
    }
    
    static func urlDirectoryCache(
        named name: String,
        in group: String? = nil,
        encode: @escaping (Value) -> Data?,
        decode: @escaping (Data) -> Value?
    ) async throws -> FileSystemBackedCache<URL, Value> {
        guard let directory = FileManager.default.cacheURL(named: name, group: group) else { throw Error.noDirectory(name: name, group: group) }
        let archiver = try await DirectoryBackedArchiver(at: directory)
        return FileSystemBackedCache(encode: encode, decode: decode, archiver: archiver)
    }
}

extension String: CacheKey {
    public func cacheKey() -> String {
        self
    }
}
