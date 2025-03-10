//
//  CacheArchiverTests.swift
//  CacheCow
//  CacheArchiverTests.swift
//
//  Created by Joseph Wardell on 1/6/25.
//

import Testing
import Foundation

@testable import CacheCow

class CacheArchiverTests {

    @Test func test_archives_correctly() async throws {
        let cache = Cache<String, String>()
        let archiver = CacheArchiver(name: filename)
        
        CacheArchiverTests.insertSomeEntries(into: cache)
            
        try await archiver.saveCacheToFile(cache)
        let thawed = try Cache<String, String>.FreezeDried.readFromFile(named: filename)

        #expect(thawed == cache.freezeDried)
    }

    deinit {
        let fm = FileManager()
        let cacheURL = fm.cacheURL(named: filename, group: nil)
        try! fm.removeItem(at: cacheURL!)
    }
    
    @discardableResult
    private static func insertSomeEntries(into sut: Cache<String, String>) -> [String] {
        let expectedCount = Int.random(in: 2 ... 20)
        
        let expected = (0 ..< expectedCount).map(String.init)
        
        for i in 0 ..< expectedCount {
            sut.insert("\(Int.random(in: -100 ... 100))", for: String(i))
        }

        return expected
    }

    private let filename = "testfile"
}
