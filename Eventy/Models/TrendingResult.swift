//
//  TrendingResult.swift
//  Eventy
//
//  Created by Valentin Varbanov on 17.02.18.
//


import Foundation

class Trending: Codable {
    let ids: [Int]
    
    enum CodingKeys: String, CodingKey {
        case ids = "ids"
    }
    
    init(ids: [Int]) {
        self.ids = ids
    }
}

// MARK: Convenience initializers

extension Trending {
    convenience init(data: Data) throws {
        let me = try JSONDecoder().decode(Trending.self, from: data)
        self.init(ids: me.ids)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
