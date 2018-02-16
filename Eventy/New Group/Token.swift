//
//  Token.swift
//  Eventy
//
//  Created by Valentin Varbanov on 16.02.18.
//

import Foundation

class Token: Codable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access-token"
    }
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
}

// MARK: Convenience initializers

extension Token {
    convenience init(data: Data) throws {
        let me = try JSONDecoder().decode(Token.self, from: data)
        self.init(accessToken: me.accessToken)
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

