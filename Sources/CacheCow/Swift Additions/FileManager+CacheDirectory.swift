//
//  FileManager+CacheDirectory.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/16/24.
//

import Foundation

extension FileManager {
    
    /// Returns the file URL for a named cache location.
    ///
    /// - Parameters:
    ///   - name: The cache file or directory name without the `.cache` extension.
    ///   - group: An optional app group identifier used to resolve a shared caches directory.
    /// - Returns: A file URL for the named cache location, or `nil` if no suitable base directory exists.
    public func cacheURL(named name: String,
                                 group: String?) -> URL? {
        let folderURL: URL?
        
        if let group {
            guard let directory = containerURL(forSecurityApplicationGroupIdentifier: group) else { return nil }
            
            folderURL = directory
                .appendingPathComponent("Library")
                .appendingPathComponent("Caches")
        }
        else {
            let folderURLs = urls(
                for: .cachesDirectory,
                in: .userDomainMask
            )
            folderURL = folderURLs.first
        }
        
        guard let folderURL else { return nil }
        
        return folderURL.appendingPathComponent(name + ".cache")
    }

}
