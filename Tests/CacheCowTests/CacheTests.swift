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
            let (sut, _) = Test.makeSUT()

            #expect(sut.keys.isEmpty)
        }

        @Test func returns_one_key_if_one_key_has_been_inserted() async throws {
            let (sut, _) = Test.makeSUT()

            sut.insert("hello", for: Test.anyKey)
            
            #expect(Set(sut.keys) == Set([anyKey]))
        }

        @Test func returns_all_inserted_keys() async throws {
            let (sut, _) = Test.makeSUT()

            let expected = Test.insertSomeEntries(into: sut)
            
            #expect(Set(sut.keys) == Set(expected))
        }
        
        @Test func returns_empty_after_all_keys_removed() async throws {
            let (sut, _) = Test.makeSUT()

            Test.insertSomeEntries(into: sut)
            sut.clear()
            
            #expect(sut.keys.isEmpty)
        }

    }

    struct count {
        @Test func returns_0_if_no_inserts_have_happened() async throws {
            let (sut, _) = Test.makeSUT()

            #expect(0 == sut.count)
        }

        @Test func returns_one_if_one_key_has_been_inserted() async throws {
            let (sut, _) = Test.makeSUT()

            sut.insert("hello", for: Test.anyKey)
            
            #expect(1 == sut.count)
        }

        @Test func returns_count_of_all_inserted_keys() async throws {
            let (sut, _) = Test.makeSUT()

            let expected = Test.insertSomeEntries(into: sut)

            #expect(expected.count == sut.count)
        }
        
        @Test func returns_0_after_all_keys_removed() async throws {
            let (sut, _) = Test.makeSUT()

            Test.insertSomeEntries(into: sut)
            sut.clear()
            
            #expect(0 == sut.count)
        }

    }

    struct isEmpty {
        @Test func returns_true_if_no_inserts_have_happened() async throws {
            let (sut, _) = Test.makeSUT()

            #expect(sut.isEmpty)
        }

        @Test func returns_false_if_keys_have_been_inserted() async throws {
            let (sut, _) = Test.makeSUT()

            Test.insertSomeEntries(into: sut)

            #expect(!sut.isEmpty)
        }
        
        @Test func returns_true_after_all_keys_removed() async throws {
            let (sut, _) = Test.makeSUT()

            Test.insertSomeEntries(into: sut)
            sut.clear()
            
            #expect(sut.isEmpty)
        }

    }

    struct valueForKey {
        @Test func returns_nil_for_empty_cache() async throws {
            let (sut, _) = Test.makeSUT()
            #expect(nil == sut.value(forKey: Test.anyKey))
        }
        
        @Test func returns_inserted_value() async throws {
            let (sut, _) = Test.makeSUT()
            let expected = "hello"
            
            sut.insert(expected, for: Test.anyKey)
            
            #expect(expected == sut.value(forKey: Test.anyKey))
        }
        
        @Test func returns_nil_after_value_removed() async throws {
            let (sut, _) = Test.makeSUT()
            let expected = "hello"
            
            sut.insert(expected, for: Test.anyKey)
            sut.removeValue(for: Test.anyKey)
            
            #expect(nil == sut.value(forKey: Test.anyKey))
        }
        
        @Test func returns_inserted_value_before_entry_lifetime_expended() async throws {
            let lifetime = TimeInterval(60)
            let (sut, time) = Test.makeSUT(lifetime: lifetime)
            let expected = "hello"
            
            sut.insert(expected, for: Test.anyKey)
            
            time.increment(by: lifetime - 1)
            
            #expect(expected == sut.value(forKey: Test.anyKey))
        }

        @Test func returns_nil_when_entry_lifetime_expended() async throws {
            let lifetime = TimeInterval(60)
            let (sut, time) = Test.makeSUT(lifetime: lifetime)
            let expected = "hello"
            
            sut.insert(expected, for: Test.anyKey)
            
            time.increment(by: lifetime)
            
            #expect(nil == sut.value(forKey: Test.anyKey))
        }

        @Test func returns_nil_after_entry_lifetime_expended() async throws {
            let lifetime = TimeInterval(60)
            let (sut, time) = Test.makeSUT(lifetime: lifetime)
            let expected = "hello"
            
            sut.insert(expected, for: Test.anyKey)
            
            time.increment(by: lifetime + 1)
            
            #expect(nil == sut.value(forKey: Test.anyKey))
        }

    }
    
    struct subscripting {
        @Test func returns_nil_for_empty_cache() async throws {
            let (sut, _) = Test.makeSUT()
            #expect(nil == sut[Test.anyKey])
        }
        
        @Test func returns_inserted_value() async throws {
            let (sut, _) = Test.makeSUT()
            let expected = "hello"
            
            sut[Test.anyKey] = expected
            
            #expect(expected == sut[Test.anyKey])
        }
        
        @Test func returns_nil_after_value_removed() async throws {
            let (sut, _) = Test.makeSUT()
            let expected = "hello"
            
            sut[Test.anyKey] = expected
            sut[Test.anyKey] = nil

            #expect(nil == sut[Test.anyKey])
        }
    }
    
    struct clear {
        @Test func removes_all_keys() async throws {
            let (sut, _) = Test.makeSUT()

            Test.insertSomeEntries(into: sut)
            sut.clear()
            
            #expect(sut.isEmpty)
        }

    }
    
    struct Encoding {
        @Test func round_trip_for_empty_cache() async throws {
            let (sut, _) = Test.makeSUT()
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            
            let data = try encoder.encode(sut)
            let decoded = try decoder.decode(Cache<String, String>.self, from: data)
            
            #expect(decoded.isEmpty)
        }
    }
    
    // MARK: - Helpers
    
    private static func makeSUT(lifetime: TimeInterval = 60) -> (Cache<String, String>, DummyTime) {
        let time = DummyTime()
        return (Cache<String, String>(dateProvider: time.currentTime, entryLifetime: lifetime), time)
    }
    
    private static let anyKey: String  = "any"
    
    @discardableResult
    static func insertSomeEntries(into sut: Cache<String, String>) -> [String] {
        let expectedCount = Int.random(in: 2 ... 20)
        
        let expected = (0 ..< expectedCount).map(String.init)
        
        for i in 0 ..< expectedCount {
            sut.insert("", for: String(i))
        }

        return expected
    }
    
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
