//
//  Test.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/16/24.
//

import Testing
import Foundation

import CacheCow

struct FileSystemBackedCacheTests {
    
    struct insert {
        
        @Test func calls_archiver() async throws {
            let (sut, _, archiver) = makeSUT()
            
            sut.insert("", for: anyKey)
            
            #expect(archiver.insertCount == 1)
        }

        @Test func passes_key_hash_as_key_to_archiver() async throws {
            let (sut, _, archiver) = makeSUT()
            
            sut.insert("", for: anyKey)
            
            #expect(archiver.insertedKeys.contains(anyKey.hashValue))
        }
    }
    
//    struct keys {
//        @Test func returns_empty_if_no_inserts_have_happened() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//
//            #expect(sut.keys.isEmpty)
//        }
//
//        @Test func returns_one_key_if_one_key_has_been_inserted() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//
//            sut.insert("hello", for: FileSystemBackedCacheTests.anyKey)
//            
//            #expect(Set(sut.keys) == Set([anyKey]))
//        }
//
//        @Test func returns_all_inserted_keys() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//
//            let expected = FileSystemBackedCacheTests.insertSomeEntries(into: sut)
//            
//            #expect(Set(sut.keys) == Set(expected))
//        }
//        
//        @Test func returns_empty_after_all_keys_removed() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//
//            FileSystemBackedCacheTests.insertSomeEntries(into: sut)
//            sut.clear()
//            
//            #expect(sut.keys.isEmpty)
//        }
//
//    }

//    struct count {
//        @Test func returns_0_if_no_inserts_have_happened() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//
//            #expect(0 == sut.count)
//        }
//
//        @Test func returns_one_if_one_key_has_been_inserted() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//
//            sut.insert("hello", for: FileSystemBackedCacheTests.anyKey)
//            
//            #expect(1 == sut.count)
//        }
//
//        @Test func returns_count_of_all_inserted_keys() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//
//            let expected = FileSystemBackedCacheTests.insertSomeEntries(into: sut)
//
//            #expect(expected.count == sut.count)
//        }
//        
//        @Test func returns_0_after_all_keys_removed() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//
//            FileSystemBackedCacheTests.insertSomeEntries(into: sut)
//            sut.clear()
//            
//            #expect(0 == sut.count)
//        }
//
//    }

