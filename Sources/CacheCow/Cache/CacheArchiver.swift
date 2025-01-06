//
//  CacheArchiver.swift
//  CacheCow
//
//  Created by Joseph Wardell on 1/6/25.
//

public actor CacheArchiver
{
    let name: String
    let groupID: String?
    
    public init(
        name: String,
        groupID: String? = nil
    ) {
        self.name = name
        self.groupID = groupID
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
        try freezeDried.saveToFile(named: name, group: groupID)
    }
}
