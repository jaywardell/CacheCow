//
//  Test.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/16/24.
//

import Testing
import Foundation

@testable import CacheCow

struct FileSystemBackedCacheTests {
    
    struct stringToKey {
        @Test func empty_returns_empty() async throws {
            let expected = ""
            #expect(FileSystemBackedCache<String, String>.stringToKey(expected) == expected)
        }

        @Test(
            "Simple Words",
            arguments: [
                "burger",
                "cat",
                "running",
                "fantabulous",
                "honorific"
            ]
        )
        func word_returns_word(_ string: String) async throws {
            let expected = string
            #expect(FileSystemBackedCache<String, String>.stringToKey(string) == expected)
        }
        
        @Test(
            "Phrases",
            arguments: [
                ("burger shop", "shopburger"),
                ("cat burglar", "burglarcat"),
                ("I love running", "runningloveI"),
                ("fantabulous stupednous marvelous", "marvelousstupednousfantabulous"),
                ("so\thonorific", "honorificso")
            ]
        )
        func words_returns_words_without_spaces(_ strings: (String, String)) async throws {
            #expect(FileSystemBackedCache<String, String>.stringToKey(strings.0) == strings.1)
        }

        @Test(
            "URLs and other punctuation",
            arguments: [
                ("https://developer.apple.com/documentation/testing/parameterizedtesting", "parameterizedtestingtestingdocumentationcomappledeveloperhttps"),
                ("https://swiftwithmajid.com/2024/11/12/introducing-swift-testing-parameterized-tests/", "testsparameterizedtestingswiftintroducing12112024comswiftwithmajidhttps"),
                ("The great manda eats, shoots, and leaves.", "leavesandshootseatsmandagreatThe")
            ]
        )
        func punctuation_returns_words_without_punctuation_reversed(_ strings: (String, String)) async throws {
            #expect(FileSystemBackedCache<String, String>.stringToKey(strings.0) == strings.1)
        }

    }
    
    struct insert {
        
        @Test func calls_archiver() async throws {
            let (sut, _, archiver) = makeSUT()
            
            sut.insert("", for: anyKey)
            
            #expect(archiver.insertCount == 1)
        }

        @Test func passes_key_hash_as_key_to_archiver() async throws {
            let (sut, _, archiver) = makeSUT()
            
            sut.insert("", for: anyKey)
            
            #expect(nil != archiver.inserted[anyKey.asCacheKey()])
        }

        @Test func passes_encoded_value_to_archiver() async throws {
            let (sut, _, archiver) = makeSUT()
            
            let expected = "expected"
            sut.insert(expected, for: anyKey)
            
            #expect(archiver.inserted[anyKey.asCacheKey()] == expected.data(using: .utf8))
        }
    }
    
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
            archiver.deleteAll()
            
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
            archiver.deleteAll()
            
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
            archiver.delete(key: anyKey.asCacheKey())
            
            #expect(nil == sut.value(for: anyKey))
        }
        
    }
    
    struct remove {
        @Test func calls_delete_on_archiver() async throws {
            let (sut, _, archiver) = FileSystemBackedCacheTests.makeSUT()
            sut.insert("expected", for: anyKey)

            sut.removeValue(for: anyKey)
            
            #expect(archiver.removed.contains(anyKey.asCacheKey()))
        }
    }
    
    struct subscripting {
        @Test func returns_nil_for_empty_cache() async throws {
            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
            #expect(nil == sut[FileSystemBackedCacheTests.anyKey])
        }
        
        @Test func returns_inserted_value() async throws {
            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
            let expected = "hello"
            
            sut[FileSystemBackedCacheTests.anyKey] = expected
            
            #expect(expected == sut[FileSystemBackedCacheTests.anyKey])
        }
        
        @Test func returns_nil_after_value_removed() async throws {
            let (sut, _, _) = FileSystemBackedCacheTests.makeSUT()
            let expected = "hello"
            
            sut[FileSystemBackedCacheTests.anyKey] = expected
            sut[FileSystemBackedCacheTests.anyKey] = nil

            #expect(nil == sut[FileSystemBackedCacheTests.anyKey])
        }
    }
    
    struct clear {
        @Test func calls_removeAll_on_archiver() async throws {
            let (sut, _, archiver) = makeSUT()
            
            FileSystemBackedCacheTests.insertSomeEntries(into: sut)
            sut.clear()

            #expect(1 == archiver.removeAllCount)
        }
    }
        
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
        private(set) var inserted = [String:Data]()
        private(set) var removed = [String]()
        
        var keys: any Collection<String> {
            inserted.keys
        }
        
        func archive(_ data: Data, for key: String) {
            insertCount += 1
            inserted[key] = data
        }
        
        func deleteAll() {
            removeAllCount += 1
            inserted.removeAll()
        }
        
        func data(at key: String) -> Data? {
            inserted[key]
        }
        
        func delete(key: String) {
            removed.append(key)
            inserted[key] = nil
        }
    }
}
