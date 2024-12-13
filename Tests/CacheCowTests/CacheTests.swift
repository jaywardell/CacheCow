//
//  Test.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/13/24.
//

import Testing
import Foundation

@testable import CacheCow

struct Test {
    
    struct valueForKey {
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
        
        @Test func returns_inserted_value_before_entry_lifetime_expended() async throws {
            let time = DummyTime()
            let lifetime = TimeInterval(60)
            let sut = Cache<String, String>(dateProvider: time.currentTime, entryLifetime: lifetime)
            let expected = "hello"
            
            sut.insert(expected, forKey: Test.anyKey)
            
            time.increment(by: lifetime - 1)
            
            #expect(expected == sut.value(forKey: Test.anyKey))
        }

        @Test func returns_nil_when_entry_lifetime_expended() async throws {
            let time = DummyTime()
            let lifetime = TimeInterval(60)
            let sut = Cache<String, String>(dateProvider: time.currentTime, entryLifetime: lifetime)
            let expected = "hello"
            
            sut.insert(expected, forKey: Test.anyKey)
            
            time.increment(by: lifetime)
            
            #expect(nil == sut.value(forKey: Test.anyKey))
        }

        @Test func returns_nil_after_entry_lifetime_expended() async throws {
            let time = DummyTime()
            let lifetime = TimeInterval(60)
            let sut = Cache<String, String>(dateProvider: time.currentTime, entryLifetime: lifetime)
            let expected = "hello"
            
            sut.insert(expected, forKey: Test.anyKey)
            
            time.increment(by: lifetime + 1)
            
            #expect(nil == sut.value(forKey: Test.anyKey))
        }

    }
    
    struct subscripting {
        @Test func returns_nil_for_empty_cache() async throws {
            let sut = Cache<String, String>()
            #expect(nil == sut[Test.anyKey])
        }
        
        @Test func returns_inserted_value() async throws {
            let sut = Cache<String, String>()
            let expected = "hello"
            
            sut[Test.anyKey] = expected
            
            #expect(expected == sut[Test.anyKey])
        }
        
        @Test func returns_nil_after_value_removed() async throws {
            let sut = Cache<String, String>()
            let expected = "hello"
            
            sut[Test.anyKey] = expected
            sut[Test.anyKey] = nil

            #expect(nil == sut[Test.anyKey])
        }
    }
    
    private static let anyKey: String  = "any"
    
    final class DummyTime {
        var time: Date
        
        init(time: Date = .now) {
            self.time = time
        }
        
        func increment(by timeInterval: TimeInterval) {
            time = time.addingTimeInterval(timeInterval)
        }
        
        func currentTime() -> Date {
            print(#function, time)
            return time
        }
    }
}
