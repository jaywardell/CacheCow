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
    
    struct keys {
        @Test func returns_empty_if_no_inserts_have_happened() async throws {
            let sut = Cache<String, String>()

            #expect(sut.keys.isEmpty)
        }

        @Test func returns_one_key_if_one_key_has_been_inserted() async throws {
            let sut = Cache<String, String>()

            sut.insert("hello", forKey: Test.anyKey)
            
            #expect(Set(sut.keys) == Set([anyKey]))
        }

        @Test func returns_all_inserted_keys() async throws {
            let sut = Cache<String, String>()
            let expectedCount = Int.random(in: 2 ... 20)
            
            let expected = (0 ..< expectedCount).map(String.init)
            
            for i in 0 ..< expectedCount {
                sut.insert("", forKey: String(i))
            }
            
            #expect(Set(sut.keys) == Set(expected))
        }
        
        @Test func returns_empty_after_all_keys_removed() async throws {
            let sut = Cache<String, String>()

            let expectedCount = Int.random(in: 2 ... 20)
            
            let expected = (0 ..< expectedCount).map(String.init)
            
            for i in 0 ..< expectedCount {
                sut.insert("", forKey: String(i))
            }

            for key in expected {
                sut.removeValue(forKey: key)
            }
            
            #expect(sut.keys.isEmpty)
        }

    }

    struct count {
        @Test func returns_0_if_no_inserts_have_happened() async throws {
            let sut = Cache<String, String>()

            #expect(0 == sut.count)
        }

        @Test func returns_one_if_one_key_has_been_inserted() async throws {
            let sut = Cache<String, String>()

            sut.insert("hello", forKey: Test.anyKey)
            
            #expect(1 == sut.count)
        }

        @Test func returns_count_of_all_inserted_keys() async throws {
            let sut = Cache<String, String>()
            let expectedCount = Int.random(in: 2 ... 20)
            
            let expected = (0 ..< expectedCount).map(String.init)
            
            for i in 0 ..< expectedCount {
                sut.insert("", forKey: String(i))
            }
            
            #expect(expectedCount == sut.count)
        }
        
        @Test func returns_0_after_all_keys_removed() async throws {
            let sut = Cache<String, String>()

            let expectedCount = Int.random(in: 2 ... 20)
            
            let expected = (0 ..< expectedCount).map(String.init)
            
            for i in 0 ..< expectedCount {
                sut.insert("", forKey: String(i))
            }

            for key in expected {
                sut.removeValue(forKey: key)
            }
            
            #expect(0 == sut.count)
        }

    }

    struct isEmpty {
        @Test func returns_true_if_no_inserts_have_happened() async throws {
            let sut = Cache<String, String>()

            #expect(sut.isEmpty)
        }

        @Test func returns_false_if_keys_have_been_inserted() async throws {
            let sut = Cache<String, String>()
            let expectedCount = Int.random(in: 1 ... 20)
                        
            for i in 0 ..< expectedCount {
                sut.insert("", forKey: String(i))
            }
            
            #expect(!sut.isEmpty)
        }
        
        @Test func returns_true_after_all_keys_removed() async throws {
            let sut = Cache<String, String>()

            let expectedCount = Int.random(in: 2 ... 20)
            
            let expected = (0 ..< expectedCount).map(String.init)
            
            for i in 0 ..< expectedCount {
                sut.insert("", forKey: String(i))
            }

            for key in expected {
                sut.removeValue(forKey: key)
            }
            
            #expect(sut.isEmpty)
        }

    }

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
