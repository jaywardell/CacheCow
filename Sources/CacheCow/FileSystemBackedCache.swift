//
//  File.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/16/24.
//

import Foundation

public protocol FileSystemBackedArchiver {}

public final class FileSystemBackedCache<Key: Hashable, Value: Codable> {
    
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval?
    private let archiver: FileSystemBackedArchiver
    
    public init(dateProvider: @escaping () -> Date,
                archiver: FileSystemBackedArchiver,
                entryLifetime: TimeInterval? = nil) {
        
        self.dateProvider = dateProvider
        self.archiver = archiver
        self.entryLifetime = entryLifetime
    }
}

extension FileSystemBackedCache: Caching {
    
    
    public func insert(_ value: Value, for key: Key) {
        fatalError(#function)
    }
    
    public func value(for key: Key) -> Value? {
        fatalError(#function)
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
        true
    }
    
    public func clear() {
        fatalError(#function)
    }
    
    
}
