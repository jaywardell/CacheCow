//
//  File.swift
//  CacheCow
//
//  Created by Joseph Wardell on 1/6/25.
//

import Foundation

struct CodableHelper {
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    func roundTripJSONEncodeDecode<C: Codable>(_ sut: C) throws -> C {
        
        let data = try encoder.encode(sut)
        return try decoder.decode(C.self, from: data)
    }
}

