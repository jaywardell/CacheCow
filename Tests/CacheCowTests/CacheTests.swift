//
//  Test.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/13/24.
//

import Testing
@testable import CacheCow

struct Test {
    
    struct ValueForKey {
        @Test func returns_nil_for_empty_cache() async throws {
            let sut = Cache<String, String>()
            #expect(nil == sut.value(forKey: Test.anyKey))
        }
        
        @Test func returns_inserted_value() async throws {
            let sut = Cache<String, String>()
            let expected = "hello"
            
            sut.insert(expected, forKey: Test.anyKey)
            
            #expect(expected == sut.value(forKey: Test.anyKey))
        }
        
        @Test func returns_nil_after_value_removed() async throws {
            let sut = Cache<String, String>()
            let expected = "hello"
            
            sut.insert(expected, forKey: Test.anyKey)
            sut.removeValue(forKey: Test.anyKey)
            
            #expect(nil == sut.value(forKey: Test.anyKey))
        }
}
    
    private static let anyKey: String  = "any"
}
