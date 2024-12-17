//
//  DirectoryBackedArchiver.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/16/24.
//

import Foundation
import OSLog

@available(macOS 13.0, *)
class DirectoryBackedArchiver {
    
    let url: URL
    private let files: FileSystem
    
    enum Error: Swift.Error {
        case notAFile
    }
    
    init(url: URL) async throws {
        guard url.isFileURL else { throw Error.notAFile }
        
        self.url = url
        self.files = FileSystem()
        
        try await files.createDirectory(at: url)
    }
    
    private func url(for key: Int) -> URL {
        url.appending(component: String(key))
    }
}

@available(macOS 13.0, *)
extension DirectoryBackedArchiver {
    private actor FileSystem {
        
        enum Error: Swift.Error {
            case cannotUseURL
            case fikeExists
            case fileDoesNotExist
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
                    throw Error.cannotUseURL
                }
            }
            else {
                try writer.createDirectory(at: url, withIntermediateDirectories: true)
            }
        }
        
        func save(_ data: Data, to url: URL) async throws {
            guard !writer.fileExists(atPath: url.path()) else { throw Error.fikeExists }
            
            try data.write(to: url)
        }
        
        func deleteFile(at url: URL) throws {
            guard writer.fileExists(atPath: url.path()) else { throw Error.fileDoesNotExist }
            
            try writer.removeItem(at: url)
        }
        
        func deleteAllFiles(at url: URL) throws {
            guard writer.fileExists(atPath: url.path()) else { throw Error.fileDoesNotExist }

            let oldURL = url
            let backupURL = url.deletingLastPathComponent().appending(component: url.lastPathComponent + ".old")
            
            try writer.moveItem(at: oldURL, to: backupURL)
            try writer.createDirectory(at: backupURL, withIntermediateDirectories: true)
            
            try writer.removeItem(at: backupURL) // note this removes recusrively
        }
        
        nonisolated func files(at url: URL) throws -> [String] {
            guard FileManager.default.fileExists(atPath: url.path()) else { throw Error.fileDoesNotExist }

            return try FileManager.default.contentsOfDirectory(atPath: url.path())
        }
        
        nonisolated func readData(at url: URL) throws -> Data? {
            try Data(contentsOf: url)
        }
    }
}

@available(macOS 13.0, *)
extension DirectoryBackedArchiver: FileSystemBackedArchiver {

    func archive(_ data: Data, for key: Int) {
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
    
    func data(at key: Int) -> Data? {
        let fileURL = url(for: key)
        do {
            return try files.readData(at: fileURL)
        }
        catch {
            Logger.directoryBachedArchiver.error("Could not read data from url \(fileURL): \(error.localizedDescription)")
        }
   }
    
    func delete(key: Int) {
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
    
    var keys: any Collection<Int> {
        do {
            return try files.files(at: url).compactMap {
                Int($0)
            }
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

@available(macOS 13.0, *)
fileprivate extension Logger {
    // see https://www.avanderlee.com/debugging/oslog-unified-logging/
        
    /// Logs the view cycles like a view that appeared.
    static let directoryBachedArchiver = Logger(subsystem: "\(DirectoryBackedArchiver.self)", category: "directory backed archiver")
}
