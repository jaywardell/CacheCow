//
//  CacheTests.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/13/24.
//

import Testing
import Foundation

import CacheCow

struct CacheTests {
    
    struct keys {
        @Test func returns_empty_if_no_inserts_have_happened() async throws {
            let (sut, _) = CacheTests.makeSUT()

            #expect(sut.keys.isEmpty)
        }

        @Test func returns_one_key_if_one_key_has_been_inserted() async throws {
            let (sut, _) = CacheTests.makeSUT()

            sut.insert("hello", for: CacheTests.anyKey)
            
            #expect(Set(sut.keys) == Set([anyKey]))
        }

        @Test func returns_all_inserted_keys() async throws {
            let (sut, _) = CacheTests.makeSUT()

            let expected = CacheTests.insertSomeEntries(into: sut)
            
            #expect(Set(sut.keys) == Set(expected))
        }
        
        @Test func returns_empty_after_all_keys_removed() async throws {
            let (sut, _) = CacheTests.makeSUT()

            CacheTests.insertSomeEntries(into: sut)
            sut.clear()
            
            #expect(sut.keys.isEmpty)
        }

    }

    struct count {
        @Test func returns_0_if_no_inserts_have_happened() async throws {
            let (sut, _) = CacheTests.makeSUT()

            #expect(0 == sut.count)
        }

        @Test func returns_one_if_one_key_has_been_inserted() async throws {
            let (sut, _) = CacheTests.makeSUT()

            sut.insert("hello", for: CacheTests.anyKey)
            
            #expect(1 == sut.count)
        }

        @Test func returns_count_of_all_inserted_keys() async throws {
            let (sut, _) = CacheTests.makeSUT()

            let expected = CacheTests.insertSomeEntries(into: sut)

            #expect(expected.count == sut.count)
        }
        
        @Test func returns_0_after_all_keys_removed() async throws {
            let (sut, _) = CacheTests.makeSUT()

            CacheTests.insertSomeEntries(into: sut)
            sut.clear()
            
            #expect(0 == sut.count)
        }

    }

    struct isEmpty {
        @Test func returns_true_if_no_inserts_have_happened() async throws {
            let (sut, _) = CacheTests.makeSUT()

            #expect(sut.isEmpty)
        }

        @Test func returns_false_if_keys_have_been_inserted() async throws {
            let (sut, _) = CacheTests.makeSUT()

            CacheTests.insertSomeEntries(into: sut)

            #expect(!sut.isEmpty)
        }
        
        @Test func returns_true_after_all_keys_removed() async throws {
            let (sut, _) = CacheTests.makeSUT()

            CacheTests.insertSomeEntries(into: sut)
            sut.clear()
            
            #expect(sut.isEmpty)
        }

    }

    struct valueForKey {
        @Test func returns_nil_for_empty_cache() async throws {
            let (sut, _) = CacheTests.makeSUT()
            #expect(nil == sut.value(for: CacheTests.anyKey))
        }
        
        @Test func returns_inserted_value() async throws {
            let (sut, _) = CacheTests.makeSUT()
            let expected = "hello"
            
            sut.insert(expected, for: CacheTests.anyKey)
            
            #expect(expected == sut.value(for: CacheTests.anyKey))
        }
        
        @Test func returns_nil_after_value_removed() async throws {
            let (sut, _) = CacheTests.makeSUT()
            let expected = "hello"
            
            sut.insert(expected, for: CacheTests.anyKey)
            sut.removeValue(for: CacheTests.anyKey)
            
            #expect(nil == sut.value(for: CacheTests.anyKey))
        }
        
        @Test func returns_inserted_value_before_entry_lifetime_expended() async throws {
            let lifetime = TimeInterval(60)
            let (sut, time) = CacheTests.makeSUT(lifetime: lifetime)
            let expected = "hello"
            
            sut.insert(expected, for: CacheTests.anyKey)
            
            time.increment(by: lifetime - 1)
            
            #expect(expected == sut.value(for: CacheTests.anyKey))
        }

        @Test func returns_nil_when_entry_lifetime_expended() async throws {
            let lifetime = TimeInterval(60)
            let (sut, time) = CacheTests.makeSUT(lifetime: lifetime)
            let expected = "hello"
            
            sut.insert(expected, for: CacheTests.anyKey)
            
            time.increment(by: lifetime)
            
            #expect(nil == sut.value(for: CacheTests.anyKey))
        }

