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
            
            #expect(nil != archiver.inserted[anyKey.hashValue])
        }

        @Test func passes_encoded_value_to_archiver() async throws {
            let (sut, _, archiver) = makeSUT()
            
            let expected = "expected"
            sut.insert(expected, for: anyKey)
            
            #expect(archiver.inserted[anyKey.hashValue] == expected.data(using: .utf8))
        }
    }
    
//    struct keys {
//        @Test func returns_empty_if_no_inserts_have_happened() async throws {
//            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
//
//            #expect(sut.keys.isEmpty)
//        }
//
//        @Test func returns_one_key_if_one_key_has_been_inserted() async throws {
//            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
//
//            sut.insert("hello", for: FileSystemBackedCacheTests.anyKey)
//            
//            #expect(Set(sut.keys) == Set([anyKey]))
//        }
//
//        @Test func returns_all_inserted_keys() async throws {
//            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
//
//            let expected = FileSystemBackedCacheTests.insertSomeEntries(into: sut)
//            
//            #expect(Set(sut.keys) == Set(expected))
//        }
//        
//        @Test func returns_empty_after_all_keys_removed() async throws {
//            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
//
//            FileSystemBackedCacheTests.insertSomeEntries(into: sut)
//            sut.clear()
//            
//            #expect(sut.keys.isEmpty)
//        }
//
//    }

    struct count {
        @Test func returns_0_if_no_inserts_have_happened() async throws {
            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()

            #expect(0 == sut.count)
        }

        @Test func returns_one_if_one_key_has_been_inserted() async throws {
            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()

            sut.insert("hello", for: FileSystemBackedCacheTests.anyKey)
            
            #expect(1 == sut.count)
        }

        @Test func returns_count_of_all_inserted_keys() async throws {
            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()

            let expected = FileSystemBackedCacheTests.insertSomeEntries(into: sut)

            #expect(expected.count == sut.count)
        }
        
        @Test func returns_0_after_all_keys_removed_from_archiver() async throws {
            let (sut, _, archiver) = FileSystemBackedCacheTests.makeSUT()

            FileSystemBackedCacheTests.insertSomeEntries(into: sut)
            archiver.removeAll()
            
            #expect(0 == sut.count)
        }

    }

    struct isEmpty {
        @Test func returns_true_if_no_inserts_have_happened() async throws {
            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()

            #expect(sut.isEmpty)
        }

        @Test func returns_false_if_keys_have_been_inserted() async throws {
            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()

            FileSystemBackedCacheTests.insertSomeEntries(into: sut)

            #expect(!sut.isEmpty)
        }
        
        @Test func returns_true_after_archiver_has_removed_all_entries() async throws {
            let (sut, _, archiver) = FileSystemBackedCacheTests.makeSUT()

            FileSystemBackedCacheTests.insertSomeEntries(into: sut)
            archiver.removeAll()
            
            #expect(sut.isEmpty)
        }
    }

    struct valueForKey {
        @Test func returns_nil_for_empty_cache() async throws {
            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
            #expect(nil == sut.value(for: FileSystemBackedCacheTests.anyKey))
        }
        
        @Test func returns_inserted_value() async throws {
            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
            let expected = "hello"
            
            sut.insert(expected, for: FileSystemBackedCacheTests.anyKey)
            
            #expect(expected == sut.value(for: FileSystemBackedCacheTests.anyKey))
        }
        
        @Test func returns_nil_after_value_removed() async throws {
            let (sut, _, archiver) = FileSystemBackedCacheTests.makeSUT()
            let expected = "hello"
            
            sut.insert(expected, for: anyKey)
            archiver.delete(key: anyKey.hashValue)
            
            #expect(nil == sut.value(for: anyKey))
        }
        
    }
    
    struct remove {
        @Test func calls_delete_on_archiver() async throws {
            let (sut, _, archiver) = FileSystemBackedCacheTests.makeSUT()
            sut.insert("expected", for: anyKey)

            sut.removeValue(for: anyKey)
            
            #expect(archiver.removed.contains(anyKey.hashValue))
        }
    }
    
//    struct subscripting {
//        @Test func returns_nil_for_empty_cache() async throws {
//            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
//            #expect(nil == sut[FileSystemBackedCacheTests.anyKey])
//        }
//        
//        @Test func returns_inserted_value() async throws {
//            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
//            let expected = "hello"
//            
//            sut[FileSystemBackedCacheTests.anyKey] = expected
//            
//            #expect(expected == sut[FileSystemBackedCacheTests.anyKey])
//        }
//        
//        @Test func returns_nil_after_value_removed() async throws {
//            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
//            let expected = "hello"
//            
//            sut[FileSystemBackedCacheTests.anyKey] = expected
//            sut[FileSystemBackedCacheTests.anyKey] = nil
//
//            #expect(nil == sut[FileSystemBackedCacheTests.anyKey])
//        }
//    }
    
    struct clear {
        @Test func calls_removeAll_on_archiver() async throws {
            let (sut, _, archiver) = makeSUT()
            
            FileSystemBackedCacheTests.insertSomeEntries(into: sut)
            sut.clear()

            #expect(1 == archiver.removeAllCount)
        }
    }
    

//    struct Encoding {
//        @Test func round_trip_for_empty_cache() async throws {
//            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
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
//            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
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
//            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
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
                encode: { $0.data(using: .utf8) },
                decode: { String(data: $0, encoding: .utf8) },
                dateProvider: time.currentTime,
                archiver: archiver
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
        private(set) var removeAllCount = 0
        private(set) var inserted = [Int:Data]()
        private(set) var removed = [Int]()
        
        var keys: any Collection<Int> {
            inserted.keys
        }
        
        func archive(_ data: Data, for key: Int) {
            insertCount += 1
            inserted[key] = data
        }
        
        func removeAll() {
            removeAllCount += 1
            inserted.removeAll()
        }
        
        func data(at key: Int) -> Data? {
            inserted[key]
        }
        
        func delete(key: Int) {
            removed.append(key)
            inserted[key] = nil
        }
    }
}