    struct isEmpty {
        @Test func returns_true_if_no_inserts_have_happened() async throws {
            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()

            #expect(sut.isEmpty)
        }

//        @Test func returns_false_if_keys_have_been_inserted() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//
//            FileSystemBackedCacheTests.insertSomeEntries(into: sut)
//
//            #expect(!sut.isEmpty)
//        }
        
//        @Test func returns_true_after_all_keys_removed() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//
//            FileSystemBackedCacheTests.insertSomeEntries(into: sut)
//            sut.clear()
//            
//            #expect(sut.isEmpty)
//        }

    }

//    struct valueForKey {
//        @Test func returns_nil_for_empty_cache() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//            #expect(nil == sut.value(for: FileSystemBackedCacheTests.anyKey))
//        }
//        
//        @Test func returns_inserted_value() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//            let expected = "hello"
//            
//            sut.insert(expected, for: FileSystemBackedCacheTests.anyKey)
//            
//            #expect(expected == sut.value(for: FileSystemBackedCacheTests.anyKey))
//        }
//        
//        @Test func returns_nil_after_value_removed() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//            let expected = "hello"
//            
//            sut.insert(expected, for: FileSystemBackedCacheTests.anyKey)
//            sut.removeValue(for: FileSystemBackedCacheTests.anyKey)
//            
//            #expect(nil == sut.value(for: FileSystemBackedCacheTests.anyKey))
//        }
//        
//        @Test func returns_inserted_value_before_entry_lifetime_expended() async throws {
//            let lifetime = TimeInterval(60)
//            let (sut, time) = FileSystemBackedCacheTests.makeSUT(lifetime: lifetime)
//            let expected = "hello"
//            
//            sut.insert(expected, for: FileSystemBackedCacheTests.anyKey)
//            
//            time.increment(by: lifetime - 1)
//            
//            #expect(expected == sut.value(for: FileSystemBackedCacheTests.anyKey))
//        }
//
//        @Test func returns_nil_when_entry_lifetime_expended() async throws {
//            let lifetime = TimeInterval(60)
//            let (sut, time) = FileSystemBackedCacheTests.makeSUT(lifetime: lifetime)
//            let expected = "hello"
//            
//            sut.insert(expected, for: FileSystemBackedCacheTests.anyKey)
//            
//            time.increment(by: lifetime)
//            
//            #expect(nil == sut.value(for: FileSystemBackedCacheTests.anyKey))
//        }
//
//        @Test func returns_nil_after_entry_lifetime_expended() async throws {
//            let lifetime = TimeInterval(60)
//            let (sut, time) = FileSystemBackedCacheTests.makeSUT(lifetime: lifetime)
//            let expected = "hello"
//            
//            sut.insert(expected, for: FileSystemBackedCacheTests.anyKey)
//            
//            time.increment(by: lifetime + 1)
//            
//            #expect(nil == sut.value(for: FileSystemBackedCacheTests.anyKey))
//        }
//
//    }
    
//    struct subscripting {
//        @Test func returns_nil_for_empty_cache() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//            #expect(nil == sut[FileSystemBackedCacheTests.anyKey])
//        }
//        
//        @Test func returns_inserted_value() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//            let expected = "hello"
//            
//            sut[FileSystemBackedCacheTests.anyKey] = expected
//            
//            #expect(expected == sut[FileSystemBackedCacheTests.anyKey])
//        }
//        
//        @Test func returns_nil_after_value_removed() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//            let expected = "hello"
//            
//            sut[FileSystemBackedCacheTests.anyKey] = expected
//            sut[FileSystemBackedCacheTests.anyKey] = nil
//
//            #expect(nil == sut[FileSystemBackedCacheTests.anyKey])
//        }
//    }
    
//    struct clear {
//        @Test func removes_all_keys() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//
//            FileSystemBackedCacheTests.insertSomeEntries(into: sut)
//            sut.clear()
//            
//            #expect(sut.isEmpty)
//        }
//
//    }
    

//    struct Encoding {
//        @Test func round_trip_for_empty_cache() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//            let encoder = JSONEncoder()
//            let decoder = JSONDecoder()
//            
//            let data = try encoder.encode(sut)
//            let decoded = try decoder.decode(Cache<String, String>.self, from: data)
//            
//            #expect(decoded.isEmpty)
//        }
//
//        @Test func round_trip_for_cache_with_objects() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//            let encoder = JSONEncoder()
//            let decoder = JSONDecoder()
//            
//            insertSomeEntries(into: sut)
//            
//            let data = try encoder.encode(sut)
//            let decoded = try decoder.decode(Cache<String, String>.self, from: data)
//            
//            #expect(Set(sut.keys) == Set(decoded.keys))
//            for key in decoded.keys {
//                #expect(sut.value(for: key) == decoded.value(for: key))
//            }
//        }
//    }
    
//    struct Saving {
//        
//        @Test func saves_and_retrieves_from_disk() async throws {
//            let (sut, _) = FileSystemBackedCacheTests.makeSUT()
//            let filename = #function
//            
//            insertSomeEntries(into: sut)
//            
//            let fm = FileManager()
//            let savedTo = try sut.saveToFile(named: filename, using: fm)
//            let retrieved = try Cache<String, String>.readFromFile(named: filename, using: fm)
//            
//            #expect(Set(sut.keys) == Set(retrieved.keys))
//            for key in retrieved.keys {
//                #expect(sut.value(for: key) == retrieved.value(for: key))
//            }
//
//            try fm.removeItem(at: savedTo)
//        }
//    }
    
    // MARK: - Helpers
    
    private static func makeSUT(lifetime: TimeInterval = 60) -> (FileSystemBackedCache<String, String>, DummyTime, DummyArchiver) {
        let time = DummyTime()
        let archiver = DummyArchiver()
        return (
            FileSystemBackedCache<String,
            String>(
                dateProvider: time.currentTime,
                archiver: archiver,
                entryLifetime: lifetime
            ),
            time,
            archiver
        )
    }
    
    private static let anyKey: String  = "any"
    
    @discardableResult
    private static func insertSomeEntries(into sut: FileSystemBackedCache<String, String>) -> [String] {
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
    
    private final class DummyArchiver: FileSystemBackedArchiver {
        private(set) var insertCount = 0
        private(set) var insertedKeys = [Int]()
        
        func archive(_ data: Data, for key: Int) {
            insertCount += 1
            insertedKeys.append(key)
        }
    }
}
