//
//  CacheArchiver.swift
//  CacheCow
//
//  Created by Joseph Wardell on 1/6/25.
//

import Foundation

/// Saves and loads a cache snapshot from disk.
public actor CacheArchiver
{
    let name: String
    let groupID: String?
    let filemanager: FileManager
    
    /// Creates an archiver for a named cache file.
    ///
    /// - Parameters:
    ///   - name: The cache file name without the `.cache` extension.
    ///   - groupID: An optional app group identifier to use for the cache location.
    public init(
        name: String,
        groupID: String? = nil
    ) {
        self.name = name
        self.groupID = groupID
        self.filemanager = FileManager()
    }
    
    nonisolated
    /// Loads a cache snapshot from disk.
    ///
    /// - Returns: A cache populated with the previously saved contents.
    public func load<Key, Value>() throws -> Cache<Key, Value>
    where Key: Codable, Value: Codable,
          Key: Sendable, Value: Sendable {

              let freezeDried = try Cache<Key, Value>.FreezeDried.readFromFile(named: name, group: groupID)
              return Cache(freezeDried: freezeDried)
    }
    
    nonisolated
    /// Saves the current contents of a cache to disk.
    ///
    /// - Parameter cache: The cache to persist.
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
