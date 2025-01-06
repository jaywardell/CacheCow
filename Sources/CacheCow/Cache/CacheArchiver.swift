//
//  CacheArchiver.swift
//  CacheCow
//
//  Created by Joseph Wardell on 1/6/25.
//

import Foundation

public actor CacheArchiver
{
    let name: String
    let groupID: String?
    let filemanager: FileManager
    
    public init(
        name: String,
        groupID: String? = nil
    ) {
        self.name = name
        self.groupID = groupID
        self.filemanager = FileManager()
    }
    
    public func load<Key, Value>() throws -> Cache<Key, Value>
    where Key: Codable, Value: Codable,
          Key: Sendable, Value: Sendable {

              let freezeDried = try Cache<Key, Value>.FreezeDried.readFromFile(named: name, group: groupID, using: filemanager)
              return Cache(freezeDried: freezeDried)
    }
    
    nonisolated
    public func saveCacheToFile<Key, Value>(_ cache: Cache<Key, Value>) async throws
    where Key: Hashable,
          Key: Codable, Value: Codable,
          Key: Sendable, Value: Sendable
    {
        let freezeDried = cache.freezeDried
        try await save(freezeDried)
    }
    
    private func save<Key, Value>(_ freezeDried: Cache<Key, Value>.FreezeDried) async throws {
        try freezeDried.saveToFile(named: name, group: groupID, using: filemanager)
    }
}
