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
    func removeAll()
}

public final class FileSystemBackedCache<Key: Hashable, Value> {
    
    private let encode: (Value) -> Data?
    private let decode: (Data) -> Value?
    private let dateProvider: () -> Date
    private let archiver: FileSystemBackedArchiver
    
    public init(encode: @escaping (Value) -> Data?,
                decode: @escaping (Data) -> Value?,
                dateProvider: @escaping () -> Date,
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
 
        archiver.archive(data, for: key.hashValue)
    }
    
    public func value(for key: Key) -> Value? {

        guard let archived = archiver.data(at: key.hashValue) else { return nil }
        
        return decode(archived)
    }
    
    public func removeValue(for key: Key) {
        fatalError(#function)
    }
    
    public subscript(key: Key) -> Value? {
        get {
            fatalError(#function)
        }
        set {
            fatalError(#function)
        }
    }
    
    
    public var count: Int {
        fatalError(#function)
    }
    
    public var isEmpty: Bool {
        archiver.keys.isEmpty
    }
    
    public func clear() {
        archiver.removeAll()
    }
    
    
}
