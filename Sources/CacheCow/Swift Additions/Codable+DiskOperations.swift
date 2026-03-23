//
//  File.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/13/24.
//

import Foundation

extension Encodable {
    
    /// Encodes the value as JSON and writes it to a file URL.
    ///
    /// - Parameters:
    ///   - fileURL: The destination file URL.
    ///   - fileManager: The file manager used by callers to coordinate disk access.
    func saveAsJSON(to fileURL: URL,
              using fileManager: FileManager = .default
    ) throws {
        
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
    }

}

extension Decodable {
    
    /// Reads JSON data from a file URL and decodes it into the receiving type.
    ///
    /// - Parameter fileURL: The source file URL.
    /// - Returns: A decoded value of the receiving type.
    static func readAsJSON(from fileURL: URL) throws -> Self {
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        
        return try decoder.decode(Self.self, from: data)
    }

}
