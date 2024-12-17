//
//  File.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/16/24.
//

import Foundation

public protocol FileSystemBackedArchiver {
    var keys: any Collection<Int> { get }
    func archive(_ data: Data, for key: Int)
    func data(at key: Int) -> Data?
    func delete(key: Int)
    func deleteAll()
}

public final class FileSystemBackedCache<Key: Hashable, Value> {
    
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

@available(macOS 13.0, *)
extension FileSystemBackedCache where Key == URL {
    
    enum Error: Swift.Error {
        case noDirectory
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
        guard let directory = FileManager.default.cacheURL(named: name, group: group) else { throw Error.noDirectory }
        let archiver = try await DirectoryBackedArchiver(at: directory)
        return FileSystemBackedCache(encode: encode, decode: decode, archiver: archiver)
    }
}

extension FileSystemBackedCache: Caching {
    
    
    public func insert(_ value: Value, for key: Key) {
        // if this fails, it's a cache, it's okay
        guard let data = encode(value) else { return }
 
        archiver.archive(data, for: key.hashValue)
    }
    
    public func value(for key: Key) -> Value? {

        guard let archived = archiver.data(at: key.hashValue) else { return nil }
        
        return decode(archived)
    }
    
    public func removeValue(for key: Key) {
        archiver.delete(key: key.hashValue)
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
