//
//  DirectoryBackedArchiver.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/16/24.
//

import Foundation
import OSLog

@available(iOS 16.0, macOS 13.0, *)
class DirectoryBackedArchiver {
    
    let url: URL
    private let files: FileSystem
    
    enum Error: Swift.Error {
        case notAFile(url: URL)
    }
    
    init(at url: URL) async throws {
        guard url.isFileURL else { throw Error.notAFile(url: url) }
        
        self.url = url
        self.files = FileSystem()
        
        try await files.createDirectory(at: url)
    }
    
    private func url(for key: String) -> URL {
        url.appending(component: key)
    }
}

@available(iOS 16.0, macOS 13.0, *)
extension DirectoryBackedArchiver {
    fileprivate actor FileSystem {
        
        enum Error: Swift.Error {
            case urlIsNotDirectory(url: URL)
            case fileExists(url: URL)
            case fileDoesNotExist(url: URL)
        }
        
        private lazy var writer = {
            FileManager()
        }()
        
        func createDirectory(at url: URL) throws {
            if writer.fileExists(atPath: url.path()) {
                if url.isDirectory {
                    return
                }
                else {
                    throw Error.urlIsNotDirectory(url: url)
                }
            }
            else {
                try writer.createDirectory(at: url, withIntermediateDirectories: true)
            }
        }
        
        func save(_ data: Data, to url: URL) async throws {
            guard !writer.fileExists(atPath: url.path()) else { throw Error.fileExists(url: url) }
            
            try data.write(to: url)
        }
        
        func deleteFile(at url: URL) throws {
            guard writer.fileExists(atPath: url.path()) else { throw Error.fileDoesNotExist(url: url) }
            
            try writer.removeItem(at: url)
        }
        
        func deleteAllFiles(at url: URL) throws {
            guard writer.fileExists(atPath: url.path()) else { throw Error.fileDoesNotExist(url: url) }

            let oldURL = url
            let backupURL = url.deletingLastPathComponent().appending(component: url.lastPathComponent + ".old")
            
            try writer.moveItem(at: oldURL, to: backupURL)
            try writer.createDirectory(at: backupURL, withIntermediateDirectories: true)
            
            try writer.removeItem(at: backupURL) // note this removes recusrively
        }
        
        nonisolated func files(at url: URL) throws -> [String] {
            guard FileManager.default.fileExists(atPath: url.path()) else { throw Error.fileDoesNotExist(url: url) }

            return try FileManager.default.contentsOfDirectory(atPath: url.path())
        }
        
        nonisolated func readData(at url: URL) throws -> Data? {
            try Data(contentsOf: url)
        }
    }
}

@available(iOS 16.0, macOS 13.0, *)
extension DirectoryBackedArchiver: FileSystemBackedArchiver {

    func archive(_ data: Data, for key: String) {
        let fileURL = url(for: key)
        Task { [files] in
            do {
                try await files.save(data, to: fileURL)
            }
            catch {
                Logger.directoryBachedArchiver.error("Could not write data to url \(fileURL): \(error.localizedDescription)")
            }
        }
    }
    
    func data(at key: String) -> Data? {
        let fileURL = url(for: key)
        do {
            return try files.readData(at: fileURL)
        }
        catch {
            Logger.directoryBachedArchiver.error("Could not read data from url \(fileURL): \(error.localizedDescription)")
            return nil
        }
   }
    
    func delete(key: String) {
        let fileURL = url(for: key)
        Task { [files] in
            do {
                try await files.deleteFile(at: fileURL)
            }
            catch {
                Logger.directoryBachedArchiver.error("Could not delete file at \(fileURL): \(error.localizedDescription)")
            }
        }
    }
    
    func deleteAll() {
        Task { [files, url] in
            do {
                try await files.deleteAllFiles(at: url)
            }
            catch {
                Logger.directoryBachedArchiver.error("Could delete all files in directory \(url): \(error.localizedDescription)")
            }
        }
    }
    
    var keys: any Collection<String> {
        do {
            return try files.files(at: url)
        }
        catch {
            Logger.directoryBachedArchiver.error("Could not read contents of directory \(self.url): \(error.localizedDescription)")
            Logger.directoryBachedArchiver.info("Returning empty array instead")
            return []
        }
    }
    

}

extension URL {
    // see https://forums.swift.org/t/checking-if-a-url-is-a-directory/13842/6
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}

@available(iOS 16.0, macOS 13.0, *)
fileprivate extension Logger {
    // see https://www.avanderlee.com/debugging/oslog-unified-logging/
        
    /// Logs the view cycles like a view that appeared.
    static let directoryBachedArchiver = Logger(subsystem: "\(DirectoryBackedArchiver.self)", category: "directory backed archiver")
}

@available(iOS 16.0, macOS 13.0, *)
extension DirectoryBackedArchiver.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notAFile(url: let url): "The url at \(url) does not represent a file URL"
        }
    }
}

@available(iOS 16.0, macOS 13.0, *)
extension DirectoryBackedArchiver.FileSystem.Error: LocalizedError {
    var errorDescription: String? {
        switch self {

        case .urlIsNotDirectory(url: let url):
            "Cannot use url \(url) because it is not a directory"
        case .fileExists(url: let url):
            "File already exists at \(url)"
        case .fileDoesNotExist(url: let url):
            "File does not exist at \(url)"
        }
    }
}
