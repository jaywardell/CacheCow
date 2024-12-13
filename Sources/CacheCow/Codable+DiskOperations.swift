//
//  File.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/13/24.
//

import Foundation

public extension Encodable {
    
    func saveAsJSON(to fileURL: URL,
              using fileManager: FileManager = .default
    ) throws {
        
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
    }

}

public extension Decodable {
    
    static func readAsJSON(from fileURL: URL) throws -> Self {
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        
        return try decoder.decode(Self.self, from: data)
    }

}