        @Test func returns_nil_after_entry_lifetime_expended() async throws {
            let lifetime = TimeInterval(60)
            let (sut, time) = CacheTests.makeSUT(lifetime: lifetime)
            let expected = "hello"
            
            sut.insert(expected, for: CacheTests.anyKey)
            
            time.increment(by: lifetime + 1)
            
            #expect(nil == sut.value(for: CacheTests.anyKey))
        }

    }
    
    struct subscripting {
        @Test func returns_nil_for_empty_cache() async throws {
            let (sut, _) = CacheTests.makeSUT()
            #expect(nil == sut[CacheTests.anyKey])
        }
        
        @Test func returns_inserted_value() async throws {
            let (sut, _) = CacheTests.makeSUT()
            let expected = "hello"
            
            sut[CacheTests.anyKey] = expected
            
            #expect(expected == sut[CacheTests.anyKey])
        }
        
        @Test func returns_nil_after_value_removed() async throws {
            let (sut, _) = CacheTests.makeSUT()
            let expected = "hello"
            
            sut[CacheTests.anyKey] = expected
            sut[CacheTests.anyKey] = nil

            #expect(nil == sut[CacheTests.anyKey])
        }
    }
    
    struct clear {
        @Test func removes_all_keys() async throws {
            let (sut, _) = CacheTests.makeSUT()

            CacheTests.insertSomeEntries(into: sut)
            sut.clear()
            
            #expect(sut.isEmpty)
        }

    }
    
    struct countLimit {

        @Test func defaults_to_0() async throws {
            // this needs to be tested because it references a value in the wrapped type
            let sut = Cache<String, String>()
            
            #expect(0 == sut.countLimit)
        }

        @Test func takes_sets_countLimit_to_value_passed_in() async throws {
            // this needs to be tested because it references a value in the wrapped type
            let expected = 15
            let sut = Cache<String, String>(countLimit: expected)
            
            #expect(sut.countLimit == expected)
        }
    }
    
    struct Encoding {
        @Test func round_trip_for_empty_cache() async throws {
            let (sut, _) = CacheTests.makeSUT()
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            
            let data = try encoder.encode(sut)
            let decoded = try decoder.decode(Cache<String, String>.self, from: data)
            
            #expect(decoded.isEmpty)
        }

        @Test func round_trip_for_cache_with_objects() async throws {
            let (sut, _) = CacheTests.makeSUT()
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            
            insertSomeEntries(into: sut)
            
            let data = try encoder.encode(sut)
            let decoded = try decoder.decode(Cache<String, String>.self, from: data)
            
            #expect(Set(sut.keys) == Set(decoded.keys))
            for key in decoded.keys {
                #expect(sut.value(for: key) == decoded.value(for: key))
            }
        }
    }
    
    struct Saving {
        
        @Test func saves_and_retrieves_from_disk() async throws {
            let (sut, _) = CacheTests.makeSUT()
            let filename = #function
            
            insertSomeEntries(into: sut)
            
            let fm = FileManager()
            let savedTo = try sut.saveToFile(named: filename, using: fm)
            let retrieved = try Cache<String, String>.readFromFile(named: filename, using: fm)
            
            #expect(Set(sut.keys) == Set(retrieved.keys))
            for key in retrieved.keys {
                #expect(sut.value(for: key) == retrieved.value(for: key))
            }

            try fm.removeItem(at: savedTo)
        }
    }
    
    // MARK: - Helpers
    
    private static func makeSUT(lifetime: TimeInterval = 60) -> (Cache<String, String>, DummyTime) {
        let time = DummyTime()
        return (Cache<String, String>(dateProvider: time.currentTime, entryLifetime: lifetime), time)
    }
    
    private static let anyKey: String  = "any"
    
    @discardableResult
    private static func insertSomeEntries(into sut: Cache<String, String>) -> [String] {
        let expectedCount = Int.random(in: 2 ... 20)
        
        let expected = (0 ..< expectedCount).map(String.init)
        
        for i in 0 ..< expectedCount {
            sut.insert("\(Int.random(in: -100 ... 100))", for: String(i))
        }

        return expected
    }
    
    private final class DummyTime {
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
