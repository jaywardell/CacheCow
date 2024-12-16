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
            
    var count: Int { get }
    var isEmpty: Bool { get }

    func insert(_ value: Value, for key: Key)

    func value(for key: Key) -> Value?

    func removeValue(for key: Key)
    
    func clear()

    subscript(key: Key) -> Value? { get set }
}
