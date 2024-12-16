//
//  File.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/16/24.
//

import Foundation

public actor FileSystemBackedCache<Key: Hashable, Value: Codable> {
    
//    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval?
    
    public init(
                entryLifetime: TimeInterval? = nil) {
        
//        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
    }
}

extension FileSystemBackedCache: Caching {
    
    
    nonisolated public func insert(_ value: Value, for key: Key) {
        fatalError(#function)
    }
    
    nonisolated public func value(for key: Key) -> Value? {
        fatalError(#function)
    }
    
    nonisolated public func removeValue(for key: Key) {
        fatalError(#function)
    }
    
    nonisolated public subscript(key: Key) -> Value? {
        get {
            fatalError(#function)
        }
        set {
            fatalError(#function)
        }
    }
    
    
    nonisolated public var count: Int {
        fatalError(#function)
    }
    
    nonisolated public var isEmpty: Bool {
        true
    }
    
    nonisolated public func clear() {
        fatalError(#function)
    }
    
    
}
