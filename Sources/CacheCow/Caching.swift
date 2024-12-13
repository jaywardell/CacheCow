//
//  Caching.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/13/24.
//

import Foundation

public protocol Caching {
    associatedtype Key
    associatedtype Value
    
    associatedtype Keys: Collection<Key>
    
    init(dateProvider: @escaping () -> Date,
         entryLifetime: TimeInterval,
         countLimit: Int)
    
    var keys: Keys { get }
    var count: Int { get }
    var isEmpty: Bool { get }

    /// The maximum number of objects the cache should hold.
    /// Note that this may or may not be enforced by the type, depending on underlying implementation.
    var countLimit: Int { get }
    func insert(_ value: Value, for key: Key)


    func value(for key: Key) -> Value?

    func removeValue(for key: Key)
    
    func clear()

    subscript(key: Key) -> Value? { get set }
}
